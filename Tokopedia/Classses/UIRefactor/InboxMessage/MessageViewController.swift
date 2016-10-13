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
    private var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    
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
        
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
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
        let message = messages[indexPath.item]
        
        return avatars[message.senderId]
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        self.fetchMessages(self.nextPage)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 20
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if(indexPath.item % 3 == 0) {
            let message = messages[indexPath.item]
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        
        return nil
        
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

            let dateString = message.message_reply_time.formatted            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
            
            let dateObj = dateFormatter.dateFromString(dateString)!
            
            if(message.user_id == self.senderId) {
                self.addMessage(self.senderId, text: message.message_reply, senderName: "",date: dateObj)
            } else {
                self.addMessage(message.user_id, text: message.message_reply, senderName: message.user_name, date: dateObj)
                let image = UIImage(data: NSData(contentsOfURL: NSURL(string: message.user_image)!)!)
                
                avatars[message.user_id] = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width))
                
            }
        })
        
        self.finishReceivingMessage()
    }
    
    func addMessage(id: String, text: String, senderName: String, date: NSDate) {
        let message = JSQMessage(senderId: id, senderDisplayName: senderName, date: date, text: text)
        messages.insert(message, atIndex: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    


}
