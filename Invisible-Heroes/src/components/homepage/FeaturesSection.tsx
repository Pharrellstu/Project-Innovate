import { useState, useEffect } from "react";
import "./FeaturesSection.css";

const features = [
  {
    title: "1. Sign Up",
    items: [
      "Quick email/password registration",
      "Verify your campus email instantly",
      "Customize profile with bio, interests, and privacy controls",
    ],
  },
  {
    title: "2. Discover Events",
    items: [
      "Personalized event suggestions based on interests",
      "Browse by category, date, or location filter",
      "Tap an event to see details, organizer info, and campus map",
    ],
  },
  {
    title: "3. Join & Sync",
    items: [
      'Tap "Join" to add events to CampusLink calendar',
      "One-tap sync with Google Calendar or iCal",
      "Get real-time notifications for any event updates",
    ],
  },
];

function FeaturesSection() {
  const [activeIndex, setActiveIndex] = useState(0);

  // Auto-cycle through features
  useEffect(() => {
    const interval = setInterval(() => {
      setActiveIndex((prevIndex) => (prevIndex + 1) % features.length);
    }, 5000); // Change feature every 5 seconds
    return () => clearInterval(interval); // Cleanup on component unmount
  }, []);

  const handleBubbleClick = (index: number) => {
    setActiveIndex(index);
  };
  return (
    <>
      {/* Header Section - Outside the dark box */}
      <div id="features" className="features-heading-div">
        <h1 className="features-heading">Features</h1>
        <p className="features-text">
          Explore the features that make CampusLink the ultimate campus
          companion.
        </p>
      </div>

      {/* Dark Features Section */}
      <section className="features-section">
        {/* Background SVGs */}
        <svg
          className="background-svg svg-top-right"
          xmlns="http://www.w3.org/2000/svg"
          width="323"
          height="379"
          viewBox="0 0 323 379"
          fill="none"
        >
          <path
            fillRule="evenodd"
            clipRule="evenodd"
            d="M0.0890052 162.094L0.0434501 190.936L127.746 191.137L9.26663 238.789L20.0286 265.547L141.577 216.661L48.7922 309.154L69.1542 329.58L158.084 240.93L107.629 355.916L134.04 367.505L187.427 245.837L187.218 378.702L216.059 378.748L216.269 245.882L269.271 367.718L295.719 356.213L245.628 241.069L334.277 329.999L354.703 309.637L262.211 216.852L383.605 266.121L394.451 239.397L276.123 191.372L403.826 191.574L403.871 162.732L276.169 162.53L394.648 114.879L383.887 88.1213L262.337 137.005L355.121 44.5137L334.761 24.0885L245.831 112.738L296.285 -2.24845L269.874 -13.8363L216.487 107.83L216.697 -25.0344L187.855 -25.08L187.645 107.787L134.643 -14.0499L108.196 -2.54553L158.287 112.6L69.6372 23.6698L49.211 44.0306L141.703 136.815L20.3098 87.5471L9.4633 114.27L127.791 162.296L0.0890052 162.094Z"
            fill="url(#paint0_linear_1252_131)"
          />
          <defs>
            <linearGradient
              id="paint0_linear_1252_131"
              x1="-39.6811"
              y1="640.891"
              x2="442.289"
              y2="672.973"
              gradientUnits="userSpaceOnUse"
            >
              <stop stopColor="#094676" />
              <stop offset="1" stopColor="#094676" stopOpacity="0" />
            </linearGradient>
          </defs>{" "}
        </svg>

        {/* Bottom SVG with container and curved tagline */}
        <div className="svg-container-bottom-left">
          <svg
            className="background-svg svg-bottom-left"
            xmlns="http://www.w3.org/2000/svg"
            width="370"
            height="266"
            viewBox="0 0 370 266"
            fill="none"
          >
            {/* ...existing SVG path code... */}
            <path
              d="M211.85 117.955L211.857 117.788L211.986 117.849L211.85 117.955ZM349.978 110.891L347.163 105.461C336.212 84.3226 321.443 65.3942 303.602 49.6313L300.345 46.7569L211.981 117.859C227.896 125.492 245.163 129.905 262.788 130.846C280.414 131.787 298.053 129.236 314.69 123.341L349.978 110.891ZM211.852 117.798L211.764 4.3771L207.483 3.64509C184.015 -0.355364 160.008 0.0214814 136.68 4.76026L130.685 5.9753L143.138 41.2552C148.989 57.9074 158.071 73.2423 169.864 86.3759C181.656 99.5095 195.927 110.185 211.857 117.788L211.852 117.798ZM259.114 369.983L264.535 367.164C285.678 356.22 304.611 341.452 320.373 323.608L323.248 320.351L252.083 232.113C244.48 248.016 240.087 265.262 239.158 282.864C238.228 300.467 240.779 318.08 246.664 334.695L259.114 369.983ZM365.626 231.769L366.357 227.488C370.36 204.017 369.978 180.009 365.232 156.679L364.026 150.688L328.738 163.138C312.11 168.979 296.797 178.044 283.676 189.811C270.555 201.58 259.883 215.82 252.273 231.717L365.626 231.769ZM252.083 232.113L252.273 231.717L251.776 231.71L252.083 232.113ZM103.343 55.3021L90.8931 20.0137L85.4628 22.8295C64.3253 33.7783 45.3966 48.549 29.6342 66.3899L26.7605 69.6459L97.8343 158.072C105.478 142.148 109.899 124.872 110.843 107.235C111.785 89.5958 109.235 71.9469 103.334 55.2981L103.343 55.3021ZM-16.3503 162.51C-20.3504 185.978 -19.9725 209.984 -15.2344 233.315L-14.0189 239.309L21.2604 226.855C37.9247 221 53.2696 211.91 66.4106 200.106C79.5534 188.302 90.2312 174.017 97.8343 158.072L-15.6176 158.228L-16.3503 162.51ZM138.012 272.143L138.141 272.205L138.133 272.042L138.012 272.143ZM0.0153934 279.111L2.83565 284.532C13.7796 305.676 28.5466 324.608 46.3915 340.371L49.6472 343.246L138.012 272.143C122.094 264.514 104.827 260.104 87.2003 259.165C69.574 258.226 51.9357 260.777 35.2984 266.671L0.0153934 279.111ZM138.141 272.205L138.228 385.625L142.511 386.357C165.98 390.36 189.988 389.979 213.319 385.233L219.309 384.027L206.859 348.738C201.006 332.086 191.923 316.754 180.131 303.62C168.338 290.487 154.069 279.811 138.141 272.205ZM138.123 272.037L138.284 271.932C172.097 248.986 211.244 235.124 251.962 231.678L251.851 231.527C228.903 197.714 215.04 158.566 211.597 117.847L211.451 117.948C177.641 140.901 138.492 154.763 97.7725 158.201L97.8687 158.357C120.822 192.164 134.686 231.311 138.128 272.028L138.123 272.037Z"
              fill="url(#paint0_linear_1252_102)"
            />
            <defs>
              <linearGradient
                id="paint0_linear_1252_102"
                x1="-7.00515"
                y1="259.211"
                x2="418.103"
                y2="148.025"
                gradientUnits="userSpaceOnUse"
              >
                <stop stopColor="#094676" />
                <stop offset="1" stopColor="#094676" stopOpacity="0" />
              </linearGradient>
            </defs>{" "}
          </svg>{" "}
        </div>

        <div className="features-content">
          <div className="feature-card">
            <h3>{features[activeIndex].title}</h3>
            <ul>
              {features[activeIndex].items.map((item, index) => (
                <li key={index}>{item}</li>
              ))}
            </ul>
          </div>
          <div className="pagination-bubbles">
            {features.map((_, index) => (
              <button
                key={index}
                className={`bubble ${index === activeIndex ? "active" : ""}`}
                onClick={() => handleBubbleClick(index)}
                aria-label={`Go to feature ${index + 1}`}
              />
            ))}
          </div>
        </div>
      </section>
    </>
  );
}

export default FeaturesSection;
