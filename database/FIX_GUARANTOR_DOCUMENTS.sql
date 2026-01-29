-- Quick fix for guarantor_documents table
-- Run this directly in your Render PostgreSQL database

-- Add missing columns
ALTER TABLE guarantor_documents 
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Copy existing uploaded_at data if it exists
UPDATE guarantor_documents 
SET created_at = COALESCE(uploaded_at, CURRENT_TIMESTAMP),
    updated_at = COALESCE(uploaded_at, CURRENT_TIMESTAMP)
WHERE created_at IS NULL OR updated_at IS NULL;

-- Optional: Drop old columns that aren't used
ALTER TABLE guarantor_documents 
DROP COLUMN IF EXISTS file_name,
DROP COLUMN IF EXISTS uploaded_at;

-- Verify the fix
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'guarantor_documents' 
ORDER BY ordinal_position;
