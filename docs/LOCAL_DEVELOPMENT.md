# Building Documentation Locally

This guide shows you how to build and preview the MkDocs documentation on your local machine.

## Prerequisites

- Python 3.7 or higher
- pip (Python package manager)

## Installation

### 1. Install Python Dependencies

```powershell
# Install from requirements file
pip install -r requirements.txt
```

Or install individually:

```powershell
pip install mkdocs-material
pip install mkdocs-git-revision-date-localized-plugin
```

## Building Documentation

### Preview Locally

Start a local development server with live reload:

```powershell
mkdocs serve
```

Then open your browser to: `http://127.0.0.1:8000`

The site will automatically reload when you save changes to any documentation file.

### Build Static Site

Generate the static HTML files:

```powershell
mkdocs build
```

The generated site will be in the `site/` directory.

### Clean Build

Remove the `site/` directory and rebuild:

```powershell
# Remove site directory
Remove-Item -Recurse -Force site -ErrorAction SilentlyContinue

# Rebuild
mkdocs build
```

## Deployment

### Deploy to GitHub Pages

The documentation automatically deploys to GitHub Pages when you push to the `master` branch (via GitHub Actions).

To manually deploy:

```powershell
mkdocs gh-deploy
```

This will:
1. Build the documentation
2. Push it to the `gh-pages` branch
3. GitHub Pages will serve it at `https://tsabo.github.io/PowerShell-DevKit/`

## Documentation Structure

```
docs/
├── index.md                  # Home page
├── getting-started/
│   ├── quick-start.md
│   ├── installation.md
│   └── requirements.md
├── components/
│   ├── overview.md
│   ├── oh-my-posh.md
│   ├── yazi.md
│   ├── terminal.md
│   ├── powershell.md
│   └── optional.md
├── scripts/
│   ├── setup.md
│   ├── test.md
│   ├── update.md
│   ├── deploy-terminal.md
│   └── custom.md
├── configuration/
│   ├── customization.md
│   ├── custom-modules.md
│   └── custom-profile.md
├── development/
│   ├── architecture.md
│   ├── contributing.md
│   └── components.md
├── troubleshooting.md
└── faq.md
```

## Writing Documentation

### Markdown Features

MkDocs Material supports:

- **Admonitions** (notes, warnings, tips)
- **Code blocks** with syntax highlighting
- **Tabs** for alternative content
- **Tables**
- **Task lists**
- **Emojis**

### Example Admonitions

```markdown
!!! note
    This is a note

!!! warning
    This is a warning

!!! tip
    This is a tip

!!! example
    This is an example
```

### Example Code Blocks

````markdown
```powershell
# PowerShell code
Get-ChildItem
```

```yaml
# YAML code
key: value
```
````

### Example Tabs

```markdown
=== "Windows"
    Windows-specific content

=== "Linux"
    Linux-specific content
```

## Configuration

The MkDocs configuration is in `mkdocs.yml` at the project root.

Key settings:
- `site_name` - Documentation title
- `theme` - Theme settings (Material)
- `nav` - Navigation structure
- `markdown_extensions` - Enabled markdown features

## Troubleshooting

### Port Already in Use

If port 8000 is in use:

```powershell
mkdocs serve -a localhost:8001
```

### Build Errors

Check for:
- Missing pages referenced in `mkdocs.yml`
- Broken internal links
- Invalid YAML in `mkdocs.yml`

### Live Reload Not Working

- Ensure you saved the file
- Check the terminal for error messages
- Try restarting the dev server

## Resources

- [MkDocs Documentation](https://www.mkdocs.org/)
- [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)
- [Markdown Guide](https://www.markdownguide.org/)
