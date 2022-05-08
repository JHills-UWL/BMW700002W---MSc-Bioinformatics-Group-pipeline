#!/bin/bash

set -e

wget http://opengene.org/fastp/fastp
chmod a+x ./fastp
sudo ln $PWD/fastp /usr/local/bin/fastp
