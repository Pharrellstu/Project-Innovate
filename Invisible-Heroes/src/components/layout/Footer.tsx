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

// Social media icons data
const socialIcons = [
  {
    name: "Facebook",
    href: "https://facebook.com",
    icon: (
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="28"
        height="25"
        viewBox="0 0 28 25"
        className="socialIcon"
        fill="none"
      >
        <path
          d="M27.2285 12.5758C27.2285 5.63 21.1339 0 13.6143 0C6.09466 0 0 5.63 0 12.5758C0 18.8542 4.97738 24.0567 11.4868 25V16.2117H8.0306V12.575H11.4868V9.805C11.4868 6.65333 13.519 4.91167 16.6294 4.91167C18.1179 4.91167 19.6772 5.1575 19.6772 5.1575V8.2525H17.959C16.2681 8.2525 15.7417 9.2225 15.7417 10.2175V12.5758H19.5174L18.9139 16.2108H15.7417V25C22.2512 24.0567 27.2285 18.8542 27.2285 12.5758Z"
          fill="#DEDEE0"
        />
      </svg>
    ),
  },
  {
    name: "LinkedIn",
    href: "https://linkedin.com",
    icon: (
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="26"
        height="23"
        viewBox="0 0 26 23"
        fill="none"
        className="socialIcon"
      >
        <path
          d="M25.5511 1.69118V21.3088C25.5511 21.7573 25.3571 22.1875 25.0116 22.5047C24.6662 22.8218 24.1977 23 23.7092 23H2.34279C1.85427 23 1.38577 22.8218 1.04034 22.5047C0.694914 22.1875 0.500854 21.7573 0.500854 21.3088L0.500854 1.69118C0.500854 1.24265 0.694914 0.812491 1.04034 0.495334C1.38577 0.178177 1.85427 0 2.34279 0L23.7092 0C24.1977 0 24.6662 0.178177 25.0116 0.495334C25.3571 0.812491 25.5511 1.24265 25.5511 1.69118ZM7.86858 8.79412H4.18472V19.6176H7.86858V8.79412ZM8.20012 5.07353C8.20207 4.81768 8.1491 4.56399 8.04426 4.32693C7.93941 4.08988 7.78474 3.87411 7.58907 3.69194C7.3934 3.50977 7.16056 3.36478 6.90386 3.26523C6.64716 3.16568 6.37161 3.11353 6.09296 3.11176H6.02665C5.45997 3.11176 4.91651 3.31845 4.51581 3.68635C4.11512 4.05425 3.89001 4.55324 3.89001 5.07353C3.89001 5.59382 4.11512 6.0928 4.51581 6.4607C4.91651 6.82861 5.45997 7.03529 6.02665 7.03529C6.30532 7.04159 6.58261 6.9974 6.84268 6.90527C7.10275 6.81313 7.3405 6.67485 7.54234 6.49832C7.74419 6.3218 7.90617 6.11048 8.01903 5.87646C8.1319 5.64243 8.19343 5.39028 8.20012 5.13441V5.07353ZM21.8673 13.0423C21.8673 9.78853 19.6127 8.52353 17.3729 8.52353C16.6396 8.48981 15.9094 8.63322 15.2553 8.93946C14.6011 9.2457 14.0459 9.70406 13.6449 10.2688H13.5417V8.79412H10.0789V19.6176H13.7628V13.8609C13.7095 13.2713 13.9118 12.6862 14.3256 12.2328C14.7395 11.7793 15.3315 11.4941 15.9731 11.4391H16.1131C17.2845 11.4391 18.1539 12.1156 18.1539 13.8203V19.6176H21.8378L21.8673 13.0423Z"
          fill="#DEDEE0"
        />
      </svg>
    ),
  },
  {
    name: "Instagram",
    href: "https://instagram.com",
    icon: (
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="26"
        height="22"
        viewBox="0 0 26 22"
        className="socialIcon"
        fill="none"
      >
        <path
          fillRule="evenodd"
          clipRule="evenodd"
          d="M8.7962 7.003C10.0035 5.94267 11.6411 5.34698 13.3485 5.34698C15.0559 5.34698 16.6934 5.94267 17.9008 7.003C19.1081 8.06333 19.7864 9.50144 19.7864 11.001C19.7864 12.5005 19.1081 13.9386 17.9008 14.999C16.6934 16.0593 15.0559 16.655 13.3485 16.655C11.6411 16.655 10.0035 16.0593 8.7962 14.999C7.58886 13.9386 6.91058 12.5005 6.91058 11.001C6.91058 9.50144 7.58886 8.06333 8.7962 7.003ZM11.7492 14.3919C12.2562 14.5764 12.7997 14.6713 13.3485 14.6713C14.4569 14.6713 15.5199 14.2846 16.3036 13.5963C17.0874 12.908 17.5277 11.9744 17.5277 11.001C17.5277 10.0275 17.0874 9.09398 16.3036 8.40566C15.5199 7.71734 14.4569 7.33064 13.3485 7.33064C12.7997 7.33064 12.2562 7.42558 11.7492 7.61003C11.2421 7.79448 10.7814 8.06484 10.3933 8.40566C10.0053 8.74648 9.69743 9.1511 9.4874 9.5964C9.27737 10.0417 9.16928 10.519 9.16928 11.001C9.16928 11.483 9.27737 11.9602 9.4874 12.4056C9.69743 12.8509 10.0053 13.2555 10.3933 13.5963C10.7814 13.9371 11.2421 14.2075 11.7492 14.3919Z"
          fill="#DEDEE0"
        />
        <path
          d="M21.2136 6.18936C21.499 5.93872 21.6593 5.59877 21.6593 5.24431C21.6593 4.88985 21.499 4.54991 21.2136 4.29926C20.9282 4.04862 20.5411 3.90781 20.1375 3.90781C19.7339 3.90781 19.3468 4.04862 19.0615 4.29926C18.7761 4.54991 18.6157 4.88985 18.6157 5.24431C18.6157 5.59877 18.7761 5.93872 19.0615 6.18936C19.3468 6.44 19.7339 6.58081 20.1375 6.58081C20.5411 6.58081 20.9282 6.44 21.2136 6.18936Z"
          fill="#DEDEE0"
        />
        <path
          fillRule="evenodd"
          clipRule="evenodd"
          d="M8.1848 0.0669764C9.52081 0.0134433 9.94667 0.000976562 13.3485 0.000976562C16.7512 0.000976562 17.1762 0.0141764 18.5114 0.0669764C19.8449 0.12051 20.7567 0.30751 21.5533 0.57811C22.3887 0.854472 23.1455 1.28741 23.7711 1.84678C24.4082 2.39628 24.9012 3.06122 25.2156 3.79524C25.5254 4.49484 25.7375 5.29491 25.7985 6.46604C25.8594 7.63937 25.8736 8.01337 25.8736 11.001C25.8736 13.9886 25.8594 14.3626 25.7985 15.5359C25.7375 16.707 25.5254 17.5071 25.2165 18.2067C24.9018 18.9404 24.4088 19.6051 23.7719 20.1544C23.1457 20.7147 22.3883 21.1474 21.5533 21.4231C20.7567 21.6952 19.8457 21.8814 18.5122 21.935C17.1762 21.9885 16.7503 22.001 13.3485 22.001C9.94667 22.001 9.52081 21.9885 8.1848 21.935C6.85129 21.8814 5.9403 21.6952 5.1437 21.4238C4.30828 21.1475 3.55147 20.7145 2.92592 20.1552C2.28797 19.6052 1.79531 18.94 1.48135 18.2067C1.17156 17.5071 0.959471 16.707 0.898515 15.5359C0.837559 14.3626 0.823364 13.9893 0.823364 11.001C0.823364 8.01264 0.838394 7.63937 0.898515 6.46677C0.959471 5.29564 1.1724 4.49484 1.48052 3.79524C1.7952 3.06154 2.28815 2.39687 2.92508 1.84751C3.55134 1.28724 4.30869 0.854576 5.1437 0.578843C5.9403 0.306777 6.85129 0.12051 8.1848 0.0669764ZM18.4103 2.04698C17.0893 1.99418 16.6927 1.98318 13.3485 1.98318C10.0043 1.98318 9.60766 1.99418 8.28667 2.04698C7.06589 2.09611 6.40289 2.27504 5.96117 2.42611C5.41709 2.60209 4.92488 2.88301 4.52078 3.24818C4.08324 3.63318 3.81103 3.99984 3.58474 4.51318C3.41189 4.90111 3.20898 5.48338 3.15304 6.55551C3.09292 7.71564 3.08039 8.06397 3.08039 11.001C3.08039 13.938 3.09292 14.2863 3.15304 15.4464C3.20898 16.5186 3.41273 17.1008 3.58474 17.4888C3.78525 17.9665 4.1051 18.3988 4.52078 18.7538C4.92493 19.1189 5.41713 19.3998 5.96117 19.5758C6.40289 19.7276 7.06589 19.9058 8.28667 19.955C9.60766 20.0078 10.0034 20.0188 13.3485 20.0188C16.6935 20.0188 17.0893 20.0078 18.4103 19.955C19.6311 19.9058 20.2941 19.7269 20.7358 19.5758C21.2799 19.3999 21.7721 19.119 22.1762 18.7538C22.5919 18.3988 22.9118 17.9666 23.1123 17.4888C23.2851 17.1008 23.488 16.5186 23.5439 15.4464C23.6041 14.2863 23.6166 13.938 23.6166 11.001C23.6166 8.06397 23.6041 7.71564 23.5439 6.55551C23.488 5.48338 23.2843 4.90111 23.1123 4.51318C22.886 3.99984 22.6146 3.63318 22.1762 3.24818C21.7378 2.86391 21.3203 2.62484 20.7358 2.42611C20.2941 2.27431 19.6311 2.09611 18.4103 2.04698Z"
          fill="#DEDEE0"
        />
      </svg>
    ),
  },
  {
    name: "YouTube",
    href: "https://youtube.com",
    icon: (
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="28"
        height="17"
        viewBox="0 0 28 17"
        className="socialIcon"
        fill="none"
      >
        <path
          fillRule="evenodd"
          clipRule="evenodd"
          d="M24.3684 0.513734C25.5394 0.793952 26.4656 1.61905 26.7802 2.66208C27.3569 4.56135 27.3744 8.49999 27.3744 8.49999C27.3744 8.49999 27.3744 12.4542 26.7977 14.3379C26.4831 15.3809 25.5569 16.206 24.3859 16.4863C22.2712 17 13.7601 17 13.7601 17C13.7601 17 5.24904 17 3.13437 16.4863C1.96344 16.206 1.03718 15.3809 0.722602 14.3379C0.145874 12.4386 0.145874 8.49999 0.145874 8.49999C0.145874 8.49999 0.145874 4.56135 0.705125 2.67766C1.0197 1.63461 1.94596 0.809525 3.1169 0.529308C5.23157 0.015564 13.7427 0 13.7427 0C13.7427 0 22.2538 0 24.3684 0.513734ZM18.0943 8.5L11.0338 12.1429V4.85714L18.0943 8.5Z"
          fill="#DEDEE0"
        />
      </svg>
    ),
  },
];

