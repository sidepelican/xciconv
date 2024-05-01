// swift-tools-version:5.7
import PackageDescription

let libiconvTarget: Target
#if os(macOS) || os(iOS)
let useLocal = false
if useLocal {
    libiconvTarget = .binaryTarget(
        name: "libiconv",
        path: "./out/libiconv.xcframework"
    )
} else {
    libiconvTarget = .binaryTarget(
        name: "libiconv",
        url: "https://github.com/sidepelican/xciconv/releases/download/1.17.3/libiconv.xcframework.zip",
        checksum: "233c46ba520d3f0636096acfb5a9ab06596bdd5c7e09c6bad21e540671ff4b61"
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
