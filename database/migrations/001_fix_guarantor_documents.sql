-- Migration: Fix guarantor_documents table schema
-- This adds created_at and updated_at columns and removes file_name if it exists

-- Drop uploaded_at if it exists and add created_at/updated_at
DO $$ 
BEGIN
    -- Drop file_name column if it exists (not used in code)
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'guarantor_documents' 
               AND column_name = 'file_name') THEN
        ALTER TABLE guarantor_documents DROP COLUMN file_name;
    END IF;

    -- Add created_at if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'guarantor_documents' 
                   AND column_name = 'created_at') THEN
        ALTER TABLE guarantor_documents 
        ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    -- Add updated_at if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'guarantor_documents' 
                   AND column_name = 'updated_at') THEN
        ALTER TABLE guarantor_documents 
        ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;

    -- Drop uploaded_at if it exists (replaced by created_at)
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'guarantor_documents' 
               AND column_name = 'uploaded_at') THEN
        -- Copy uploaded_at to created_at for existing records
        UPDATE guarantor_documents 
        SET created_at = uploaded_at, updated_at = uploaded_at 
        WHERE uploaded_at IS NOT NULL;
        
        ALTER TABLE guarantor_documents DROP COLUMN uploaded_at;
    END IF;
END $$;

-- Verify the changes
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'guarantor_documents' 
ORDER BY ordinal_position;
