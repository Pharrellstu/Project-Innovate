import { useState } from "react";
import "./LonelinessTypesSection.css";

interface LonelinessType {
  id: number;
  title: string;
  description: string;
  items: string[];
}

const lonelinessTypes: LonelinessType[] = [
  {
    id: 0,
    title: "Situational",
    description: "Feeling isolated due to specific circumstances:",
    items: [
      "Being new to campus or city",
      "Living far from family and friends",
      "Major life changes like starting university",
      "Moving to a different country or culture",
      "Temporary separation from loved ones"
    ]
  },
  {
    id: 1,
    title: "Emotional",
    description: "Missing deep, ingful connections:",
    items: [
      "Having people around but feeling misunderstood",
      "Lacking someone to share personal thoughts with",
      "Feeling like no one truly \"gets\" you",
      "Missing intimate friendships or relationships",
      "Craving deeper conversations and connections"
    ]
  },
  {
    id: 2,
    title: "Social",
    description: "Lacking a broader social network:",
    items: [
      "Feeling excluded from groups or communities",
      "Struggling to find your social circle",
      "Difficulty making casual friendships",
      "Missing shared activities and group experiences",
      "Not having people to hang out with regularly"
    ]
  },
  {
    id: 3,
    title: "Cultural",
    description: "Feeling disconnected due to cultural differences:",
    items: [
      "Language barriers and communication challenges",
      "Missing familiar cultural traditions and customs",
      "Feeling misunderstood due to different backgrounds",
      "Struggling with different social norms and expectations",
      "Being away from cultural community and support systems"
    ]
  },
  {
    id: 4,
    title: "Transitional",
    description: "Temporary loneliness during major life transitions:",
    items: [
      "Starting university or changing schools",
      "Moving to a new city or country",
      "Changing majors or career paths",
      "Ending relationships or friendships",
      "Adjusting to new life phases and responsibilities"
    ]
  }
];

function LonelinessTypesSection() {
  const [activeCard, setActiveCard] = useState<number | null>(null);

  const handleCardClick = (cardIndex: number) => {
    setActiveCard(activeCard === cardIndex ? null : cardIndex);
  };

  return (
    <div className="loneliness-types-section">
      <h3>Types of Loneliness</h3>
      <p>
        Everyone's experience of loneliness is unique. Below are the most
        common forms students face—whether you're new on campus, finding it
        hard to connect, or missing a close confidant.
      </p>
      <p className="interaction-hint">(Hover/Tap)</p>
      <div className="loneliness-cards">
        {lonelinessTypes.map((type) => (
          <div
            key={type.id}
            className={`loneliness-card ${activeCard === type.id ? "active" : ""}`}
            onClick={() => handleCardClick(type.id)}
          >
            <h4>{type.title}</h4>
            <div className="card-content">
              <p>{type.description}</p>
              <ul>
                {type.items.map((item, index) => (
                  <li key={index}>{item}</li>
                ))}
              </ul>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

export default LonelinessTypesSection;
