import Navigation from "../components/Navigation";
import HeroSection from "../components/HeroSection";
import AboutSection from "../components/AboutSection";
import FeaturesSection from "../components/FeaturesSection";
import Footer from "../components/Footer";

function HomePage() {
  return (
    <>
      <Navigation />
      <div className="app-container">
        <HeroSection />
        <section className="about-section">
          <AboutSection />
        </section>
        <FeaturesSection />
      </div>
      <Footer />
    </>
  );
}

export default HomePage;
