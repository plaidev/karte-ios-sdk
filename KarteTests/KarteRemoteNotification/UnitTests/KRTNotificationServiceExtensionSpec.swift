//
//  Copyright 2025 PLAID, Inc.
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
//

import XCTest
import UniformTypeIdentifiers
@testable import KarteNotificationServiceExtension

class KRTNotificationServiceExtensionSpec: XCTestCase {

    var service: NotificationServiceExtension!

    override func setUp() {
        super.setUp()
        service = NotificationServiceExtension()
    }

    // MARK: - uniformTypeIdentifier(fromMIMEType:)

    func testUniformTypeIdentifierFromMIMEType_empty_returnsBlank() {
        XCTAssertEqual(service.uniformTypeIdentifier(fromMIMEType: ""), "", "Empty MIME type should return blank")
    }

    func testUniformTypeIdentifierFromMIMEType_invalid_returnsBlank() {
        XCTAssertEqual(service.uniformTypeIdentifier(fromMIMEType: "invalid/type"), "", "Invalid MIME type should return blank")
    }

    func testUniformTypeIdentifierFromMIMEType_imageJpeg_returnsJPEG() {
        let result = service.uniformTypeIdentifier(fromMIMEType: "image/jpeg")
        XCTAssertEqual(result, UTType.jpeg.identifier, "image/jpeg should return JPEG type identifier")
    }

    func testUniformTypeIdentifierFromMIMEType_imagePng_returnsPNG() {
        let result = service.uniformTypeIdentifier(fromMIMEType: "image/png")
        XCTAssertEqual(result, UTType.png.identifier, "image/png should return PNG type identifier")
    }

    func testUniformTypeIdentifierFromMIMEType_imageGif_returnsGIF() {
        let result = service.uniformTypeIdentifier(fromMIMEType: "image/gif")
        XCTAssertEqual(result, UTType.gif.identifier, "image/gif should return GIF type identifier")
    }

    func testUniformTypeIdentifierFromMIMEType_videoMp4_returnsMPEG4() {
        let result = service.uniformTypeIdentifier(fromMIMEType: "video/mp4")
        XCTAssertEqual(result, UTType.mpeg4Movie.identifier, "video/mp4 should return MPEG4 type identifier")
    }

    func testUniformTypeIdentifierFromMIMEType_audioMpeg_returnsMP3() {
        let result = service.uniformTypeIdentifier(fromMIMEType: "audio/mpeg")
        XCTAssertEqual(result, UTType.mp3.identifier, "audio/mpeg should return MP3 type identifier")
    }

    func testUniformTypeIdentifierFromMIMEType_audioWav_returnsWAV() {
        let result = service.uniformTypeIdentifier(fromMIMEType: "audio/wav")
        XCTAssertEqual(result, UTType.wav.identifier, "audio/wav should return WAV type identifier")
    }

    func testUniformTypeIdentifierFromMIMEType_videoMpeg_returnsMPEG() {
        let result = service.uniformTypeIdentifier(fromMIMEType: "video/mpeg")
        XCTAssertEqual(result, UTType.mpeg.identifier, "video/mpeg should return MPEG type identifier")
    }

    func testUniformTypeIdentifierFromMIMEType_videoMpeg2_returnsMPEG2Video() {
        let result = service.uniformTypeIdentifier(fromMIMEType: "video/mpeg2")
        XCTAssertEqual(result, UTType.mpeg2Video.identifier, "video/mpeg2 should return MPEG2Video type identifier")
    }

    func testUniformTypeIdentifierFromMIMEType_audioAiff_returnsAIFF() {
        let result = service.uniformTypeIdentifier(fromMIMEType: "audio/aiff")
        XCTAssertEqual(result, UTType.aiff.identifier, "audio/aiff should return AIFF type identifier")
    }

    func testUniformTypeIdentifierFromMIMEType_audioMp4_returnsMPEG4Audio() {
        let result = service.uniformTypeIdentifier(fromMIMEType: "audio/mp4")
        XCTAssertEqual(result, UTType.mpeg4Audio.identifier, "audio/mp4 should return MPEG4Audio type identifier")
    }

    func testUniformTypeIdentifierFromMIMEType_unsupported_returnsBlank() {
        XCTAssertEqual(service.uniformTypeIdentifier(fromMIMEType: "text/plain"), "", "Unsupported MIME type should return blank")
    }

    // MARK: - uniformTypeIdentifier(from:)

    func testUniformTypeIdentifierFromData_empty_returnsBlank() {
        XCTAssertEqual(service.uniformTypeIdentifier(from: Data()), "", "Empty data should return blank")
    }

    func testUniformTypeIdentifierFromData_tooShort_returnsBlank() {
        let shortData = Data([0x00, 0x01])
        XCTAssertEqual(service.uniformTypeIdentifier(from: shortData), "", "Too short data should return blank")
    }

