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

import XCTest
import Security
@testable import KarteUtilities

class DataGzipTests: XCTestCase {

    // MARK: - isGzipped tests

    func testIsGzippedReturnsFalseForEmptyData() {
        let data = Data()
        XCTAssertFalse(data.isGzipped, "Empty data should not be gzipped")
    }

    func testIsGzippedReturnsFalseForSingleByte() {
        let data = Data([0x1f])
        XCTAssertFalse(data.isGzipped, "Single byte should not be gzipped")
    }

    func testIsGzippedReturnsTrueForGzipMagicBytes() {
        let data = Data([0x1f, 0x8b])
        XCTAssertTrue(data.isGzipped, "Data with gzip magic bytes should be gzipped")
    }

    func testIsGzippedReturnsFalseForNonGzipData() {
        let data = Data([0x00, 0x01, 0x02, 0x03])
        XCTAssertFalse(data.isGzipped, "Non-gzip data should return false")
    }

    func testIsGzippedReturnsTrueForCompressedData() throws {
        let original = "Hello, World!".data(using: .utf8)!
        let compressed = try original.gzipped()
        XCTAssertTrue(compressed.isGzipped, "Compressed data should be gzipped")
    }

    // MARK: - gzipped() tests

    func testGzippedReturnsEmptyDataForEmptyInput() throws {
        let data = Data()
        let compressed = try data.gzipped()
        XCTAssertEqual(compressed.count, 0, "Compressing empty data should return empty data")
    }

    func testGzippedOutputStartsWithMagicBytes() throws {
        let data = "test".data(using: .utf8)!
        let compressed = try data.gzipped()
        XCTAssertTrue(compressed.isGzipped, "Compressed output should start with gzip magic bytes")
        XCTAssertGreaterThan(compressed.count, 2, "Compressed data should be more than just magic bytes")
    }

    func testGzippedRoundTrip() throws {
        let original = "The quick brown fox jumps over the lazy dog".data(using: .utf8)!
        let compressed = try original.gzipped()
        let decompressed = try compressed.gunzipped()
        XCTAssertEqual(decompressed, original, "Round-trip should preserve data")
    }

    func testGzippedWorksWithSmallData() throws {
        let original = Data([0x42])
        let compressed = try original.gzipped()
        let decompressed = try compressed.gunzipped()
        XCTAssertEqual(decompressed, original, "Should handle single-byte data")
    }

    func testGzippedWorksWithLargeData() throws {
        // 100KB of repeating pattern
        let original = Data(repeating: 0xAB, count: 100_000)
        let compressed = try original.gzipped()
        let decompressed = try compressed.gunzipped()
        XCTAssertEqual(decompressed, original, "Should handle large data")
        // Repeating pattern should compress well
        XCTAssertLessThan(compressed.count, original.count / 10, "Repeating data should compress significantly")
    }

    func testGzippedWorksWithHighEntropyData() throws {
        // Random data with high entropy (low compression ratio) to test deflateBound allocation
        var randomData = Data(count: 100_000)
        randomData.withUnsafeMutableBytes { buffer in
            _ = SecRandomCopyBytes(kSecRandomDefault, 100_000, buffer.baseAddress!)
        }
        let compressed = try randomData.gzipped()
        let decompressed = try compressed.gunzipped()
        XCTAssertEqual(decompressed, randomData, "Should handle high-entropy data")
        // Random data doesn't compress well, output may be similar or larger than input
        XCTAssertGreaterThan(compressed.count, randomData.count / 2, "High-entropy data should not compress significantly")
    }

    func testGzippedWithNoCompression() throws {
        let original = "test data".data(using: .utf8)!
        let compressed = try original.gzipped(level: .noCompression)
        let decompressed = try compressed.gunzipped()
        XCTAssertEqual(decompressed, original, "No compression level should still produce valid gzip")
    }

    func testGzippedWithBestSpeed() throws {
        let original = "test data".data(using: .utf8)!
        let compressed = try original.gzipped(level: .bestSpeed)
        let decompressed = try compressed.gunzipped()
        XCTAssertEqual(decompressed, original, "Best speed level should produce valid gzip")
    }

    func testGzippedWithBestCompression() throws {
        let original = "test data".data(using: .utf8)!
        let compressed = try original.gzipped(level: .bestCompression)
        let decompressed = try compressed.gunzipped()
        XCTAssertEqual(decompressed, original, "Best compression level should produce valid gzip")
    }

    func testGzippedCompressesFixtureFile() throws {
        let plaintextURL = try XCTUnwrap(
            Bundle(for: Self.self).url(forResource: "gzippedCompressesFixtureFile", withExtension: "txt")
        )
        let expectedURL = try XCTUnwrap(
            Bundle(for: Self.self).url(forResource: "gzippedCompressesFixtureFile", withExtension: "gz")
        )

        let plaintext = try Data(contentsOf: plaintextURL)
        let expected = try Data(contentsOf: expectedURL)

        let compressed = try plaintext.gzipped()

        XCTAssertTrue(compressed.isGzipped, "Output should be gzip format")
        XCTAssertEqual(compressed, expected, "Compressed output should match golden fixture")
    }

    // MARK: - gunzipped() tests

    func testGunzippedReturnsEmptyDataForEmptyInput() throws {
        let data = Data()
        let decompressed = try data.gunzipped()
        XCTAssertEqual(decompressed.count, 0, "Decompressing empty data should return empty data")
    }

