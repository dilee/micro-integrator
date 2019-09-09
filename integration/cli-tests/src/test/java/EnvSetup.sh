# Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
#
# WSO2 Inc. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.

#!/bin/bash

set -o xtrace

echo "Executing Environment Setup script"
platform=$(uname -s)
bitType=$(arch)

echo "Platform : $platform"
echo "Bittype : $bitType"

#Extract the compressed archive based on the platform and the bitype
extractCompressArchive() {
    echo "Extracting the archive files"

    if [[ "${platform}" == "Linux" && "${bitType}" == "i586" ]]; then
        tar -zxvf wso2mi-cli-$VERSION-linux-i586.tar.gz

    elif [[ "${platform}" == "Linux" && "${bitType}" == "x86_64" ]]; then
        tar -zxvf wso2mi-cli-$VERSION-linux-x64.tar.gz

    elif [[ "${platform}" == "Darwin" && "${bitType}" == "x64"  ]]; then
        tar -zxvf wso2mi-cli-$VERSION-macosx-x64.tar.gz

    elif [[ "${platform}" == "windows" && "${bitType}" == "i586" ]]; then
        tar -zxvf wso2mi-cli-$VERSION-windows-i586.tar.gz

    elif [[ "${platform}" == "windows" && "${bitType}" == "x64" ]]; then
        tar -zxvf wso2mi-cli-$VERSION-windows-x64.tar.gz
    fi
}
#get the product version from the pom file
getPomVersion(){
    VERSION=$(cat pom.xml | grep "^    <version>.*</version>$" | awk -F'[><]' '{print $3}');
    echo "Version : $VERSION"
}

setup(){
#Setting up the CLI environment
#Check if the cli build is available in the location
DIR="../../../cmd/build"
if [ -d "$DIR" ]; then
    echo "CLI build exists. Hence skipping the environment setup phase"
else
    echo "CLI build does not exists. Setting up the environment..."
    #download all the dependencies
    cd ../../../cmd
    go mod vendor
    sleep 10

    #build Micro Integrator CLI
    echo "Build Micro Integrator CLI"
    cd ../

    #get the version from the pom
    getPomVersion
    cd cmd
    ./build.sh -t mi.go -v ${VERSION} -f

    #Extract the compressed archive generated
    echo "Extract the CLI archive "
    pwd
    cd build
    ls
    extractCompressArchive

    #start the application
    cd wso2mi-cli-$VERSION/bin
    mi
    echo "ClI setup Complete"
fi
}

setup
