import { sequelize } from "../db/sequelize.js";
import ChatMembership from "../models/ChatMembership.js";
import ChatRoom from "../models/ChatRoom.js";
import User from "../models/userModel.js";
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
            include: [{
                model: User,
                as: "participants",
                attributes: ["uid","username"],
                through: {
                    // participant membership fields
                    attributes: ["role","joinedAt"],
                },
            }],
        }],
        order: [
            ["pinned","DESC"], // pinned chats first
            [ChatRoom, "updatedAt","DESC"], // then by last updated chat
        ],
    });
    if (!chatrooms || chatrooms.length === 0) {
        throw AppError.notFound('No chatrooms exist for the current user', { code: "CHATROOMS_NOT_FOUND" });
    }

    // organize the res payload with necessary fetched info
    const payload = chatrooms.map((m) => ({
        chatroom: m.ChatRoom,
        membership: {
            pinned: m.pinned,
            role: m.role,
            joinedAt: m.joinedAt,
        },
        // add participants for each chatroom EXCLUDING the current user
        participants: (m.ChatRoom?.participants ?? []).filter((u) => u.uid !== uid),
    }));

    // attach and return the payload w/ res
    return res.json(payload);
}

export async function createChatroom(req, res) {
    const uid = req.user.uid;
    const { name } = req.body;
    if (!name) throw AppError.badRequest('Name is a required field', { code: 'NAME_MISSING' });

    // because multiple queries need to be made, start a transaction (to prevent orphan entries)
    const t = await sequelize.transaction();
    try {
        // only name is customizable, everything else is generated
        const chatroom = await ChatRoom.create({ name }, { transaction: t });

        // add the user as the owner of the room
        await ChatMembership.create({
            // the userId + chatId act as a primary key, so there is no new id
            userId: uid, // the current user
            chatId: chatroom.id, // the chatroom's generated id
            role: 'owner', // give the creater ownership permissions
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

export async function deleteChatroom(req, res) {

}

export async function leaveChatroom(req, res) {
    
}