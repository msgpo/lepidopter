#!/bin/bash
set -ex

TOR_DEB_REPO="http://deb.torproject.org/torproject.org"
TOR_DEB_REPO_SRC_LIST="/etc/apt/sources.list.d/tor.list"
TOR_REPO_GPG="A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89"
GPG_KEYSERVER="hkp://keyserver.ubuntu.com"

# Add Torproject Debian repository
apt-key adv --keyserver ${GPG_KEYSERVER} --recv-keys ${TOR_REPO_GPG}
echo "deb ${TOR_DEB_REPO} ${DEB_RELEASE} main" > ${TOR_DEB_REPO_SRC_LIST}
apt-get update

# Install ooniprobe and pluggable transports dependencies
RUNLEVEL=1 apt-get -y install openssl libssl-dev libyaml-dev libffi-dev libpcap-dev tor \
    libgeoip-dev libdumbnet-dev python-dev libgmp-dev openvpn
# Install obfs4proxy (includes a lite version of meek)
apt-get -y install -t stretch obfs4proxy python-pip

# Remove old system versions of python packages pyasn1, cryptography and openssl
apt-get -y remove python-pyasn1 python-cryptography python-openssl
# Install and ooniprobe
pip install txtorcon==0.18.0 fteproxy ooniprobe==2.2.0

# Enable ooniprobe systemd service to start on boot
systemctl enable ooniprobe

# Stop running tor service that can lead to a busy chroot mount
service tor stop

# Disable the OpenVPN unit
systemctl disable openvpn

history -c
