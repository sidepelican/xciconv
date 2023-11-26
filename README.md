# xciconv

Pre-built libiconv XCFramework for fixing iconv issues on iOS 17.1

## Usage

This package can be used with the Swift Package Manager (SwiftPM).

In Xcode's 'Package Dependencies' pane, click the [+] button. Search for `https://github.com/sidepelican/xciconv.git`, and then add the `xciconv` package.

## Building the XCFramework Locally

From the root of the repository, run:

```sh
./build.sh
```

The generated XCFramework will be located in `out/libiconv.xcframework`.
