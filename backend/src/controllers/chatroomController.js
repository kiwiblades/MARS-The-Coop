import { Op } from "sequelize";
import { sequelize } from "../db/sequelize.js";
import ChatMembership from "../models/ChatMembership.js";
import ChatRoom from "../models/ChatRoom.js";
import ChatSettings from "../models/ChatSettings.js";
import User from "../models/userModel.js";
import Message from "../models/Message.js";
import AppError from "../utils/errors/AppError.js";

export async function getChatrooms(req, res) {
    const uid = req.user.uid;

    // fetch all chatrooms the current user is a member in
    const chatrooms = await ChatMembership.findAll({
        where: { userId: uid },
        attributes: ["pinned","role","joinedAt","chatId"],
        include: [{
            model: ChatRoom,
            attributes: ["id","name","inviteCode","createdAt","updatedAt"],
            // fetch details for each user participating in the chat
            include: [{
                model: User,
                as: "participants",
                attributes: ["uid","username","pigeonId"],
                through: {
                    // participant membership fields
                    attributes: ["role","joinedAt"],
                },
            }],
        }],
        order: [
            ["pinned","DESC"], // pinned chats first
            [ChatRoom, "lastMsgSent","DESC NULLS LAST"], // then sort by most recent msg
        ],
    });
    if (!chatrooms || chatrooms.length === 0) {
        throw AppError.notFound('No chatrooms exist for the current user', { code: "CHATROOMS_NOT_FOUND" });
    }

    // collect all chatroom ids the user is in to fetch last msgs in a single query
    const chatIds = chatrooms.map((m) => m.chatId);

    const lastMessages = await Message.findAll({
        // get only one per chat_id
        attributes: ['chat_id', 'content', 'createdAt'],
        where: {
            chat_id: chatIds,
            // for each msg row, only include if its createdAt matches MAX createdAt for that chat_id,
            // allowing fetching latest msg per chatroom without separate query per room
            // there is no latest per group feature in sequelize. the subquery runs once per msg row
            createdAt: {
                [Op.in]: sequelize.literal(`(
                    select max("createdAt") from "Messages"
                    where "chat_id" = "Message"."chat_id"
                )`)
            }
        }
    });

    // build a lookup map so each chatroom's last message can be easily fetched
    const lastMessageMap = Object.fromEntries(
        lastMessages.map((m) => [m.chat_id, m])
    );

    // organize the res payload with necessary fetched info
    const payload = chatrooms.map((m) => {
        // look up the last message for the current chatroom, if one exists
        const lastMessage = lastMessageMap[m.chatId];
        return {
            chatroom: m.ChatRoom,
            membership: {
                pinned: m.pinned,
                role: m.role,
                joinedAt: m.joinedAt,
            },
            // add participants for each chatroom EXCLUDING the current user
            participants: (m.ChatRoom?.participants ?? []).filter((u) => u.uid !== uid),
            lastSentMessage: lastMessage?.content ?? '',
            lastSentTime: lastMessage?.createdAt ?? '',
        }
    });

    // attach and return the payload w/ res
    return res.json(payload);
}

export async function createChatroom(req, res) {
    const uid = req.user.uid;
    const { name, relationshipType, allowedTopics } = req.body;
    if (!name) throw AppError.badRequest('Name is a required field', { code: 'NAME_MISSING' });

    // because multiple queries need to be made, start a transaction (to prevent orphan entries)
    const t = await sequelize.transaction();
    try {
        // 1. create base room
        // only name is customizable, everything else is generated
        const chatroom = await ChatRoom.create({ 
            name,
            lastMsgSent: new Date(Date.now() + 60*1000), // set 1 min grace period into future to keep new chat at top
        }, { transaction: t });

        // 2. create settings row for the new chatroom (ChatSettings Table)
        await ChatSettings.create({
            chatId: chatroom.id, // the chatroom's generated id
            relationshipType: relationshipType || 'Friends', 
            allowedTopics: allowedTopics || [], 
            //role: 'owner', // give the creater ownership permissions
        }, { transaction: t });

        // 3. Add to Membership as 'owner'
        await ChatMembership.create({
            userId: uid,
            chatId: chatroom.id,
            role: 'owner' 
        }, { transaction: t });

        await t.commit(); // commit the transaction
        return res.status(201).json(chatroom);
    } catch(e) {
        await t.rollback(); // rollback the transaction if unsuccessful
        throw e; // throw sequelize errors
    }
}

