import { Fragment } from "react";
import { Link, useNavigate, useLocation } from "react-router-dom";
import Button from "../ui/Button";
import "./Navigation.css";

function Navigation() {
  const navigate = useNavigate();
  const location = useLocation();
  const handleFeaturesClick = (e: React.MouseEvent<HTMLAnchorElement>) => {
    e.preventDefault();

    // If we're already on the homepage, just scroll to the features section
    if (location.pathname === "/") {
      const featuresSection = document.getElementById("features");
      if (featuresSection) {
        featuresSection.scrollIntoView({
          behavior: "smooth",
          block: "start",
        });
      }
    } else {
      // If we're on another page, navigate to homepage first, then scroll
      navigate("/");
      // Small delay to allow the page to load before scrolling
      setTimeout(() => {
        const featuresSection = document.getElementById("features");
        if (featuresSection) {
          featuresSection.scrollIntoView({
            behavior: "smooth",
            block: "start",
          });
        }      }, 100);
    }
  };

  const handleContactClick = (e: React.MouseEvent<HTMLAnchorElement>) => {
    e.preventDefault();

    // If we're already on the homepage, just scroll to the contact section
    if (location.pathname === "/") {
      const contactSection = document.getElementById("contact");
      if (contactSection) {
        contactSection.scrollIntoView({
          behavior: "smooth",
          block: "start",
        });
      }
    } else {
      // If we're on another page, navigate to homepage first, then scroll
      navigate("/");
      // Small delay to allow the page to load before scrolling
      setTimeout(() => {
        const contactSection = document.getElementById("contact");
        if (contactSection) {
          contactSection.scrollIntoView({
            behavior: "smooth",
            block: "start",
          });
        }
      }, 100);
    }
  };

  const handleLogoClick = (e: React.MouseEvent<HTMLAnchorElement>) => {
    e.preventDefault();

    // If we're already on the homepage, just scroll to the top
    if (location.pathname === "/") {
      window.scrollTo({
        top: 0,
        behavior: "smooth",
      });
    } else {
      // If we're on another page, navigate to homepage (will scroll to top automatically)
      navigate("/");
    }
  };
  const handleDownloadClick = () => {
    navigate("/download");
  };

  const handleSignInClick = () => {
    navigate("/signin");
  };

  return (
    <Fragment>
      <nav className="navigation">
        <div className="contentDiv">
          {" "}
          <h1 className="logo">
            <a href="/" onClick={handleLogoClick}>
              CampusLink
            </a>
          </h1>
          <div className="navRight">
            <ul className="listNavBar">
              <li className="listNavBarElement">
                <Link to="/about">About</Link>
              </li>{" "}
              <li className="listNavBarElement">
                <a href="#features" onClick={handleFeaturesClick}>
                  Features
                </a>
              </li>              <li className="listNavBarElement">
                <a href="#contact" onClick={handleContactClick}>
                  Contact
                </a>
              </li>
            </ul>{" "}
            <Button
              variant="hollow"
              size="medium"
              className="nav-sign-button"
              onClick={handleSignInClick}
            >
              Sign in
            </Button>
            <Button
              variant="filled"
              size="medium"
              className="nav-download-button"
              onClick={handleDownloadClick}
              icon={
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="17"
                  height="18"
                  viewBox="0 0 17 18"
                  fill="none"
                >
                  <path
                    fillRule="evenodd"
                    clipRule="evenodd"
                    d="M4.89715 1.65427C4.89715 1.01678 5.41394 0.5 6.05142 0.5H15.8457C16.4832 0.5 17 1.01678 17 1.65427V11.4486C17 12.0861 16.4832 12.6028 15.8457 12.6028C15.2082 12.6028 14.6915 12.0861 14.6915 11.4486V4.44092L1.97046 17.1619C1.51969 17.6127 0.788848 17.6127 0.338078 17.1619C-0.112693 16.7112 -0.112693 15.9803 0.338078 15.5295L13.0591 2.80854H6.05142C5.41394 2.80854 4.89715 2.29176 4.89715 1.65427Z"
                    fill="currentColor"
                  />
                </svg>
              }
            >
              Download
            </Button>
          </div>
        </div>
      </nav>

      {/* Mobile */}
      <nav className="navigationMobile">
        <div className="contentMobileDiv">
          {" "}
          <h1 className="logoMobile">
            <a href="/" onClick={handleLogoClick}>
              CampusLink
            </a>
          </h1>
          <input type="checkbox" id="nav-toggle" className="nav-toggle" />
          <label htmlFor="nav-toggle" className="nav-toggle-label">
            <span></span>
          </label>{" "}
          <div className="mobileMenu">
            <Link to="/about">About</Link>
            <a href="#features" onClick={handleFeaturesClick}>
              Features
            </a>
            <a href="#contact" onClick={handleContactClick}>
              Contact
            </a>{" "}
            <Button
              variant="hollow"
              size="medium"
              className="nav-sign-button-mobile"
              onClick={handleSignInClick}
            >
              Sign in
            </Button>
            <Button
              variant="filled"
              size="medium"
              className="nav-download-button-mobile"
              onClick={handleDownloadClick}
              icon={
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="17"
                  height="18"
                  viewBox="0 0 17 18"
                  fill="none"
                >
                  <path
                    fillRule="evenodd"
                    clipRule="evenodd"
                    d="M4.89715 1.65427C4.89715 1.01678 5.41394 0.5 6.05142 0.5H15.8457C16.4832 0.5 17 1.01678 17 1.65427V11.4486C17 12.0861 16.4832 12.6028 15.8457 12.6028C15.2082 12.6028 14.6915 12.0861 14.6915 11.4486V4.44092L1.97046 17.1619C1.51969 17.6127 0.788848 17.6127 0.338078 17.1619C-0.112693 16.7112 -0.112693 15.9803 0.338078 15.5295L13.0591 2.80854H6.05142C5.41394 2.80854 4.89715 2.29176 4.89715 1.65427Z"
                    fill="currentColor"
                  />
                </svg>
              }
            >
              Download
            </Button>
          </div>
        </div>
      </nav>
    </Fragment>
  );
}

export default Navigation;