function Footer() {
  return (
    <Fragment>
      <footer className="footerDiv">
        <div className="footerContentDiv">
          <div className="infoDiv">
            <h1 className="headerFooter">{footerData.brandName}</h1>

            <div className="alignmentDiv">
              <div className="leftInfoDiv">
                {footerData.leftLinks.map((link, index) => (
                  <p key={index}>
                    <a href={link.href}>{link.text}</a>
                  </p>
                ))}
              </div>

              <div className="rightInfoDiv">
                {footerData.rightLinks.map((link, index) => (
                  <p key={index}>
                    <a href={link.href}>{link.text}</a>
                  </p>
                ))}
              </div>
            </div>
            <p className="copyrightText">{footerData.copyrightText}</p>
          </div>
        </div>{" "}
        <div className="stayUpdatedDiv">
          <h1 className="stayUpdatedHeadin">{footerData.newsletter.title}</h1>
          <p className="stayUpdatedText">
            {footerData.newsletter.description}
          </p>{" "}
          <div className="emailInputDiv">
            <input
              type="email"
              placeholder="Enter your email"
              className="emailInput"
            />{" "}
            <Button variant="filled" size="small">
              Subscribe
            </Button>
          </div>
          <div className="footerAlignmentDiv">
            <h1 className="followHeader">
              {footerData.newsletter.followTitle}
            </h1>
            <div className="socialMediaIconsDiv">
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
      <footer className="footerDivMobile">
        <div className="footerContentDivMobile">
          <div className="stayUpdatedDivMobile">
            <h1 className="stayUpdatedHeadinMobile">Get in touch</h1>
            <p className="stayUpdatedTextMobile">
              Have questions about CampusLink, need support? Get in touch!
            </p>

            <div className="inputDivMobile">
              <input type="text" placeholder="Name" className="NameInput" />
              <input
                type="email"
                placeholder="Enter your email"
                className="emailInput"
              />
              <input
                type="text"
                placeholder="Subject"
                className="subjectInput"
              />{" "}
              <textarea
                className="messageInput"
                placeholder="Message"
              ></textarea>{" "}
              <Button variant="filled" size="extra-small">
                Send Message
              </Button>
            </div>
          </div>{" "}
          <div className="infoDivMobile">
            <h1 className="headerFooterMobile">{footerData.brandName}</h1>

            <div className="alignmentDivMobile">
              <div className="leftInfoDivMobile">
                {footerData.leftLinks.map((link, index) => (
                  <p key={index}>
                    <a href={link.href}>{link.text}</a>
                  </p>
                ))}
              </div>

              <div className="rightInfoDivMobile">
                {footerData.rightLinks.map((link, index) => (
                  <p key={index}>
                    <a href={link.href}>{link.text}</a>
                  </p>
                ))}
              </div>
            </div>

            <hr />

            <div className="socialMediaIconsDivMobile">
              {socialIcons.map((social, index) => (
                <a key={index} href={social.href} aria-label={social.name}>
                  {social.icon}
                </a>
              ))}
            </div>

            <hr />

            <p className="copyrightText">{footerData.copyrightText}</p>
          </div>
        </div>
      </footer>
    </Fragment>
  );
}

export default Footer;
