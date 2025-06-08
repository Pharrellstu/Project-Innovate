# CampusLink Website

A modern React + TypeScript + Vite web application for connecting campus communities.

## 🚀 Quick Setup Guide

### Prerequisites
Before you start, make sure you have the following installed:
- **Node.js** (version 18 or higher) - [Download here](https://nodejs.org/)
- **Git** - [Download here](https://git-scm.com/)
- A code editor like **VS Code** - [Download here](https://code.visualstudio.com/)

### Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Invisible-Heroes
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Start the development server**
   ```bash
   npm run dev
   ```
   or
   ```bash
   npm start
   ```

4. **Open your browser**
   - The app will be running at `http://localhost:5173`
   - The page will automatically reload when you make changes

### 📝 Available Scripts

- `npm run dev` or `npm start` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint to check code quality

### 🛠️ Tech Stack

- **React 19** - UI framework
- **TypeScript** - Type safety
- **Vite** - Build tool and dev server
- **Bootstrap 5** - CSS framework
- **ESLint** - Code linting

### 📁 Project Structure

```
src/
├── components/          # React components
│   ├── css/            # Component-specific styles
│   ├── AboutSection.tsx
│   ├── FeaturesSection.tsx
│   ├── Navigation.tsx
│   └── ...
├── styles/             # Global styles
├── App.tsx             # Main app component
└── main.tsx           # Entry point
```

### 🔧 Development Workflow

1. **Pull latest changes**
   ```bash
   git pull origin main
   ```

2. **Create a new branch for your feature**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes and test locally**
   ```bash
   npm run dev
   ```

4. **Commit and push your changes**
   ```bash
   git add .
   git commit -m "Add your descriptive commit message"
   git push origin feature/your-feature-name
   ```

5. **Create a Pull Request** on GitHub

### 🆘 Troubleshooting

#### Common Issues:

**"Command not found: npm"**
- Make sure Node.js is installed and added to your PATH

**"Module not found" errors**
- Run `npm install` to install all dependencies
- Delete `node_modules` folder and `package-lock.json`, then run `npm install` again

**Port already in use**
- The dev server will automatically find an available port
- Or specify a different port: `npm run dev -- --port 3000`

**CSS import errors**
- Make sure CSS file paths are correct relative to the component
- Check that the CSS file exists in the `css/` folder

### 📞 Need Help?

If you run into any issues, feel free to:
- Check existing issues on GitHub
- Ask in the team chat
- Create a new issue with details about the problem

---

Happy coding! 🎉

## Expanding the ESLint configuration

If you are developing a production application, we recommend updating the configuration to enable type-aware lint rules:

```js
export default tseslint.config({
  extends: [
    // Remove ...tseslint.configs.recommended and replace with this
    ...tseslint.configs.recommendedTypeChecked,
    // Alternatively, use this for stricter rules
    ...tseslint.configs.strictTypeChecked,
    // Optionally, add this for stylistic rules
    ...tseslint.configs.stylisticTypeChecked,
  ],
  languageOptions: {
    // other options...
    parserOptions: {
      project: ['./tsconfig.node.json', './tsconfig.app.json'],
      tsconfigRootDir: import.meta.dirname,
    },
  },
})
```

You can also install [eslint-plugin-react-x](https://github.com/Rel1cx/eslint-react/tree/main/packages/plugins/eslint-plugin-react-x) and [eslint-plugin-react-dom](https://github.com/Rel1cx/eslint-react/tree/main/packages/plugins/eslint-plugin-react-dom) for React-specific lint rules:

```js
// eslint.config.js
import reactX from 'eslint-plugin-react-x'
import reactDom from 'eslint-plugin-react-dom'

export default tseslint.config({
  plugins: {
    // Add the react-x and react-dom plugins
    'react-x': reactX,
    'react-dom': reactDom,
  },
  rules: {
    // other rules...
    // Enable its recommended typescript rules
    ...reactX.configs['recommended-typescript'].rules,
    ...reactDom.configs.recommended.rules,
  },
})
```
