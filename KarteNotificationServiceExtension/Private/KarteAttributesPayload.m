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

#import "KarteAttributesPayload.h"

#define kKRTEXTNotificationAttributesKey @"krt_attributes"
#define kKRTEXTNotificationAttachmentURLKey @"attachment_url"


@implementation KarteAttributesPayload

- (instancetype)initWithUserInfo:(NSDictionary *)userInfo
{
    self = [super init];
    if (self) {
        NSData *data = [userInfo[kKRTEXTNotificationAttributesKey] dataUsingEncoding:NSUTF8StringEncoding];
        if (!data) {
            return nil;
        }

        NSError *error = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            return nil;
        }

        NSString *urlString = json[kKRTEXTNotificationAttachmentURLKey];
        if (!urlString) {
            return nil;
        }

        NSURL *url = [NSURL URLWithString:urlString];
        if (!url) {
            return nil;
        }

        self.url = url;
    }
    return self;
}
@end
