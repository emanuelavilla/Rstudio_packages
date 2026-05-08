FROM rocker/rstudio:4.5.0

USER root

ENV DEBIAN_FRONTEND=noninteractive
ENV MAKEFLAGS="-j1"

# ------------------------------------------------------------------
# SYSTEM
# ------------------------------------------------------------------

RUN apt-get update && apt-get install -y \
    sudo \
    git \
    wget \
    curl \
    cmake \
    make \
    gcc \
    g++ \
    gfortran \
    patch \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    liblzma-dev \
    libbz2-dev \
    zlib1g-dev \
    libhdf5-dev \
    libhdf5-serial-dev \
    hdf5-tools \
    libpng-dev \
    libjpeg-dev \
    libtiff5-dev \
    libcairo2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libxt-dev \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libnetcdf-dev \
    libglpk-dev \
    libgsl-dev \
    libmagick++-dev \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------
# CORE INSTALLERS
# ------------------------------------------------------------------

RUN R -e "install.packages(c( \
    'BiocManager', \
    'remotes', \
    'devtools', \
    'pak', \
    'R.utils' \
    ), repos='https://cloud.r-project.org')"

# ------------------------------------------------------------------
# LOW LEVEL COMPILED PACKAGES
# ------------------------------------------------------------------

RUN R -e "install.packages(c( \
    'RcppEigen', \
    'RSpectra', \
    'uwot', \
    'RcppAnnoy', \
    'FNN', \
    'hdf5r', \
    'future', \
    'future.apply' \
    ), repos='https://cloud.r-project.org')"

# ------------------------------------------------------------------
# SEURAT STACK
# ------------------------------------------------------------------

RUN R -e "install.packages(c( \
    'SeuratObject', \
    'Seurat', \
    'Signac', \
    'harmony' \
    ), repos='https://cloud.r-project.org')"

RUN R -e "library(Seurat); library(Signac); sessionInfo()"

# ------------------------------------------------------------------
# CORE CRAN
# ------------------------------------------------------------------

RUN R -e "install.packages(c( \
    'tidyverse', \
    'data.table', \
    'janitor', \
    'stringr', \
    'stringi', \
    'readr', \
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
    'EnhancedVolcano' \
    ), repos='https://cloud.r-project.org')"

# ------------------------------------------------------------------
# GITHUB
# ------------------------------------------------------------------

RUN R -e "remotes::install_github('erocoar/gghalves')"

RUN R -e "remotes::install_github('immunogenomics/presto')"

RUN R -e "remotes::install_github('chris-mcginnis-ucsf/DoubletFinder')"

RUN R -e "tryCatch( \
    remotes::install_github('satijalab/seurat-wrappers', dependencies=FALSE), \
    error=function(e) message(e$message) \
    )"

RUN R -e "remotes::install_github('BorchLab/scRepertoire')"

# ------------------------------------------------------------------
# BIOCONDUCTOR CORE
# ------------------------------------------------------------------

RUN R -e "BiocManager::install(c( \
    'BiocParallel', \
    'SummarizedExperiment', \
    'SingleCellExperiment', \
    'GenomicRanges', \
    'IRanges', \
    'rtracklayer', \
    'Biostrings', \
    'BSgenome' \
    ), ask=FALSE, update=FALSE)"

# ------------------------------------------------------------------
# BULK RNA
# ------------------------------------------------------------------

RUN R -e "BiocManager::install(c( \
    'edgeR', \
    'limma', \
    'sva', \
    'tidybulk' \
    ), ask=FALSE, update=FALSE)"

# ------------------------------------------------------------------
# SINGLE CELL ADVANCED
# ------------------------------------------------------------------

RUN R -e "BiocManager::install(c( \
    'scran', \
    'scater', \
    'slingshot', \
    'miloR', \
    'tricycle', \
    'miQC', \
    'scDblFinder' \
    ), ask=FALSE, update=FALSE)"

# monocle3 alone
RUN R -e "BiocManager::install('monocle3', ask=FALSE, update=FALSE)"

# ------------------------------------------------------------------
# ENRICHMENT
# ------------------------------------------------------------------

RUN R -e "BiocManager::install(c( \
    'fgsea', \
    'clusterProfiler', \
    'enrichplot', \
    'DOSE' \
    ), ask=FALSE, update=FALSE)"

# ------------------------------------------------------------------
# ANNOTATION
# ------------------------------------------------------------------

RUN R -e "BiocManager::install(c( \
    'org.Hs.eg.db', \
    'org.Mm.eg.db', \
    'TxDb.Hsapiens.UCSC.hg18.knownGene', \
    'TxDb.Mmusculus.UCSC.mm10.knownGene' \
    ), ask=FALSE, update=FALSE)"

# ------------------------------------------------------------------
# HEATMAP / CHIP
# ------------------------------------------------------------------

RUN R -e "BiocManager::install(c( \
    'ComplexHeatmap', \
    'InteractiveComplexHeatmap', \
    'ChIPseeker', \
    'ChIPpeakAnno', \
    'TFBSTools' \
    ), ask=FALSE, update=FALSE)"

# ------------------------------------------------------------------
# FINAL CHECK
# ------------------------------------------------------------------

RUN R -e "library(Seurat); \
library(Signac); \
library(SeuratWrappers); \
library(DoubletFinder); \
library(scRepertoire); \
library(scDblFinder); \
library(monocle3); \
library(miloR); \
library(tricycle); \
library(ComplexHeatmap); \
sessionInfo()"

# ------------------------------------------------------------------
# USER
# ------------------------------------------------------------------

RUN useradd -m -s /bin/bash rstudio_user && \
    echo 'rstudio_user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER rstudio_user

EXPOSE 8787
