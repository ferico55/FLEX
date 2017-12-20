//
//  NotificationInbox.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/14/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON

final class NotificationInbox: NSObject, NSCoding {
    let ticket: Int
    let review: Int
    var message: Int
    let talk: Int
    
    init(
        ticket: Int,
        review: Int,
        message: Int,
        talk: Int
    ) {
        self.ticket = ticket
        self.review = review
        self.message = message
        self.talk = talk
    }
    
    required convenience init?(coder decoder: NSCoder) {
        self.init(
            ticket: decoder.decodeInteger(forKey: "ticket"),
            review: decoder.decodeInteger(forKey: "review"),
            message: decoder.decodeInteger(forKey: "message"),
            talk: decoder.decodeInteger(forKey: "talk")
        )
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.ticket, forKey: "ticket")
        aCoder.encode(self.review, forKey: "review")
        aCoder.encode(self.message, forKey: "message")
        aCoder.encode(self.talk, forKey: "talk")
    }
}

extension NotificationInbox : JSONAbleType {
    static func fromJSON(_ source: [String: Any]) -> NotificationInbox {
        let json = JSON(source)
        
        let ticket = json["inbox_ticket"].int ?? 0
        let review = json["inbox_review"].int ?? 0
        let message = json["inbox_message"].int ?? 0
        let talk = json["inbox_talk"].int ?? 0
        
        return NotificationInbox(ticket: ticket, review: review, message: message, talk: talk)
    }
}
