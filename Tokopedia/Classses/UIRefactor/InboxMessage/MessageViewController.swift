//
//  MessageViewController.swift
//  Tokopedia
//
//  Created by Tonito Acen on 10/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class MessageViewController: JSQMessagesViewController {
    var messageTitle = ""
    var messageId: String!
    
    private var messages = [JSQMessage]()
    private var outgoingBubbleImageView: JSQMessagesBubbleImage!
    private var incomingBubbleImageView: JSQMessagesBubbleImage!
    private var nextPage: String?
    
    lazy var fetchMessageManager : TokopediaNetworkManager = {
       var manager = TokopediaNetworkManager()
        manager.isUsingHmac = true
        return manager
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputToolbar.contentView.leftBarButtonItem = nil
        title = messageTitle
        setupBubbles()
        fetchMessages("1")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: JSQMessageDataSource
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.whiteColor()
        } else {
            cell.textView!.textColor = UIColor.blackColor()
        }
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        self.fetchMessages(self.nextPage)
    }
    
    //MARK: Bubble Setup
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    //MARK: Network
    private func fetchMessages(page: String!) {
        fetchMessageManager .
            requestWithBaseUrl(
                NSString.kunyitUrl(),
                path: "/v1/message/detail",
                method: .GET,
                parameter: ["message_id" : messageId, "page" : page, "per_page" : "10"],
                mapping: InboxMessageDetail.mapping(),
                onSuccess: { [unowned self] (result, operation) in
                    let result = result.dictionary()[""] as! InboxMessageDetail
                    self.didReceiveMessages(result.result.list as! [InboxMessageDetailList])
                    
                    self.showLoadEarlierMessagesHeader = result.result.paging.isShowNext
                    self.nextPage = result.result.paging.uriNext.valueForKey("page")
                },
                onFailure: { (error) in
            
                }
        )
    }
    
    private func didReceiveMessages(messages: [InboxMessageDetailList]) {
        messages.forEach({ (message) in
            let message = message
            if(message.user_id == self.senderId) {
                self.addMessage(self.senderId, text: message.message_reply)
            } else {
                self.addMessage(message.user_id, text: message.message_reply)
            }
        })
        
        self.finishReceivingMessage()
    }
    
    func addMessage(id: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: "", text: text)
        messages.insert(message, atIndex: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    


}
