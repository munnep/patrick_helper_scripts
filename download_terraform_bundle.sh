#!/usr/bin/env bash
#  
#  This script was created by kikitux. 
#  It downloads the latest terraform executable and the latest version of the requested providers. 
#  This can then be used as a terraform bundle in Terraform enterprise. This is an alternative to the Terraform Bundle tool
#  
#  
#  
#
#
which jq wget unzip zip &>/dev/null || echo "err: this script needs jq wget unzip zip"

# download terraform
P=terraform
VERSION=$(curl -sL https://releases.hashicorp.com/${P}/index.json | jq -r '.versions[].version' | sort -V | egrep -v 'ent|beta|rc|alpha' | tail -n1)
bundle=${VERSION}
mkdir -p tmp/
file=${P}_${VERSION}_linux_amd64.zip
sha=${P}_${VERSION}_SHA256SUMS

[ -f ${file} ] || wget -q -O tmp/${file} https://releases.hashicorp.com/${P}/${VERSION}/${file}
[ -f ${sha} ] || wget -q -O tmp/${sha} https://releases.hashicorp.com/${P}/${VERSION}/${sha}

pushd tmp/
grep ${file} ${sha} | shasum  --check - || {
	echo err: shasum for ${file} fail, exiting
	exit 1
}
popd

unzip -o -d . tmp/${file}

# download the provider
for p in null aws; do
  P=terraform-provider-${p}
  VERSION=$(curl -sL https://releases.hashicorp.com/${P}/index.json | jq -r '.versions[].version' | sort -V | egrep -v 'ent|beta|rc|alpha' | tail -n1)

  plugin=plugins/registry.terraform.io/hashicorp/${p}/${VERSION}/linux_amd64
  mkdir -p ${plugin}

  mkdir -p tmp/
  file=${P}_${VERSION}_linux_amd64.zip
  sha=${P}_${VERSION}_SHA256SUMS
  [ -f ${file} ] || wget -q -O tmp/${file} https://releases.hashicorp.com/${P}/${VERSION}/${file}
  [ -f ${sha} ] || wget -q -O tmp/${sha} https://releases.hashicorp.com/${P}/${VERSION}/${sha}

  pushd tmp/
  grep ${file} ${sha} | shasum  --check - || {
	echo err: shasum for ${file} fail, exiting
	exit 1
  }
  popd
  unzip -o -d ${plugin} tmp/${file}

done

# create bundle
zip -r bundle-${bundle}-$(date +%Y%m%d-%H%M).zip terraform plugins

rm -fr plugins/
