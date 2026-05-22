# Base image: RStudio + R 4.5.0
FROM rocker/rstudio:4.5.0

# System dependencies
RUN apt-get update && \
    apt-get install -y \
    libcurl4-openssl-dev \
    liblzma-dev \
    libbz2-dev \
    libssl-dev \
    libxml2-dev \
    libhdf5-dev \
    libv8-dev \
    libhdf5-serial-dev \
    hdf5-tools \
    libsodium-dev \
    libglpk40 \
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
    libboost-dev \
    libgeos-dev \
    libproj-dev \
    libmagick++-dev \
    cmake \
    make \
    gcc \
    g++ \
    git \
    patch && \
    rm -rf /var/lib/apt/lists/*

# Core installers
RUN R -e "install.packages(c('BiocManager', 'devtools', 'remotes', 'R.utils'), repos='https://cloud.r-project.org')"

# CRAN packages - general utilities and plotting
RUN R -e "install.packages(c( \
    'tidyverse', 'readr', 'stringi', 'stringr', 'janitor', 'data.table', \
    'rlist', 'seqinr', 'spgs', \
    'ggrepel', 'RColorBrewer', 'viridis', 'cowplot', 'patchwork', \
    'gridExtra', 'UpSetR', 'plotmics', 'pheatmap', 'circlize', \
    'EnhancedVolcano' \
    ), repos='https://cloud.r-project.org')"

# CRAN packages - single-cell ecosystem
RUN R -e "setRepositories(ind = 1:3, addURLs = c('https://r-universe.dev')); \
    install.packages('SeuratObject', repos='https://cloud.r-project.org'); \
    install.packages('Seurat', repos='https://cloud.r-project.org'); \
    install.packages(c('Signac', 'harmony', 'hdf5r'), repos='https://cloud.r-project.org')"

# Seurat v5 extensions
RUN R -e "setRepositories(ind = 1:3, addURLs = c('https://satijalab.r-universe.dev')); \
    install.packages(c('BPCells', 'glmGamPoi'))"

# GitHub / fragile packages installed separately
RUN R -e "remotes::install_github('erocoar/gghalves')"
RUN R -e "remotes::install_github('immunogenomics/presto')"
RUN R -e "remotes::install_github('chris-mcginnis-ucsf/DoubletFinder')"

# Optional, do not block build
RUN R -e "tryCatch(remotes::install_github('satijalab/seurat-wrappers', dependencies = TRUE), error = function(e) message('SeuratWrappers install failed: ', e$message))"

# scRepertoire requirements
RUN R -e "install.packages('gsl', repos='https://cloud.r-project.org')"
RUN R -e "remotes::install_github('BorchLab/scRepertoire')"

# Bioconductor core + bulk + single-cell packages
RUN R -e "BiocManager::install(c( \
    'BiocGenerics', 'SummarizedExperiment', 'SingleCellExperiment', \
    'GenomicRanges', 'IRanges', 'rtracklayer', 'Biostrings', 'BSgenome', \
    'edgeR', 'limma', 'sva', 'tidybulk', \
    'scran', 'scater', 'slingshot', 'monocle3', 'miloR', 'tricycle', 'miQC', 'MAST', \
    'fgsea', 'enrichplot', 'DOSE', 'clusterProfiler', \
    'org.Hs.eg.db', 'org.Mm.eg.db', \
    'TxDb.Hsapiens.UCSC.hg18.knownGene', \
    'TxDb.Mmusculus.UCSC.mm10.knownGene', \
    'ComplexHeatmap', 'InteractiveComplexHeatmap', \
    'ChIPseeker', 'ChIPpeakAnno', 'BiocParallel' \
    ), ask = FALSE, update = FALSE)"

# xgboost dependency for scDblFinder
RUN R -e "install.packages('xgboost', repos='https://cloud.r-project.org')"

# scDblFinder
RUN R -e "BiocManager::install('scDblFinder', ask = FALSE, update = FALSE)"
RUN R -e "library(scDblFinder); packageVersion('scDblFinder')"

# TFBSTools separately
RUN R -e "BiocManager::install('TFBSTools', ask = FALSE, update = FALSE)"

# Force-check/install core packages needed for this image
RUN R -e "install.packages(c('tidyverse', 'rlist', 'seqinr', 'spgs'), repos='https://cloud.r-project.org')"
RUN R -e "remotes::install_github('immunogenomics/presto')"
RUN R -e "BiocManager::install('miQC', ask = FALSE, update = FALSE)"

# Final checks
RUN R -e "library(MAST); packageVersion('MAST')"
RUN R -e "library(Seurat); packageVersion('Seurat')"
RUN R -e "library(scDblFinder); packageVersion('scDblFinder')"

# Create RStudio user
RUN useradd -m -s /bin/bash rstudio_user && \
    echo 'rstudio_user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    chown -R rstudio_user:rstudio_user /home/rstudio_user

EXPOSE 8787
USER rstudio_user
