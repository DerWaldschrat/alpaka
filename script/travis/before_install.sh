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

source ./script/travis/set.sh

#-------------------------------------------------------------------------------
# Those are set to g++/gcc within the git bash even though they are overwritten in the .travis.yml file.
if [ "$TRAVIS_OS_NAME" = "windows" ]
then
    CXX=cl.exe
    CC=cl.exe
fi

#-------------------------------------------------------------------------------
# gcc
if [ ! -z ${ALPAKA_CI_GCC_VER+x} ]
then
    ALPAKA_CI_GCC_VER_SEMANTIC=( ${ALPAKA_CI_GCC_VER//./ } )
    export ALPAKA_CI_GCC_VER_MAJOR="${ALPAKA_CI_GCC_VER_SEMANTIC[0]}"
    echo ALPAKA_CI_GCC_VER_MAJOR: "${ALPAKA_CI_GCC_VER_MAJOR}"
fi

#-------------------------------------------------------------------------------
# Boost.
ALPAKA_CI_BOOST_BRANCH_MAJOR=${ALPAKA_CI_BOOST_BRANCH:6:1}
echo ALPAKA_CI_BOOST_BRANCH_MAJOR: "${ALPAKA_CI_BOOST_BRANCH_MAJOR}"
ALPAKA_CI_BOOST_BRANCH_MINOR=${ALPAKA_CI_BOOST_BRANCH:8:2}
echo ALPAKA_CI_BOOST_BRANCH_MINOR: "${ALPAKA_CI_BOOST_BRANCH_MINOR}"

#-------------------------------------------------------------------------------
if [ "$TRAVIS_OS_NAME" = "linux" ]
then
    if [ "${ALPAKA_CI_STDLIB}" == "libc++" ]
    then
        if [ "${CXX}" == "g++" ]
        then
            echo "using libc++ with g++ not yet supported."
            exit 1
        fi

        if [ "${ALPAKA_CI_DOCKER_BASE_IMAGE_NAME}" == "ubuntu:14.04" ]
        then
            echo "using libc++ with ubuntu:14.04 not supported."
            exit 1
        fi

        if (( ( ( "${ALPAKA_CI_BOOST_BRANCH_MAJOR}" == 1 ) && ( "${ALPAKA_CI_BOOST_BRANCH_MINOR}" < 65 ) ) || ( "${ALPAKA_CI_BOOST_BRANCH_MAJOR}" < 1 ) ))
        then
            echo "using libc++ with boost < 1.65 is not supported."
            exit 1
        fi
    fi
fi

#-------------------------------------------------------------------------------
# CUDA
export ALPAKA_CI_INSTALL_CUDA="OFF"
if [ "${ALPAKA_ACC_GPU_CUDA_ENABLE}" == "ON" ]
then
    export ALPAKA_CI_INSTALL_CUDA="ON"
fi
if [ "${ALPAKA_ACC_GPU_HIP_ENABLE}" == "ON" ]
then
    if [ "${ALPAKA_HIP_PLATFORM}" == "nvcc" ]
    then
        export ALPAKA_CI_INSTALL_CUDA="ON"
    fi
fi

# GCC-5.5 has broken avx512vlintrin.h in Release mode with NVCC 9.X
#   https://gcc.gnu.org/bugzilla/show_bug.cgi?id=76731
#   https://github.com/tensorflow/tensorflow/issues/10220
if [ "${ALPAKA_CI_INSTALL_CUDA}" == "ON" ]
then
    if [ "${ALPAKA_CUDA_COMPILER}" == "nvcc" ]
    then
        if [ "${CXX}" == "g++" ]
        then
            if (( "${ALPAKA_CI_GCC_VER_MAJOR}" == 5 ))
            then
                if [ "${CMAKE_BUILD_TYPE}" == "Release" ]
                then
                    export CMAKE_BUILD_TYPE=Debug
                fi
            fi
        fi
    fi
fi

#-------------------------------------------------------------------------------
# HIP
export ALPAKA_CI_INSTALL_HIP="OFF"
if [ "${ALPAKA_ACC_GPU_HIP_ENABLE}" == "ON" ]
then
    export ALPAKA_CI_INSTALL_HIP="ON"

    # if platform is nvcc, CUDA part is already processed in this file.
    if [ "${ALPAKA_HIP_PLATFORM}" == "hcc" ]
    then
        echo "HIP(hcc) not supported yet."
        exit 1
    fi
fi

#-------------------------------------------------------------------------------
# TBB
export ALPAKA_CI_INSTALL_TBB="OFF"
if [ ! -z ${ALPAKA_ACC_CPU_B_TBB_T_SEQ_ENABLE+x} ]
then
    if [ "${ALPAKA_ACC_CPU_B_TBB_T_SEQ_ENABLE}" = "ON" ]
    then
        export ALPAKA_CI_INSTALL_TBB="ON"
    fi
else
    # If the variable is not set, the backend will most probably be used by default so we install it.
    export ALPAKA_CI_INSTALL_TBB="ON"
fi

#-------------------------------------------------------------------------------
# Fibers
export ALPAKA_CI_INSTALL_FIBERS="OFF"
if [ ! -z ${ALPAKA_ACC_CPU_B_SEQ_T_FIBERS_ENABLE+x} ]
then
    if [ "${ALPAKA_ACC_CPU_B_SEQ_T_FIBERS_ENABLE}" = "ON" ]
    then
        export ALPAKA_CI_INSTALL_FIBERS="ON"
    fi
else
    # If the variable is not set, the backend will most probably be used by default so we install it.
    export ALPAKA_CI_INSTALL_FIBERS="ON"
fi
