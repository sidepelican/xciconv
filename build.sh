#!/bin/bash -eux
cd $(dirname $0)

MIN_IOS_VERSION=15.0
MIN_MACOS_VERSION=12.0
LIBICONV_VERSION=1.17
ICONV_DIR="libiconv-${LIBICONV_VERSION}"

if [ ! -d ${ICONV_DIR} ]; then
    curl -L https://ftp.gnu.org/pub/gnu/libiconv/${ICONV_DIR}.tar.gz -o ${ICONV_DIR}.tar.gz
    tar -xzf ${ICONV_DIR}.tar.gz
    rm ${ICONV_DIR}.tar.gz
    patch -c ${ICONV_DIR}/include/iconv.h.in < template/iconv.h.in.patch
fi

HOST="$(uname -m)-apple-darwin"
XCODE_ROOT=$(xcode-select -p)

rm -rf out
mkdir out

pushd ${ICONV_DIR}
function build_iconv() {
    local TARGET=$1
    local ARCH=$2
    case ${TARGET} in
        "ios")
        local SDKROOT="${XCODE_ROOT}/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk"
        export CFLAGS="-arch ${ARCH} -pipe -isysroot ${SDKROOT} -mios-version-min=${MIN_IOS_VERSION}"
        ;;
        "iossim")
        local SDKROOT="${XCODE_ROOT}/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk"
        export CFLAGS="-arch ${ARCH} -pipe -isysroot ${SDKROOT} -mios-simulator-version-min=${MIN_IOS_VERSION}"
        ;;
        "macos")
        local SDKROOT="${XCODE_ROOT}/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
        export CFLAGS="-arch ${ARCH} -pipe -isysroot ${SDKROOT} -mmacosx-version-min=${MIN_MACOS_VERSION}"
        ;;
    esac
    export CPPFLAGS=${CFLAGS}
    export CXXFLAGS=${CFLAGS}
    export LDFLAGS="-arch ${ARCH} -isysroot ${SDKROOT}"
    export CC="$(xcrun -find clang)"
    export CXX="$(xcrun -find clang++)"
    set +e
    make clean
    make distclean
    set -e
    ./configure \
        --host=${HOST} \
        --enable-static \
        --disable-shared \
        --enable-extra-encodings \
        --prefix=$(PWD)/../out/iconv_${TARGET}_${ARCH}
    make
    make install
}

build_iconv "ios" "arm64"
build_iconv "iossim" "arm64"
build_iconv "iossim" "x86_64"
build_iconv "macos" "arm64"
build_iconv "macos" "x86_64"
popd

pushd out

mkdir -p iconv_ios/lib
cp iconv_ios_arm64/lib/libiconv.a iconv_ios/lib/libiconv.a

mkdir -p iconv_iossim/lib
lipo -create -output iconv_iossim/lib/libiconv.a \
    iconv_iossim_x86_64/lib/libiconv.a \
    iconv_iossim_arm64/lib/libiconv.a

mkdir -p iconv_macos/lib
lipo -create -output iconv_macos/lib/libiconv.a \
    iconv_macos_x86_64/lib/libiconv.a \
    iconv_macos_arm64/lib/libiconv.a

function copy_iconv() {
    local TARGET=$1
    mkdir -p ${TARGET}/libiconv.framework/Headers
    mkdir -p ${TARGET}/libiconv.framework/Modules
    cp ../template/module.modulemap ${TARGET}/libiconv.framework/Modules
    cp iconv_${TARGET}_arm64/include/iconv.h ${TARGET}/libiconv.framework/Headers
    cp iconv_${TARGET}/lib/libiconv.a ${TARGET}/libiconv.framework/libiconv
}
copy_iconv "ios"
copy_iconv "iossim"
copy_iconv "macos"

xcodebuild -create-xcframework \
    -framework ios/libiconv.framework \
    -framework iossim/libiconv.framework \
    -framework macos/libiconv.framework \
    -output libiconv.xcframework

popd

