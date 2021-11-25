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

@import KarteCore;

NS_ASSUME_NONNULL_BEGIN

@interface KRTTracker (RemoteNotification)

/// 通知の効果測定用のイベント（message_click）を発火します。
///
/// - Parameter userInfo: 通知ペイロード
+ (void)trackClickWithUserInfo:(NSDictionary *)userInfo;

@end

NS_ASSUME_NONNULL_END
