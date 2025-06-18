import { useEffect, useRef } from "react";
import { useNavigate } from "react-router-dom";
import "./AboutSection.css";
import Button from "../ui/Button";

function AboutSection() {
  const panelRefs = useRef<(HTMLDivElement | null)[]>([]);
  const hasBeenShown = useRef<Set<HTMLElement>>(new Set());
  const navigate = useNavigate();
  const handleAndMoreClick = () => {
    navigate('/about');
  };

  const scrollToNextSection = () => {
    const element = document.getElementById('about-section-3-pannel-1');
    if (element) {
      element.scrollIntoView({ behavior: 'smooth' });
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
      >
        <div id="about-section-3-pannel-1" className="about-slide">
          <h1>Leave your story - Anonymously</h1>
          <p>
            Inspire others that are going through the same struggles you are
            going through. There are always others out there experiencing what
            you are. You are not alone!
          </p>
          <form action="" method="post">
            <input type="text" name="subject" placeholder="Subject" required />
            <textarea
              name="message"
              placeholder="Share your story..."
              rows={6}
              required
            ></textarea>
            <Button variant="rounded-hollow" type="submit">
              Submit Story
            </Button>{" "}
          </form>
        </div>
      </div>
    </div>
  );
}

export default AboutSection;
