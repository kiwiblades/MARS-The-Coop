/*
    The raw token is not stored in the database, but rather its computed fingerprint
*/

import crypto from "crypto";
import { config } from "../config.js";

export function tokenFingerprint(token) {
    return crypto
        .createHmac("sha256", config.security.token_hash_secret)
        .update(token)
        .digest("hex");
}