export async function joinChatroom(req, res) {
    const uid = req.user.uid;
    const { inviteCode } = req.body;
    if (!inviteCode) {
        throw AppError.badRequest('Invite code is a required field', { code: 'INVITE_CODE_MISSING' });
    }

    // fetch the chatroom belonging to the invite code
    const chatroom = await ChatRoom.findOne({ where: { inviteCode: inviteCode.trim().toUpperCase() }});
    if (!chatroom) {
        throw AppError.notFound("No chatroom found with the given invite code", { code: "CHATROOM_NOT_FOUND" });
    }

    // add the user as a member
    try {
        const membership = await ChatMembership.create({
            userId: uid,
            chatId: chatroom.id,
        });
        // backup error check, but it's more likely Sequelize will throw a particular error
        if (!membership) {
            throw AppError.conflict("User is already a member of this chatroom");
        }
    } catch(e) {
        // Sequelize throws this error when a value with the given pk pair exists, meaning the user is in the chatroom already
        if (e.name === 'SequelizeUniqueConstraintError') {
            throw AppError.conflict("User is already a member of this chatroom");
        }
    }

    return res.json(chatroom);
}

export async function leaveChatroom(req, res) {
    const uid = req.user.uid;
    const { chatroomId } = req.body; // the request should indicate which chatroom the user wants to leave
    if (!chatroomId) {
        throw AppError.badRequest("chatroomId is required for leaving a chatroom");
    }

    // for the query, first use the uid and chatroomId to pull the ChatMembership
    const membership = await ChatMembership.findOne({
        where: {
            userId: uid,
            chatId: chatroomId
        }
    });
    if (!membership) {
        throw AppError.notFound("User isn't a member of the designated chatroom");
    }
    // for later implementation
    // if (membership.role == "owner") {
    //     throw AppError.unauthorized("The owner cannot leave the chatroom");
    // }
    await membership.destroy();

    // check if anyone is left in the chatroom
    const remaining = await ChatMembership.count({ where: { chatId: chatroomId } });
    if (remaining == 0) {
        // the last member left, so delete the chatroom
        await ChatRoom.destroy({ where: { id: chatroomId } });
    }

    return res.status(204).end(); // success w/ no content
}

export async function deleteChatroom(req, res) {
    const uid = req.user.uid;
    const chatroomId = req.params.id;

    if (!chatroomId) {
        throw AppError.badRequest("chatroomId is required for deleting a chatroom");
    }

    // fetch the specific user's membership first to check the owner status
    const membership = await ChatMembership.findOne({
        where: {
            userId: uid,
            chatId: chatroomId
        }
    });
    if (membership.role !== "owner") {
        throw AppError.forbidden("Only the owner of the chatroom can delete it");
    }

    // once their permissions are verified, must delete both the ChatRoom row and the ChatMemberships
    const t = await sequelize.transaction();
    try {
        // delete all rows in one transaction, so if it fails there are no orphan rows
        await ChatMembership.destroy({
            where: {
                chatId: chatroomId,
            },
            transaction: t
        });

        await ChatRoom.destroy({
            where: {
                id: chatroomId,
            },
            transaction: t
        });

        await t.commit();
        return res.status(204).end();
    } catch(e) {
        await t.rollback();
        throw e;
    }
}

// rather than making both an unpin and pin, just flip the state when the function is called
export async function togglePin(req, res) {
    const uid = req.user.uid;
    const { chatroomId } = req.body;
    if (!chatroomId) {
        throw AppError.badRequest("chatroomId is required for pinning/unpinning a chatroom");
    }

    const membership = await ChatMembership.findOne({
        where: {
            chatId: chatroomId,
            userId: uid
        }
    });
    if (!membership) {
        throw AppError.notFound("User isn't a member of the designated chatroom");
    }

    console.log(membership.pinned);
    membership.pinned = !membership.pinned; // toggle the pinned state
    await membership.save(); // save the changes
    console.log(membership.pinned);

    return res.status(204).end();
}

export async function updateSettings(req, res, next) {
  const { name, relationshipType, allowedTopics } = req.body;
  const chatId = req.params.id;
  
  const t = await sequelize.transaction();

  try {
    // 1. Update ChatRoom Name
    if (name) {
      await ChatRoom.update(
        { name }, 
        { where: { id: chatId }, transaction: t }
      );
    }

    // 2. Update ChatSettings Table
    await ChatSettings.update(
      { relationshipType, allowedTopics },
      { where: { chatId: chatId }, transaction: t }
    );

    await t.commit();

    // Fetch the updated settings to return to the frontend
    const updatedSettings = await ChatSettings.findOne({ where: { chatId } });

    // 3. BROADCAST via Socket.io
    const io = req.app.get('io');
    io.to(chatId).emit('room_settings_updated', { 
      chatId, 
      newName: name,
      relationshipType,
      allowedTopics
    });

    const settings = await ChatSettings.findOne({ where: { chatId } });
    res.status(200).json({ 
      message: 'Settings updated successfully',
      settings: updatedSettings
    });

  } catch (error) {
    if (t) await t.rollback();
    next(error);
  }
}