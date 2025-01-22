-- Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('newBooking', 'bookingStatusUpdate', 'newMessage', 'paymentReceived')),
    booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_read BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Create messages table
CREATE TABLE IF NOT EXISTS messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_read BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_booking FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    CONSTRAINT fk_sender FOREIGN KEY (sender_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Create bookings table
CREATE TABLE IF NOT EXISTS bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    renter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    status TEXT NOT NULL CHECK (status IN ('pending', 'confirmed', 'declined', 'cancelled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    rating DECIMAL(3,2),
    review TEXT
);

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_booking_id ON messages(booking_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);

-- Create RLS policies for notifications
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Drop existing policy if it exists
DROP POLICY IF EXISTS "Users can view their own notifications" ON notifications;

-- Create policy for users to view their own notifications
CREATE POLICY "Users can view their own notifications"
    ON notifications FOR SELECT
    USING (auth.uid() = user_id);

-- Drop existing policy if it exists
DROP POLICY IF EXISTS "System can create notifications" ON notifications;

-- Create policy for the system to create notifications
CREATE POLICY "System can create notifications"
    ON notifications FOR INSERT
    WITH CHECK (true);

-- Create RLS policies for bookings
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

-- Create policy for users to view their own bookings
CREATE POLICY IF NOT EXISTS "Users can view bookings"
    ON bookings FOR SELECT
    USING (auth.uid() = renter_id OR auth.uid() = owner_id);

-- Create RLS policies for messages
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Drop existing policy if it exists
DROP POLICY IF EXISTS "Users can view messages if they are part of the booking" ON messages;

-- Create policy for users to view messages if they are part of the booking
CREATE POLICY "Users can view messages if they are part of the booking"
    ON messages FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM bookings
            WHERE bookings.id = messages.booking_id
            AND (bookings.renter_id = auth.uid() OR bookings.owner_id = auth.uid())
        )
    );

-- Create policy for users to send messages if they are part of the booking
CREATE POLICY "Users can send messages if they are part of the booking"
    ON messages FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM bookings
            WHERE bookings.id = messages.booking_id
            AND (bookings.renter_id = auth.uid() OR bookings.owner_id = auth.uid())
        )
        AND auth.uid() = sender_id
    );

CREATE POLICY IF NOT EXISTS "Users can update their own message read status"
    ON messages FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM bookings
            WHERE bookings.id = messages.booking_id
            AND (bookings.renter_id = auth.uid() OR bookings.owner_id = auth.uid())
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM bookings
            WHERE bookings.id = messages.booking_id
            AND (bookings.renter_id = auth.uid() OR bookings.owner_id = auth.uid())
        )
    );

-- Create function to notify users of new messages
CREATE OR REPLACE FUNCTION notify_new_message()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO notifications (user_id, title, message, type, booking_id)
    SELECT 
        CASE 
            WHEN b.renter_id = NEW.sender_id THEN b.owner_id
            ELSE b.renter_id
        END,
        'New Message',
        'You have a new message in your booking chat',
        'newMessage',
        NEW.booking_id
    FROM bookings b
    WHERE b.id = NEW.booking_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for new message notifications
CREATE TRIGGER IF NOT EXISTS on_new_message
    AFTER INSERT ON messages
    FOR EACH ROW
    EXECUTE FUNCTION notify_new_message();

-- Create function to notify users of booking status changes
CREATE OR REPLACE FUNCTION notify_booking_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status != OLD.status THEN
        INSERT INTO notifications (user_id, title, message, type, booking_id)
        VALUES (
            CASE 
                WHEN NEW.status IN ('confirmed', 'declined') THEN NEW.renter_id
                ELSE NEW.owner_id
            END,
            'Booking Status Updated',
            CASE 
                WHEN NEW.status = 'confirmed' THEN 'Your booking has been confirmed'
                WHEN NEW.status = 'declined' THEN 'Your booking has been declined'
                WHEN NEW.status = 'cancelled' THEN 'A booking has been cancelled'
                ELSE 'Booking status has been updated to ' || NEW.status
            END,
            'bookingStatusUpdate',
            NEW.id
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for booking status change notifications
CREATE TRIGGER IF NOT EXISTS on_booking_status_change
    AFTER UPDATE ON bookings
    FOR EACH ROW
    WHEN (OLD.status IS DISTINCT FROM NEW.status)
    EXECUTE FUNCTION notify_booking_status_change();
