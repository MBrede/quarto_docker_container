FROM rocker/r2u:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    UV_NO_CACHE=1 \
    VIRTUAL_ENV=/workspace/req-venv


RUN apt-get update && apt-get install -y \
    curl \
    git \
    imagemagick \
    python3 \
    python3-pip \
    python3-venv \
    wget \
    pandoc \
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-plain-generic \
    texlive-luatex\
    texlive-latex-base\
    texlive-fonts-extra\
    librsvg2-bin \
    && apt-get install -y wget gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.8.25/quarto-1.8.25-linux-amd64.deb && \
    dpkg -i quarto-1.8.25-linux-amd64.deb && \
    rm quarto-1.8.25-linux-amd64.deb

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin/:$PATH"

WORKDIR /workspace

# Create virtual environment
RUN uv venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN uv pip install jupyter

RUN Rscript -e 'install.packages("stringr", Ncpus = 6)'

COPY collect_python_deps.py /workspace/collect_python_deps.py
COPY collect_r_deps.R /workspace/collect_r_deps.R

RUN chmod +x /workspace/collect_python_deps.py && \
    chmod +x /workspace/collect_r_deps.R



CMD ["/bin/bash"]
