import "./App.css";
import Navigation from "./components/Navigation";
import AboutSection from "./components/AboutSection";
import HeroSection from "./components/HeroSection";
import FeaturesSection from "./components/FeaturesSection";

function App() {
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
    </>
  );
}

export default App;
