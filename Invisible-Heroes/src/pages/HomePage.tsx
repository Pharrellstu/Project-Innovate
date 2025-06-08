import Navigation from "../components/layout/Navigation";
import HeroSection from "../components/homepage/HeroSection";
import AboutSection from "../components/about/AboutSection";
import FeaturesSection from "../components/homepage/FeaturesSection";
import Footer from "../components/layout/Footer";

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
