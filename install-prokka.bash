#!/bin/bash

set -e

git clone https://github.com/tseemann/prokka.git
$PWD/prokka/bin/prokka --setupdb
sudo ln -s $PWD/prokka/bin/prokka /usr/local/bin/prokka
