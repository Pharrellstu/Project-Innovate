import React from "react";
import "./Button.css";

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  children: React.ReactNode;
  variant?: "filled" | "hollow" | "rounded-hollow";
  size?: "extra-small" | "small" | "medium" | "large";
  className?: string;
  icon?: React.ReactNode;
}

const Button: React.FC<ButtonProps> = ({
  children,
  variant = "filled",
  size = "medium",
  className = "",
  icon,
  ...buttonProps
}) => {
  const baseClass = "btn";
  const variantClass = `btn--${variant}`;
  const sizeClass = `btn--${size}`;
  const classes = [baseClass, variantClass, sizeClass, className]
    .filter(Boolean)
    .join(" ");

  return (
    <button className={classes} {...buttonProps}>
      {children}
      {icon && <span className="btn__icon">{icon}</span>}
    </button>
  );
};

export default Button;
