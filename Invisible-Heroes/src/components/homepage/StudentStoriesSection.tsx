import { useState, useEffect, useRef } from "react";
import "./StudentStoriesSection.css";
import dummyAvatar from "../../assets/dummy_image_group_photo.jpg";

function StudentStoriesSection() {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [visibleStories, setVisibleStories] = useState(3);
  const carouselRef = useRef<HTMLDivElement>(null);

  // Sample stories for testing - will be replaced with real data from admin-approved submissions
  const stories = [
    {
      id: 1,
      subject: "Finding My Voice",
      story:
        "Coming to a new country felt overwhelming at first. The language barrier and cultural differences made me feel invisible. But through anonymous storytelling, I found the courage to share my experiences and realized I wasn't alone.",
      author: "NHL Stenden Student",
    },
    {
      id: 2,
      subject: "From Isolation to Connection",
      story:
        "I spent my first semester eating lunch alone and avoiding social events. Sharing my story anonymously helped me realize others felt the same way. Now I help organize events for other international students.",
      author: "NHL Stenden Student",
    },
    {
      id: 3,
      subject: "Breaking the Silence",
      story:
        "Homesickness hit me harder than expected. I was embarrassed to admit I was struggling until I read similar stories from other students. It gave me the courage to reach out and ask for help.",
      author: "NHL Stenden Student",
    },
    {
      id: 4,
      subject: "Building Confidence",
      story:
        "The anonymous platform allowed me to express my fears about making friends without judgment. Reading others' experiences and seeing how they overcame similar challenges inspired me to put myself out there.",
      author: "NHL Stenden Student",
    },
    {
      id: 5,
      subject: "Creating Community",
      story:
        "After sharing my story about feeling disconnected, I started attending campus events. The platform helped me realize that many students were looking for meaningful connections, just like me.",
      author: "NHL Stenden Student",
    },
    {
      id: 6,
      subject: "Overcoming Anxiety",
      story:
        "Social anxiety made university life challenging. Through anonymous storytelling, I learned coping strategies from other students and gradually built the confidence to participate in campus activities.",
      author: "NHL Stenden Student",
    },
  ]; // Handle mobile scroll behavior and responsive navigation
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
    setCurrentIndex((prev) => {
      // If at the beginning, wrap to the end
      if (prev === 0) {
        return maxIndex;
      }
      return prev - 1;
    });
  };

  const handleNext = () => {
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
      {" "}
      <div className="student-stories-intro">
        <h1>Real Stories</h1>
        <div className="carousel-controls">
          <button className="carousel-btn" onClick={handlePrevious}>
            Back
          </button>
          <button className="carousel-btn" onClick={handleNext}>
            Next
          </button>
        </div>
      </div>
      <div className="carousel-container" ref={carouselRef}>
        {" "}
        <div
          className="student-stories-container"
          style={{
            transform: `translateX(-${
              currentIndex * (100 / visibleStories + 100 * 0.02)
            }%)`,
          }}
        >
          {stories.map((story) => (
            <div key={story.id} className="student-story">
              <h2>{story.subject}</h2>
              <p>"{story.story}"</p>{" "}
              <div className="story-author">
                <img src={dummyAvatar} alt="Anonymous student avatar" />
                <p>{story.author}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

export default StudentStoriesSection;
