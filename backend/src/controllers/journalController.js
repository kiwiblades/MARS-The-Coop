/* This handles the logic for checking shared chatrooms and filtering unique "birds" for the Coop. */

import { Journal, User, ChatMembership } from '../models/index.js';
import { Op } from 'sequelize';
import { sequelize } from '../db/sequelize.js';

/**
 * Create a journal entry with an interaction check
 */
export const createJournalEntry = async (req, res, next) => {
  const { subjectId, content } = req.body;
  const ownerId = req.user.uid || req.user.id; 

  try {
    // Interaction Check - Find shared chatrooms
    const sharedChat = await ChatMembership.findOne({
      where: {
        userId: ownerId,
        chatroomId: {
          [Op.in]: sequelize.literal(`(SELECT "chatroomId" FROM chatmemberships WHERE "userId" = '${subjectId}')`)
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
  //const ownerId = req.user.uid || req.user.id;
  // Try every possible location for the ID
  const ownerId = req.user?.uid || req.user?.id;

//   if (!ownerId) {
//     console.error("DEBUG: No User ID found in req.user:", req.user);
//     return res.status(401).json({ error: "Authentication token missing user UID" });
//   }

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
  const ownerId = req.user?.uid || req.user?.id;

  try {
    const subjects = await Journal.findAll({
      where: { ownerId },
      attributes: [[sequelize.fn('DISTINCT', sequelize.col('subjectId')), 'subjectId']],
      include: [{
        model: User,
        as: 'SubjectProfile',
        attributes: ['username', 'pigeonId'] // Fixed: matching your user model 'pigeonId'
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
  const userId = req.user?.uid || req.user?.id;
  const { search } = req.query;

  if (!userId) {
    return res.status(401).json({ error: "Unauthorized: No user UID found" });
  }

  try {
    const eligible = await User.findAll({
      where: {
        uid: { 
          [Op.ne]: userId,
          [Op.in]: sequelize.literal(`(
            SELECT DISTINCT "userId" FROM chatmemberships 
            WHERE "chatroomId" IN (SELECT "chatroomId" FROM chatmemberships WHERE "userId" = '${userId}')
          )`),
          [Op.notIn]: sequelize.literal(`(
            SELECT DISTINCT "subjectId" FROM journals WHERE "ownerId" = '${userId}'
          )`)
        },
        ...(search && { username: { [Op.iLike]: `%${search}%` } })
      },
      attributes: ['uid', 'username', 'pigeonId'] 
    });

    res.status(200).json(eligible);
  } catch (error) {
    console.error("DEBUG ELIGIBILITY ERROR:", error);
    next(error);
  }
};