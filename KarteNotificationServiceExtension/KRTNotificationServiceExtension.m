//
//  Copyright 2021 PLAID, Inc.
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

#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

#import "KRTNotificationServiceExtension.h"
#import "KarteAttributesPayload.h"

static const NSString *KarteNotificationKey = @"krt_push_notification";
static const NSString *KarteMassPushNotificationKey = @"krt_mass_push_notification";


@interface KRTNotificationServiceExtension ()
@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;
@property (nonatomic, strong) UNMutableNotificationContent *modifiedContent;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

- (NSURL *)processFromTemporaryFileURL:(NSURL *)temporaryFileURL withURL:(NSURL *)URL;
- (NSString *)uniformTypeIdentifierFromData:(NSData *)data;
@end


@implementation KRTNotificationServiceExtension

- (NSURL *)processFromTemporaryFileURL:(NSURL *)temporaryFileURL withURL:(NSURL *)URL
{
    NSString *suffix = [NSString stringWithFormat:@"%@_%@", [[NSUUID UUID] UUIDString], URL.lastPathComponent];
    NSURL *destinationFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:suffix]];

    NSError *error;
    [[NSFileManager defaultManager] moveItemAtURL:temporaryFileURL toURL:destinationFileURL error:&error];

    if (error) {
        NSLog(@"Error copying file at %@ to %@: %@", temporaryFileURL.path, destinationFileURL.path, error.localizedDescription);
        return nil;
    }

    return destinationFileURL;
}

- (BOOL)hasKnownExtensionsFromFileURL:(NSURL *)fileURL
{
    NSString *fileName = fileURL.lastPathComponent.lowercaseString;

    NSArray *knownExtensions = @[@"jpg", @"jpeg", @"png", @"gif", @"aif", @"aiff", @"mp3", @"mpg", @"mpeg", @"mp4", @"m4a", @"wav", @"avi"];

    BOOL hasExtension = NO;
    for (NSString *extension in knownExtensions) {
        if ([fileName hasSuffix:extension]) {
            hasExtension = YES;
            break;
        }
    }

    return hasExtension;
}

- (NSString *)uniformTypeIdentifierFromMIMEType:(NSString *)mimeType
{
    if (!mimeType) {
        return nil;
    }

    UTType *type = [UTType typeWithMIMEType: mimeType];
    if (!type) {
        return nil;
    }

    UTType *acceptedTypes[] = {
        UTTypeJPEG, UTTypePNG, UTTypeGIF,
        UTTypeMPEG, UTTypeMPEG2Video, UTTypeMPEG4Movie, UTTypeAVI,
        UTTypeAIFF, UTTypeWAV, UTTypeMP3, UTTypeMPEG4Audio};

    NSString *inferredTypeIdentifier = nil;
    int length = sizeof(acceptedTypes) / sizeof(acceptedTypes[0]);
    for (int i = 0; i < length; i++) {
        if ([type conformsToType:acceptedTypes[i]]) {
            inferredTypeIdentifier = type.identifier;
            break;
        }
    }

    return inferredTypeIdentifier;
}

- (NSString *)uniformTypeIdentifierFromData:(NSData *)data
{
    NSUInteger length = 16;

    if (data.length < length) {
        return nil;
    }

    uint8_t header[length];
    [data getBytes:&header length:length];

    NSDictionary *types = [self uniformTypeIdentifierMap];

    for (NSString *typeIdentifier in types) {
        NSArray *signatures = types[typeIdentifier];
        for (NSDictionary *signature in signatures) {
            NSUInteger offset = [signature[@"offset"] unsignedIntegerValue];
            NSUInteger signatureLength = [signature[@"length"] unsignedIntegerValue];
            NSData *bytes = signature[@"bytes"];

            if (memcmp(header + offset, bytes.bytes, signatureLength) == 0) {
                return typeIdentifier;
            }
        }
    }

    NSLog(@"Unable to infer type identifier for header: %@", [NSData dataWithBytes:header length:length]);

    return nil;
}

