import Navigation from "../components/layout/Navigation";
import Footer from "../components/layout/Footer";
import AboutHeroSection from "../components/about/AboutHeroSection";
import AboutStorySection from "../components/about/AboutStorySection";
import LonelinessTypesSection from "../components/about/LonelinessTypesSection";
import MeetTheTeamSection from "../components/about/MeetTheTeamSection";
import "./css/AboutPage.css";

function AboutPage() {
  return (
    <>
      <Navigation />{" "}
      <div className="about-page-container">
        <AboutHeroSection />
        <AboutStorySection />
        <LonelinessTypesSection />
        <MeetTheTeamSection />
      </div>
      <Footer />
    </>
  );
}

export default AboutPage;
