import "./MeetTheTeamSection.css";

function MeetTheTeamSection() {
  return (
    <section className="meet-the-team-section py-5">
      <div className="container">
        {/* Section Header */}
        <div className="row text-center mb-5">
          <div className="col-12">
            <h2 className="section-title">Meet Our Team</h2>
            <p className="text-muted">
              The young minds working together to combat student loneliness
            </p>
          </div>
        </div>        {/* Team Members */}
        <div className="row g-4">
          {/* Team Member 1 - Pharrell */}
          <div className="col-lg-3 col-md-6">
            <div className="team-member text-center p-4">
              <img
                src="src/assets/team/pharrell.jpg"
                alt="Pharrell Buckman"
                className="mb-4 shadow"
              />
              <h5 className="mb-1">Pharrell Buckman</h5>
              <p className="text-muted mb-3">Project Leader</p>
              <p className="small mb-3">
                Ensures the team is on the same path, is working together on the same project and
                progress altogether by providing feedback to the team.
              </p>
              <div className="social-links">
                <a
                  href="https://www.linkedin.com/in/pharrell-buckman-192120368/"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <i className="fab fa-linkedin-in"></i>
                </a>
                <a
                  href="https://github.com/Pharrellstu"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <i className="fab fa-github"></i>
                </a>
              </div>
            </div>
          </div>

          {/* Team Member 2 - Peter */}
          <div className="col-lg-3 col-md-6">
            <div className="team-member text-center p-4">
              <img
                src="src/assets/team/peter.jpg"
                alt="Peter Kapsiar"
                className="mb-4 shadow"
              />
              <h5 className="mb-1">Peter Kapsiar</h5>
              <p className="text-muted mb-3">Co-leader</p>
              <p className="small mb-3">
                Co-Leader in planning and executing projects while coordinating and managing project
                tasks.
              </p>
              <div className="social-links">
                <a
                  href="https://www.linkedin.com/in/peter-kapsiar-630743213/"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <i className="fab fa-linkedin-in"></i>
                </a>
                <a
                  href="https://github.com/pop9459"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <i className="fab fa-github"></i>
                </a>
              </div>
            </div>
          </div>

          {/* Team Member 3 - Alexandros */}
          <div className="col-lg-3 col-md-6">
            <div className="team-member text-center p-4">
              <img
                src="src/assets/team/alex.jpeg"
                alt="Alexandros Karayiannis"
                className="mb-4 shadow"
              />
              <h5 className="mb-1">Alexandros Karayiannis</h5>
              <p className="text-muted mb-3">UI/UX and Quality Manager</p>              <p className="small mb-3">
                Designing intuitive user experiences and ensuring high-quality standards across all project deliverables.
              </p>
              <div className="social-links">
                <a
                  href="https://www.linkedin.com/in/alexandros-karayiannis-5ab1ab2bb/"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <i className="fab fa-linkedin-in"></i>
                </a>
                <a
                  href="https://github.com/AlexMakesC0de"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <i className="fab fa-github"></i>
                </a>
              </div>
            </div>
          </div>

          {/* Team Member 4 - Amir */}
          <div className="col-lg-3 col-md-6">
            <div className="team-member text-center p-4">
              <img
                src="src/assets/team/amir.jpg"
                alt="Amir Ranjbar Maki"
                className="mb-4 shadow"
              />
              <h5 className="mb-1">Amir Ranjbar Maki</h5>
              <p className="text-muted mb-3">Flutter Developer</p>              <p className="small mb-3">
                Building robust mobile applications that connect students through innovative Flutter development.
              </p>
              <div className="social-links">
                <a
                  href="https://www.linkedin.com/in/amir-ranjbar-229774342/"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <i className="fab fa-linkedin-in"></i>
                </a>
                <a
                  href="https://github.com/amirranjbarmaki"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <i className="fab fa-github"></i>
                </a>
              </div>
            </div>
          </div>

          {/* Team Member 5 - Oliver */}
          <div className="col-lg-3 col-md-6">
            <div className="team-member text-center p-4">
              <img
                src="src/assets/team/oliver.jpg"
                alt="Oliver Nemess"
                className="mb-4 shadow"
              />
              <h5 className="mb-1">Oliver Nemess</h5>
              <p className="text-muted mb-3">Flutter Developer</p>              <p className="small mb-3">
                Creating seamless mobile experiences and implementing features that bring students closer together.
              </p>
              <div className="social-links">
                <a
                  href="https://github.com/NemessOliver"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <i className="fab fa-github"></i>
                </a>
                <a
                  href="https://www.instagram.com/oli_nemess/"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <i className="fab fa-instagram"></i>
                </a>
              </div>
            </div>
          </div>

          {/* Team Member 6 - Joey */}
          <div className="col-lg-3 col-md-6">
            <div className="team-member text-center p-4">
              <img
                src="src/assets/team/joey.jpg"
                alt="Joey Harms"
                className="mb-4 shadow"
              />
              <h5 className="mb-1">Joey Harms</h5>
              <p className="text-muted mb-3">Flutter Developer</p>              <p className="small mb-3">
                Developing cross-platform solutions and crafting beautiful mobile interfaces for student connectivity.
              </p>
              <div className="social-links">
                <a
                  href="https://www.linkedin.com/in/joey-harms-6bb73626a/"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <i className="fab fa-linkedin-in"></i>
                </a>
                <a
                  href="https://github.com/JoeyHarms"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <i className="fab fa-github"></i>
                </a>
              </div>
            </div>
          </div>

          {/* Team Member 7 - Nick */}
          <div className="col-lg-3 col-md-6">
            <div className="team-member text-center p-4">
              <img
                src="src/assets/team/nick.jpeg"
                alt="Nick Grahovskis"
                className="mb-4 shadow"
              />
              <h5 className="mb-1">Nick Grahovskis</h5>
              <p className="text-muted mb-3">Database Engineer</p>              <p className="small mb-3">
                Architecting secure and scalable database solutions to store and manage student connections and data.
              </p>
              <div className="social-links">
                <a
                  href="https://github.com/NickGrahovskis"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <i className="fab fa-github"></i>
                </a>
                <a
                  href="https://www.instagram.com/niks_grah/"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <i className="fab fa-instagram"></i>
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

export default MeetTheTeamSection;
