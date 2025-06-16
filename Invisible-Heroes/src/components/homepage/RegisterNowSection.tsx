import { useState, useEffect, useRef } from "react";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import "./RegisterNowSection.css";

gsap.registerPlugin(ScrollTrigger);

function RegisterNowSection() {
  const [timeLeft, setTimeLeft] = useState({
    days: 0,
    hours: 0,
    minutes: 0,
    seconds: 0,
  });

  const svgWrapperRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    // Set target date - 30 days from now (you can adjust this)
    const targetDate = new Date();
    targetDate.setDate(targetDate.getDate() + 30);
    targetDate.setHours(23, 59, 59, 999); // End of day

    const updateTimer = () => {
      const now = new Date().getTime();
      const target = targetDate.getTime();
      const difference = target - now;

      if (difference > 0) {
        const days = Math.floor(difference / (1000 * 60 * 60 * 24));
        const hours = Math.floor(
          (difference % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60)
        );
        const minutes = Math.floor(
          (difference % (1000 * 60 * 60)) / (1000 * 60)
        );
        const seconds = Math.floor((difference % (1000 * 60)) / 1000);

        setTimeLeft({ days, hours, minutes, seconds });
      } else {
        setTimeLeft({ days: 0, hours: 0, minutes: 0, seconds: 0 });
      }
    };

    // Update immediately
    updateTimer();

    // Update every second
    const interval = setInterval(updateTimer, 1000);

    return () => clearInterval(interval);
  }, []);
  useEffect(() => {
    if (window.innerWidth > 768 && svgWrapperRef.current) {
      const animation = gsap.to(svgWrapperRef.current, {
        rotation: 60, // Reduced rotation - was 360, now 180 for more subtle effect
        ease: "none",
        // You can easily tweak these transform-origin values:
        // Try: "center center", "50% 45%", "55% 50%", "200px 160px", etc.
        transformOrigin: "center center",
        scrollTrigger: {
          trigger: ".register-now-timer-container",
          start: "top bottom",
          end: "bottom top",
          scrub: 5, // Slower, less sensitive - was 1, now 3 (higher = slower response)
          // Uncomment the next line to see rotation markers for debugging:
          // markers: true,
        },
      });

      return () => {
        animation.kill();
        ScrollTrigger.getAll().forEach((trigger) => trigger.kill());
      };
    }
  }, []);

  // Format numbers with leading zero
  const formatNumber = (num: number) => num.toString().padStart(2, "0");
  return (
    <div className="register-now-section">
      <div className="register-now-intro">
        <h1>Register Now</h1>
        <p>
          Sign up before the timer hits zero to unlock your exclusive OG Founder
          badge!
        </p>
      </div>{" "}
      <div className="register-now-timer-container">
        <div className="timer-left-section">
          <p className="timer-header-text">
            Exclusive OG Founder Badge Ends In
          </p>
          <div className="timer-display">
            <div className="register-now-timer">
              <span className="timer-number">
                {formatNumber(timeLeft.days)}
              </span>
              <span className="timer-label">DAYS</span>
            </div>
            <div className="timer-separator">:</div>
            <div className="register-now-timer">
              <span className="timer-number">
                {formatNumber(timeLeft.hours)}
              </span>
              <span className="timer-label">HOURS</span>
            </div>{" "}
            <div className="timer-separator">:</div>
            <div className="register-now-timer">
              <span className="timer-number">
                {formatNumber(timeLeft.minutes)}
              </span>
              <span className="timer-label">MINUTES</span>
            </div>
          </div>
        </div>{" "}
        <div className="timer-right-section">
          <div ref={svgWrapperRef} className="svg-rotation-wrapper">
            <svg
              className="starburst-svg"
              xmlns="http://www.w3.org/2000/svg"
              width="364"
              height="410"
              viewBox="0 0 364 410"
              fill="none"
              overflow="visible"
            >
              <path
                fillRule="evenodd"
                clipRule="evenodd"
                d="M396.621 145.144L386.496 118.138L266.922 162.969L360.995 76.609L341.491 55.3625L244.98 143.96L299.201 24.6959L272.945 12.7596L220.977 127.069L227.655 1.67859L198.855 0.144635L191.788 132.822L145.144 8.41332L118.138 18.5386L164.782 142.947L72.2307 47.6191L51.537 67.7098L139.005 157.802L24.6959 105.834L12.7605 132.09L132.024 186.31L1.05421 183.001L0.32654 211.833L127.988 215.059L8.41345 259.891L18.5388 286.897L138.113 242.065L44.0402 328.426L63.5433 349.672L160.055 261.075L105.835 380.338L132.089 392.274L184.057 277.965L177.379 403.356L206.18 404.889L213.247 272.213L259.891 396.621L286.897 386.496L240.252 262.086L332.804 357.415L353.498 337.325L266.029 247.232L380.339 299.199L392.275 272.945L273.012 218.725L403.98 222.033L404.709 193.202L277.047 189.976L396.621 145.144Z"
                fill="url(#paint0_linear_326_1105)"
              />
              <defs>
                <linearGradient
                  id="paint0_linear_326_1105"
                  x1="391.559"
                  y1="131.641"
                  x2="-70.777"
                  y2="271.533"
                  gradientUnits="userSpaceOnUse"
                >
                  <stop stopColor="#094676" />
                  <stop
                    offset="1"
                    stopColor="#094676"
                    stopOpacity="0"
                  />
                </linearGradient>
              </defs>
            </svg>
          </div>
        </div>
      </div>
    </div>
  );
}

export default RegisterNowSection;
