-- Create the stories table
CREATE TABLE IF NOT EXISTS stories (
  id SERIAL PRIMARY KEY,
  subject VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved')),
  submitted_at TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create an index on status for faster filtering
CREATE INDEX IF NOT EXISTS idx_stories_status ON stories(status);

-- Create an index on submitted_at for sorting
CREATE INDEX IF NOT EXISTS idx_stories_submitted_at ON stories(submitted_at DESC);

-- Create a function to automatically update the updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

-- Create trigger for stories table
DROP TRIGGER IF EXISTS update_stories_updated_at ON stories;
CREATE TRIGGER update_stories_updated_at
  BEFORE UPDATE ON stories
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Insert some sample data (optional)
INSERT INTO stories (subject, message, submitted_at) VALUES
('Finding My Place on Campus', 'I was really struggling with feeling isolated during my first year at university. The transition from high school to college was harder than I expected, and I felt like I didn''t belong anywhere. CampusLink helped me find study groups and social events that matched my interests. Now I have a great group of friends and I''m much happier!', '2025-01-15 10:30:00+00'),
('International Student Experience', 'Being an international student, I felt really disconnected from campus life. I didn''t know about most events and activities happening around campus. CampusLink''s event discovery feature helped me find cultural clubs and academic workshops that made me feel more at home.', '2025-01-14 15:45:00+00'),
('Transfer Student Connections', 'After transferring to this university, I had a hard time making new connections. Everyone seemed to already have their friend groups established. Through CampusLink, I found volunteer opportunities and hobby-based meetups where I met like-minded people.', '2025-01-13 09:20:00+00')
ON CONFLICT DO NOTHING;
