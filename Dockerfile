# Base image: RStudio + R 4.5.0
FROM rocker/rstudio:4.5.0

# Reduce parallel compilation to avoid Eigen/Rcpp crashes
ENV MAKEFLAGS="-j1"
ENV CXXFLAGS="-O2"
ENV CXX11FLAGS="-O2"
ENV CXX14FLAGS="-O2"
ENV CXX17FLAGS="-O2"

# System dependencies
RUN apt-get update && \
    apt-get install -y \
    libcurl4-openssl-dev \
    liblzma-dev \
    libbz2-dev \
    libssl-dev \
    libxml2-dev \
    libhdf5-dev \
    libhdf5-serial-dev \
    hdf5-tools \
    zlib1g-dev \
    gfortran \
    libpng-dev \
    libjpeg-dev \
    libnetcdf-dev \
    libglpk-dev \
    libgsl-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libtiff5-dev \
    libfontconfig1-dev \
    libcairo2-dev \
    libxt-dev \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libmagick++-dev \
    cmake \
    make \
    gcc \
    g++ \
    git \
    patch \
    sudo && \
    rm -rf /var/lib/apt/lists/*

# Core installers
RUN R -e "install.packages(c( \
    'BiocManager', \
    'devtools', \
    'remotes', \
    'R.utils' \
    ), repos='https://cloud.r-project.org')"

# Critical compiled dependencies first
RUN R -e "install.packages(c( \
    'RcppEigen', \
    'RSpectra', \
    'uwot', \
    'RcppAnnoy', \
    'FNN', \
    'hdf5r' \
    ), repos='https://cloud.r-project.org')"

# Seurat pinned versions
RUN R -e "remotes::install_version( \
    'SeuratObject', \
    version='5.1.0', \
    repos='https://cloud.r-project.org', \
    upgrade='never' \
    )"

RUN R -e "remotes::install_version( \
    'Seurat', \
    version='5.3.0', \
    repos='https://cloud.r-project.org', \
    upgrade='never' \
    )"

# Verify Seurat installation BEFORE anything else
RUN R -e "ip <- installed.packages(); \
    print(ip[rownames(ip) %in% c('Seurat','SeuratObject'), c('Package','Version')]); \
    library(SeuratObject); \
    library(Seurat); \
    sessionInfo()"

# CRAN packages
RUN R -e "install.packages(c( \
    'tidyverse', \
    'readr', \
    'stringi', \
    'stringr', \
    'janitor', \
    'data.table', \
    'rlist', \
    'seqinr', \
    'spgs', \
    'ggrepel', \
    'RColorBrewer', \
    'viridis', \
    'cowplot', \
    'patchwork', \
    'gridExtra', \
    'UpSetR', \
    'plotmics', \
    'pheatmap', \
    'circlize', \
    'EnhancedVolcano', \
    'gsl', \
    'future', \
    'future.apply' \
    ), repos='https://cloud.r-project.org')"

# Seurat ecosystem extras
RUN R -e "install.packages(c( \
    'Signac', \
    'harmony' \
    ), repos='https://cloud.r-project.org')"

# GitHub packages
RUN R -e "remotes::install_github( \
    'erocoar/gghalves', \
    upgrade='never' \
    )"

RUN R -e "remotes::install_github( \
    'immunogenomics/presto', \
    upgrade='never' \
    )"

RUN R -e "remotes::install_github( \
    'chris-mcginnis-ucsf/DoubletFinder', \
    upgrade='never' \
    )"

# Optional Seurat wrappers
RUN R -e "tryCatch( \
    remotes::install_github( \
        'satijalab/seurat-wrappers', \
        dependencies=FALSE, \
        upgrade='never' \
    ), \
    error=function(e) message('SeuratWrappers install failed: ', e$message) \
    )"

# scRepertoire
RUN R -e "remotes::install_github( \
    'BorchLab/scRepertoire', \
    upgrade='never' \
    )"

# Bioconductor packages
RUN R -e "BiocManager::install(c( \
    'BiocGenerics', \
    'SummarizedExperiment', \
    'SingleCellExperiment', \
    'GenomicRanges', \
    'IRanges', \
    'rtracklayer', \
    'Biostrings', \
    'BSgenome', \
    'edgeR', \
    'limma', \
    'sva', \
    'tidybulk', \
    'scran', \
    'scater', \
    'slingshot', \
    'miloR', \
    'tricycle', \
    'miQC', \
    'fgsea', \
    'enrichplot', \
    'DOSE', \
    'clusterProfiler', \
    'org.Hs.eg.db', \
    'org.Mm.eg.db', \
    'TxDb.Hsapiens.UCSC.hg18.knownGene', \
    'TxDb.Mmusculus.UCSC.mm10.knownGene', \
    'ComplexHeatmap', \
    'InteractiveComplexHeatmap', \
    'ChIPseeker', \
    'ChIPpeakAnno', \
    'BiocParallel', \
    'TFBSTools', \
    'scDblFinder' \
    ), ask=FALSE, update=FALSE)"

# Optional heavy packages separately
RUN R -e "BiocManager::install('monocle3', ask=FALSE, update=FALSE)"

# xgboost
RUN R -e "install.packages('xgboost', repos='https://cloud.r-project.org')"

# Final check
RUN R -e "library(Seurat); \
    library(SeuratObject); \
    library(Signac); \
    library(scDblFinder); \
    packageVersion('Seurat'); \
    packageVersion('SeuratObject'); \
    packageVersion('Signac'); \
    packageVersion('scDblFinder')"

# Create RStudio user
RUN useradd -m -s /bin/bash rstudio_user && \
    echo 'rstudio_user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    chown -R rstudio_user:rstudio_user /home/rstudio_user

EXPOSE 8787

USER rstudio_user
