// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "xciconv",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(name: "libiconv", targets: ["libiconv"]),
    ],
    targets: [
        .binaryTarget(
            name: "libiconv",
            url: "https://github.com/sidepelican/xciconv/releases/download/1.17.0/libiconv.xcframework.zip",
            checksum: "72156afbdbcd8cb7c33f8503ddc1ed603cfd69b3c11790df8113eab102dd74c4"
        )
    ]
)
