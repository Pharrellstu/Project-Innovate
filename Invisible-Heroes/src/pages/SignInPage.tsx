import Navigation from "../components/layout/Navigation";
import FooterSimple from "../components/layout/FooterSimple";
import "./css/SignInPage.css";

function SignInPage() {
  return (
    <div className="signInPage">
      <Navigation />
      <div className="content">
        <h1>Sign In</h1>
        <p>Welcome back! Please sign in to your account.</p>
        {/* Sign in form would go here */}
      </div>
      <FooterSimple />
    </div>
  );
}

export default SignInPage;
