#!/usr/bin/bash

set -e

################## ARGS ##############################

BIOTOOLS_PATH=~/biotools/

sudo apt-get -y update && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
	unzip \
	default-jre \
	git \
	wget \
	gcc \
	g++ \
	make \
	libdatetime-perl \
	libxml-simple-perl \
	libdigest-md5-perl \
	bioperl \
	python3 \
	python3-pip \
	ncbi-blast+ \
	ncbi-tools-bin

echo yes | cpan
sudo cpan Bio::Perl
sudo cpan Bio::SearchIO::hmmer3

#python
pip3 install setuptools multiqc
sudo ln -s /usr/bin/python3 /usr/bin/python

################## BIOTOOLS ######################

mkdir -p $BIOTOOLS_PATH
cp ./install*.*sh $BIOTOOLS_PATH
cd $BIOTOOLS_PATH

bash install-nextflow.bash
bash install-fastqc.bash
bash install-fastp.bash
bash install-trimmomatic.bash
bash install-spades.bash
bash install-unicycler.bash
bash install-prokka.bash

printf "\n\nInstallation complete!\n\n"
