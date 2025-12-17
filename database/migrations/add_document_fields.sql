-- Migration: Add document fields to users table
-- This adds all document URLs and public IDs for staff profile documents

BEGIN;

-- Add document fields to users table
ALTER TABLE users 
    -- Educational Certificates
    ADD COLUMN IF NOT EXISTS waec_certificate_url VARCHAR(500),
    ADD COLUMN IF NOT EXISTS waec_certificate_public_id VARCHAR(255),
    ADD COLUMN IF NOT EXISTS neco_certificate_url VARCHAR(500),
    ADD COLUMN IF NOT EXISTS neco_certificate_public_id VARCHAR(255),
    ADD COLUMN IF NOT EXISTS jamb_result_url VARCHAR(500),
    ADD COLUMN IF NOT EXISTS jamb_result_public_id VARCHAR(255),
    ADD COLUMN IF NOT EXISTS degree_certificate_url VARCHAR(500),
    ADD COLUMN IF NOT EXISTS degree_certificate_public_id VARCHAR(255),
    ADD COLUMN IF NOT EXISTS diploma_certificate_url VARCHAR(500),
    ADD COLUMN IF NOT EXISTS diploma_certificate_public_id VARCHAR(255),
    
    -- Identity Documents
    ADD COLUMN IF NOT EXISTS birth_certificate_url VARCHAR(500),
    ADD COLUMN IF NOT EXISTS birth_certificate_public_id VARCHAR(255),
    ADD COLUMN IF NOT EXISTS national_id_url VARCHAR(500),
    ADD COLUMN IF NOT EXISTS national_id_public_id VARCHAR(255),
    ADD COLUMN IF NOT EXISTS passport_url VARCHAR(500),
    ADD COLUMN IF NOT EXISTS passport_public_id VARCHAR(255),
    ADD COLUMN IF NOT EXISTS drivers_license_url VARCHAR(500),
    ADD COLUMN IF NOT EXISTS drivers_license_public_id VARCHAR(255),
    ADD COLUMN IF NOT EXISTS voters_card_url VARCHAR(500),
    ADD COLUMN IF NOT EXISTS voters_card_public_id VARCHAR(255),
    
    -- Government Documents
    ADD COLUMN IF NOT EXISTS nysc_certificate_url VARCHAR(500),
    ADD COLUMN IF NOT EXISTS nysc_certificate_public_id VARCHAR(255),
    ADD COLUMN IF NOT EXISTS state_of_origin_cert_url VARCHAR(500),
    ADD COLUMN IF NOT EXISTS state_of_origin_cert_public_id VARCHAR(255),
    ADD COLUMN IF NOT EXISTS lga_certificate_url VARCHAR(500),
    ADD COLUMN IF NOT EXISTS lga_certificate_public_id VARCHAR(255),
    
    -- Employment Documents
    ADD COLUMN IF NOT EXISTS resume_url VARCHAR(500),
    ADD COLUMN IF NOT EXISTS resume_public_id VARCHAR(255),
    ADD COLUMN IF NOT EXISTS cover_letter_url VARCHAR(500),
    ADD COLUMN IF NOT EXISTS cover_letter_public_id VARCHAR(255);

-- Add comments for documentation
COMMENT ON COLUMN users.waec_certificate_url IS 'WAEC certificate document URL';
COMMENT ON COLUMN users.neco_certificate_url IS 'NECO certificate document URL';
COMMENT ON COLUMN users.jamb_result_url IS 'JAMB result document URL';
COMMENT ON COLUMN users.degree_certificate_url IS 'Degree certificate document URL';
COMMENT ON COLUMN users.diploma_certificate_url IS 'Diploma certificate document URL';
COMMENT ON COLUMN users.birth_certificate_url IS 'Birth certificate document URL';
COMMENT ON COLUMN users.national_id_url IS 'National ID document URL';
COMMENT ON COLUMN users.passport_url IS 'International passport document URL';
COMMENT ON COLUMN users.drivers_license_url IS 'Driver license document URL';
COMMENT ON COLUMN users.voters_card_url IS 'Voter card document URL';
COMMENT ON COLUMN users.nysc_certificate_url IS 'NYSC certificate document URL';
COMMENT ON COLUMN users.state_of_origin_cert_url IS 'State of origin certificate URL';
COMMENT ON COLUMN users.lga_certificate_url IS 'LGA certificate document URL';
COMMENT ON COLUMN users.resume_url IS 'Resume/CV document URL';
COMMENT ON COLUMN users.cover_letter_url IS 'Cover letter document URL';

-- Create table for document access logs (audit trail)
CREATE TABLE IF NOT EXISTS document_access_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    accessed_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    document_type VARCHAR(100) NOT NULL,
    action VARCHAR(50) NOT NULL, -- 'view', 'upload', 'delete', 'replace'
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_document_access_user ON document_access_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_document_access_by ON document_access_logs(accessed_by);
CREATE INDEX IF NOT EXISTS idx_document_access_date ON document_access_logs(created_at);

COMMENT ON TABLE document_access_logs IS 'Audit trail for document access and modifications';

COMMIT;
