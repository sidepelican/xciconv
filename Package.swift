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
            url: "https://example.com/binaries/libiconv.zip",
            checksum: "The checksum of the binary file"
        )
    ]
)
