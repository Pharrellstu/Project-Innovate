import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { supabase } from "../lib/supabase";
import "./css/AdminLoginPage.css";

function AdminLoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const navigate = useNavigate();
  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError("");

    try {
      // Step 1: Authenticate with Supabase Auth
      const { data: authData, error: authError } =
        await supabase.auth.signInWithPassword({
          email: email,
          password: password,
        });

      if (authError) {
        setError("Invalid email or password");
        return;
      }

      if (!authData.user) {
        setError("Authentication failed");
        return;
      }

      // Step 2: Check if authenticated user is an admin in the account table
      const { data: accountData, error: accountError } = await supabase
        .from("account")
        .select("accountid, email, isadmin, auth_user_id")
        .eq("auth_user_id", authData.user.id)
        .eq("isadmin", true)
        .single();

      if (accountError || !accountData) {
        // Sign out the user since they don't have admin privileges
        await supabase.auth.signOut();
        setError("Access denied. Admin privileges required.");
        return;
      }

      // Step 3: Store authentication info
      localStorage.setItem("isAdminAuthenticated", "true");
      localStorage.setItem("adminAccountId", accountData.accountid.toString());
      localStorage.setItem("adminEmail", accountData.email);
      localStorage.setItem("supabaseSession", JSON.stringify(authData.session));

      // Navigate to admin panel
      navigate("/admin-panel");
    } catch (err) {
      setError("Login failed. Please try again.");
      console.error("Login error:", err);
    } finally {
      setLoading(false);
    }
  };
  return (
    <div className="admin-login-container">
      <form onSubmit={handleLogin} className="login-form">
        <h2>Admin Login</h2>

        {error && <div className="error-message">{error}</div>}

        <div className="form-group">
          <label htmlFor="email">Email</label>
          <input
            type="email"
            id="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            disabled={loading}
            placeholder="name.surname@student.nhlstenden.com"
          />
        </div>
        <div className="form-group">
          <label htmlFor="password">Password</label>
          <input
            type="password"
            id="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            disabled={loading}
          />
        </div>
        <button type="submit" className="login-button" disabled={loading}>
          {loading ? "Logging in..." : "Login"}
        </button>
      </form>
    </div>
  );
}

export default AdminLoginPage;
