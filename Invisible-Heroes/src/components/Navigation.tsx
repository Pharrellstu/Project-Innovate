import { Fragment } from "react";
import "./css/Navigation.css";


function Navigation() {
    return(
        <Fragment>
            <nav className="navigation">
                <div className="contentDiv">

                    <h1 className="logo">CampusLink</h1>

                <div className="navRight">
                    <ul className="listNavBar">
                        <li className="listNavBarElement"><a href="">About</a></li>
                        <li className="listNavBarElement"><a href="">Features</a></li>
                        <li className="listNavBarElement"><a href="">Contact</a></li>
                    </ul>

                    <button className="signButton">
                        <p>Sign in</p>
                    </button>

                    <button className="downloadButton">
                        <p>Download</p>
                        <svg
                            className="arrowIconNav"
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
                                fill="white"
                            />
                        </svg>
                    </button>
                </div>

                </div>
            </nav>


            { /* Mobile */}

            <nav className="navigationMobile">
                <div className="contentMobileDiv">

                    <h1 className="logoMobile">CampusLink</h1>


                    <input type="checkbox" id="nav-toggle" className="nav-toggle"/>
                    <label htmlFor="nav-toggle" className="nav-toggle-label">
                        <span></span>
                    </label>

                    <div className="mobileMenu">
                        <a href="#">About</a>
                        <a href="#">Features</a>
                        <a href="#">Contact</a>
                        <button className="signButton">
                        <p>Sign in</p>
                        </button>
                        <button className="downloadButton">
                            <p>Download</p>
                            <img src="/public/arrowUp.png" className="arrowImg"/>
                        </button>
                    </div>


                </div>
            </nav>

        </Fragment>
    );

}

export default Navigation;