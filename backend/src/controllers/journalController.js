/* This handles the logic for checking shared chatrooms and filtering unique "birds" for the Coop. */

import { Journal, User, ChatMembership } from '../models/index.js';
import { Op } from 'sequelize';
import { sequelize } from '../db/sequelize.js';
import AppError from '../utils/errors/AppError.js';

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
        chatId: {
          [Op.in]: sequelize.literal(`(SELECT "chatId" FROM "chatmembership" WHERE "userId" = '${subjectId}')`)
        }
      }
    });

    if (!sharedChat) {
      return res.status(403).json({ error: 'You can only journal about people you share a chatroom with.' });
    }

    // 2. Create the entry
    const entry = await Journal.create({
      ownerId,
      subjectId,
      content: content || "New journal started" // Ensure content isn't null/undefined
    });

    // 3. RE-FETCH with Inclusions
    const fullEntry = await Journal.findByPk(entry.id, {
      include: [
        {
          model: User,
          as: 'SubjectProfile',
          attributes: ['uid', 'username', 'pigeonId']
        },
        {
          model: User,
          as: 'AuthorProfile',
          attributes: ['uid', 'username', 'pigeonId']
        }
      ]
    });

    res.status(201).json(fullEntry);
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
      order: [['createdAt', 'DESC']],
      include: [
        {
          model: User,
          as: 'SubjectProfile',
          attributes: ['uid', 'username', 'pigeonId']
        }
      ]
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
      //attributes: [[sequelize.fn('DISTINCT', sequelize.col('subjectId')), 'subjectId']],
	  attributes: ['subjectId', 'ownerId'], // Include ownerId for grouping
      group: ['subjectId', 'ownerId', 'SubjectProfile.uid', 'AuthorProfile.uid'], // Group by subjectId and ownerId to get unique subjects  
      include: [{
        model: User,
        as: 'SubjectProfile',
        attributes: ['uid', 'username', 'pigeonId'] 
      },
        {
          model: User,
          as: 'AuthorProfile', // THE WRITER
          attributes: ['uid', 'username', 'pigeonId'] 
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
            SELECT DISTINCT "userId" FROM "chatmembership" 
            WHERE "chatId" IN (SELECT "chatId" FROM "chatmembership" WHERE "userId" = '${userId}')
          )`),
          [Op.notIn]: sequelize.literal(`(
            SELECT DISTINCT "subjectId" FROM "journals" WHERE "ownerId" = '${userId}'
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

export async function deleteEntry(req, res) {
  const uid = req.user.uid;
  const journalId = req.params.id;

  if (!journalId) {
    throw AppError("journalId is required for deleting an entry");
  }
  
  const entry = await Journal.findByPk(journalId);
  if (!entry) {
    throw AppError.notFound("Journal entry not found");
  }
  if (entry.ownerId !== uid) {
    throw AppError.forbidden("You can only delete your own journal entries");
  }

  await entry.destroy();
  return res.status(204).end();
}

export async function updateEntry(req, res) {
  const uid = req.user.uid;
  const journalId = req.params.id;
  const { content } = req.body;

  if (!journalId) {
    throw AppError.badRequest("journalId is required for updating an entry");
  }
  if (!content) {
    throw AppError.badRequest("content is required");
  }

  const entry = await Journal.findByPk(journalId);
  if (!entry) {
    throw AppError.notFound("Journal entry not found");
  }
  if (entry.ownerId !== uid) {
    throw AppError.forbidden("You can only update your own journal entries");
  }

  await entry.update({ content });
  return res.status(204).end();
}