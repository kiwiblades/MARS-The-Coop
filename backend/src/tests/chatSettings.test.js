import request from 'supertest';
import app from '../../server.js'; 
import { sequelize } from '../db/sequelize.js';

import User from '../models/userModel.js'; 
import ChatRoom from '../models/ChatRoom.js';
import ChatSettings from '../models/ChatSettings.js';
import ChatMembership from '../models/ChatMembership.js';
import BannedUser from '../models/BannedUser.js';

describe('Sprint 3: Chat Management & Persistence', () => {
    let moniqueToken;
    let intruderToken;
    let intruderId;
    let roomId;

    beforeAll(async () => {
        try {
            // Clean slate for testing
            await sequelize.sync({ force: true });

            // 1. Setup Monique (The Owner)
            const moniqueData = { username: 'MoniqueTest', email: 'monique@test.com', password: 'Password123!' };
            await request(app).post('/api/auth/signup').send(moniqueData);
            await User.update({ emailVerified: true }, { where: { email: moniqueData.email } });
            const moniqueLogin = await request(app).post('/api/auth/signin').send({ 
                username: moniqueData.username, password: moniqueData.password 
            });
            moniqueToken = moniqueLogin.body.accessToken;

            // 2. Setup Intruder (For Permission/Ban Testing)
            const intruderData = { username: 'Intruder', email: 'intruder@test.com', password: 'Password123!' };
            const intruderSignup = await request(app).post('/api/auth/signup').send(intruderData);
            
            // Adjusting based on common controller structures
            intruderId = intruderSignup.body.user?.uid || intruderSignup.body.uid; 
            
            await User.update({ emailVerified: true }, { where: { email: intruderData.email } });
            const intruderLogin = await request(app).post('/api/auth/signin').send({ 
                username: intruderData.username, password: intruderData.password 
            });
            intruderToken = intruderLogin.body.accessToken;
        } catch (error) {
            console.error("Setup failed:", error);
            throw error;
        }
    });

    afterAll(async () => {
        const io = app.get('io');
        if (io) await io.close();
        if (sequelize) await sequelize.close();
        await new Promise(resolve => setTimeout(resolve, 500));
    });

    // --- AC 3: Automatic Role Assignment ---
    test('AC 3: Create Room - Verify Owner Role in DB', async () => {
        const res = await request(app)
            .post('/chatroom/create')
            .set('Authorization', `Bearer ${moniqueToken}`)
            .send({ name: 'Sprint 3 Room' });

        expect(res.status).toBe(201);
        roomId = res.body.id;

        const membership = await ChatMembership.findOne({ where: { chatId: roomId } });
        expect(membership.role).toBe('owner');
    });

    // --- AC 2: Chat Settings Persistence ---
    test('AC 2: Verify Automatic ChatSettings Row', async () => {
        const settings = await ChatSettings.findOne({ where: { chatId: roomId } });
        expect(settings).not.toBeNull();
    });

    // --- AC 4: Permissions (The Intruder Test) ---
    test('AC 4: Security - Non-owner cannot delete room', async () => {
        const res = await request(app)
            .delete('/chatroom/delete')
            .set('Authorization', `Bearer ${intruderToken}`)
            .send({ chatroomId: roomId });

        expect(res.status).toBe(403);
    });

    // --- AC 6: Ban Management ---
    test('AC 6: Banning prevents re-joining', async () => {
        // 1. Owner bans the intruder (Verify your route path here)
        await request(app)
            .post(`/chatroom/${roomId}/ban`) 
            .set('Authorization', `Bearer ${moniqueToken}`)
            .send({ userId: intruderId });

        // 2. Intruder tries to join
        const joinRes = await request(app)
            .post(`/chatroom/${roomId}/join`)
            .set('Authorization', `Bearer ${intruderToken}`);

        expect(joinRes.status).toBe(403);
    });

    // --- AC 7: Hard Deletion & Cascade ---
    test('AC 7: Hard Delete - Verify Cascade Wipe', async () => {
        const res = await request(app)
            .delete('/chatroom/delete')
            .set('Authorization', `Bearer ${moniqueToken}`)
            .send({ chatroomId: roomId });

        expect([200, 204]).toContain(res.status);

        // Verify room is gone
        const room = await ChatRoom.findByPk(roomId);
        expect(room).toBeNull();

        // Verify settings row is gone (Cascade check)
        const settings = await ChatSettings.findOne({ where: { chatId: roomId } });
        expect(settings).toBeNull();
    });
});