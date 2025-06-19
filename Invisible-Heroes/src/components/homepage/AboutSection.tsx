import { useEffect, useRef, useState } from "react";
import { useNavigate } from "react-router-dom";
import { storyService } from "../../lib/supabase";
import "./AboutSection.css";
import Button from "../ui/Button";

// Security utilities
const sanitizeInput = (input: string): string => {
  // Remove potential XSS characters and SQL injection attempts
  return input
    .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '') // Remove script tags
    .replace(/<[^>]*>/g, '') // Remove all HTML tags
    .replace(/javascript:/gi, '') // Remove javascript: protocols
    .replace(/on\w+\s*=/gi, '') // Remove event handlers
    .replace(/[\x00-\x1F\x7F]/g, '') // Remove control characters
    .replace(/['";\\]/g, '') // Remove potentially dangerous characters
    .trim();
};

const validateInput = (input: string, maxLength: number = 1000): { isValid: boolean; error?: string } => {
  if (!input || input.trim().length === 0) {
    return { isValid: false, error: "Field cannot be empty" };
  }
  
  if (input.length > maxLength) {
    return { isValid: false, error: `Text must be less than ${maxLength} characters` };
  }
  
  // Check for suspicious patterns
  const suspiciousPatterns = [
    /drop\s+table/i,
    /delete\s+from/i,
    /update\s+.*set/i,
    /insert\s+into/i,
    /select\s+.*from/i,
    /union\s+select/i,
    /exec\s*\(/i,
    /script\s*>/i,
    /javascript\s*:/i,
    /vbscript\s*:/i,
    /data\s*:/i,
    /base64/i
  ];
  
  for (const pattern of suspiciousPatterns) {
    if (pattern.test(input)) {
      return { isValid: false, error: "Invalid content detected" };
    }
  }
  
  return { isValid: true };
};

const validateSubject = (subject: string): { isValid: boolean; error?: string } => {
  const basicValidation = validateInput(subject, 50); // Shorter limit for subject
  if (!basicValidation.isValid) {
    return basicValidation;
  }
  
  // Count words (split by whitespace and filter empty strings)
  const words = subject.trim().split(/\s+/).filter(word => word.length > 0);
  
  if (words.length < 3) {
    return { isValid: false, error: "Subject must be at least 3 words" };
  }
  
  if (words.length > 5) {
    return { isValid: false, error: "Subject must be no more than 5 words" };
  }
  
  return { isValid: true };
};

// Rate limiting
const RATE_LIMIT_KEY = 'story_submissions';
const MAX_SUBMISSIONS = 3; // Max 3 submissions per hour
const RATE_LIMIT_WINDOW = 60 * 60 * 1000; // 1 hour in milliseconds

const checkRateLimit = (): { allowed: boolean; remaining?: number } => {
  const now = Date.now();
  const stored = localStorage.getItem(RATE_LIMIT_KEY);
  
  if (!stored) {
    localStorage.setItem(RATE_LIMIT_KEY, JSON.stringify([now]));
    return { allowed: true, remaining: MAX_SUBMISSIONS - 1 };
  }
  
  try {
    const submissions: number[] = JSON.parse(stored);
    // Filter out submissions older than the rate limit window
    const recentSubmissions = submissions.filter(time => now - time < RATE_LIMIT_WINDOW);
    
    if (recentSubmissions.length >= MAX_SUBMISSIONS) {
      return { allowed: false, remaining: 0 };
    }
    
    // Add current submission and update storage
    recentSubmissions.push(now);
    localStorage.setItem(RATE_LIMIT_KEY, JSON.stringify(recentSubmissions));
    
    return { allowed: true, remaining: MAX_SUBMISSIONS - recentSubmissions.length };
  } catch {
    // If parsing fails, reset
    localStorage.setItem(RATE_LIMIT_KEY, JSON.stringify([now]));
    return { allowed: true, remaining: MAX_SUBMISSIONS - 1 };
  }
};

function AboutSection() {
  const panelRefs = useRef<(HTMLDivElement | null)[]>([]);
  const hasBeenShown = useRef<Set<HTMLElement>>(new Set());
  const navigate = useNavigate();
    // Form state
  const [subject, setSubject] = useState("");
  const [message, setMessage] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitMessage, setSubmitMessage] = useState("");
  const [fieldErrors, setFieldErrors] = useState<{subject?: string; message?: string}>({});
  // Real-time input handlers with validation
  const handleSubjectChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    setSubject(value);
    
    // Clear any existing field errors
    setFieldErrors(prev => ({ ...prev, subject: undefined }));
    
    // Count words
    const words = value.trim().split(/\s+/).filter(word => word.length > 0);
    const wordCount = value.trim() === '' ? 0 : words.length;
    
    // Show word count feedback
    if (wordCount < 3) {
      setFieldErrors(prev => ({ ...prev, subject: `${wordCount}/3-5 words (need ${3 - wordCount} more)` }));
    } else if (wordCount > 5) {
      setFieldErrors(prev => ({ ...prev, subject: `${wordCount}/3-5 words (${wordCount - 5} too many)` }));
    } else {
      setFieldErrors(prev => ({ ...prev, subject: `${wordCount}/3-5 words ✓` }));
    }
  };

  const handleMessageChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    const value = e.target.value;
    setMessage(value);
    
    // Clear any existing field errors
    setFieldErrors(prev => ({ ...prev, message: undefined }));
    
    // Show character count feedback (target ~280 chars like example)
    if (value.length > 350) {
      setFieldErrors(prev => ({ ...prev, message: `${value.length}/350 characters (${value.length - 350} too many)` }));
    } else if (value.length > 280) {
      setFieldErrors(prev => ({ ...prev, message: `${value.length}/350 characters (consider shortening)` }));
    } else if (value.length > 0) {
      setFieldErrors(prev => ({ ...prev, message: `${value.length}/350 characters` }));
    }
  };

  const handleAndMoreClick = () => {
    navigate('/about');
  };
  const scrollToNextSection = () => {
    const element = document.getElementById('about-section-3-pannel-1');
    if (element) {
      element.scrollIntoView({ behavior: 'smooth' });
    }
  };
  const handleFormSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    // Basic validation
    if (!subject.trim() || !message.trim()) {
      setSubmitMessage("Please fill in all fields");
      return;
    }

    // Rate limiting check
    const rateLimitCheck = checkRateLimit();
    if (!rateLimitCheck.allowed) {
      setSubmitMessage("Too many submissions. Please try again later.");
      return;
    }    // Input validation and sanitization
    const subjectValidation = validateSubject(subject); // Use new subject validator
    if (!subjectValidation.isValid) {
      setSubmitMessage(`Subject: ${subjectValidation.error}`);
      return;
    }

    const messageValidation = validateInput(message, 350); // 350 char limit for message
    if (!messageValidation.isValid) {
      setSubmitMessage(`Message: ${messageValidation.error}`);
      return;
    }

    // Sanitize inputs
    const cleanSubject = sanitizeInput(subject.trim());
    const cleanMessage = sanitizeInput(message.trim());

    // Double-check after sanitization
    if (!cleanSubject || !cleanMessage) {
      setSubmitMessage("Invalid content detected. Please check your input.");
      return;
    }

    setIsSubmitting(true);
    setSubmitMessage("");

    try {
      await storyService.createStory({
        subject: cleanSubject,
        message: cleanMessage,
        status: 'pending',
        submitted_at: new Date().toISOString()
      });

      setSubmitMessage("Story submitted successfully! It will be reviewed before being published.");
      setSubject("");
      setMessage("");
    } catch (error) {
      console.error("Error submitting story:", error);
      setSubmitMessage("Failed to submit story. Please try again.");
    } finally {
      setIsSubmitting(false);
    }
  };

  useEffect(() => {
    const observerOptions = {
      root: null,
      rootMargin: "-20% 0px -20% 0px", // Trigger when panel is 20% visible from top/bottom
      threshold: [0, 0.2, 0.5, 0.8],
    };

    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        const panel = entry.target as HTMLElement;

        if (entry.isIntersecting) {
          // Panel is in view - fade in
          if (entry.intersectionRatio >= 0.2) {
            panel.classList.add("fade-in");
            panel.classList.remove("fade-out");
            // Mark this panel as having been shown
            hasBeenShown.current.add(panel);
          }
        } else {
          // Only fade out if the panel hasn't been shown before
          if (!hasBeenShown.current.has(panel)) {
            panel.classList.remove("fade-in");
            panel.classList.add("fade-out");
          }
        }
      });
    }, observerOptions);

    // Observe all panels
    panelRefs.current.forEach((panel) => {
      if (panel) {
        observer.observe(panel);
      }
    });

    return () => {
      // Cleanup observer
      panelRefs.current.forEach((panel) => {
        if (panel) {
          observer.unobserve(panel);
        }
      });
    };
  }, []);
  return (
    <div className="about-horizontal-wrapper">
      <div
        className="about-section-panel"
        ref={(el) => {
          panelRefs.current[0] = el;
        }}
      >
        <div id="about-section-1-pannel-1" className="about-slide">
          <h1>About</h1>
          <p>
            CampusLink is the all-in-one student hub for discovering events,
            sharing stories, and syncing your campus life seamlessly.
          </p>
          <ul>
            <li>Find Your People</li>
            <li>Share Your Story</li>            <li>Built by Students, for Students</li>
          </ul>
          <Button variant="rounded-hollow" onClick={handleAndMoreClick}>
            And More
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="17"
              height="18"
              viewBox="0 0 17 18"
              fill="none"
            >
              <path
                fillRule="evenodd"
                clipRule="evenodd"
                d="M4.89715 1.65427C4.89715 1.01678 5.41394 0.5 6.05142 0.5H15.8457C16.4832 0.5 17 1.01678 17 1.65427V11.4486C17 12.0861 16.4832 12.6028 15.8457 12.6028C15.2082 12.6028 14.6915 12.0861 14.6915 11.4486V4.44092L1.97046 17.1619C1.51969 17.6127 0.788848 17.6127 0.338078 17.1619C-0.112693 16.7112 -0.112693 15.9803 0.338078 15.5295L13.0591 2.80854H6.05142C5.41394 2.80854 4.89715 2.29176 4.89715 1.65427Z"
                fill="#1C1A1A"
              />
            </svg>
          </Button>
        </div>
        <div id="about-section-1-pannel-2" className="about-slide">
          <h1>Key Features</h1>
          <p>
            From an interactive map and personalized feed to calendar sync and
            event badges, CampusLink has everything you need to stay connected.
          </p>
        </div>
        <div id="about-section-1-pannel-3" className="about-slide">
          <h1>Join the Community</h1>
          <p>
            Download the app to meet fellow students, follow your favorite
            clubs, and be the first to hear about every campus experience.{" "}
          </p>
        </div>
      </div>
      <div
        className="about-section-panel"
        ref={(el) => {
          panelRefs.current[1] = el;
        }}
      >
        <div id="about-section-2-pannel-1" className="about-slide">
          <h1>Our MDT Journey</h1>
          <p>
            Through the MDT project, we've listened to hundreds of students'
            stories of quiet loneliness — homesick first-years, shy transfers,
            and anyone searching for a friendly face.
          </p>
        </div>
        <div id="about-section-2-pannel-2" className="about-slide">
          <h1>Building Connections</h1>
          <p>
            CampusLink brings those voices to life by turning isolation into
            shared laughter — transforming empty hallways into vibrant
            gatherings and forging genuine campus community.
          </p>
        </div>
        <div id="about-section-2-pannel-3" className="about-slide">
          <h1>Share Your Story</h1>          <p>
            Tell us anonymously about your own struggles or breakthroughs in
            finding friends on campus — your courage will guide others from
            solitude to solidarity.
          </p>
          <Button variant="rounded-hollow" onClick={scrollToNextSection}>
            And More
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="17"
              height="18"
              viewBox="0 0 17 18"
              fill="none"
            >
              <path
                fillRule="evenodd"
                clipRule="evenodd"
                d="M4.89715 1.65427C4.89715 1.01678 5.41394 0.5 6.05142 0.5H15.8457C16.4832 0.5 17 1.01678 17 1.65427V11.4486C17 12.0861 16.4832 12.6028 15.8457 12.6028C15.2082 12.6028 14.6915 12.0861 14.6915 11.4486V4.44092L1.97046 17.1619C1.51969 17.6127 0.788848 17.6127 0.338078 17.1619C-0.112693 16.7112 -0.112693 15.9803 0.338078 15.5295L13.0591 2.80854H6.05142C5.41394 2.80854 4.89715 2.29176 4.89715 1.65427Z"
                fill="#1C1A1A"
              />
            </svg>
          </Button>{" "}
        </div>
      </div>
      <div
        className="about-section-panel"
        ref={(el) => {
          panelRefs.current[2] = el;
        }}
      >        <div id="about-section-3-pannel-1" className="about-slide">
          <h1>Leave your story - Anonymously</h1>
          <p>
            Inspire others that are going through the same struggles you are
            going through. There are always others out there experiencing what
            you are. You are not alone!
          </p>
          
          {submitMessage && (
            <div className={`submit-message ${submitMessage.includes('successfully') ? 'success' : 'error'}`}>
              {submitMessage}
            </div>
          )}          <form onSubmit={handleFormSubmit}>
            <div className="form-field">
              <input 
                type="text" 
                name="subject" 
                placeholder="Subject (up to 5 words)" 
                value={subject}
                onChange={handleSubjectChange}
                disabled={isSubmitting}
                maxLength={50}
                required 
              />
              {fieldErrors.subject && (
                <div className={`field-error ${fieldErrors.subject.includes('✓') ? 'field-success' : ''}`}>
                  {fieldErrors.subject}
                </div>
              )}
            </div>
            
            <div className="form-field">
              <textarea
                name="message"
                placeholder="Share your story briefly... (about ~250 characters)"
                rows={4}
                value={message}
                onChange={handleMessageChange}
                disabled={isSubmitting}
                maxLength={350}
                required
              ></textarea>
              {fieldErrors.message && (
                <div className="field-error">{fieldErrors.message}</div>
              )}
            </div>
            
            <Button 
              variant="rounded-hollow" 
              type="submit"
              disabled={isSubmitting || subject.length === 0 || message.length === 0}
            >
              {isSubmitting ? "Submitting..." : "Submit Story"}
            </Button>
          </form>
        </div>
      </div>
    </div>
  );
}

export default AboutSection;
