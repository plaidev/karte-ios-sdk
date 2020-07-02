//
//  Copyright 2020 PLAID, Inc.
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

#import "CrashReport.h"

@interface KRTCrashReport ()
@property(nonatomic, readwrite, nullable) NSString *type;
@property(nonatomic, readwrite, nullable) NSString *code;
@property(nonatomic, readwrite, nullable) NSString *name;
@property(nonatomic, readwrite, nullable) NSString *reason;
@property(nonatomic, readwrite, nullable) NSString *symbols;
@property(nonatomic, readwrite, nullable) NSDate *timestamp;
@end

@implementation KRTCrashReport

- (instancetype)initWithCrashReport:(KRTPLCrashReport *)crashReport
{
    if (self = [super init]) {
        self.type = crashReport.signalInfo.name;
        self.code = [NSString stringWithFormat:@"%@ at 0x%" PRIx64 "", crashReport.signalInfo.code, crashReport.signalInfo.address];
        
        if (crashReport.hasExceptionInfo) {
            self.name = crashReport.exceptionInfo.exceptionName;
            self.reason = crashReport.exceptionInfo.exceptionReason;
        }
        
        NSMutableString *symbols = [NSMutableString string];
        for (KRTPLCrashReportThreadInfo *thread in crashReport.threads) {
            if (thread.crashed) {
                for (NSUInteger frameIdx = 0; frameIdx < thread.stackFrames.count; frameIdx++) {
                    KRTPLCrashReportStackFrameInfo *stackFrameInfo = thread.stackFrames[frameIdx];
                    [symbols appendString:[self formatStackFrame:stackFrameInfo frameIndex:frameIdx crashReport:crashReport lp64:[self isLp64WithCrashReport:crashReport]]];
                }
                break;
            }
        }
        self.symbols = symbols;
        self.timestamp = crashReport.systemInfo.timestamp;
    }
    return self;
}

- (BOOL)isLp64WithCrashReport:(KRTPLCrashReport *)crashReport
{
    NSString *codeType = nil;
    BOOL lp64 = YES;

    for (KRTPLCrashReportBinaryImageInfo *binaryImageInfo in crashReport.images) {
        if (binaryImageInfo.codeType == nil) {
            continue;
        }

        if (binaryImageInfo.codeType.typeEncoding != PLCrashReportProcessorTypeEncodingMach) {
            continue;
        }

        switch (binaryImageInfo.codeType.type) {
            case CPU_TYPE_ARM:
                codeType = @"ARM";
                lp64 = NO;
                break;

            case CPU_TYPE_ARM64:
                codeType = @"ARM-64";
                lp64 = YES;
                break;

            case CPU_TYPE_X86:
                codeType = @"X86";
                lp64 = NO;
                break;

            case CPU_TYPE_X86_64:
                codeType = @"X86_64";
                lp64 = YES;
                break;

            default:
                break;
        }

        if (codeType) {
            break;
        }
    }

    if (codeType == nil && crashReport.systemInfo.processorInfo.typeEncoding == PLCrashReportProcessorTypeEncodingMach) {
        switch (crashReport.systemInfo.processorInfo.type) {
            case CPU_TYPE_ARM:
                lp64 = NO;
                break;

            case CPU_TYPE_ARM64:
                lp64 = YES;
                break;

            case CPU_TYPE_X86:
                lp64 = NO;
                break;

            case CPU_TYPE_X86_64:
                lp64 = YES;
                break;

            default:
                lp64 = YES;
                break;
        }
    }

    return lp64;
}

- (NSString *)formatStackFrame:(KRTPLCrashReportStackFrameInfo *)frameInfo frameIndex:(NSUInteger)frameIndex crashReport:(KRTPLCrashReport *)report lp64:(BOOL)lp64
{
    /* Base image address containing instrumention pointer, offset of the IP from that base
     * address, and the associated image name */
    uint64_t baseAddress = 0x0;
    uint64_t pcOffset = 0x0;
    NSString *imageName = @"\?\?\?";
    NSString *symbolString = nil;

    PLCrashReportBinaryImageInfo *imageInfo = [report imageForAddress:frameInfo.instructionPointer];
    if (imageInfo != nil) {
        imageName = [imageInfo.imageName lastPathComponent];
        baseAddress = imageInfo.imageBaseAddress;
        pcOffset = frameInfo.instructionPointer - imageInfo.imageBaseAddress;
    }

    /* If symbol info is available, the format used in Apple's reports is Sym + OffsetFromSym. Otherwise,
     * the format used is imageBaseAddress + offsetToIP */
    if (frameInfo.symbolInfo != nil) {
        NSString *symbolName = frameInfo.symbolInfo.symbolName;

        /* Apple strips the _ symbol prefix in their reports. */
        if ([symbolName rangeOfString: @"_"].location == 0 && [symbolName length] > 1) {
            switch (report.systemInfo.operatingSystem) {
                case PLCrashReportOperatingSystemMacOSX:
                case PLCrashReportOperatingSystemiPhoneOS:
                case PLCrashReportOperatingSystemAppleTVOS:
                case PLCrashReportOperatingSystemiPhoneSimulator:
                    symbolName = [symbolName substringFromIndex: 1];
                    break;

                default:
                    break;
            }
        }
        
        
        uint64_t symOffset = frameInfo.instructionPointer - frameInfo.symbolInfo.startAddress;
        symbolString = [NSString stringWithFormat: @"%@ + %" PRId64, symbolName, symOffset];
    } else {
        symbolString = [NSString stringWithFormat: @"0x%" PRIx64 " + %" PRId64, baseAddress, pcOffset];
    }

    /* Note that width specifiers are ignored for %@, but work for C strings.
     * UTF-8 is not correctly handled with %s (it depends on the system encoding), but
     * UTF-16 is supported via %S, so we use it here */
    return [NSString stringWithFormat: @"%-4ld%-35S 0x%0*" PRIx64 " %@\n",
            (long) frameIndex,
            (const uint16_t *)[imageName cStringUsingEncoding: NSUTF16StringEncoding],
            lp64 ? 16 : 8, frameInfo.instructionPointer,
            symbolString];
}

@end
