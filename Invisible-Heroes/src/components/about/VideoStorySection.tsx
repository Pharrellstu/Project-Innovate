import { useState } from "react";
import "./VideoStorySection.css";

interface VideoStorySectionProps {
  title?: string;
  subtitle?: string;
  youtubeUrls?: string[]; // one or more YouTube links
}

// Contract:
// - Renders an accessible, responsive YouTube embed card with optional title/subtitle.
// - Defaults to the provided YouTube link if no prop is passed.
export default function VideoStorySection({
  title = "Student Stories",
  subtitle = "Watch short videos from our community.",
  youtubeUrls = [
    "https://youtu.be/Utl0BvFI_TI",
    "https://youtu.be/e2pK2X37ces",
    "https://youtu.be/2ndtrxMjxHk",
    "https://youtu.be/emykub_b-10",
  ],
}: VideoStorySectionProps) {
  const [active, setActive] = useState(0);
  // Convert a YouTube URL to an embeddable URL (works with youtu.be or youtube.com links)
  const getEmbedUrl = (url: string) => {
    try {
      const u = new URL(url);
      // youtu.be/<id>
      if (u.hostname.includes("youtu.be")) {
        return `https://www.youtube.com/embed/${u.pathname.replace("/", "")}`;
      }
      // www.youtube.com/watch?v=<id>
      if (u.hostname.includes("youtube.com")) {
        const id = u.searchParams.get("v");
        if (id) return `https://www.youtube.com/embed/${id}`;
      }
      // Fallback to original if parsing fails
      return url;
    } catch {
      return url;
    }
  };

  const embedUrl = getEmbedUrl(youtubeUrls[Math.max(0, Math.min(active, youtubeUrls.length - 1))] ?? youtubeUrls[0]);

  return (
    <section className="video-story-section" aria-labelledby="video-story-heading">
      <div className="video-story-container">
        <header className="video-story-header">
          <h2 id="video-story-heading" className="video-story-title">{title}</h2>
          <p className="video-story-subtitle">{subtitle}</p>
        </header>

        {youtubeUrls.length > 1 && (
          <div className="video-switch" role="tablist" aria-label="Select a video">
            {youtubeUrls.map((_, idx) => {
              const isActive = idx === active;
              return (
                <button
                  key={idx}
                  role="tab"
                  aria-selected={isActive}
                  aria-controls={`video-panel-${idx}`}
                  id={`video-tab-${idx}`}
                  className={`video-switch-btn${isActive ? " is-active" : ""}`}
                  onClick={() => setActive(idx)}
                >
                  Video {idx + 1}
                </button>
              );
            })}
          </div>
        )}

        <div className="video-card" role="group" aria-label="Video story">
          <div className="video-aspect">
            <iframe
              className="video-embed"
              src={embedUrl}
              title="YouTube video player"
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
              referrerPolicy="strict-origin-when-cross-origin"
              allowFullScreen
            />
          </div>
        </div>
      </div>
    </section>
  );
}
