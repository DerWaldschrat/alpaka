#!/bin/bash

#
# Copyright 2017-2019 Benjamin Worpitz
#
# This file is part of alpaka.
#
# alpaka is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# alpaka is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with alpaka.
# If not, see <http://www.gnu.org/licenses/>.
#

source ./script/travis/travis_retry.sh

source ./script/travis/set.sh

: ${ALPAKA_CI_CLANG_DIR?"ALPAKA_CI_CLANG_DIR must be specified"}
: ${ALPAKA_CI_CLANG_VER?"ALPAKA_CI_CLANG_VER must be specified"}
: ${ALPAKA_CI_CLANG_LIBSTDCPP_VERSION?"ALPAKA_CI_CLANG_LIBSTDCPP_VERSION must be specified"}
: ${ALPAKA_CI_STDLIB?"ALPAKA_CI_STDLIB must be specified"}
: ${CXX?"CXX must be specified"}

if [ -z "$(ls -A "${ALPAKA_CI_CLANG_DIR}")" ]
then
    ALPAKA_CLANG_PKG_FILE_NAME=clang+llvm-${ALPAKA_CI_CLANG_VER}-x86_64-linux-gnu-ubuntu-14.04.tar.xz
    travis_retry wget --no-verbose "http://llvm.org/releases/${ALPAKA_CI_CLANG_VER}/${ALPAKA_CLANG_PKG_FILE_NAME}"
    mkdir -p "${ALPAKA_CI_CLANG_DIR}"
    xzcat "${ALPAKA_CLANG_PKG_FILE_NAME}" | tar -xf - --strip 1 -C "${ALPAKA_CI_CLANG_DIR}"
    sudo rm -rf "${ALPAKA_CLANG_PKG_FILE_NAME}"
fi
"${ALPAKA_CI_CLANG_DIR}/bin/llvm-config" --version
export LLVM_CONFIG="${ALPAKA_CI_CLANG_DIR}/bin/llvm-config"

travis_retry sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
travis_retry sudo apt-get -y --quiet update

travis_retry sudo apt-get -y --quiet --allow-unauthenticated --no-install-recommends install libstdc++-"${ALPAKA_CI_CLANG_LIBSTDCPP_VERSION}"-dev
if [ "${ALPAKA_CI_STDLIB}" == "libc++" ]
then
    travis_retry sudo apt-get -y --quiet --allow-unauthenticated --no-install-recommends install libc++-dev
    travis_retry sudo apt-get -y --quiet --allow-unauthenticated --no-install-recommends install libc++abi-dev
fi
travis_retry sudo apt-get -y --quiet --allow-unauthenticated --no-install-recommends install libiomp-dev
sudo update-alternatives --install /usr/bin/clang clang "${ALPAKA_CI_CLANG_DIR}"/bin/clang 50
sudo update-alternatives --install /usr/bin/clang++ clang++ "${ALPAKA_CI_CLANG_DIR}"/bin/clang++ 50
sudo update-alternatives --install /usr/bin/cc cc "${ALPAKA_CI_CLANG_DIR}"/bin/clang 50
sudo update-alternatives --install /usr/bin/c++ c++ "${ALPAKA_CI_CLANG_DIR}"/bin/clang++ 50
# We have to prepend /usr/bin to the path because else the preinstalled clang from usr/bin/local/ is used.
export PATH=${ALPAKA_CI_CLANG_DIR}/bin:${PATH}
if [ -z ${LD_LIBRARY_PATH+x} ]
then
    LD_LIBRARY_PATH=
fi
export LD_LIBRARY_PATH=${ALPAKA_CI_CLANG_DIR}/lib:${LD_LIBRARY_PATH}
if [ -z ${CPPFLAGS+x} ]
then
    CPPFLAGS=
fi
export CPPFLAGS="-I ${ALPAKA_CI_CLANG_DIR}/include/c++/v1 ${CPPFLAGS}"

which "${CXX}"
${CXX} -v
