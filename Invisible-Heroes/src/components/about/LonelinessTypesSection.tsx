import { useState } from "react";
import "./LonelinessTypesSection.css";

function LonelinessTypesSection() {
  const [activeIndex, setActiveIndex] = useState<number | null>(null);

  const toggleAccordion = (index: number) => {
    setActiveIndex(activeIndex === index ? null : index);
  };

  const lonelinessTypes = [
    {
      title: "Situational Loneliness",
      content: (
        <>
          This temporary form of loneliness occurs when life circumstances
          change or disrupt your usual social connections.
          <ul>
            <li>Moving to a new city or starting university</li>
            <li>Losing touch with old friends due to distance</li>
            <li>Major life transitions like graduation or breakups</li>
            <li>Temporary isolation due to illness or circumstances</li>
          </ul>
          Remember, situational loneliness usually improves as you adapt to new
          circumstances and rebuild connections.
        </>
      ),
    },
    {
      title: "Emotional Loneliness",
      content: (
        <>
          This occurs when you lack deep, intimate relationships and feel
          emotionally disconnected from others.
          <ul>
            <li>Missing someone to share your deepest thoughts with</li>
            <li>Feeling emotionally distant even when surrounded by people</li>
            <li>Lacking a close confidant or best friend</li>
            <li>Feeling misunderstood or not truly known by others</li>
          </ul>
          Building one meaningful relationship can often help alleviate this
          profound sense of emotional isolation.
        </>
      ),
    },
    {
      title: "Social Loneliness",
      content: (
        <>
          This happens when you feel excluded from a social network or community
          that you want to be part of.
          <ul>
            <li>Feeling left out of group activities or conversations</li>
            <li>Not having a regular friend group to hang out with</li>
            <li>Struggling to find people who share your interests</li>
            <li>Feeling like an outsider in social situations</li>
          </ul>
          Joining clubs, attending events, or participating in group activities
          can help you find your social tribe.
        </>
      ),
    },
    {
      title: "Cultural Loneliness",
      content: (
        <>
          This is experienced when you feel disconnected from your cultural
          identity or struggle to fit into a new culture.
          <ul>
            <li>Being an international student in a new country</li>
            <li>Missing cultural traditions, food, or language</li>
            <li>Feeling like others don't understand your background</li>
            <li>Struggling with cultural differences and expectations</li>
          </ul>
          Connecting with others from similar backgrounds or finding culturally
          diverse communities can provide comfort and understanding.
        </>
      ),
    },
    {
      title: "Transitional",
      content: (
        <>
          This type of loneliness occurs during major life transitions when your
          sense of identity or role is changing.
          <ul>
            <li>Starting university and leaving home for the first time</li>
            <li>Changing from student life to professional life</li>
            <li>Shifting friend groups or social circles</li>
            <li>
              Personal growth that creates distance from old relationships
            </li>
          </ul>
          This loneliness often resolves as you establish your new identity and
          form relationships that align with who you're becoming.
        </>
      ),
    },
  ];
  return (
    <section className="loneliness-types-section">
      <div className="loneliness-types-intro">
        <h1>Types of Loneliness</h1>
        <p>
          Everyone’s experience of loneliness is unique. Below are the most
          common forms students face—whether you’re new on campus, finding it
          hard to connect, or missing a close confidant.
        </p>
      </div>{" "}
      <div className="loneliness-types-contents">
        {lonelinessTypes.map((type, index) => (
          <div
            key={index}
            className={`loneliness-type ${
              activeIndex === index ? "active" : ""
            }`}
          >
            <div
              className="loneliness-type-header"
              onClick={() => toggleAccordion(index)}
            >
              <h2>{type.title}</h2>
              <span className="accordion-icon">
                <svg
                  width="20"
                  height="20"
                  viewBox="0 0 24 24"
                  fill="none"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    d="M6 9l6 6 6-6"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                </svg>
              </span>
            </div>
            <div className="loneliness-type-content">
              <p>{type.content}</p>
            </div>
          </div>
        ))}
      </div>
      <div className="loneliness-support">
        <h2>Need Support?</h2>
        <p>
          If you’re feeling any of these types of loneliness, know that you’re
          not alone. CampusLink is here to help you connect with others and find
          your community.
        </p>
      </div>
    </section>
  );
}

export default LonelinessTypesSection;
