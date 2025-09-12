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

import Quick
import Nimble
import UserNotifications
import UniformTypeIdentifiers
@testable import KarteNotificationServiceExtension

class KRTNotificationServiceExtensionSpec: QuickSpec {

    override func spec() {
        describe("KRTNotificationServiceExtension") {
            var service: NotificationServiceExtension!

            beforeEach {
                service = NotificationServiceExtension()
            }

            describe("uniformTypeIdentifierFromMIMEType") {
                context("when mimeType is nil") {
                    it("returns blank") {
                        expect(service.uniformTypeIdentifier(fromMIMEType: "")).to(equal(""))
                    }
                }

                context("when mimeType is invalid") {
                    it("returns blank") {
                        expect(service.uniformTypeIdentifier(fromMIMEType: "invalid/type")).to(equal(""))
                    }
                }

                context("when mimeType is image/jpeg") {
                    it("returns JPEG type identifier") {
                        let result = service.uniformTypeIdentifier(fromMIMEType: "image/jpeg")
                        expect(result).to(equal(UTType.jpeg.identifier))
                    }
                }

                context("when mimeType is image/png") {
                    it("returns PNG type identifier") {
                        let result = service.uniformTypeIdentifier(fromMIMEType: "image/png")
                        expect(result).to(equal(UTType.png.identifier))
                    }
                }

                context("when mimeType is image/gif") {
                    it("returns GIF type identifier") {
                        let result = service.uniformTypeIdentifier(fromMIMEType: "image/gif")
                        expect(result).to(equal(UTType.gif.identifier))
                    }
                }

                context("when mimeType is video/mp4") {
                    it("returns MPEG4 type identifier") {
                        let result = service.uniformTypeIdentifier(fromMIMEType: "video/mp4")
                        expect(result).to(equal(UTType.mpeg4Movie.identifier))
                    }
                }

                context("when mimeType is audio/mpeg") {
                    it("returns MP3 type identifier") {
                        let result = service.uniformTypeIdentifier(fromMIMEType: "audio/mpeg")
                        expect(result).to(equal(UTType.mp3.identifier))
                    }
                }

                context("when mimeType is audio/wav") {
                    it("returns WAV type identifier") {
                        let result = service.uniformTypeIdentifier(fromMIMEType: "audio/wav")
                        expect(result).to(equal(UTType.wav.identifier))
                    }
                }

                context("when mimeType is video/mpeg") {
                    it("returns MPEG type identifier") {
                        let result = service.uniformTypeIdentifier(fromMIMEType: "video/mpeg")
                        expect(result).to(equal(UTType.mpeg.identifier))
                    }
                }

                context("when mimeType is video/mpeg2") {
                    it("returns MPEG2Video type identifier") {
                        let result = service.uniformTypeIdentifier(fromMIMEType: "video/mpeg2")
                        expect(result).to(equal(UTType.mpeg2Video.identifier))
                    }
                }

                context("when mimeType is audio/aiff") {
                    it("returns AIFF type identifier") {
                        let result = service.uniformTypeIdentifier(fromMIMEType: "audio/aiff")
                        expect(result).to(equal(UTType.aiff.identifier))
                    }
                }

                context("when mimeType is audio/mp4") {
                    it("returns MPEG4Audio type identifier") {
                        let result = service.uniformTypeIdentifier(fromMIMEType: "audio/mp4")
                        expect(result).to(equal(UTType.mpeg4Audio.identifier))
                    }
                }

                context("when mimeType is for unsupported type") {
                    it("returns blank") {
                        expect(service.uniformTypeIdentifier(fromMIMEType: "text/plain")).to(equal(""))
                    }
                }
            }

            describe("uniformTypeIdentifierFromData") {
                context("when data is nil") {
                    it("returns blank") {
                        expect(service.uniformTypeIdentifier(from: Data())).to(equal(""))
                    }
                }

                context("when data is too short") {
                    it("returns blank") {
                        let shortData = Data([0x00, 0x01])
                        expect(service.uniformTypeIdentifier(from: shortData)).to(equal(""))
                    }
                }

                context("when data has JPEG signature") {
                    it("returns JPEG type identifier") {
                        // JPEG file signature: 0xFFD8FFE0 (JFIF)
                        let jpegData = Data([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x00, 0x00, 0x00,
                                             0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
                        expect(service.uniformTypeIdentifier(from: jpegData)).to(equal(UTType.jpeg.identifier))
                    }
                }

                context("when data has PNG signature") {
                    it("returns PNG type identifier") {
                        // PNG file signature: 0x89504E470D0A1A0A
                        let pngData = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
                                            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
                        expect(service.uniformTypeIdentifier(from: pngData)).to(equal(UTType.png.identifier))
                    }
                }

                context("when data has GIF signature") {
                    it("returns GIF type identifier") {
                        // GIF file signature: "GIF8" (0x47494638)
                        let gifData = Data([0x47, 0x49, 0x46, 0x38, 0x00, 0x00, 0x00, 0x00,
                                            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
                        expect(service.uniformTypeIdentifier(from: gifData)).to(equal(UTType.gif.identifier))
                    }
                }

                context("when data has MP3 signature") {
                    it("returns MP3 type identifier") {
                        // MP3 file signature: "ID3" (ID3v2 tag)
                        let mp3Data = Data([0x49, 0x44, 0x33, 0x00, 0x00, 0x00, 0x00, 0x00,
                                            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
                        expect(service.uniformTypeIdentifier(from: mp3Data)).to(equal(UTType.mp3.identifier))
                    }
                }

                context("when data has WAV signature") {
                    it("returns WAV type identifier") {
                        // WAV file signature: "WAVE" at offset 8
                        let wavData = Data([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                                            0x57, 0x41, 0x56, 0x45, 0x00, 0x00, 0x00, 0x00])
                        expect(service.uniformTypeIdentifier(from: wavData)).to(equal(UTType.wav.identifier))
                    }
                }

                context("when data has MP4 signature") {
                    it("returns MPEG4 type identifier") {
                        // MP4 file signature: "ftyp" + "mp41" (ISO Base Media file format)
                        let mp4Data = Data([0x00, 0x00, 0x00, 0x00, 0x66, 0x74, 0x79, 0x70,
                                            0x6D, 0x70, 0x34, 0x31, 0x00, 0x00, 0x00, 0x00])
                        expect(service.uniformTypeIdentifier(from: mp4Data)).to(equal(UTType.mpeg4Movie.identifier))
                    }
                }

                context("when data has MPEG signature") {
                    it("returns MPEG type identifier") {
                        // MPEG Program Stream header: 0x000001BA
                        let mpegData = Data([0x00, 0x00, 0x01, 0xBA, 0x00, 0x00, 0x00, 0x00,
                                             0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
                        expect(service.uniformTypeIdentifier(from: mpegData)).to(equal(UTType.mpeg.identifier))
                    }
                }

                context("when data has alternative MPEG signature") {
                    it("returns MPEG type identifier") {
                        // MPEG Video Sequence header: 0x000001B3
                        let mpegData = Data([0x00, 0x00, 0x01, 0xB3, 0x00, 0x00, 0x00, 0x00,
                                             0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
                        expect(service.uniformTypeIdentifier(from: mpegData)).to(equal(UTType.mpeg.identifier))
                    }
                }

                context("when data has AVI signature") {
                    it("returns AVI type identifier") {
                        // AVI file signature: "AVI " at offset 8
                        let aviData = Data([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                                            0x41, 0x56, 0x49, 0x20, 0x00, 0x00, 0x00, 0x00])
                        expect(service.uniformTypeIdentifier(from: aviData)).to(equal(UTType.avi.identifier))
                    }
                }

                context("when data has AIFF signature") {
                    it("returns AIFF type identifier") {
                        // AIFF file signature: "FORM" at beginning
                        let aiffData = Data([0x46, 0x4F, 0x52, 0x4D, 0x00, 0x00, 0x00, 0x00,
                                             0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
                        expect(service.uniformTypeIdentifier(from: aiffData)).to(equal(UTType.aiff.identifier))
                    }
                }

                context("when data has MPEG4Audio signature") {
                    it("returns MPEG4Audio type identifier") {
                        // M4A file signature: "ftyp" + "M4A " (MPEG-4 Audio)
                        let m4aData = Data([0x00, 0x00, 0x00, 0x00, 0x66, 0x74, 0x79, 0x70,
                                            0x4D, 0x34, 0x41, 0x20, 0x00, 0x00, 0x00, 0x00])
                        expect(service.uniformTypeIdentifier(from: m4aData)).to(equal(UTType.mpeg4Audio.identifier))
                    }
                }

                context("when data has unknown signature") {
                    it("returns blank") {
                        let unknownData = Data([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
                                                0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F])
                        expect(service.uniformTypeIdentifier(from: unknownData)).to(equal(""))
                    }
                }
            }
        }
    }
}
