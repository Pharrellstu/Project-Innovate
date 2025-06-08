import Navigation from "../components/Navigation";
import FooterSimple from "../components/FooterSimple";
import Button from "../components/Button";
import "./css/DownloadPage.css";

function DownloadPage() {
  return (
    <div className="downloadPage">
      <Navigation />
      <div className="content">        <div className="left-section">
          <h1>Your next great story starts here</h1>
          <p>
            New friendships, unforgettable memories, and endless possibilities
            await!
          </p>          <Button 
            variant="filled" 
            size="medium"
            className="download-button"
          >
            Download Now!
          </Button>
        </div>

        <div className="right-section">
          <img
            src="/src/assets/iphoneWithMap.jpg"
            alt="Iphone with the CampusLink application running that contains a geographic map of events"
          />
        </div>
      </div>
      <FooterSimple />
    </div>
  );
}

export default DownloadPage;
