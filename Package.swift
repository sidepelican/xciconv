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
        url: "https://github.com/sidepelican/xciconv/releases/download/1.17.2/libiconv.xcframework.zip",
        checksum: "c76931e0a1fdedc0aa46e3766e332451275cf818061f4b8154728aefccbd4191"
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
