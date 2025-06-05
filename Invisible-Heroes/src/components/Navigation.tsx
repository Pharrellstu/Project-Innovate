import "./Navigation.css";
import Button from "./Button";

const Navigation = () => (
  <nav className="navigation">
    <div className="nav-container">
      {/* Logo */}
      <div className="nav-logo">
        <h2>CampusLink</h2>
      </div>
      {/* Navigation Links */}
      <ul className="nav-links">
        <li>
          <a href="#about">About</a>
        </li>
        <li>
          <a href="#features">Features</a>
        </li>
        <li>
          <a href="#contact">Contact</a>
        </li>
      </ul>{" "}
      {/* Action Buttons */}
      <div className="nav-buttons">
        <Button variant="hollow" size="small">
          Sign In
        </Button>
        <Button variant="filled" size="small">
          Download
        </Button>
      </div>
    </div>
  </nav>
);

export default Navigation;
