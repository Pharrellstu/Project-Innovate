import React from 'react';
import './LonelinessTypesSectionNew.css';

const LonelinessTypesSectionNew: React.FC = () => {
  const lonelinessTypes = [
    {
      id: 1,
      title: "Social Loneliness",
      description: "Feeling disconnected from others or lacking meaningful relationships",
      color: "#FF6B6B",
      icon: (
        <svg width="40" height="40" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z" fill="currentColor"/>
        </svg>
      )
    },
    {
      id: 2,
      title: "Emotional Loneliness",
      description: "Missing deep emotional connections or intimate bonds with others",
      color: "#4ECDC4",
      icon: (
        <svg width="40" height="40" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z" fill="currentColor"/>
        </svg>
      )
    },
    {
      id: 3,
      title: "Cultural Loneliness",
      description: "Feeling isolated due to cultural differences or being away from familiar environments",
      color: "#45B7D1",
      icon: (
        <svg width="40" height="40" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z" fill="currentColor"/>
        </svg>
      )
    },
    {
      id: 4,
      title: "Academic Loneliness",
      description: "Struggling alone with academic challenges without peer or mentor support",
      color: "#96CEB4",
      icon: (
        <svg width="40" height="40" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M12 3L1 9l4 2.18v6L12 21l7-3.82v-6l2-1.09V17h2V9L12 3zm6.82 6L12 12.72 5.18 9 12 5.28 18.82 9zM17 15.99l-5 2.73-5-2.73v-3.72L12 15l5-2.73v3.72z" fill="currentColor"/>
        </svg>
      )
    }
  ];

  return (
    <section className="loneliness-types-section-new">
      <div className="loneliness-types-container">
        <div className="loneliness-types-header">
          <h2>Understanding Different Types of Loneliness</h2>
          <p>Loneliness affects everyone differently. Recognizing these patterns can help you identify what you're experiencing and find the right support.</p>
        </div>
        
        <div className="loneliness-types-grid">
          {lonelinessTypes.map((type) => (
            <div 
              key={type.id} 
              className="loneliness-type-card"
              style={{ '--accent-color': type.color } as React.CSSProperties}
            >
              <div className="loneliness-type-icon" style={{ color: type.color }}>
                {type.icon}
              </div>
              <h3>{type.title}</h3>
              <p>{type.description}</p>
            </div>
          ))}
        </div>
        
        <div className="loneliness-types-footer">
          <p>Remember: Experiencing loneliness is normal and temporary. You're not alone in feeling alone.</p>
        </div>
      </div>
    </section>
  );
};

export default LonelinessTypesSectionNew;
