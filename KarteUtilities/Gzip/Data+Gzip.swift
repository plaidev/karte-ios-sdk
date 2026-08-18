//
//  Copyright 2026 PLAID, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Foundation
import zlib

extension Data {
    /// Returns `true` if this data starts with the gzip magic bytes (0x1f 0x8b).
    var isGzipped: Bool {
        count >= 2 && self[startIndex] == 0x1f && self[startIndex + 1] == 0x8b
    }

    /// Compresses this data using gzip compression.
    ///
    /// - Parameter level: The compression level to use. Defaults to `.defaultCompression`.
    /// - Returns: Gzip-compressed data.
    /// - Throws: `GzipError` if compression fails.
    func gzipped(level: CompressionLevel = .defaultCompression) throws -> Data {
        guard !isEmpty else { return Data() }

        var stream = z_stream()

        let status = deflateInit2_(
            &stream,
            level.rawValue,
            Z_DEFLATED,
            MAX_WBITS + 16,
            MAX_MEM_LEVEL,
            Z_DEFAULT_STRATEGY,
            ZLIB_VERSION,
            Int32(MemoryLayout<z_stream>.size)
        )

        guard status == Z_OK else {
            throw GzipError(code: status, msg: stream.msg)
        }

        // Ensure cleanup happens even on error, but track if we need to throw
        var deflateError: GzipError?
        defer {
            let endStatus = deflateEnd(&stream)
            // deflateEnd should always be called, but check its return value
            // If deflate already failed, prioritize that error over deflateEnd errors
            if endStatus != Z_OK && deflateError == nil {
                // In Debug builds only, crash on unexpected cleanup failures
                assertionFailure("deflateEnd failed with code \(endStatus)")
            }
        }

        let bound = deflateBound(&stream, UInt(count))
        var output = Data(count: Int(bound))

        try withUnsafeBytes { inputPointer in
            stream.next_in = UnsafeMutablePointer(mutating: inputPointer.bindMemory(to: Bytef.self).baseAddress!)
            stream.avail_in = uInt(count)

            try output.withUnsafeMutableBytes { outputPointer in
                stream.next_out = outputPointer.bindMemory(to: Bytef.self).baseAddress!
                stream.avail_out = uInt(bound)

                let result = deflate(&stream, Z_FINISH)

                // deflateBound() guarantees the output buffer is large enough for a
                // single-pass Z_FINISH deflate, so the only expected result is
                // Z_STREAM_END. Any other code (including Z_BUF_ERROR) indicates an
                // unexpected failure.
                guard result == Z_STREAM_END else {
                    deflateError = GzipError(code: result, msg: stream.msg)
                    throw deflateError!
                }
            }
        }

        output.count = Int(stream.total_out)
        return output
    }

    /// Decompresses this gzip-compressed data.
    ///
    /// - Returns: The decompressed data.
    /// - Throws: `GzipError` if the data is not valid gzip format or decompression fails.
    func gunzipped() throws -> Data {
        guard !isEmpty else { return Data() }

        var stream = z_stream()
        try initializeInflateStream(&stream)

        var inflateError: GzipError?
        defer { cleanupInflateStream(&stream, error: inflateError) }

        return try decompressData(using: &stream, trackingError: &inflateError)
    }

    private func initializeInflateStream(_ stream: inout z_stream) throws {
        let status = inflateInit2_(
            &stream,
            MAX_WBITS + 32,
            ZLIB_VERSION,
            Int32(MemoryLayout<z_stream>.size)
        )
        guard status == Z_OK else {
            throw GzipError(code: status, msg: stream.msg)
        }
    }

    private func cleanupInflateStream(_ stream: inout z_stream, error: GzipError?) {
        let endStatus = inflateEnd(&stream)
        if endStatus != Z_OK && error == nil {
            assertionFailure("inflateEnd failed with code \(endStatus)")
        }
    }

    private func decompressData(using stream: inout z_stream, trackingError error: inout GzipError?) throws -> Data {
        var output = Data(capacity: count * 2)
        let chunkSize = 16_384

        do {
            try withUnsafeBytes { inputPointer in
                stream.next_in = UnsafeMutablePointer(mutating: inputPointer.bindMemory(to: Bytef.self).baseAddress!)
                stream.avail_in = uInt(count)

                var buffer = Data(count: chunkSize)
                try decompressLoop(stream: &stream, buffer: &buffer, output: &output, chunkSize: chunkSize)
            }
        } catch let gzipError as GzipError {
            error = gzipError
            throw gzipError
        }

        return output
    }

    private func decompressLoop(stream: inout z_stream, buffer: inout Data, output: inout Data, chunkSize: Int) throws {
        while true {
            let result = try inflateChunk(stream: &stream, buffer: &buffer, chunkSize: chunkSize)
            let bytesWritten = chunkSize - Int(stream.avail_out)

            if bytesWritten > 0 {
                output.append(buffer.prefix(bytesWritten))
            }

            if result == Z_STREAM_END {
                break
            }

            try handleBufferError(result: result, bytesWritten: bytesWritten, stream: stream)
        }
    }

    private func inflateChunk(stream: inout z_stream, buffer: inout Data, chunkSize: Int) throws -> Int32 {
        try buffer.withUnsafeMutableBytes { bufferPointer in
            stream.next_out = bufferPointer.bindMemory(to: Bytef.self).baseAddress!
            stream.avail_out = uInt(chunkSize)

            let result = inflate(&stream, Z_NO_FLUSH)

            switch result {
            case Z_OK, Z_STREAM_END, Z_BUF_ERROR:
                return result
            case Z_NEED_DICT:
                throw GzipError(code: result, msg: stream.msg)
            default:
                throw GzipError(code: result, msg: stream.msg)
            }
        }
    }

    private func handleBufferError(result: Int32, bytesWritten: Int, stream: z_stream) throws {
        guard result == Z_BUF_ERROR && bytesWritten == 0 else { return }
        throw GzipError(code: Z_DATA_ERROR, msg: stream.msg)
    }
}
