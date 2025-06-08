import Navigation from "../components/Navigation";
import FooterSimple from "../components/FooterSimple";
import "./css/SignUpPage.css";

function SignUpPage() {
  return (
    <div className="signUpPage">
      <Navigation />
      <div className="content">
        <h1>Sign Up</h1>
        <p>Create your CampusLink account to get started.</p>
        {/* Sign up form would go here */}
      </div>
      <FooterSimple />
    </div>
  );
}

export default SignUpPage;
