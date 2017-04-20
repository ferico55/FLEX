//
//  MessageViewController.swift
//  Tokopedia
//
//  Created by Tonito Acen on 10/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import JLRoutes
import SwiftOverlays

class MessageViewController: JSQMessagesViewController {
    var messageTitle = ""
    var messageSubtitle = ""
    var messageId: String!
    var messageTabName: String!
    var onMessagePosted: ((String) -> Void)!
    var labelColorsCollection = [
        "1" : UIColor(red: 248.0/255.0, green: 148.0/255.0, blue: 6.0/255.0, alpha: 1.0), //admin
        "2" : UIColor(red: 70.0/255.0, green: 136.0/255.0, blue: 71.0/255.0, alpha: 1.0), //pengguna
        "3" : UIColor(red: 185.0/255.0, green: 74.0/255.0, blue: 72.0/255.0, alpha: 1.0), //penjual
        "4" : UIColor(red: 42.0/255.0, green: 180.0/255.0, blue: 194.0/255.0, alpha: 1.0), //pembeli
        "5" : UIColor(red: 153.0/255.0, green: 153.0/255.0, blue: 153.0/255.0, alpha: 1.0) // system
    ]

    fileprivate var messages = [JSQMessage]()
    fileprivate var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    fileprivate var userLabelColors = Dictionary<String, UIColor>()
    
    fileprivate var outgoingBubbleImageView: JSQMessagesBubbleImage!
    fileprivate var incomingBubbleImageView: JSQMessagesBubbleImage!
    fileprivate var nextPage: String?
    fileprivate var indicator = UIActivityIndicatorView()
    fileprivate let route = JLRoutes()
    
