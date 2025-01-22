-- Add verification fields to profiles table
ALTER TABLE profiles
ADD COLUMN verification_status smallint DEFAULT 0,
ADD COLUMN selfie_with_id_url text,
ADD COLUMN verified_at timestamp with time zone,
ADD COLUMN verification_rejection_reason text;

-- Create index for faster verification queries
CREATE INDEX idx_profiles_verification_status ON profiles(verification_status);

-- Add verification status check constraint
ALTER TABLE profiles
ADD CONSTRAINT chk_verification_status 
CHECK (verification_status >= 0 AND verification_status <= 3);

-- Create function to update verified_at timestamp
CREATE OR REPLACE FUNCTION update_verified_at()
RETURNS trigger AS $$
BEGIN
    IF NEW.verification_status = 2 AND OLD.verification_status != 2 THEN
        NEW.verified_at = NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to update verified_at
CREATE TRIGGER tr_update_verified_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_verified_at();
