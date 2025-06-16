import React from "react";
import Navigation from "../components/layout/Navigation";
import FooterSimple from "../components/layout/FooterSimple";
import "./css/TermsPage.css";

const TermsPage: React.FC = () => {
  return (
    <>
      <Navigation />
      <main className="terms-page">
        <div className="terms-container">
          <header className="terms-header">
            <h1>Terms & Conditions</h1>
            <p className="last-updated">Last updated: June 13, 2025</p>
          </header>

          <div className="terms-content">
            <section className="terms-section">
              <h2>1. Acceptance of Terms</h2>
              <p>
                By accessing and using CampusLink ("the Service"), you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.
              </p>
            </section>

            <section className="terms-section">
              <h2>2. Description of Service</h2>
              <p>
                CampusLink is a social networking platform designed to help university students connect with peers, discover events, and build meaningful relationships within their campus community. Our service includes:
              </p>
              <ul>
                <li>Student profile creation and management</li>
                <li>Event discovery and participation</li>
                <li>Peer matching based on interests and activities</li>
                <li>Campus community forums and discussions</li>
                <li>Study group formation and coordination</li>
              </ul>
            </section>

            <section className="terms-section">
              <h2>3. User Eligibility</h2>
              <p>
                To use CampusLink, you must:
              </p>
              <ul>
                <li>Be at least 18 years old or have reached the age of majority in your jurisdiction</li>
                <li>Be currently enrolled in or affiliated with a recognized educational institution</li>
                <li>Provide accurate and complete registration information</li>
                <li>Maintain the security of your account credentials</li>
                <li>Not create multiple accounts for the same person</li>
              </ul>
            </section>

            <section className="terms-section">
              <h2>4. User Conduct and Responsibilities</h2>
              <p>
                You agree to use CampusLink responsibly and in accordance with these terms. You will not:
              </p>
              <ul>
                <li>Post content that is harmful, threatening, abusive, or discriminatory</li>
                <li>Share false, misleading, or deceptive information</li>
                <li>Harass, bully, or intimidate other users</li>
                <li>Violate any applicable laws or regulations</li>
                <li>Attempt to gain unauthorized access to other accounts or systems</li>
                <li>Use the service for commercial purposes without express permission</li>
                <li>Share personal contact information publicly (phone numbers, addresses)</li>
              </ul>
            </section>

            <section className="terms-section">
              <h2>5. Privacy and Data Protection</h2>
              <p>
                Your privacy is important to us. By using CampusLink, you acknowledge that:
              </p>
              <ul>
                <li>We collect and process personal data as outlined in our Privacy Policy</li>
                <li>You consent to the collection and use of your information for service provision</li>
                <li>We implement appropriate security measures to protect your data</li>
                <li>You have the right to access, modify, or delete your personal information</li>
                <li>We do not sell your personal data to third parties</li>
              </ul>
            </section>

            <section className="terms-section">
              <h2>6. Content Ownership and Licensing</h2>
              <p>
                Regarding content shared on CampusLink:
              </p>
              <ul>
                <li>You retain ownership of content you create and share</li>
                <li>You grant CampusLink a license to use, display, and distribute your content within the platform</li>
                <li>You are responsible for ensuring you have rights to any content you share</li>
                <li>CampusLink reserves the right to remove content that violates these terms</li>
                <li>We respect intellectual property rights and respond to valid copyright claims</li>
              </ul>
            </section>

            <section className="terms-section">
              <h2>7. Service Availability and Modifications</h2>
              <p>
                CampusLink strives to provide reliable service, however:
              </p>
              <ul>
                <li>We do not guarantee uninterrupted or error-free service</li>
                <li>We may temporarily suspend service for maintenance or updates</li>
                <li>We reserve the right to modify, suspend, or discontinue features</li>
                <li>We will provide reasonable notice of significant changes when possible</li>
              </ul>
            </section>

            <section className="terms-section">
              <h2>8. Account Termination</h2>
              <p>
                Either party may terminate the service relationship:
              </p>
              <ul>
                <li>You may delete your account at any time through your profile settings</li>
                <li>We may suspend or terminate accounts that violate these terms</li>
                <li>We may terminate inactive accounts after extended periods of non-use</li>
                <li>Upon termination, your access to the service will cease immediately</li>
              </ul>
            </section>

            <section className="terms-section">
              <h2>9. Limitation of Liability</h2>
              <p>
                To the fullest extent permitted by law:
              </p>
              <ul>
                <li>CampusLink is provided "as is" without warranties of any kind</li>
                <li>We are not liable for any indirect, incidental, or consequential damages</li>
                <li>Our total liability shall not exceed the amount you paid for the service</li>
                <li>You acknowledge that social networking involves inherent risks</li>
                <li>We do not guarantee the accuracy of user-generated content</li>
              </ul>
            </section>

            <section className="terms-section">
              <h2>10. Safety and Security</h2>
              <p>
                Your safety is a priority. We encourage you to:
              </p>
              <ul>
                <li>Meet new connections in public, well-lit places</li>
                <li>Trust your instincts and report suspicious behavior</li>
                <li>Protect your personal information and account credentials</li>
                <li>Use our reporting tools if you encounter inappropriate content</li>
                <li>Block users who make you feel uncomfortable</li>
              </ul>
            </section>

            <section className="terms-section">
              <h2>11. Intellectual Property</h2>
              <p>
                The CampusLink platform, including its design, features, and technology, is protected by intellectual property laws. Users may not:
              </p>
              <ul>
                <li>Copy, modify, or distribute our proprietary technology</li>
                <li>Use our trademarks or branding without permission</li>
                <li>Reverse engineer or attempt to extract source code</li>
                <li>Create derivative works based on our platform</li>
              </ul>
            </section>

            <section className="terms-section">
              <h2>12. Dispute Resolution</h2>
              <p>
                In the event of disputes:
              </p>
              <ul>
                <li>We encourage users to first contact our support team</li>
                <li>Disputes will be governed by the laws of [Your Jurisdiction]</li>
                <li>Any legal proceedings must be brought in the appropriate courts</li>
                <li>We prefer to resolve conflicts through good faith communication</li>
              </ul>
            </section>

            <section className="terms-section">
              <h2>13. Changes to Terms</h2>
              <p>
                We may update these Terms & Conditions from time to time. When we do:
              </p>
              <ul>
                <li>We will post the updated terms on this page</li>
                <li>We will update the "Last updated" date</li>
                <li>For significant changes, we may notify users via email or platform notifications</li>
                <li>Continued use of the service constitutes acceptance of updated terms</li>
              </ul>
            </section>

            <section className="terms-section">
              <h2>14. Contact Information</h2>
              <p>
                If you have questions about these Terms & Conditions, please contact us:
              </p>
              <div className="contact-info">
                <p><strong>Email:</strong> legal@campuslink.com</p>
                <p><strong>Address:</strong> CampusLink Legal Department<br />
                123 University Avenue<br />
                Innovation District<br />
                Tech City, TC 12345</p>
                <p><strong>Phone:</strong> +1 (555) 123-4567</p>
              </div>
            </section>

            <section className="terms-section acknowledgment">
              <h2>15. Acknowledgment</h2>
              <p>
                By using CampusLink, you acknowledge that you have read, understood, and agree to be bound by these Terms & Conditions. These terms constitute a legally binding agreement between you and CampusLink.
              </p>
              <p>
                <strong>Welcome to CampusLink – Let's build meaningful connections together!</strong>
              </p>
            </section>
          </div>
        </div>
      </main>
      <FooterSimple />
    </>
  );
};

export default TermsPage;
