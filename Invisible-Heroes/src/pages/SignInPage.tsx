import Navigation from "../components/layout/Navigation";
import FooterSimple from "../components/layout/FooterSimple";
import Button from "../components/ui/Button";
import "./css/SignInPage.css";

function SignInPage() {
  return (
    <div className="signInPage">
      <Navigation />
      <div className="content">
        <h1>Sign In</h1>
        <div className="sign-in-form">
          <h2>Hi! Welcome Back. We've missed you.</h2>
          <form action="" method="POST">
            <div className="form-group">
              <label htmlFor="email">Email</label>
              <input type="email" id="email" name="email" required />
            </div>
            <div className="form-group">
              <label htmlFor="password">Password</label>
              <input type="password" id="password" name="password" required />
            </div>            <p className="alternative-action">
              Don't have an account? <a href="/signup">Sign Up</a>
            </p>            <Button type="submit" variant="filled" size="medium">
              Sign In
            </Button>
          </form>
        </div>
      </div>
      <FooterSimple />
    </div>
  );
}

export default SignInPage;