    lazy var titleView : UIView = {
        let vw = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width - 120, height: 44))
        return vw
    }()
    
    lazy var fetchMessageManager : TokopediaNetworkManager = {
       var manager = TokopediaNetworkManager()
        manager.isUsingHmac = true
        return manager
    }()
    
    lazy var sendMessageManager : TokopediaNetworkManager = {
        var manager = TokopediaNetworkManager()
        manager.isUsingHmac = true
        return manager
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        AnalyticsManager.trackScreenName("Inbox Message Detail Page")
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        //set margin between bubble, thus the bubble will adjust how it appear on iPad
        collectionView.collectionViewLayout.messageBubbleLeftRightMargin = 50.0
        
        self.topContentAdditionalInset = 30
        self.inputToolbar.isHidden = true
        inputToolbar.contentView.leftBarButtonItem = nil
        title = messageTitle
        setupBubbles()
        setupTitle()
        setupRoute()
        fetchMessages("1")
    }
    
    fileprivate func setupRoute(){
        route.addRoute("/invoice.pl") { [unowned self] dictionary in
            
            guard let pdf = dictionary["pdf"] else {return false}
            guard let id = dictionary["id"] else {return false}
            
            let url = "\(NSString.tokopediaUrl())/invoice.pl?pdf=\(pdf)&id=\(id)"
            
            NavigateViewController.navigateToInvoice(from: self, withInvoiceURL: url)
            
            return true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: JSQMessageDataSource
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item]
        
        if(message.senderId != self.senderId) {
            var senderName = message.senderDisplayName
            if((senderName!.characters.count) > 30) {
                senderName = "\(senderName![(senderName!.index((senderName!.startIndex), offsetBy: 0))...(senderName!.index((senderName!.startIndex), offsetBy: 30))])..."
            }
            
            return NSAttributedString(string: senderName!, attributes: [NSForegroundColorAttributeName : userLabelColors[message.senderId]!, NSFontAttributeName : UIFont.microThemeMedium()])
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            return 0
        } else {
            return 20
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.white
        } else {
            cell.textView!.textColor = UIColor.black
        }
        
        cell.textView!.delegate = self
        cell.textView!.linkTextAttributes = [NSForegroundColorAttributeName : UIColor.blue, NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue]
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, at indexPath: IndexPath!) {
        if(UIDevice.current.userInterfaceIdiom == .phone) {
            let message = messages[indexPath.item]
            
            let controller = NavigateViewController()
            controller.navigateToProfile(from: self, withUserID: message.senderId)
        }

    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item]
        
        return avatars[message.senderId]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        self.fetchMessages(self.nextPage)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        if(indexPath.item == 0) {
            return 30
        }

        if(indexPath.item > 0) {
            let message = messages[indexPath.item - 1]
            let previousMessage = self.messages[indexPath.item]
            let dateString = NSAttributedString(string: JSQMessagesTimestampFormatter.shared().relativeDate(for: message.date))
            let previousDateString = NSAttributedString(string: JSQMessagesTimestampFormatter.shared().relativeDate(for: previousMessage.date))
            
            if(dateString != previousDateString) {
                return 30
            }
        }
        
        return 0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item]
        
        if(indexPath.item == 0) {
            return NSAttributedString(string: JSQMessagesTimestampFormatter.shared().relativeDate(for: message.date))
        }
        
        if(indexPath.item > 0) {
            let previousMessage = self.messages[indexPath.item - 1]
            let dateString = NSAttributedString(string: JSQMessagesTimestampFormatter.shared().relativeDate(for: message.date))
            let previousDateString = NSAttributedString(string: JSQMessagesTimestampFormatter.shared().relativeDate(for: previousMessage.date))

            if(dateString != previousDateString) {
                return NSAttributedString(string: JSQMessagesTimestampFormatter.shared().relativeDate(for: message.date))
            }
        }
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return 20
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item]
        
        return NSAttributedString(string: JSQMessagesTimestampFormatter.shared().time(for: message.date))

    }
        
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        AnalyticsManager.trackEventName("clickMessage", category: GA_EVENT_CATEGORY_INBOX_MESSAGE, action: GA_EVENT_ACTION_SEND, label: "Message")
        let message = JSQMessage(senderId: self.senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages.append(message!)
        
        self.finishSendingMessage(animated: true)
        
        sendMessageManager .
            request(withBaseUrl: NSString.kunyitUrl(),
                               path: "/v1/message/reply",
                               method: .POST,
                               parameter: ["reply_message" : text, "message_id" : self.messageId],
                               mapping: InboxMessageAction.mapping(),
                               onSuccess: { [weak self] (result, operation) in
                                    guard let `self` = self else { return }
                                    let result = result.dictionary()[""] as! InboxMessageAction
                                    if(result.data.is_success == "1") {
                                        self.onMessagePosted(text)
                                    } else {
                                        self.receiveErrorSendMessage(result.message_error as [AnyObject])
                                    }
                               },
                               onFailure: {  [weak self] (error) in
                                    guard let `self` = self else { return }
                                    self.receiveErrorSendMessage([])
                               }
                
        )
    }
    
    fileprivate func receiveErrorSendMessage(_ errors: [AnyObject]) {
        AnalyticsManager.trackEventName("clickMessage", category: GA_EVENT_CATEGORY_INBOX_MESSAGE, action: GA_EVENT_ACTION_ERROR, label: "Message")
        let stickyAlert = StickyAlertView(errorMessages: errors, delegate: self)
        stickyAlert? .show()
        let lastMessage = self.messages.last?.text
        self.messages.removeLast()
        
        self.finishSendingMessage(animated: true)
        self.inputToolbar.contentView.textView.text = lastMessage
    }
    
    //MARK: TextView Delegate
    override func textView(_ textView: UITextView, shouldInteractWith url: Foundation.URL, in characterRange: NSRange) -> Bool {
        guard !route.routeURL(url) else {return false}
        
        if(url.scheme?.lowercased() == "http" || url.scheme?.lowercased() == "https") {
            if(url.host == "www.tokopedia.com") {
                TPRoutes.routeURL(url)
            } else {
                self.openWebViewWithUrl("https://tkp.me/r?url=\(url.absoluteString.replacingOccurrences(of: "*", with: "."))")
            }
            return false
        }
        
        return true
    }
    
    //MARK: Bubble Setup
    fileprivate func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
        incomingBubbleImageView = factory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    fileprivate func setupTitle() {
        let titleLabel = UILabel(frame: CGRect.zero)
        let betweenLabel = UILabel(frame: CGRect.zero)
        
        titleView.addSubview(titleLabel)
        titleView.addSubview(betweenLabel)
        
        titleLabel.text = messageTitle
        titleLabel.font = UIFont.largeThemeMedium()
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.mas_makeConstraints { (make) in
            make?.top.left().right().equalTo()(self.titleView)
        }
        
        
        betweenLabel.text = messageSubtitle
        betweenLabel.font = UIFont.smallTheme()
        betweenLabel.textAlignment = .center
        betweenLabel.textColor = UIColor.white
        betweenLabel.mas_makeConstraints { (make) in
            make?.top.equalTo()(titleLabel.mas_bottom)
            make?.left.right().equalTo()(self.titleView)
        }
        
        self.navigationItem.titleView = titleView
    }
    
    //MARK: Network
    fileprivate func fetchMessages(_ page: String!) {
        showLoading()
        fetchMessageManager.request(
            withBaseUrl: NSString.kunyitUrl(),
            path: "/v1/message/detail",
            method: .GET,
            parameter: ["message_id" : messageId, "page" : page, "per_page" : "10", "nav" : messageTabName],
            mapping: InboxMessageDetail.mapping(),
            onSuccess: { [unowned self] (result, operation) in
                
                let messageDetail = result.dictionary()[""] as! InboxMessageDetail
                if((messageDetail.message_error == nil)) {
                    self.didReceiveMessages(messageDetail.result.list as! [InboxMessageDetailList])
                    let detailResult = messageDetail.result
                    if (detailResult?.textarea_reply == "1") {
                        self.inputToolbar.isHidden = false
                    }
                    let messageUsers = messageDetail.result.conversation_between.map({"\(($0 as! InboxMessageDetailBetween).user_name)"}).joined(separator: ", ")
                    if(messageUsers != "") {
                        self.messageSubtitle = "Antara : \(messageUsers)"
                    }
                    self.setupTitle()
                    
                    self.showLoadEarlierMessagesHeader = messageDetail.result.paging.isShowNext
                    self.nextPage = TokopediaNetworkManager.getPageFromUri(messageDetail.result.paging.uri_next)
                }
                self.hideLoading()
            },
            onFailure: { (error) in
                self.hideLoading()
        }
        )
    }
    
    fileprivate func showLoading() {
        indicator.startAnimating()
        indicator.activityIndicatorViewStyle = .gray
        
        self.view.addSubview(indicator)
        indicator.mas_makeConstraints { (make) in
            make?.left.top().right().equalTo()(self.collectionView)
            make?.height.equalTo()(44)
        }
    }
    
    fileprivate func hideLoading() {
        indicator.stopAnimating()
        self.topContentAdditionalInset = 0
    }
    
    fileprivate func didReceiveMessages(_ messages: [InboxMessageDetailList]) {
        messages.forEach({ (message) in
            let message = message
            let dateString = message.message_reply_time.formatted
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
            dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
            
            let dateObj = dateFormatter.date(from: dateString!)!
            let messageReply = NSString.extracTKPMEUrl(message.message_reply)

            if (message.user_label_id == String(describing: UserLabelMessage.Administrator)){
                inputToolbar.isHidden = true
            }
            
            if(message.user_id == self.senderId) {
                self.addMessage(self.senderId, text: messageReply , senderName: "",date: dateObj)
            } else {
                self.addMessage(message.user_id, text: messageReply, senderName: "\(message.user_label) - \(message.user_name)", date: dateObj)
                let imageView = UIImageView(frame: CGRect.zero)
                imageView.setImageWith(NSURL(string: message.user_image) as URL!, placeholderImage: UIImage(named: "default-boy.png"))
                
                avatars[message.user_id] = JSQMessagesAvatarImageFactory.avatarImage(with: imageView.image, diameter: UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width))
                userLabelColors[message.user_id] = labelColorsCollection[message.user_label_id]
                
            }
        })
        
        self.finishReceivingMessage()
    }
    
    func addMessage(_ id: String, text: String, senderName: String, date: Date) {
        let message = JSQMessage(senderId: id, senderDisplayName: senderName, date: date, text: text)
        messages.insert(message!, at: 0)
    }
    
    fileprivate func openWebViewWithUrl(_ url: String) {
        let controller = WebViewController()
        controller.strURL = url
        controller.strTitle = url
        controller.shouldAuthorizeRequest = true
        controller.onTapLinkWithUrl = {[weak self] tappedUrl in
            guard let `self` = self else { return }
            
            if(tappedUrl?.absoluteString == "https://www.tokopedia.com/") {
                self.navigationController!.popViewController(animated: true)
            }
        }
        
        self.navigationController?.pushViewController(controller, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
