#!/bin/bash

sudo apt-get update && apt-get install -y \
    maven default-jdk
wget http://downloads.lightbend.com/scala/2.11.8/scala-2.11.8.deb && \
    sudo dpkg -i scala-2.11.8.deb && rm scala-2.11.8.deb
  
sudo apt-get -y install python-pip python-dev build-essential
sudo apt-get -y install doxygen
sudo apt-get -y install pandoc
sudo apt-get -y install python-tk

sudo python -m pip install -U pip
sudo pip install sphinx==1.5.1 CommonMark==0.5.4 breathe mock==1.0.1 recommonmark pypandoc
sudo pip install --upgrade requests
