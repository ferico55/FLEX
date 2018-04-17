//
//  GroupChatTableViewManager.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 23/03/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import React
import SwiftyJSON

@objc (GroupChatTableViewManager)
public class GroupChatTableViewManager: RCTViewManager {
    // Return the native view that represents your React component
    override public func view() -> UIView! {
        return GroupChatTableView()
    }
    
    @objc public func scrollToEnd(_ reactTag: NSNumber){
        self.bridge?.uiManager.addUIBlock { (uiManager: RCTUIManager?, viewRegistry:[NSNumber : UIView]?) in
            guard let viewRegistry = viewRegistry, let reactView = viewRegistry[reactTag], let delegate = reactView as? GroupChatTableViewDelegate else {
                return
            }
            delegate.scrollToEnd()
        }
    }
    
    @objc public func appendNewMessage(_ reactTag: NSNumber, data:[String: Any]){
        self.bridge?.uiManager.addUIBlock { (uiManager: RCTUIManager?, viewRegistry:[NSNumber : UIView]?) in
            guard let viewRegistry = viewRegistry, let reactView = viewRegistry[reactTag], let delegate = reactView as? GroupChatTableViewDelegate else {
                return
            }
            let json = JSON(data)
            let chatItem = ChatItem(json: json)
            delegate.appendNewMessage(data: chatItem)
        }
    }
    
    @objc public func mergeQueueMessages(_ reactTag: NSNumber, data:NSArray, scrolling: Bool = true){
        self.bridge?.uiManager.addUIBlock { (uiManager: RCTUIManager?, viewRegistry:[NSNumber : UIView]?) in
            guard let viewRegistry = viewRegistry, let reactView = viewRegistry[reactTag], let delegate = reactView as? GroupChatTableViewDelegate else {
                return
            }
            var newData = [ChatItem]()
            let json = JSON(data)
            
            for value in json.arrayValue {
                let chatItem = ChatItem(json: value)
                newData.append(chatItem)
            }
            
            delegate.mergeData(data: newData, scrolling: scrolling)
        }
    }
    
    @objc public func loadMoreMessages(_ reactTag: NSNumber, data: NSArray){
        self.bridge?.uiManager.addUIBlock { (uiManager: RCTUIManager?, viewRegistry:[NSNumber : UIView]?) in
            guard let viewRegistry = viewRegistry, let reactView = viewRegistry[reactTag], let delegate = reactView as? GroupChatTableViewDelegate else {
                return
            }
            let json = JSON(data)
            let groupChatDataSources = GroupChatDataSources(json: json)
            delegate.loadMoreData(data: groupChatDataSources)
        }
    }
}
