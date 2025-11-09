# Quarto Docker Build and Workflow

This package contains everything needed to build a Docker container for Quarto rendering with automatic dependency collection and a GitHub Actions workflow.

## Files

- **Dockerfile** - Container definition with Quarto, R, Python, and LaTeX for PDF rendering
- **collect_python_deps.py** - Script to automatically detect and install Python packages
- **collect_r_deps.R** - Script to automatically detect and install R packages
- **build-and-push.sh** - Shell script to build and push container to Docker Hub
- **quarto-publish.yml** - GitHub Actions workflow file

## Setup Instructions

### 1. Build and Push the Container

1. Replace `your-dockerhub-username` with your actual Docker Hub username in:
   - `build-and-push.sh`
   - `quarto-publish.yml`

2. Place all files in the same directory

3. Make the build script executable and run it:
   ```bash
   chmod +x build-and-push.sh
   ./build-and-push.sh
   ```

4. Enter your Docker Hub credentials when prompted

### 2. Set Up GitHub Actions

1. Copy `quarto-publish.yml` to `.github/workflows/` in your repository:
   ```bash
   mkdir -p .github/workflows
   cp quarto-publish.yml .github/workflows/
   ```

2. Commit and push to your repository

### 3. Usage

The workflow automatically:
- Triggers on pushes to the `main` branch
- Scans all `.qmd`, `.py`, `.ipynb`, `.R`, `.Rmd` files for package usage
- Installs discovered packages plus those in `requirements.txt` and `DESCRIPTION`
- Renders and publishes to GitHub Pages

## Features

### Automatic Dependency Detection

**Python packages** are detected from:
- `import` statements
- `from ... import` statements
- `requirements.txt` file

**R packages** are detected from:
- `library()` calls
- `require()` calls
- `package::function()` usage
- `DESCRIPTION` file

### PDF Support

The container includes full LaTeX support via texlive-xetex. To render PDFs, ensure your `_quarto.yml` includes:

```yaml
format:
  html: default
  pdf:
    documentclass: scrreprt
```

## Container Contents

- Ubuntu 24.04 base
- R with r2u (fast binary R packages)
- Python 3 with pip and jupyter
- Quarto CLI
- ImageMagick
- Complete LaTeX distribution for PDF rendering
- Pre-installed `stringr` R package

## Troubleshooting

**Container build fails:**
- Ensure Docker is running
- Check internet connection for package downloads

**Dependency detection misses packages:**
- Add them manually to `requirements.txt` (Python) or `DESCRIPTION` (R)

**PDF rendering fails:**
- Check that your document doesn't use specialized LaTeX packages not in texlive-xetex
- Consider adding additional texlive packages to the Dockerfile

## Customization

### Add More System Dependencies

Edit the Dockerfile's first `RUN` command to add apt packages:
```dockerfile
RUN apt-get update && apt-get install -y \
    your-package-here \
    another-package \
    && rm -rf /var/lib/apt/lists/*
```

### Pre-install Common Packages

Add to Dockerfile to speed up workflows:
```dockerfile
RUN /workspace/req-venv/bin/pip install pandas numpy matplotlib
RUN Rscript -e 'install.packages(c("ggplot2", "dplyr"), Ncpus = 6)'
```

### Update Quarto Version

Change the version number in the Dockerfile:
```dockerfile
RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/vX.Y.Z/quarto-X.Y.Z-linux-amd64.deb
```

## License

Customize as needed for your project.
