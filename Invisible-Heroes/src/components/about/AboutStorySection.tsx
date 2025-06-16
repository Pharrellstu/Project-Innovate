import { useEffect, useState } from "react";
import "./AboutStorySection.css";

function AboutStorySection() {
  const [isExpanded, setIsExpanded] = useState(false);
  useEffect(() => {
    let ticking = false;

    const handleScroll = () => {
      if (!ticking) {
        requestAnimationFrame(() => {
          const scrollPosition = window.scrollY;
          const triggerPoint = 80; // Trigger after scrolling 80px

          setIsExpanded(scrollPosition > triggerPoint);
          ticking = false;
        });
        ticking = true;
      }
    };

    window.addEventListener("scroll", handleScroll, { passive: true });
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  return (
    <div className="about-story-section">
      <img
        src="/src/assets/dummy_image_group_photo.jpg"
        alt="Group photo of the students that brought this project to life"
        className={isExpanded ? "expanded" : ""}
      />

      <div className="about-story-text">
        <h3>Fitting In Isn't Easy</h3>
        <p>
          Moving to a new country meant navigating unfamiliar streets, new
          rules, and a campus full of strangers. We—like so many
          others—found ourselves sitting alone between lectures, scrolling
          for a friendly face. It was only when we organized our first
          casual game night that we realized how powerful a simple
          invitation could be.
        </p>
        <p>
          Inspired by that moment, we set out to build CampusLink: an app
          designed with empathy and shaped by our own challenges.
        </p>
      </div>
    </div>
  );
}

export default AboutStorySection;
