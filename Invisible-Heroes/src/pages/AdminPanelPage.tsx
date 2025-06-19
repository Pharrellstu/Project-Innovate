import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { storyService, supabase } from "../lib/supabase";
import type { Story } from "../lib/supabase";
import "./css/AdminPanelPage.css";

function AdminPanelPage() {
  const [stories, setStories] = useState<Story[]>([]);
  const [filter, setFilter] = useState("all");
  const [editingId, setEditingId] = useState<number | null>(null);
  const [editSubject, setEditSubject] = useState("");
  const [editMessage, setEditMessage] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const navigate = useNavigate();

  useEffect(() => {
    // Check if admin is authenticated
    checkAuthentication();
  }, [navigate]);

  const checkAuthentication = async () => {
    try {
      const isAuthenticated = localStorage.getItem("isAdminAuthenticated");
      if (!isAuthenticated) {
        navigate("/admin-login");
        return;
      }

      // Verify Supabase session is still valid
      const {
        data: { session },
        error,
      } = await supabase.auth.getSession();

      if (error || !session) {
        handleLogout();
        return;
      }

      // Verify user still has admin privileges
      const { data: accountData, error: accountError } = await supabase
        .from("account")
        .select("isadmin")
        .eq("auth_user_id", session.user.id)
        .eq("isadmin", true)
        .single();

      if (accountError || !accountData) {
        handleLogout();
        return;
      }

      // Load stories if authentication is valid
      loadStories();
    } catch (err) {
      console.error("Authentication check failed:", err);
      handleLogout();
    }
  };

  const loadStories = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await storyService.getStories();
      setStories(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load stories");
      console.error("Error loading stories:", err);
    } finally {
      setLoading(false);
    }
  };
  const handleApprove = async (id: number) => {
    try {
      await storyService.updateStory(id, { status: "approved" });
      await loadStories(); // Reload stories from database
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to approve story");
      console.error("Error approving story:", err);
    }
  };
  const handleReject = async (id: number) => {
    try {
      // Rejected messages are instantly deleted
      await storyService.deleteStory(id);
      await loadStories(); // Reload stories from database
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to reject story");
      console.error("Error rejecting story:", err);
    }
  };
  const handleEdit = (id: number, subject: string, message: string) => {
    setEditingId(id);
    setEditSubject(subject);
    setEditMessage(message);
  };
  const handleDelete = async (id: number) => {
    try {
      await storyService.deleteStory(id);
      await loadStories(); // Reload stories from database
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to delete story");
      console.error("Error deleting story:", err);
    }
  };

  const handleSaveEdit = async (id: number) => {
    try {
      await storyService.updateStory(id, {
        subject: editSubject,
        message: editMessage,
      });
      setEditingId(null);
      setEditSubject("");
      setEditMessage("");
      await loadStories(); // Reload stories from database
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to save changes");
      console.error("Error saving story:", err);
    }
  };

  const handleCancelEdit = () => {
    setEditingId(null);
    setEditSubject("");
    setEditMessage("");
  };
  const handleLogout = async () => {
    try {
      await supabase.auth.signOut();
    } catch (error) {
      console.error("Logout error:", error);
    } finally {
      localStorage.removeItem("isAdminAuthenticated");
      localStorage.removeItem("adminAccountId");
      localStorage.removeItem("adminEmail");
      localStorage.removeItem("supabaseSession");
      navigate("/admin-login");
    }
  };

  const filteredStories = stories.filter((story) => {
    if (filter === "all") return true;
    return story.status === filter;
  });

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString("en-US", {
      year: "numeric",
      month: "long",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  return (
    <div className="admin-panel">
      <header className="admin-header">
        <h1>Admin Panel - Story Management</h1>
        <button onClick={handleLogout} className="logout-btn">
          Logout
        </button>
      </header>
      <div className="admin-controls">
        <div className="filter-controls">
          <label>Filter by status:</label>
          <select
            value={filter}
            onChange={(e) => setFilter(e.target.value)}
            className="filter-select"
          >
            {" "}
            <option value="all">All Stories</option>
            <option value="pending">Pending</option>
            <option value="approved">Approved</option>
          </select>
        </div>
        <div className="stats">
          <span className="stat">Total: {stories.length}</span>
          <span className="stat">
            Pending: {stories.filter((s) => s.status === "pending").length}
          </span>
          <span className="stat">
            Approved: {stories.filter((s) => s.status === "approved").length}
          </span>
        </div>
      </div>{" "}
      <div className="stories-container">
        {loading ? (
          <div className="loading-state">
            <p>Loading stories...</p>
          </div>
        ) : error ? (
          <div className="error-state">
            <p>Error: {error}</p>
            <button onClick={loadStories} className="retry-btn">
              Retry
            </button>
          </div>
        ) : filteredStories.length === 0 ? (
          <div className="no-stories">
            <p>No stories found for the selected filter.</p>
          </div>
        ) : (
          filteredStories.map((story) => (
            <div key={story.id} className={`story-card ${story.status}`}>
              <div className="story-header">
                <div className="story-info">
                  {editingId === story.id ? (
                    <input
                      type="text"
                      value={editSubject}
                      onChange={(e) => setEditSubject(e.target.value)}
                      className="edit-subject-input"
                      placeholder="Subject"
                    />
                  ) : (
                    <h3>{story.subject}</h3>
                  )}
                  <p className="date">
                    Submitted: {formatDate(story.submitted_at)}
                  </p>
                </div>
                <div className={`status-badge ${story.status}`}>
                  {story.status.charAt(0).toUpperCase() + story.status.slice(1)}
                </div>
              </div>

              <div className="story-content">
                {editingId === story.id ? (
                  <textarea
                    value={editMessage}
                    onChange={(e) => setEditMessage(e.target.value)}
                    className="edit-message-textarea"
                    placeholder="Message"
                    rows={5}
                  />
                ) : (
                  <p>{story.message}</p>
                )}
              </div>
              <div className="story-actions">
                {editingId === story.id ? (
                  <>
                    <button
                      onClick={() => handleSaveEdit(story.id)}
                      className="save-btn"
                    >
                      Save
                    </button>
                    <button onClick={handleCancelEdit} className="cancel-btn">
                      Cancel
                    </button>
                  </>
                ) : (
                  <>
                    {story.status === "pending" && (
                      <>
                        <button
                          onClick={() =>
                            handleEdit(story.id, story.subject, story.message)
                          }
                          className="edit-btn"
                        >
                          Edit
                        </button>
                        <button
                          onClick={() => handleApprove(story.id)}
                          className="approve-btn"
                        >
                          Approve
                        </button>
                        <button
                          onClick={() => handleReject(story.id)}
                          className="reject-btn"
                        >
                          Reject
                        </button>
                      </>
                    )}{" "}
                    {story.status === "approved" && (
                      <>
                        <button
                          onClick={() =>
                            handleEdit(story.id, story.subject, story.message)
                          }
                          className="edit-btn"
                        >
                          Edit
                        </button>
                        <button
                          onClick={() => handleDelete(story.id)}
                          className="delete-btn"
                        >
                          Delete
                        </button>
                      </>
                    )}
                  </>
                )}
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}

export default AdminPanelPage;
