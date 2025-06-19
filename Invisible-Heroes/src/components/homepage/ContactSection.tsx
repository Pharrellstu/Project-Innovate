import "./ContactSection.css";
import Button from "../ui/Button";
import UniversityLocationMap from "../../assets/UniversityLocation.png"; // Import the map image

function ContactSection() {
  return (
    <div id="contact" className="contact-section">
      <div className="contact-top-section">
        <div className="contact-left-section">
          <h1>We're Here To Connect And Assist You</h1>
          <p>
            Have questions about the summit? Need help with registration? Our
            team is ready to assist you.
          </p>

          <div className="social-information-section">
            <div id="socials-section-1">
              <h2>CONTACT US</h2>
              <p>+31 0591 853 100</p>
            </div>
            <div id="socials-section-2">
              <h2>LOCATION</h2>
              <p>
                NHL Stenden Univesity of Applied Sciences, Emmen, The
                Netherlands
              </p>
            </div>
            <div id="socials-section-3">
              <h2>EMAIL</h2>
              <p>info@campuslink.com</p>
            </div>{" "}
            <div id="socials-section-4">
              <h2>FOLLOW US</h2>
              <div className="social-icons">
                <a href="#" aria-label="Facebook">
                  <i className="fab fa-facebook-f"></i>
                </a>
                <a href="#" aria-label="LinkedIn">
                  <i className="fab fa-linkedin-in"></i>
                </a>
                <a href="#" aria-label="Instagram">
                  <i className="fab fa-instagram"></i>
                </a>
                <a href="#" aria-label="YouTube">
                  <i className="fab fa-youtube"></i>
                </a>
              </div>
            </div>
          </div>
        </div>{" "}
        <div className="contact-right-section">
          <h2>GET IN TOUCH</h2>
          <p>Have questions about CampusLink, need support? Get in touch!</p>

          <form className="contact-form" action="" method="post">
            <div className="form-group">
              <input
                type="text"
                id="name"
                name="name"
                className="form-input"
                placeholder="Name"
                required
              />
            </div>
            <div className="form-group">
              <input
                type="email"
                id="email"
                name="email"
                className="form-input"
                placeholder="Email"
                required
              />
            </div>
            <div className="form-group">
              <input
                type="text"
                id="subject"
                name="subject"
                className="form-input"
                placeholder="Subject"
                required
              />
            </div>
            <div className="form-group">
              <textarea
                id="message"
                name="message"
                className="form-input form-textarea"
                placeholder="Your Message"
                rows={5}
                required
              ></textarea>
            </div>
          </form>
          <Button
            size="medium"
            className="contact-submit-btn"
            onClick={() => console.log("Message sent!")}
          >
            Send Message
          </Button>
        </div>
      </div>

      <div className="contact-bottom-section">
        <img
          src={UniversityLocationMap}
          alt="Map showing NHL Stenden Emmen location"
          className="location-map-image"
        />
      </div>
    </div>
  );
}

export default ContactSection;
