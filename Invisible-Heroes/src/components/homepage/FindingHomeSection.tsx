import { useEffect, useRef } from "react";
import "./FindingHomeSection.css";

function FindingHomeSection() {
  const panelRefs = useRef<(HTMLDivElement | null)[]>([]);

  useEffect(() => {
    // Only add scroll listener on mobile devices
    const isMobile = window.innerWidth <= 768;
    if (!isMobile) return;

    const handleScroll = () => {
      const viewportCenter = window.innerHeight / 2;
      let centerPanel: HTMLDivElement | null = null;
      let minDistance = Infinity;

      panelRefs.current.forEach((panel) => {
        if (panel) {
          const rect = panel.getBoundingClientRect();
          const panelCenter = rect.top + rect.height / 2;
          const distance = Math.abs(panelCenter - viewportCenter);

          if (distance < minDistance) {
            minDistance = distance;
            centerPanel = panel;
          }
        }
      });

      // Remove active class from all panels
      panelRefs.current.forEach((panel) => {
        if (panel) {
          panel.classList.remove("active");
        }
      }); // Add active class to center panel
      if (centerPanel) {
        (centerPanel as HTMLDivElement).classList.add("active");
      }
    };

    // Add scroll listener
    window.addEventListener("scroll", handleScroll);
    // Check initial state
    handleScroll();

    // Cleanup
    return () => {
      window.removeEventListener("scroll", handleScroll);
    };
  }, []);
  return (
    <div id="finding-home" className="finding-home-section">
      <div className="finding-home-intro">
        <h1>Finding Home</h1>
        <p>
          Through shared stories and student events, CampusLink turns loneliness
          into belonging.
        </p>
      </div>

      <div className="finding-home-section-content">
        {" "}
        <div
          id="finding-home-panel-1"
          className="finding-home-panel"
          ref={(el) => {
            panelRefs.current[0] = el;
          }}
        >
          <h2>Arrive and Feel Alone</h2>
          <div className="panel-content-wrapper">
            <p className="panel-number">01</p>
            <p className="panel-text">
              Stepping onto campus in a new country can feel like being
              invisible—away from home, unsure where to begin.
            </p>
          </div>
        </div>
        <div
          id="finding-home-panel-2"
          className="finding-home-panel"
          ref={(el) => {
            panelRefs.current[1] = el;
          }}
        >
          <h2>Speak Your Truth</h2>
          <div className="panel-content-wrapper">
            <p className="panel-number">02</p>
            <p className="panel-text">
              Anonymously share your first-year story—homesickness, awkward
              silences, and the longing for a friendly face.
            </p>
          </div>
        </div>
        <div
          id="finding-home-panel-3"
          className="finding-home-panel"
          ref={(el) => {
            panelRefs.current[2] = el;
          }}
        >
          <h2>Find Your People</h2>
          <div className="panel-content-wrapper">
            <p className="panel-number">03</p>
            <p className="panel-text">
              Browse real-student events—from casual game sessions to pub
              meetups—born from those very stories of loneliness.
            </p>
          </div>
        </div>
        <div
          id="finding-home-panel-4"
          className="finding-home-panel"
          ref={(el) => {
            panelRefs.current[3] = el;
          }}
        >
          <h2>Belong Together</h2>
          <div className="panel-content-wrapper">
            <p className="panel-number">04</p>
            <p className="panel-text">
              Show up, check in, and earn a community badge as you transform
              those first-day jitters into lasting friendships.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

export default FindingHomeSection;
