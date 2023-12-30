import libiconv
import Foundation

let context = libiconv_open("UTF-8", "EUC-JISX0213")
var eucText = Data(base64Encoded: "pc+l7aG8LKXvobyl66XJIQ==")!

let utf8Text = eucText.withUnsafeMutableBytes { eucBuf in
    var inBuffer = UnsafeMutablePointer(mutating: eucBuf.baseAddress?.assumingMemoryBound(to: CChar.self))
    var inBytesLeft = eucBuf.count
    
    let tmpBuffer = UnsafeMutablePointer<CChar>.allocate(capacity: 256)
    defer {
        tmpBuffer.deallocate()
    }
    var outBuffer: UnsafeMutablePointer<CChar>? = tmpBuffer
    var outBytesLeft = 256

    libiconv(
        context,
        &inBuffer,
        &inBytesLeft,
        &outBuffer,
        &outBytesLeft
    )

    return String(cString: tmpBuffer)
}
libiconv_close(context)

print(utf8Text)
if utf8Text != "ハロー,ワールド!" {
    exit(1)
}
