# xciconv

Pre-built libiconv XCFramework for fixing iconv issues on iOS 17.1

## Usage

This package can be used with the Swift Package Manager (SwiftPM).

In Xcode's 'Package Dependencies' pane, click the [+] button. Search for `https://github.com/sidepelican/xciconv.git`, and then add the `xciconv` package.

## Use in code

Unlike the system library version, almost all of the symbols are prefixed with lib (this is a specification by libiconv).

```swift
import libiconv

let context: libiconv_t = libiconv_open("to_code", "from_code")

libiconv(context, &inBuffer, &inBytesLeft, &outBuffer, &outBytesLeft)

libiconv_close(context)
```

## Building the XCFramework Locally

From the root of the repository, run:

```sh
./build.sh
```

The generated XCFramework will be located in `out/libiconv.xcframework`.
