-- Migration: Add device_tokens table for push notifications
-- This table stores FCM device tokens for push notifications

CREATE TABLE IF NOT EXISTS device_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_token TEXT NOT NULL,
    device_type VARCHAR(20) NOT NULL CHECK (device_type IN ('ios', 'android', 'web')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, device_token)
);

-- Index for faster lookups by user
CREATE INDEX IF NOT EXISTS idx_device_tokens_user_id ON device_tokens(user_id);

-- Index for faster lookups by token
CREATE INDEX IF NOT EXISTS idx_device_tokens_token ON device_tokens(device_token);

COMMENT ON TABLE device_tokens IS 'Stores FCM device tokens for push notifications';
COMMENT ON COLUMN device_tokens.device_token IS 'FCM device registration token';
COMMENT ON COLUMN device_tokens.device_type IS 'Type of device: ios, android, or web';
