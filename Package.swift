// swift-tools-version:5.7
import PackageDescription

let libiconvTarget: Target
#if os(macOS) || os(iOS)
let useLocal = true
if useLocal {
    libiconvTarget = .binaryTarget(
        name: "libiconv",
        path: "./out/libiconv.xcframework"
    )
} else {
    libiconvTarget = .binaryTarget(
        name: "libiconv",
        url: "https://github.com/sidepelican/xciconv/releases/download/1.17.0/libiconv.xcframework.zip",
        checksum: "72156afbdbcd8cb7c33f8503ddc1ed603cfd69b3c11790df8113eab102dd74c4"
    )
}
#else
libiconvTarget = .systemLibrary(
    name: "libiconv",
    pkgConfig: "libiconv"
)
#endif

let package = Package(
    name: "xciconv",
    platforms: [
        .iOS(.v15), .macOS(.v12),
    ],
    products: [
        .library(name: "libiconv", targets: ["libiconv"]),
    ],
    targets: [
        libiconvTarget,
        .executableTarget(
            name: "test",
            dependencies: ["libiconv"]
        )
    ]
)
