import { DataTypes } from "sequelize";
import { sequelize } from "../db/sequelize.js";

const BannedUser = sequelize.define("BannedUser", {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    chatId: {
        type: DataTypes.UUID,
        allowNull: false,
    },
    userId: {
        type: DataTypes.UUID,
        allowNull: false,
    },
}, {
    tableName: "bannedusers",
    timestamps: true,
});

export default BannedUser;