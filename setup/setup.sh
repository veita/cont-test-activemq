#!/bin/bash

set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get update -qy
apt-get upgrade -qy
apt-get install -qy sudo locales lsb-release curl gnupg2 less vim default-jre-headless

apt-get autoremove -qy
apt-get clean -qy

# global shell configuration
sed -i 's/# "\\e\[5~": history-search-backward/"\\e\[5~": history-search-backward/g' /etc/inputrc
sed -i 's/# "\\e\[6~": history-search-forward/"\\e\[6~": history-search-forward/g' /etc/inputrc

sed -i 's/SHELL=\/bin\/sh/SHELL=\/bin\/bash/g' /etc/default/useradd

sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /etc/skel/.bashrc

# global vim configuration
sed -i 's/"syntax on/syntax on/g' /etc/vim/vimrc
sed -i 's/"set background=dark/set background=dark/g' /etc/vim/vimrc

# shell settings for root
cat << EOF >> /root/.bashrc
PS1='\[\033[01;33m\](container) \u@\h\[\033[01;34m\] \w \$\[\033[00m\] '

alias l="ls --time-style=long-iso --color=always -laF"
alias ll="ls --time-style=long-iso --color=auto -laF"
alias ls="ls --time-style=long-iso --color=auto"
alias g="grep --exclude-dir .git --exclude-dir .svn --color=always"
alias o="less -r"
alias s="screen"
alias t="screen -dr || screen"
alias v="vim"
alias ..="cd .."
alias ...="cd ../.."
EOF

# vim settings for root
echo 'set mouse-=a' > /root/.vimrc

# set password 'admin' for the root user
echo 'root:admin' | chpasswd

# install and configure ActiveMQ
mkdir /opt/tmp
tar -C /opt/tmp -xzf /opt/archive.tar.gz
mv /opt/tmp/* /opt/activemq
rm /opt/archive.tar.gz
rmdir /opt/tmp

useradd -r -M -d /opt/activemq activemq
shopt -s dotglob
cp /etc/skel/* /opt/activemq
chown -R activemq:activemq /opt/activemq

sed -i 's|<property name="host" value="127.0.0.1"/>|<property name="host" value="0.0.0.0"/>|g' /opt/activemq/conf/jetty.xml
