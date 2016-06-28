#!/bin/bash

set -x
set -e

mkdir /home/ubuntu/gringo
cd /home/ubuntu/gringo
if [ ! -e clingo ]; then
  curl -L -Ss "http://downloads.sourceforge.net/project/potassco/clingo/4.5.3/clingo-4.5.3-linux-x86_64.tar.gz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fpotassco%2Ffiles%2Fclingo%2F4.5.3%2F&ts=1467123598&use_mirror=heanet" | tar xzf -
  sudo cp -v /home/ubuntu/gringo/clingo-4.5.3-linux-x86_64/clingo /usr/local/bin/clingo
fi
