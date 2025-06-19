import { useState, useEffect, useRef } from "react";
import { storyService } from "../../lib/supabase";
import type { Story } from "../../lib/supabase";
import "./StudentStoriesSection.css";
import anonymousAvatar from "../../assets/anonymous-user.png";

function StudentStoriesSection() {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [visibleStories, setVisibleStories] = useState(3);
  const [stories, setStories] = useState<Story[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const carouselRef = useRef<HTMLDivElement>(null);  // Fetch approved stories from database
  useEffect(() => {    const fetchStories = async () => {
      try {
        setLoading(true);
        setError(null);
        const approvedStories = await storyService.getApprovedStories();
        setStories(approvedStories);
      } catch (err) {
        console.error("Error fetching stories:", err);
        setError("Failed to load stories");
        // Fallback to empty array if stories can't be loaded
        setStories([]);
      } finally {
        setLoading(false);
      }
    };

    fetchStories();
  }, []);

  // Handle mobile scroll behavior and responsive navigation
  useEffect(() => {
    const carousel = carouselRef.current;

    const updateVisibleStories = () => {
      if (window.innerWidth <= 850) {
        setVisibleStories(2); // Show 2 stories on medium screens
      } else {
        setVisibleStories(3); // Show 3 stories on large screens
      }
    };

    // Set initial value
    updateVisibleStories();

    // Handle resize
    window.addEventListener("resize", updateVisibleStories);

    // Handle mobile scroll behavior
    if (carousel) {
      const isMobilePhone = window.innerWidth <= 480;

      if (isMobilePhone) {
        carousel.style.overscrollBehaviorX = "contain";
      }
    }

    return () => {
      window.removeEventListener("resize", updateVisibleStories);
    };
  }, []);
  const maxIndex = Math.max(0, stories.length - visibleStories);

  const handlePrevious = () => {
    if (stories.length === 0) return;
    setCurrentIndex((prev) => {
      // If at the beginning, wrap to the end
      if (prev === 0) {
        return maxIndex;
      }
      return prev - 1;
    });
  };

  const handleNext = () => {
    if (stories.length === 0) return;
    setCurrentIndex((prev) => {
      // If at the end, wrap to the beginning
      if (prev >= maxIndex) {
        return 0;
      }
      return prev + 1;
    });
  };

  return (
    <div className="student-stories-section">
      {" "}      <div className="student-stories-intro">
        <h1>Real Stories</h1>
        <div className="carousel-controls">
          <button 
            className="carousel-btn" 
            onClick={handlePrevious}
            disabled={loading || stories.length === 0}
          >
            Back
          </button>
          <button 
            className="carousel-btn" 
            onClick={handleNext}
            disabled={loading || stories.length === 0}
          >
            Next
          </button>
        </div>
      </div>
      <div className="carousel-container" ref={carouselRef}>
        {" "}        <div
          className="student-stories-container"
          style={{
            transform: `translateX(-${
              currentIndex * (100 / visibleStories + 100 * 0.02)
            }%)`,
          }}
        >
          {loading ? (
            <div className="loading-message">Loading stories...</div>
          ) : error ? (
            <div className="error-message">Unable to load stories at this time.</div>
          ) : stories.length === 0 ? (
            <div className="no-stories-message">No stories available yet.</div>
          ) : (
            stories.map((story) => (
              <div key={story.id} className="student-story">
                <h2>{story.subject}</h2>
                <p>"{story.message}"</p>{" "}
                <div className="story-author">
                  <img src={anonymousAvatar} alt="Anonymous student avatar" />
                  <p>NHL Stenden Student</p>
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
}

export default StudentStoriesSection;
