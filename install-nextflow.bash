#!/usr/bin/bash

set -e

wget -qO- https://get.nextflow.io | bash
sudo ln -s $PWD/nextflow /usr/local/bin/nextflow
