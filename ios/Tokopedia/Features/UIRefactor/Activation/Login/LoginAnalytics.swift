//
//  LoginAnalytics.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 07/08/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
class LoginAnalytics {

    func trackLoginErrorEvent(label: String) {
        self.trackLoginEvent(name: "loginError", action: GA_EVENT_ACTION_LOGIN_ERROR, label: label)
    }
    func trackLoginSuccessEvent(label: String) {
        self.trackLoginEvent(name: "loginSuccess", action: GA_EVENT_ACTION_LOGIN_SUCCESS, label: label)
    }
    func trackLoginClickEvent(label: String) {
        self.trackLoginEvent(name: "clickLogin", action: GA_EVENT_ACTION_CLICK, label: label)
    }
    //    MARK: - GA_EVENT_CATEGORY_LOGIN
    func trackLoginEvent(name: String, action: String, label: String) {
        AnalyticsManager.trackEventName(name,
                                        category: GA_EVENT_CATEGORY_LOGIN,
                                        action: action,
                                        label: label)
    }
    //    MARK: - Touch Id
    func trackTouchIdClickEvent(name: String, label: String) {
        AnalyticsManager.trackEventName(name,
                                        category: GA_EVENT_CATEGORY_SETUP_TOUCHID,
                                        action: GA_EVENT_ACTION_CLICK,
                                        label: label)
    }
    //    MARK: - Mo engage event
    func trackMoEngageEvent(with login: Login) {
        let attributes = ["mobile_number": login.result.phoneNumber ?? "", "customer_id": login.result.user_id ?? "", "medium": login.medium ?? "", "email": login.result.email ?? ""]
        AnalyticsManager.moEngageTrackEvent(withName: "Login", attributes: attributes)
    }
}