- (NSDictionary *)uniformTypeIdentifierMap
{
    // Offset 0
    uint8_t jpeg[] = {0xFF, 0xD8, 0xFF, 0xE0};
    uint8_t jpegAlt[] = {0xFF, 0xD8, 0xFF, 0xE2};
    uint8_t jpegAlt2[] = {0xFF, 0xD8, 0xFF, 0xE3};
    uint8_t png[] = {0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A};
    uint8_t gif[] = {0x47, 0x49, 0x46, 0x38};
    uint8_t aiff[] = {0x46, 0x4F, 0x52, 0x4D, 0x00};
    uint8_t mp3[] = {0x49, 0x44, 0x33};
    uint8_t mpeg[] = {0x00, 0x00, 0x01, 0xBA};
    uint8_t mpegAlt[] = {0x00, 0x00, 0x01, 0xB3};

    // Offset 4
    uint8_t mp4v1[] = {0x66, 0x74, 0x79, 0x70, 0x6D, 0x70, 0x34, 0x31};
    uint8_t mp4v2[] = {0x66, 0x74, 0x79, 0x70, 0x6D, 0x70, 0x34, 0x32};
    uint8_t mp4mmp4[] = {0x66, 0x74, 0x79, 0x70, 0x6D, 0x6D, 0x70, 0x34};
    uint8_t mp4isom[] = {0x66, 0x74, 0x79, 0x70, 0x69, 0x73, 0x6f, 0x6d};
    uint8_t m4a[] = {0x66, 0x74, 0x79, 0x70, 0x4D, 0x34, 0x41, 0x20};

    // Offset 8
    uint8_t wav[] = {0x57, 0x41, 0x56, 0x45};
    uint8_t avi[] = {0x41, 0x56, 0x49, 0x20};

    NSDictionary * (^sig)(NSUInteger, uint8_t *, NSUInteger) = ^NSDictionary *(NSUInteger offset, uint8_t *bytes, NSUInteger length)
    {
        NSData *data = [NSData dataWithBytes:bytes length:length];
        return @{ @"offset": @(offset),
                  @"length": @(length),
                  @"bytes": data };
    };

    NSDictionary *types = @{
        UTTypeJPEG.identifier: @[sig(0, jpeg, sizeof(jpeg)),
                                 sig(0, jpegAlt, sizeof(jpegAlt)),
                                 sig(0, jpegAlt2, sizeof(jpegAlt2))],
        UTTypePNG.identifier: @[sig(0, png, sizeof(png))],
        UTTypeGIF.identifier: @[sig(0, gif, sizeof(gif))],
        UTTypeAIFF.identifier: @[sig(0, aiff, sizeof(aiff))],
        UTTypeWAV.identifier: @[sig(8, wav, sizeof(wav))],
        UTTypeAVI.identifier: @[sig(8, avi, sizeof(avi))],
        UTTypeMP3.identifier: @[sig(0, mp3, sizeof(mp3))],
        UTTypeMPEG4Movie.identifier: @[sig(4, mp4v1, sizeof(mp4v1)),
                                       sig(4, mp4v2, sizeof(mp4v2)),
                                       sig(4, mp4mmp4, sizeof(mp4mmp4)),
                                       sig(4, mp4isom, sizeof(mp4isom))],
        UTTypeMPEG4Audio.identifier: @[sig(4, m4a, sizeof(m4a))],
        UTTypeMPEG.identifier: @[sig(0, mpeg, sizeof(mpeg)),
                                 sig(0, mpegAlt, sizeof(mpegAlt))]
    };

    return types;
}
- (UNNotificationAttachment *)attachmentWithTemporaryFileURL:(NSURL *)temporaryFileURL withURL:(NSURL *)URL mimeType:(NSString *)mimeType
{
    NSURL *fileURL = [self processFromTemporaryFileURL:temporaryFileURL withURL:URL];
    if (!fileURL) {
        return nil;
    }

    NSMutableDictionary *options = [NSMutableDictionary dictionary];

    BOOL hasExtension = [self hasKnownExtensionsFromFileURL:fileURL];
    if (!hasExtension) {
        NSString *uniformTypeIdentifier = [self uniformTypeIdentifierFromMIMEType:mimeType];
        if (!uniformTypeIdentifier.length) {
            NSData *data = [NSData dataWithContentsOfFile:fileURL.path
                                                  options:NSMappedRead
                                                    error:nil];
            uniformTypeIdentifier = [self uniformTypeIdentifierFromData:data];
        }

        if (uniformTypeIdentifier) {
            [options setObject:uniformTypeIdentifier forKey:UNNotificationAttachmentOptionsTypeHintKey];
        }
    }

    NSError *error;
    UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@""
                                                                                          URL:fileURL
                                                                                      options:options
                                                                                        error:&error];
    if (error) {
        NSLog(@"Error creating attachment: %@", error.localizedDescription);
        return nil;
    }

    return attachment;
}

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent *_Nonnull))contentHandler
{
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    self.modifiedContent = [request.content mutableCopy];

    KarteAttributesPayload *payload = [[KarteAttributesPayload alloc] initWithUserInfo:request.content.userInfo];
    if (!payload) {
        contentHandler(self.bestAttemptContent);
        return;
    }

    self.downloadTask = [[NSURLSession sharedSession] downloadTaskWithURL:payload.url completionHandler:^(NSURL *_Nullable location, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        if (error) {
            self.contentHandler(self.bestAttemptContent);
            return;
        }

        NSString *mimeType = nil;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            mimeType = httpResponse.allHeaderFields[@"Content-Type"];
        }

        UNNotificationAttachment *attachment = [self attachmentWithTemporaryFileURL:location
                                                                            withURL:payload.url
                                                                           mimeType:mimeType];
        if (!attachment) {
            self.contentHandler(self.bestAttemptContent);
            return;
        }

        self.modifiedContent.attachments = @[attachment];
        self.contentHandler(self.modifiedContent);
    }];
    [self.downloadTask resume];
}

- (void)serviceExtensionTimeWillExpire
{
    [self.downloadTask cancel];
    self.contentHandler(self.bestAttemptContent);
}

- (BOOL)canHandleRemoteNotification:(NSDictionary *)userInfo
{
    if (!userInfo) {
        return NO;
    }
    return userInfo[KarteNotificationKey] != nil || userInfo[KarteMassPushNotificationKey] != nil;
}

@end
