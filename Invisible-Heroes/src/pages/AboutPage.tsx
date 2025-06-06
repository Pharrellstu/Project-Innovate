import { useEffect, useState } from "react";
import Navigation from "../components/Navigation";
import Footer from "../components/Footer";
import "./css/AboutPage.css";

function AboutPage() {
  const [isExpanded, setIsExpanded] = useState(false);
  useEffect(() => {
    const handleScroll = () => {
      const scrollPosition = window.scrollY;
      const triggerPoint = 80; // Trigger after scrolling 80px

      setIsExpanded(scrollPosition > triggerPoint);
    };

    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);
  return (
    <>
      <Navigation />
      <div className="about-page-container">
        <h1>We were new here too!</h1>
        <h2>
          As first-year students in a foreign country, we struggled to belong.
          CampusLink was born from our own search for real connection.
        </h2>
        {/* <img
          src="/src/assets/dummy_image_group_photo.jpg"
          alt="Group photo of the students that brought this project to life"
        /> */}{" "}
        <div className="about-small-section">
          <img
            src="/src/assets/dummy_image_group_photo.jpg"
            alt="Group photo of the students that brought this project to life"
            className={isExpanded ? "expanded" : ""}
          />

          <div className="about-small-section-text">
            <h3>Fitting In Isn’t Easy</h3>
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
        </div>{" "}
        <div className="types-of-loneliness">
          <h3>Types of Loneliness</h3>
          <p>
            Everyone’s experience of loneliness is unique. Below are the most
            common forms students face—whether you’re new on campus, finding it
            hard to connect, or missing a close confidant.
          </p>
          <p>(Hover)</p>
          
          <div className="loneliness-cards">            <div className="loneliness-card">
              <h4>Situational</h4>
              <div className="card-content">
                <p>Feeling isolated due to specific circumstances:</p>
                <ul>
                  <li>Being new to campus or city</li>
                  <li>Living far from family and friends</li>
                  <li>Major life changes like starting university</li>
                  <li>Moving to a different country or culture</li>
                  <li>Temporary separation from loved ones</li>
                </ul>
              </div>
            </div>
              <div className="loneliness-card">
              <h4>Emotional</h4>
              <div className="card-content">
                <p>Missing deep, meaningful connections:</p>
                <ul>
                  <li>Having people around but feeling misunderstood</li>
                  <li>Lacking someone to share personal thoughts with</li>
                  <li>Feeling like no one truly "gets" you</li>
                  <li>Missing intimate friendships or relationships</li>
                  <li>Craving deeper conversations and connections</li>
                </ul>
              </div>
            </div>
              <div className="loneliness-card">
              <h4>Social</h4>
              <div className="card-content">
                <p>Lacking a broader social network:</p>
                <ul>
                  <li>Feeling excluded from groups or communities</li>
                  <li>Struggling to find your social circle</li>
                  <li>Difficulty making casual friendships</li>
                  <li>Missing shared activities and group experiences</li>
                  <li>Not having people to hang out with regularly</li>
                </ul>
              </div>
            </div>
              <div className="loneliness-card">
              <h4>Cultural</h4>
              <div className="card-content">
                <p>Feeling disconnected due to cultural differences:</p>
                <ul>
                  <li>Language barriers and communication challenges</li>
                  <li>Missing familiar cultural traditions and customs</li>
                  <li>Feeling misunderstood due to different backgrounds</li>
                  <li>Struggling with different social norms and expectations</li>
                  <li>Being away from cultural community and support systems</li>
                </ul>
              </div>
            </div>
            
            <div className="loneliness-card">
              <h4>Transitional</h4>
              <div className="card-content">
                <p>Temporary loneliness during major life transitions:</p>
                <ul>
                  <li>Starting university or changing schools</li>
                  <li>Moving to a new city or country</li>
                  <li>Changing majors or career paths</li>
                  <li>Ending relationships or friendships</li>
                  <li>Adjusting to new life phases and responsibilities</li>
                </ul>
              </div>
            </div>
          </div>

        </div>
      </div>
      <Footer />
    </>
  );
}

export default AboutPage;
