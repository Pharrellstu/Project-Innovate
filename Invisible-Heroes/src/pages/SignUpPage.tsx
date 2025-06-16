import Navigation from "../components/layout/Navigation";
import FooterSimple from "../components/layout/FooterSimple";
import Button from "../components/ui/Button";
import "./css/SignUpPage.css";

function SignUpPage() {
  return (
    <div className="signUpPage">
      <Navigation />
      <div className="content">
        <h1>Sign Up</h1>
        <div className="sign-up-form">
          <h2>
            Fill your information below making sure to use your NHL Stenden
            email.
          </h2>
          <form action="" method="POST">
            {" "}
            <div className="form-group">
              <label htmlFor="email">Email</label>
              <input
                type="email"
                id="email"
                name="email"
                placeholder="firstname.lastname@student.nhlstenden.com"
                required
              />
            </div>
            <div className="form-group">
              <label htmlFor="password">Password</label>
              <input type="password" id="password" name="password" required />
            </div>
            <div className="form-group">
              <label htmlFor="confirm-password">Confirm Password</label>
              <input
                type="password"
                id="confirm-password"
                name="confirm-password"
                required
              />{" "}
            </div>
            <p className="alternative-action">
              Already have an account? <a href="/signin">Sign In</a>
            </p>
            <Button type="submit" variant="filled" size="medium">
              Sign Up
            </Button>
          </form>
        </div>
      </div>
      <FooterSimple />
    </div>
  );
}

export default SignUpPage;
