import React from "react";
import Navigation from "../components/layout/Navigation";
import FooterSimple from "../components/layout/FooterSimple";
import "./css/PrivacyPage.css";

const PrivacyPage: React.FC = () => {
  return (
    <>
      <Navigation />
      <main className="privacy-page">
        <div className="privacy-container">
          <header className="privacy-header">
            <h1>Privacy Policy</h1>
            <p className="last-updated">Last updated: June 13, 2025</p>
          </header>

          <div className="privacy-content">
            <section className="privacy-section">
              <h2>1. Information We Collect</h2>
              <p>
                At CampusLink, we collect information to provide better services to our users. We collect information in the following ways:
              </p>
              <ul>
                <li><strong>Account Information:</strong> When you create an account, we collect your name, email address, university affiliation, and profile details.</li>
                <li><strong>Profile Data:</strong> Information you choose to share in your profile, including interests, academic program, and social preferences.</li>
                <li><strong>Usage Data:</strong> How you interact with our platform, including events attended, connections made, and feature usage.</li>
                <li><strong>Communication Data:</strong> Messages and interactions with other users and our support team.</li>
                <li><strong>Device Information:</strong> Technical information about your device, browser, and network connection.</li>
              </ul>
            </section>

            <section className="privacy-section">
              <h2>2. How We Use Your Information</h2>
              <p>
                We use the information we collect to:
              </p>
              <ul>
                <li>Provide and improve our social networking services</li>
                <li>Match you with compatible peers and relevant events</li>
                <li>Facilitate communication between users</li>
                <li>Send you notifications about platform activity and updates</li>
                <li>Ensure platform safety and prevent misuse</li>
                <li>Analyze platform usage to enhance user experience</li>
                <li>Comply with legal obligations and enforce our terms</li>
              </ul>
            </section>

            <section className="privacy-section">
              <h2>3. Information Sharing</h2>
              <p>
                We respect your privacy and limit information sharing to:
              </p>
              <ul>
                <li><strong>Other Users:</strong> Profile information you choose to make visible to other users</li>
                <li><strong>Service Providers:</strong> Third-party companies that help us operate our platform</li>
                <li><strong>Legal Requirements:</strong> When required by law or to protect rights and safety</li>
                <li><strong>Business Transfers:</strong> In case of merger, acquisition, or sale of assets</li>
              </ul>
              <p>
                <strong>We never sell your personal data to advertisers or marketing companies.</strong>
              </p>
            </section>

            <section className="privacy-section">
              <h2>4. Your Privacy Controls</h2>
              <p>
                You have control over your privacy settings:
              </p>
              <ul>
                <li>Choose what information to display in your profile</li>
                <li>Control who can see your profile and contact you</li>
                <li>Manage notification preferences</li>
                <li>Access, update, or delete your personal information</li>
                <li>Download your data or deactivate your account</li>
              </ul>
            </section>

            <section className="privacy-section">
              <h2>5. Data Security</h2>
              <p>
                We implement robust security measures to protect your information:
              </p>
              <ul>
                <li>Encryption of data in transit and at rest</li>
                <li>Regular security audits and vulnerability assessments</li>
                <li>Access controls and authentication requirements</li>
                <li>Employee training on data protection practices</li>
                <li>Incident response procedures for security breaches</li>
              </ul>
            </section>

            <section className="privacy-section">
              <h2>6. Contact Us</h2>
              <p>
                If you have questions about this Privacy Policy, please contact us:
              </p>
              <div className="contact-info">
                <p><strong>Email:</strong> privacy@campuslink.com</p>
                <p><strong>Address:</strong> CampusLink Privacy Team<br />
                123 University Avenue<br />
                Innovation District<br />
                Tech City, TC 12345</p>
              </div>
            </section>
          </div>
        </div>
      </main>
      <FooterSimple />
    </>
  );
};

export default PrivacyPage;
