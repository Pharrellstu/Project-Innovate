import { Fragment } from "react";
import "./FooterSimple.css";

// Simplified footer data for download, sign in, and sign up pages
const simpleFooterData = {
  brandName: "CampusLink",
  links: [
    { text: "About", href: "/about" },
    { text: "Terms & conditions", href: "/terms" },
    { text: "Privacy policy", href: "/privacy" },
    { text: "Support", href: "/support" }
  ],
  copyrightText: "© 2025 CampusLink. All rights reserved."
};

function FooterSimple() {
  return (
    <Fragment>
      <footer className="footerSimple">
        <div className="footerSimpleContent">
          <div className="footerSimpleTop">
            <h2 className="footerSimpleBrand">{simpleFooterData.brandName}</h2>
            <nav className="footerSimpleNav">
              {simpleFooterData.links.map((link, index) => (
                <a key={index} href={link.href} className="footerSimpleLink">
                  {link.text}
                </a>
              ))}
            </nav>
          </div>
          <div className="footerSimpleBottom">
            <p className="footerSimpleCopyright">{simpleFooterData.copyrightText}</p>
          </div>
        </div>
      </footer>
    </Fragment>
  );
}

export default FooterSimple;
