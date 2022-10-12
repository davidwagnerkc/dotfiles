# syntax=docker/dockerfile:experimental
FROM ubuntu:22.04
SHELL ["/bin/bash", "-l", "-c"]
ENV MAMBA_ROOT_PREFIX="/opt/conda"
ENV MAMBA_EXE=/root/.local/bin/micromamba
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    bzip2 \
    ca-certificates \
    && rm -rf /var/lib/apt /var/lib/dpkg /var/lib/cache /var/lib/log
RUN curl micro.mamba.pm/install.sh | bash
RUN echo 'export MAMBA_ROOT_PREFIX="/opt/conda"' >> ~/.bashrc && \
    echo 'export MAMBA_EXE=/root/.local/bin/micromamba' >> ~/.bashrc && \
    echo 'micromamba activate base' >> ~/.bashrc
COPY env.yml .
RUN --mount=type=cache,id=conda-cache,mode=0777,target=/opt/conda/pkgs \
    --mount=type=cache,id=pip-cache,mode=0777,target=/root/.cache/pip \
    ~/.local/bin/micromamba install -y -n base -f env.yml
CMD ["/bin/bash", "-i", "-l"]
