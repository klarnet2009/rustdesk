# Extension Guide

Follow these steps to safely add new views or endpoints to the RustDesk Web Management Panel.

## 1. Adding a New Page View
1. Define the HTML string template variable inside `web_panel/server.py`. Inherit the base template using `{% extends "base" %}`.
2. Ensure components utilize DaisyUI visual classes.
3. Register a new web route inside `server.py` decorated with `@web_login_required`:
   ```python
   @app.route('/my-new-page')
   @web_login_required
   def web_new_page():
       return render_page(NEW_PAGE_HTML, title='New Page', active_page='new_page')
   ```
4. If you introduce new styles or custom CSS classes, compile the stylesheet:
   ```bash
   cd web_panel
   npm run build
   ```

## 2. Extending the Database Schema
1. Modify `init_db()` inside `server.py` to declare new table creation or alter queries.
2. Keep in mind that SQLite is embedded; avoid using features unsupported by SQLite engine versions.
3. Make sure to run `init_db()` on startup to apply migrations.
