import Navigation from "../components/layout/Navigation";
import HeroSection from "../components/homepage/HeroSection";
import AboutSection from "../components/homepage/AboutSection";
import FeaturesSection from "../components/homepage/FeaturesSection";
import FindingHomeSection from "../components/homepage/FindingHomeSection";
import StudentStoriesSection from "../components/homepage/StudentStoriesSection";
import RegisterNowSection from "../components/homepage/RegisterNowSection";
import ContactSection from "../components/homepage/ContactSection";
import Footer from "../components/layout/Footer";

function HomePage() {
  return (
    <>
      <Navigation />
      <div className="app-container">
        <HeroSection />
        <section className="about-section">
          <AboutSection />
        </section>{" "}
        <FeaturesSection />
        <FindingHomeSection />
        <StudentStoriesSection />
        <RegisterNowSection />
        <ContactSection />
      </div>
      <Footer />
    </>
  );
}

export default HomePage;
