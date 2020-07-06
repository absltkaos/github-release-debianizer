#!/bin/bash
set -e
version="$1"
new_release='false'
proj_root=$(dirname "$0")
proj_root=$(dirname "$proj_root")

cd ${proj_root}

#Clean up any possible old directories, and try to find and download the binary from github
rm -rf docs/
source "${proj_root}/github_project_vars"
cicd/get_release $version > "${proj_root}/debian/changelog"
if [ $? -ne 0 ] ; then
    echo "Failed retrieving releases information!"
    exit 1
fi
cp docs/LICENSE "${proj_root}/debian/copyright"

mkdir -p builds
cp "${proj_root}/debian/changelog" builds/

source "${proj_root}/release.env"
echo "Customizing debian package control files"
cat <<EOF > "${proj_root}/debian/install"
$GITHUB_ASSET_FILE /usr/bin/
EOF
cat <<EOF > "${proj_root}/debian/control"
Source: $PACKAGE_NAME
Section: utils
Priority: optional
Maintainer: Auto Release
Homepage: $GITHUB_URL
Vcs-Git:  $GITHUB_URL
Vcs-Browser: $GITHUB_URL
Standards-Version: 3.9.3
Build-Depends: debhelper (>= 9), dh-systemd, python3

Package: $PACKAGE_NAME
Architecture: any
Depends: \${misc:Depends}
Description: $PACKAGE_DESCRIPTION
EOF

#Build the package
if dpkg-buildpackage -us -uc ; then
    mv ../*.deb ../*.changes ../*.dsc ../*_*.tar.gz builds/
    if ls ../*.buildinfo > /dev/null 2>&1 ; then
        mv ../*.buildinfo builds/
    fi
else
    echo "Package building failed. :-("
    exit 1
fi

#List the files created from building the package
echo "Files built (at ./builds):"
if [ -d "builds/" ] ; then
    ls -l builds/
fi
