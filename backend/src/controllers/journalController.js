/* This handles the logic for checking shared chatrooms and filtering unique "birds" for the Coop. */

import { Journal, User, Membership } from '../models/index.js';
import { Op } from 'sequelize';
import { sequelize } from '../db/sequelize.js';

/**
 * Create a journal entry with an interaction check
 */
export const createJournalEntry = async (req, res, next) => {
  const { subjectId, content } = req.body;
  const ownerId = req.user.id; // From Auth Middleware JWT

  try {
    // AC 3: Interaction Check - Find shared chatrooms
    const sharedChat = await Membership.findOne({
      where: {
        userId: ownerId,
        chatroomId: {
          [Op.in]: sequelize.literal(`(SELECT chatroomId FROM memberships WHERE userId = '${subjectId}')`)
        }
      }
    });

    if (!sharedChat) {
      return res.status(403).json({ error: 'You can only journal about people you share a chatroom with.' });
    }

    const entry = await Journal.create({
      ownerId,
      subjectId,
      content
    });

    res.status(201).json(entry);
  } catch (error) {
    next(error);
  }
};

/**
 * Fetch all notes for a specific subject (reverse chronological)
 */
export const getEntriesBySubject = async (req, res, next) => {
  const { subjectId } = req.params;
  const ownerId = req.user.id;

  try {
    const entries = await Journal.findAll({
      where: { ownerId, subjectId },
      order: [['createdAt', 'DESC']]
    });

    res.status(200).json(entries);
  } catch (error) {
    next(error);
  }
};

/**
 * Get UNIQUE subjects the user has already journaled about (The Bird Grid)
 */
export const getJournalSubjects = async (req, res, next) => {
  const ownerId = req.user.id;

  try {
    const subjects = await Journal.findAll({
      where: { ownerId },
      attributes: [[sequelize.fn('DISTINCT', sequelize.col('subjectId')), 'subjectId']],
      include: [{
        model: User,
        as: 'SubjectProfile', // Ensure this alias is set in models/index.js
        attributes: ['username', 'pigeonType']
      }]
    });

    res.status(200).json(subjects || []);
  } catch (error) {
    next(error);
  }
};

/**
 * Get people you share chats with but HAVEN'T journaled about yet (The Cage)
 */
export const getEligibleSubjects = async (req, res, next) => {
  const userId = req.user.id;
  const { search } = req.query;

  try {
    // 1. Find all unique users in your chatrooms (excluding yourself)
    // 2. Filter out those who already have a journal entry by you
    const eligible = await User.findAll({
      where: {
        id: {
          [Op.ne]: userId,
          [Op.in]: sequelize.literal(`(
            SELECT DISTINCT userId FROM memberships 
            WHERE chatroomId IN (SELECT chatroomId FROM memberships WHERE userId = '${userId}')
          )`),
          [Op.notIn]: sequelize.literal(`(
            SELECT DISTINCT subjectId FROM journals WHERE ownerId = '${userId}'
          )`)
        },
        // Search functionality
        ...(search && { username: { [Op.iLike]: `%${search}%` } })
      },
      attributes: ['id', 'username', 'pigeonType']
    });

    res.status(200).json(eligible);
  } catch (error) {
    next(error);
  }
};