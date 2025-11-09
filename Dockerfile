FROM rocker/r2u:24.04

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
    librsvg2-bin \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.4.553/quarto-1.4.553-linux-amd64.deb && \
    dpkg -i quarto-1.4.553-linux-amd64.deb && \
    rm quarto-1.4.553-linux-amd64.deb

RUN python3 -m pip install --upgrade pip && \
    pip install jupyter

RUN Rscript -e 'install.packages("stringr", Ncpus = 6)'

COPY collect_python_deps.py /usr/local/bin/collect_python_deps.py
COPY collect_r_deps.R /usr/local/bin/collect_r_deps.R

RUN chmod +x /usr/local/bin/collect_python_deps.py && \
    chmod +x /usr/local/bin/collect_r_deps.R

WORKDIR /workspace

CMD ["/bin/bash"]