    func testGunzippedDecompressesFixtureFile() throws {
        let url = try XCTUnwrap(
            Bundle(for: Self.self).url(forResource: "gunzippedDecompressesFixtureFile", withExtension: "gz")
        )
        let compressed = try Data(contentsOf: url)

        XCTAssertTrue(compressed.isGzipped, "Fixture should be gzip format")

        let decompressed = try compressed.gunzipped()
        let expected = "test".data(using: .utf8)!
        XCTAssertEqual(decompressed, expected, "Fixture should decompress to 'test'")
    }

    func testGunzippedThrowsForInvalidData() {
        let invalidData = Data([0x00, 0x01, 0x02, 0x03])
        XCTAssertThrowsError(try invalidData.gunzipped()) { error in
            guard let gzipError = error as? GzipError else {
                XCTFail("Expected GzipError, got \(type(of: error))")
                return
            }
            XCTAssertEqual(gzipError.kind, .data, "Invalid data should throw data error")
        }
    }

    func testGunzippedThrowsForCorruptedGzipData() {
        // Gzip magic bytes but corrupted payload
        let corruptedData = Data([0x1f, 0x8b, 0x08, 0x00, 0xFF, 0xFF, 0xFF, 0xFF])
        XCTAssertThrowsError(try corruptedData.gunzipped()) { error in
            XCTAssertTrue(error is GzipError, "Should throw GzipError for corrupted data")
        }
    }

    func testGunzippedHandlesMultipleChunks() throws {
        // Create data larger than the 16KB chunk size to test chunked decompression
        let largeData = Data(repeating: 0x42, count: 50_000)
        let compressed = try largeData.gzipped()
        let decompressed = try compressed.gunzipped()
        XCTAssertEqual(decompressed, largeData, "Should handle data requiring multiple chunks")
    }

    func testGunzippedWithVeryLargeData() throws {
        // Test with data larger than initial capacity (count * 2)
        let veryLargeData = Data(repeating: UInt8.random(in: 0...255), count: 200_000)
        let compressed = try veryLargeData.gzipped()
        let decompressed = try compressed.gunzipped()
        XCTAssertEqual(decompressed.count, veryLargeData.count, "Should handle very large data")
    }

    func testGunzippedPreservesDataIntegrity() throws {
        // Test with random non-repeating data to ensure no data loss
        var randomData = Data(count: 10_000)
        randomData.withUnsafeMutableBytes { buffer in
            _ = SecRandomCopyBytes(kSecRandomDefault, 10_000, buffer.baseAddress!)
        }
        let compressed = try randomData.gzipped()
        let decompressed = try compressed.gunzipped()
        XCTAssertEqual(decompressed, randomData, "Should preserve exact data integrity")
    }

    // MARK: - GzipError tests

    func testGzipErrorKindMapping() {
        // Test that zlib error codes map to the correct Kind
        let streamError = GzipError(code: -2, msg: nil) // Z_STREAM_ERROR
        XCTAssertEqual(streamError.kind, .stream)

        let dataError = GzipError(code: -3, msg: nil) // Z_DATA_ERROR
        XCTAssertEqual(dataError.kind, .data)

        let memError = GzipError(code: -4, msg: nil) // Z_MEM_ERROR
        XCTAssertEqual(memError.kind, .memory)

        let bufError = GzipError(code: -5, msg: nil) // Z_BUF_ERROR
        XCTAssertEqual(bufError.kind, .buffer)

        let versionError = GzipError(code: -6, msg: nil) // Z_VERSION_ERROR
        XCTAssertEqual(versionError.kind, .version)

        let needDictError = GzipError(code: 2, msg: nil) // Z_NEED_DICT
        XCTAssertEqual(needDictError.kind, .needDict)

        let unknownError = GzipError(code: -999, msg: nil)
        if case .unknown(let code) = unknownError.kind {
            XCTAssertEqual(code, -999)
        } else {
            XCTFail("Expected unknown error kind")
        }
    }

    func testGzipErrorMessageExtraction() {
        let msg = "test error message"
        let error = msg.withCString { ptr in
            GzipError(code: -3, msg: ptr)
        }
        XCTAssertEqual(error.message, "test error message")
        XCTAssertEqual(error.localizedDescription, "test error message")
    }

    func testGzipErrorFallbackMessage() {
        let error = GzipError(code: -3, msg: nil)
        XCTAssertEqual(error.message, "Unknown gzip error")
        XCTAssertEqual(error.localizedDescription, "Unknown gzip error")
    }

    // MARK: - CompressionLevel tests

    func testCompressionLevelRawRepresentable() {
        let level = CompressionLevel(rawValue: 6)
        XCTAssertEqual(level.rawValue, 6, "RawRepresentable should round-trip")
    }

    func testCompressionLevelConvenienceInit() {
        let level = CompressionLevel(5)
        XCTAssertEqual(level.rawValue, 5, "Convenience init should set rawValue")
    }

    func testCompressionLevelConstants() {
        XCTAssertEqual(CompressionLevel.noCompression.rawValue, 0)
        XCTAssertEqual(CompressionLevel.bestSpeed.rawValue, 1)
        XCTAssertEqual(CompressionLevel.bestCompression.rawValue, 9)
        XCTAssertEqual(CompressionLevel.defaultCompression.rawValue, -1)
    }
}
