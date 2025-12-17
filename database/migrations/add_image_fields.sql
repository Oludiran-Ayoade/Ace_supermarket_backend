-- Migration: Add image URL fields to users table
-- Run this migration to add image storage support

-- Add profile image to users table
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS profile_image_url VARCHAR(500),
ADD COLUMN IF NOT EXISTS profile_image_public_id VARCHAR(255);

-- Create index for faster image lookups
CREATE INDEX IF NOT EXISTS idx_users_profile_image ON users(profile_image_url) WHERE profile_image_url IS NOT NULL;

-- Add comments for documentation
COMMENT ON COLUMN users.profile_image_url IS 'Cloudinary URL for user profile image';
COMMENT ON COLUMN users.profile_image_public_id IS 'Cloudinary public ID for image deletion';
