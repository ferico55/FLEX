//
//  InboxTalk.swift
//  Tokopedia
//
//  Created by Elly Susilowati on 10/20/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class InboxTalk : MorePage
{
    var more = MorePage()
    let comment = app.tables["talkList"].cells.buttons.matching(identifier: "totalComment").element(boundBy: 0)
    let follow = app.tables["talkList"].cells.buttons.matching(identifier: "follow").element(boundBy: 0)
    let filter = app.buttons.staticTexts["Semua Diskusi"]
    //let reviewButton = app.tables.staticTexts["Share ke Teman"]
    let writeTalk = app.otherElements.staticTexts["talkField"]
    let writeTalkType = app.otherElements.staticTexts["talkField"].typeText("auti talk from machine")
    let attach = app.buttons["attach"]
    let kirim = app.buttons["kirim"]
    
    func goToDetail()
    {
        more.goToInboxTalk()
        waitFor(element: comment, status: .Exists)
        comment.tap()
    }
    
//    func insertTalk(komen: String)
//    {
//
//        waitFor(element: writeTalk, status: .Exists)
//        writeTalk.tap()
//        writeTalk.typeText(komen)
//        kirim.tap()
//        //return CheckTalk()
//    }
    func insertTalk()
    {
        waitFor(element: writeTalk, status: .Exists)
        writeTalk.tap()
        //writeTalk.typeText("auto talk from machine")
        writeTalkType
        kirim.tap()
    }

    
}
