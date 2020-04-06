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

import Quick
import Nimble
@testable import KarteCore

class EventFieldNameSpec: QuickSpec {
    
    override func spec() {
        describe("a event field name") {
            describe("its raw value") {
                context("when the event field name is campaignId") {
                    it("is `campaign_id`") {
                        expect(EventFieldName.campaignId.rawValue).to(equal("campaign_id"))
                    }
                }
                context("when the event field name is shortenId") {
                    it("is `shorten_id`") {
                        expect(EventFieldName.shortenId.rawValue).to(equal("shorten_id"))
                    }
                }
                context("when the event field name is fcmToken") {
                    it("is `fcm_token`") {
                        expect(EventFieldName.fcmToken.rawValue).to(equal("fcm_token"))
                    }
                }
                context("when the event field name is subscribe") {
                    it("is `subscribe`") {
                        expect(EventFieldName.subscribe.rawValue).to(equal("subscribe"))
                    }
                }
                context("when the event field name is massPushId") {
                    it("is `mass_push_id`") {
                        expect(EventFieldName.massPushId.rawValue).to(equal("mass_push_id"))
                    }
                }
                context("when the event field name is userId") {
                    it("is `user_id`") {
                        expect(EventFieldName.userId.rawValue).to(equal("user_id"))
                    }
                }
                context("when the event field name is taskId") {
                    it("is `task_id`") {
                        expect(EventFieldName.taskId.rawValue).to(equal("task_id"))
                    }
                }
                context("when the event field name is scheduleId") {
                    it("is `schedule_id`") {
                        expect(EventFieldName.scheduleId.rawValue).to(equal("schedule_id"))
                    }
                }
                context("when the event field name is sourceUserId") {
                    it("is `source_user_id`") {
                        expect(EventFieldName.sourceUserId.rawValue).to(equal("source_user_id"))
                    }
                }
                context("when the event field name is target") {
                    it("is `target`") {
                        expect(EventFieldName.target.rawValue).to(equal("target"))
                    }
                }
                context("when the event field name is newVisitorId") {
                    it("is `new_visitor_id`") {
                        expect(EventFieldName.newVisitorId.rawValue).to(equal("new_visitor_id"))
                    }
                }
                context("when the event field name is oldVisitorId") {
                    it("is `old_visitor_id`") {
                        expect(EventFieldName.oldVisitorId.rawValue).to(equal("old_visitor_id"))
                    }
                }
                context("when the event field name is viewId") {
                    it("is `view_id`") {
                        expect(EventFieldName.viewId.rawValue).to(equal("view_id"))
                    }
                }
                context("when the event field name is viewName") {
                    it("is `view_name`") {
                        expect(EventFieldName.viewName.rawValue).to(equal("view_name"))
                    }
                }
                context("when the event field name is title") {
                    it("is `title`") {
                        expect(EventFieldName.title.rawValue).to(equal("title"))
                    }
                }
                context("when the event field name is localEventDate") {
                    it("is `_local_event_date`") {
                        expect(EventFieldName.localEventDate.rawValue).to(equal("_local_event_date"))
                    }
                }
                context("when the event field name is retry") {
                    it("is `_retry`") {
                        expect(EventFieldName.retry.rawValue).to(equal("_retry"))
                    }
                }
            }
            
            describe("its field") {
                context("when the event field name is campaignId") {
                    it("is `campaign_id") {
                        expect(field(.campaignId)).to(equal("campaign_id"))
                    }
                }
            }
        }
    }
}
