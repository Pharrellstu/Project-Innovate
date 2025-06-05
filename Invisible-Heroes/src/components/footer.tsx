import { Fragment } from "react";
import "../css/footer.css"



function Footer() {
    return(
        <Fragment>
            <footer className="footerDiv">
                <div className="footerContentDiv">

                    <div className="infoDiv">
                        <h1 className="headerFooter">CampusLink</h1>

                        <div className="allignmentDiv">
                            <div className="leftInfoDiv">
                                <p><a href="">About</a></p>
                                <p><a href="">Features</a></p>
                                <p><a href="">Sign up</a></p>
                                <p><a href="">Get the app</a></p>
                                <p><a href="">FAQ</a></p>
                            </div>

                            <div className="rightInfoDiv">
                                <p><a href="">Terms & conditions</a></p>
                                <p><a href="">Privacy policy </a></p>
                                <p><a href="">Cookie policy</a></p>
                            </div>
                        </div>
                        <p className="copyrightText">© 2025 CampusLink. All rights reserved.</p>

                    </div>
                </div>

                <div className="stayUpdatedDiv">
                    <h1 className="stayUpdatedHeadin">Stay updated</h1>
                    <p className="stayUpdatedText">Subscribe for event updates & exclusive content.</p>

                    <div className="emailInputDiv">
                        <input type="email" placeholder="Enter your email" className="emailInput"/>
                        <button className="subscribeButton">Subscribe</button>
                    </div>

                    <div className="footerAllignmentDiv">
                        <h1 className="followHeader">Follow us</h1>
                        <div className="socialMediaIconsDiv">
                            <a href=""><img src="/public/facebook.svg" alt="Facebook" className="socialIcon"/></a>
                            <a href=""><img src="/public/instagram.svg" alt="Instagram" className="socialIcon"/></a>
                            <a href=""><img src="/public/linkedin.svg" alt="LinkedIn" className="socialIcon"/></a>
                            <a href=""><img src="/public/youtube.svg" alt="Twitter" className="socialIcon"/></a>
                        </div>
                    </div>


                </div>

            </footer>

            { /*Mobile */}

            <footer className="footerDivMobile">
                <div className="footerContentDivMobile">

                    <div className="stayUpdatedDivMobile">
                        <h1 className="stayUpdatedHeadinMobile">Get in touch</h1>
                        <p className="stayUpdatedTextMobile">Have questions about CampusLink, need support? Get in touch!</p>

                        <div className="inputDivMobile">
                            <input type="text" placeholder="Name" className="NameInput"/>
                            <input type="email" placeholder="Enter your email" className="emailInput"/>
                            <input type="text" placeholder="Subject" className="subjectInput"/>

                            <textarea className="messageInput" placeholder="Message"></textarea>

                            <button className="messageButton">Send Message</button>
                        </div>


                    </div>

                    <div className="infoDivMobile">
                        <h1 className="headerFooterMobile">CampusLink</h1>

                        <div className="allignmentDivMobile">
                            <div className="leftInfoDivMobile">
                                <p><a href="">About</a></p>
                                <p><a href="">Features</a></p>
                                <p><a href="">Sign up</a></p>
                                <p><a href="">Get the app</a></p>
                                <p><a href="">FAQ</a></p>
                            </div>

                            <div className="rightInfoDivMobile">
                                <p><a href="">Terms & conditions</a></p>
                                <p><a href="">Privacy policy </a></p>
                                <p><a href="">Cookie policy</a></p>
                            </div>
                        </div>

                        <hr/>

                        <div className="socialMediaIconsDivMobile">
                            <a href=""><img src="/public/facebook.svg" alt="Facebook" className="socialIcon"/></a>
                            <a href=""><img src="/public/instagram.svg" alt="Instagram" className="socialIcon"/></a>
                            <a href=""><img src="/public/linkedin.svg" alt="LinkedIn" className="socialIcon"/></a>
                            <a href=""><img src="/public/youtube.svg" alt="Twitter" className="socialIcon"/></a>
                        </div>

                        <hr/>

                        <p className="copyrightText">© 2025 CampusLink</p>

                    </div>
                </div>
            </footer>
        </Fragment>
    );

}

export default Footer;