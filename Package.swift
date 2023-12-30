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
        url: "https://github.com/sidepelican/xciconv/releases/download/1.17.1/libiconv.xcframework.zip",
        checksum: "d74bcf877420a08e0d01b4add46845f497e4f21ae396fcd0c8e96743e7e9ee0f"
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
