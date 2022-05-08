#!/usr/bin/bash

set -e

wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.9.zip
unzip fastqc_v0.11.9.zip
rm fastqc_v0.11.9.zip
chmod +x $PWD/FastQC/fastqc
sudo ln -s $PWD/FastQC/fastqc /usr/local/bin/fastqc
