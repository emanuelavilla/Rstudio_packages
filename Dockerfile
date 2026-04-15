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
    libhdf5-serial-dev \
    hdf5-tools \
    zlib1g-dev \
    gfortran \
    libpng-dev \
    libjpeg-dev \
    libnetcdf-dev \
    libglpk-dev \
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
    patch && \
    rm -rf /var/lib/apt/lists/*

# Core installers
RUN R -e "install.packages(c('BiocManager', 'devtools', 'remotes', 'R.utils'), repos='https://cloud.r-project.org')"

# CRAN packages - general utilities and plotting
RUN R -e "install.packages(c('tidyverse', 'readr', 'stringi', 'stringr', 'janitor', 'data.table','ggrepel', 'RColorBrewer', 'viridis', 'cowplot', 'patchwork', \
'gridExtra', 'UpSetR', 'plotmics', 'pheatmap', 'circlize','EnhancedVolcano'), repos='https://cloud.r-project.org')"

# CRAN packages - single-cell ecosystem
RUN R -e "install.packages(c('Seurat', 'SeuratObject', 'Signac', 'harmony'), repos='https://cloud.r-project.org')"

# Fragile CRAN / GitHub packages installed separately
RUN R -e "install.packages('gghalves', repos='https://cloud.r-project.org')" && \
    R -e "remotes::install_github('immunogenomics/presto')" && \
    R -e "devtools::install_github('hhoeflin/hdf5r')" && \
    R -e "devtools::install_github('constantAmateur/SoupX')" && \
    R -e "remotes::install_github('chris-mcginnis-ucsf/DoubletFinder')" && \
    R -e "remotes::install_github('BorchLab/scRepertoire')" && \
    R -e "devtools::install_github('satijalab/seurat-wrappers')"

# Bioconductor core + bulk + most single-cell packages
RUN R -e "BiocManager::install(c('BiocGenerics', 'SummarizedExperiment', 'SingleCellExperiment','GenomicRanges', 'IRanges', 'rtracklayer', 'Biostrings', 'BSgenome', \
    'edgeR', 'limma', 'sva', 'tidybulk','scran', 'scater', 'slingshot', 'monocle3', 'miloR', 'tricycle','fgsea', 'enrichplot', 'DOSE', 'clusterProfiler', \
    'org.Hs.eg.db', 'org.Mm.eg.db','TxDb.Hsapiens.UCSC.hg18.knownGene','TxDb.Mmusculus.UCSC.mm10.knownGene','ComplexHeatmap', 'InteractiveComplexHeatmap', \
    'ChIPseeker', 'ChIPpeakAnno'), ask = FALSE, update = FALSE)"

# Bioconductor fragile packages installed separately
RUN R -e "BiocManager::install(c('scDblFinder', 'muscat', 'TFBSTools'), ask = FALSE, update = FALSE)"

# Create RStudio user
RUN useradd -m -s /bin/bash rstudio_user && \
    echo 'rstudio_user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    chown -R rstudio_user:rstudio_user /home/rstudio_user

# Expose RStudio Server port
EXPOSE 8787

# Run as non-root user
USER rstudio_user
