#!/bin/bash
cd $(dirname $0)

MIN_IOS_VERSION=15.0
LIBICONV_VERSION=1.17

if [ ! -d "libiconv-*" ]; then
    curl -L https://ftp.gnu.org/pub/gnu/libiconv/libiconv-${LIBICONV_VERSION}.tar.gz -o libiconv-${LIBICONV_VERSION}.tar.gz
    tar -xzf libiconv-${LIBICONV_VERSION}.tar.gz
    rm libiconv-${LIBICONV_VERSION}.tar.gz
fi

pushd libiconv-${LIBICONV_VERSION}

HOST="$(uname -m)-apple-darwin"
XCODE_ROOT=$(xcode-select -p)

rm -rf out
mkdir out

function build_iconv() {
    local ARCH=$1
    local IS_SIMULATOR=$2

    if [ "${IS_SIMULATOR}" = "true" ]; then
        export SDKVERSION=$(xcrun -sdk iphonesimulator --show-sdk-version)
        export DEVROOT="${XCODE_ROOT}/Platforms/iPhoneSimulator.platform/Developer"
        export SDKROOT="${DEVROOT}/SDKs/iPhoneSimulator${SDKVERSION}.sdk"
        export CFLAGS="-arch ${ARCH} -pipe -isysroot ${SDKROOT} -mios-simulator-version-min=${MIN_IOS_VERSION}"
        local NAME="iossim"
    else
        export SDKVERSION=$(xcrun -sdk iphoneos --show-sdk-version)
        export DEVROOT="${XCODE_ROOT}/Platforms/iPhoneOS.platform/Developer"
        export SDKROOT="${DEVROOT}/SDKs/iPhoneOS${SDKVERSION}.sdk"
        export CFLAGS="-arch ${ARCH} -pipe -isysroot ${SDKROOT} -mios-version-min=${MIN_IOS_VERSION}"
        local NAME="ios"
    fi
    export LDFLAGS="-arch ${ARCH} -isysroot ${SDKROOT}"
    export CC="$(xcrun -find clang)"
    export CXX="$(xcrun -find clang++)"
    export LIBICONV_PLUG=1
    make clean
    ./configure \
        --host=${HOST} \
        --enable-static \
        --disable-shared \
        --enable-extra-encodings \
        --prefix=$(PWD)/../out/iconv_${ARCH}_${NAME}
    make
    make install
}

build_iconv "arm64" "false"
build_iconv "x86_64" "true"
build_iconv "arm64" "true"

popd
pushd out

mkdir -p iconv_universal_iossim/lib
lipo -create -output iconv_universal_iossim/lib/libiconv.a \
    iconv_x86_64_iossim/lib/libiconv.a \
    iconv_arm64_iossim/lib/libiconv.a

mkdir -p ios/libiconv.framework/Headers
mkdir -p ios/libiconv.framework/Modules
cp ../module.modulemap ios/libiconv.framework/Modules
cp iconv_arm64_ios/include/iconv.h ios/libiconv.framework/Headers
cp iconv_arm64_ios/lib/libiconv.a ios/libiconv.framework/libiconv

mkdir -p iossim/libiconv.framework/Headers
mkdir -p iossim/libiconv.framework/Modules
cp ../module.modulemap iossim/libiconv.framework/Modules
cp iconv_arm64_iossim/include/iconv.h iossim/libiconv.framework/Headers
cp iconv_universal_iossim/lib/libiconv.a iossim/libiconv.framework/libiconv

xcodebuild -create-xcframework \
    -framework ios/libiconv.framework \
    -framework iossim/libiconv.framework \
    -output libiconv.xcframework

popd

