import { Fragment } from "react";
import Button from "../ui/Button";
import "./Footer.css";

// Footer data structure for better maintainability
const footerData = {
  brandName: "CampusLink",
  leftLinks: [
    { text: "About", href: "/about" },
    { text: "Features", href: "/features" },
    { text: "Sign up", href: "/signup" },
    { text: "Get the app", href: "/app" },
    { text: "FAQ", href: "/faq" },
  ],
  rightLinks: [
    { text: "Terms & conditions", href: "/terms" },
    { text: "Privacy policy", href: "/privacy" },
    { text: "Cookie policy", href: "/cookies" },
  ],
  copyrightText: "© 2025 CampusLink. All rights reserved.",
  newsletter: {
    title: "Stay updated",
    description: "Subscribe for event updates & exclusive content.",
    followTitle: "Follow us",
  },
};

// Social media icons data - using Font Awesome icons like contact section
const socialIcons = [
  {
    name: "Facebook",
    href: "https://facebook.com",
    icon: <i className="fab fa-facebook-f"></i>,
  },
  {
    name: "LinkedIn",
    href: "https://linkedin.com",
    icon: <i className="fab fa-linkedin-in"></i>,
  },
  {
    name: "Instagram",
    href: "https://instagram.com",
    icon: <i className="fab fa-instagram"></i>,
  },
  {
    name: "YouTube",
    href: "https://youtube.com",
    icon: <i className="fab fa-youtube"></i>,
  },
];

function Footer() {
  return (
    <Fragment>
      <footer className="footer-div">
        <div className="footer-content-div">
          <div className="info-div">
            <h1 className="header-footer">{footerData.brandName}</h1>

            <div className="alignment-div">
              <div className="left-info-div">
                {footerData.leftLinks.map((link, index) => (
                  <p key={index}>
                    <a href={link.href}>{link.text}</a>
                  </p>
                ))}
              </div>

              <div className="right-info-div">
                {footerData.rightLinks.map((link, index) => (
                  <p key={index}>
                    <a href={link.href}>{link.text}</a>
                  </p>
                ))}
              </div>
            </div>
            <p className="copyright-text">{footerData.copyrightText}</p>
          </div>
        </div>

        <div className="stay-updated-div">
          <h1 className="stay-updated-heading">
            {footerData.newsletter.title}
          </h1>
          <p className="stay-updated-text">
            {footerData.newsletter.description}
          </p>

          <div className="email-input-div">
            <input
              type="email"
              placeholder="Enter your email"
              className="email-input"
            />
            <Button variant="filled" size="small">
              Subscribe
            </Button>
          </div>

          <div className="footer-alignment-div">
            <h1 className="follow-header">
              {footerData.newsletter.followTitle}
            </h1>
            <div className="social-media-icons-div">
              {socialIcons.map((social, index) => (
                <a key={index} href={social.href} aria-label={social.name}>
                  {social.icon}
                </a>
              ))}
            </div>
          </div>
        </div>
      </footer>

      {/* Mobile Footer */}
      <footer className="footer-div-mobile">
        <div className="footer-content-div-mobile">
          <div className="stay-updated-div-mobile">
            <h1 className="stay-updated-heading-mobile">Get in touch</h1>
            <p className="stay-updated-text-mobile">
              Have questions about CampusLink, need support? Get in touch!
            </p>

            <div className="input-div-mobile">
              <input type="text" placeholder="Name" className="name-input" />
              <input
                type="email"
                placeholder="Enter your email"
                className="email-input"
              />
              <input
                type="text"
                placeholder="Subject"
                className="subject-input"
              />
              <textarea
                className="message-input"
                placeholder="Message"
              ></textarea>
              <Button variant="filled" size="extra-small">
                Send Message
              </Button>
            </div>
          </div>

          <div className="info-div-mobile">
            <h1 className="header-footer-mobile">{footerData.brandName}</h1>

            <div className="alignment-div-mobile">
              <div className="left-info-div-mobile">
                {footerData.leftLinks.map((link, index) => (
                  <p key={index}>
                    <a href={link.href}>{link.text}</a>
                  </p>
                ))}
              </div>

              <div className="right-info-div-mobile">
                {footerData.rightLinks.map((link, index) => (
                  <p key={index}>
                    <a href={link.href}>{link.text}</a>
                  </p>
                ))}
              </div>
            </div>

            <hr />

            <div className="social-media-icons-div-mobile">
              {socialIcons.map((social, index) => (
                <a key={index} href={social.href} aria-label={social.name}>
                  {social.icon}
                </a>
              ))}
            </div>

            <hr />

            <p className="copyright-text">{footerData.copyrightText}</p>
          </div>
        </div>
      </footer>
    </Fragment>
  );
}

export default Footer;
