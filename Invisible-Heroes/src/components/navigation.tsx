import { Fragment } from "react";
import "../css/Navigation.css";


function Navigation() {
    return(
        <Fragment>
            <nav className="navigation">
                <div className="contentDiv">

                    <h1 className="logo">CampusLink</h1>

                <div className="navRight">
                    <ul className="listNavBar">
                        <li>About</li>
                        <li>Features</li>
                        <li>Contact</li>
                    </ul>

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