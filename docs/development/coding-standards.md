# Coding Standards

## Python
- **Format:** PEP 8 compatibility for style.
- **SQL Operations:** Always use parameterized SQL placeholders (`?`) to prevent injection vulnerabilities.
- **Database Connections:** Always close database connections in a `finally` block or ensure they are closed directly after operations.
- **Error Logging:** Log exceptions gracefully to `server.log` or print logs with timestamps.

## CSS & Styling (Tailwind / DaisyUI)
- **Visual Design:** Rely on predefined DaisyUI CSS class tokens (`stats`, `card bg-base-100`, `table table-zebra`, etc.). Avoid hardcoded inline style attributes in HTML layouts.
- **Aesthetics:** Utilize custom RustDesk primary orange (`#fd6a02`) and accent blue (`#0d6efd`) defined inside `tailwind.config.js`.
- **Responsive Layout:** Ensure sidebar and drawer layouts adapt cleanly to narrow screens using Tailwind's grid breakpoints.
