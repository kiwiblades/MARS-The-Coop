import request from 'supertest';
import app from '../../server.js'; 
import { sequelize } from '../db/sequelize.js';

import User from '../models/userModel.js'; 
import ChatRoom from '../models/ChatRoom.js';
import ChatSettings from '../models/ChatSettings.js';
import ChatMembership from '../models/ChatMembership.js';

describe('Sprint 3: Chat Management & Persistence', () => {
    let moniqueToken;
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