    func testUniformTypeIdentifierFromData_jpegSignature_returnsJPEG() {
        let jpegData = Data([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x00, 0x00, 0x00,
                             0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        XCTAssertEqual(service.uniformTypeIdentifier(from: jpegData), UTType.jpeg.identifier, "JPEG signature should return JPEG type identifier")
    }

    func testUniformTypeIdentifierFromData_pngSignature_returnsPNG() {
        let pngData = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
                            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        XCTAssertEqual(service.uniformTypeIdentifier(from: pngData), UTType.png.identifier, "PNG signature should return PNG type identifier")
    }

    func testUniformTypeIdentifierFromData_gifSignature_returnsGIF() {
        let gifData = Data([0x47, 0x49, 0x46, 0x38, 0x00, 0x00, 0x00, 0x00,
                            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        XCTAssertEqual(service.uniformTypeIdentifier(from: gifData), UTType.gif.identifier, "GIF signature should return GIF type identifier")
    }

    func testUniformTypeIdentifierFromData_mp3Signature_returnsMP3() {
        let mp3Data = Data([0x49, 0x44, 0x33, 0x00, 0x00, 0x00, 0x00, 0x00,
                            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        XCTAssertEqual(service.uniformTypeIdentifier(from: mp3Data), UTType.mp3.identifier, "MP3 signature should return MP3 type identifier")
    }

    func testUniformTypeIdentifierFromData_wavSignature_returnsWAV() {
        let wavData = Data([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                            0x57, 0x41, 0x56, 0x45, 0x00, 0x00, 0x00, 0x00])
        XCTAssertEqual(service.uniformTypeIdentifier(from: wavData), UTType.wav.identifier, "WAV signature should return WAV type identifier")
    }

    func testUniformTypeIdentifierFromData_mp4Signature_returnsMPEG4() {
        let mp4Data = Data([0x00, 0x00, 0x00, 0x00, 0x66, 0x74, 0x79, 0x70,
                            0x6D, 0x70, 0x34, 0x31, 0x00, 0x00, 0x00, 0x00])
        XCTAssertEqual(service.uniformTypeIdentifier(from: mp4Data), UTType.mpeg4Movie.identifier, "MP4 signature should return MPEG4 type identifier")
    }

    func testUniformTypeIdentifierFromData_mpegProgramStreamSignature_returnsMPEG() {
        let mpegData = Data([0x00, 0x00, 0x01, 0xBA, 0x00, 0x00, 0x00, 0x00,
                             0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        XCTAssertEqual(service.uniformTypeIdentifier(from: mpegData), UTType.mpeg.identifier, "MPEG Program Stream signature should return MPEG type identifier")
    }

    func testUniformTypeIdentifierFromData_mpegVideoSequenceSignature_returnsMPEG() {
        let mpegData = Data([0x00, 0x00, 0x01, 0xB3, 0x00, 0x00, 0x00, 0x00,
                             0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        XCTAssertEqual(service.uniformTypeIdentifier(from: mpegData), UTType.mpeg.identifier, "MPEG Video Sequence signature should return MPEG type identifier")
    }

    func testUniformTypeIdentifierFromData_aviSignature_returnsAVI() {
        let aviData = Data([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                            0x41, 0x56, 0x49, 0x20, 0x00, 0x00, 0x00, 0x00])
        XCTAssertEqual(service.uniformTypeIdentifier(from: aviData), UTType.avi.identifier, "AVI signature should return AVI type identifier")
    }

    func testUniformTypeIdentifierFromData_aiffSignature_returnsAIFF() {
        let aiffData = Data([0x46, 0x4F, 0x52, 0x4D, 0x00, 0x00, 0x00, 0x00,
                             0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        XCTAssertEqual(service.uniformTypeIdentifier(from: aiffData), UTType.aiff.identifier, "AIFF signature should return AIFF type identifier")
    }

    func testUniformTypeIdentifierFromData_m4aSignature_returnsMPEG4Audio() {
        let m4aData = Data([0x00, 0x00, 0x00, 0x00, 0x66, 0x74, 0x79, 0x70,
                            0x4D, 0x34, 0x41, 0x20, 0x00, 0x00, 0x00, 0x00])
        XCTAssertEqual(service.uniformTypeIdentifier(from: m4aData), UTType.mpeg4Audio.identifier, "M4A signature should return MPEG4Audio type identifier")
    }

    func testUniformTypeIdentifierFromData_unknownSignature_returnsBlank() {
        let unknownData = Data([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
                                0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F])
        XCTAssertEqual(service.uniformTypeIdentifier(from: unknownData), "", "Unknown signature should return blank")
    }
}
