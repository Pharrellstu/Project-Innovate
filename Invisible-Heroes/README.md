# CampusLink Website

A modern React + TypeScript + Vite web application for connecting campus communities and combating student loneliness.

## Quick Start

### Prerequisites
- **Node.js** (version 18.17.0 or higher) - [Download here](https://nodejs.org/)
- **Git** - [Download here](https://git-scm.com/)

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Invisible-Heroes
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up environment variables**
   ```bash
   # Copy the example environment file
   cp .env.example .env
   
   # Edit .env with your Supabase credentials
   # VITE_SUPABASE_URL=your_supabase_project_url
   # VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. **Start the development server**
   ```bash
   npm run dev
   ```

5. **Open your browser**
   - Navigate to `http://localhost:5173`
   - The app will automatically reload when you make changes

## Available Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start development server |
| `npm run build` | Build for production |
| `npm run preview` | Preview production build |
| `npm run lint` | Run ESLint code quality checks |

## Tech Stack

- **Frontend**: React 19 + TypeScript
- **Build Tool**: Vite
- **Styling**: CSS3 + Bootstrap 5
- **Backend**: Supabase
- **Code Quality**: ESLint + TypeScript

## Project Structure

```
src/
├── components/              # React components
│   ├── homepage/           # Homepage sections
│   ├── about/              # About page components  
│   ├── layout/             # Navigation, Footer, etc.
│   └── ui/                 # Reusable UI components
├── pages/                  # Page components
├── styles/                 # Global CSS and variables
├── lib/                    # Utility functions and configs
├── assets/                 # Images and static files
├── App.tsx                 # Main app component
└── main.tsx               # Entry point
```

## Troubleshooting

### Common Issues

**"npm command not found"**
- Install Node.js from the official website
- Restart your terminal after installation

**"Module not found" errors**
- Run `npm install` to install dependencies
- If issues persist: `rm -rf node_modules package-lock.json && npm install`

**Environment variable errors**
- Make sure `.env` file exists with correct Supabase credentials
- Check that variables start with `VITE_` prefix

**Port already in use**
- Vite will automatically use the next available port
- Or specify a port: `npm run dev -- --port 3000`

## Features

- **Modern UI/UX**: Clean, responsive design
- **Student Stories**: Share and browse campus experiences
- **Real-time Updates**: Powered by Supabase
- **Mobile Optimized**: Works on all devices
- **Accessibility**: Built with web standards

## Development Notes

- This project uses TypeScript for type safety
- CSS follows BEM methodology for consistent styling
- All components are functional components with React hooks
- Environment variables are required for Supabase integration

---

Built with ❤️ for connecting campus communities
