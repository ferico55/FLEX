//
//  ProductDetailDiscussionNode.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 8/14/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render

class ProductDetailDiscussionNode: ContainerNode {
    fileprivate let state: ProductDetailState
    fileprivate let didTapAllDiscussion: (ProductUnbox) -> Void
    
    init(identifier: String, state: ProductDetailState, didTapAllDiscussion: @escaping (ProductUnbox) -> Void) {
        self.state = state
        self.didTapAllDiscussion = didTapAllDiscussion
        
        super.init(identifier: identifier)
        
        guard let _ = state.productDetail?.latestDiscussion else { return }
        
        node.add(children: [
            container().add(children: [
                GlobalRenderComponent.horizontalLine(identifier: "Recommendation-Line-1", marginLeft: 0),
                titleLabel(),
                productDiscussionView(),
                GlobalRenderComponent.horizontalLine(identifier: "Recommendation-Line-2", marginLeft: 0),
                productMoreView(),
                GlobalRenderComponent.horizontalLine(identifier: "Recommendation-Line-3", marginLeft: 0),
            ]),
        ])
    }
    
    private func container() -> NodeType {
        return Node<UIView>() { view, layout, size in
            layout.width = size.width
            layout.flexDirection = .column
            layout.marginTop = 10
            view.backgroundColor = .white
            view.isUserInteractionEnabled = true
        }
    }
    
    private func titleLabel() -> NodeType {
        return Node<UILabel>() { view, layout, _ in
            layout.marginLeft = 15
            layout.height = 60
            view.text = "Diskusi Terakhir"
            view.textColor = .tpPrimaryBlackText()
            view.font = .largeThemeMedium()
        }
    }
    
    private func productDiscussionView() -> NodeType {
        guard let productDetail = state.productDetail,
            let latestDiscussion = productDetail.latestDiscussion else {
            return NilNode()
        }
        
        return Node<UIView>(identifier: "Discussion-Frame-View") { view, layout, _ in
            layout.flexDirection = .row
        }.add(children: [
            Node<UIImageView>() { view, layout, _ in
                layout.marginLeft = 15
                layout.width = 48
                layout.height = 48
                
                view.setImageWith(URL(string: latestDiscussion.userImage), placeholderImage: #imageLiteral(resourceName: "icon_profile_picture"))
                view.contentMode = .scaleAspectFill
                view.clipsToBounds = true
                view.layer.cornerRadius = 4
                view.layer.masksToBounds = true
                view.layer.borderColor = UIColor.tpBorder().cgColor
                view.layer.borderWidth = 1
            },
            productDiscussionInfoView(discussion: latestDiscussion),
        ])
    }
    
    private func productDiscussionInfoView(discussion: ProductTalk) -> NodeType {
        return Node<UIView>(identifier: "Discussion-Info-View") { _, layout, _ in
            layout.marginLeft = 10
        }.add(children: [
            Node<UILabel>() { view, layout, _ in
                layout.height = 22
                view.font = .largeThemeMedium()
                view.textColor = .tpPrimaryBlackText()
                view.text = discussion.userName
            },
            Node<UILabel>() { view, layout, _ in
                layout.height = 16
                view.font = .microTheme()
                view.textColor = .tpDisabledBlackText()
                view.text = discussion.publishTime
            },
            Node<UILabel>() { view, layout, size in
                layout.marginTop = 10
                layout.marginBottom = 10
                layout.marginRight = 15
                layout.width = size.width - 90
                view.font = .title1Theme()
                view.textColor = .tpSecondaryBlackText()
                var discussionMessage = ""
                if let decodeDiscussion = discussion.message.kv_decodeHTMLCharacterEntities() {
                    discussionMessage = NSString.extracTKPMEUrl(decodeDiscussion) as String
                }
                view.text = discussionMessage
                view.numberOfLines = 4
            },
            productReplyView(discussion: discussion),
        ])
    }
    
    private func productReplyView(discussion: ProductTalk) -> NodeType {
        guard discussion.comments.count > 0 else { return NilNode() }
        
        let comment = discussion.comments[0]
        
        return Node<UIView>(identifier: "Reply-Frame-View") { _, layout, _ in
            layout.flexDirection = .row
        }.add(children: [
            Node<UIImageView>() { view, layout, _ in
                layout.width = 24
                layout.height = 24
                
                view.setImageWith(URL(string: comment.userImage), placeholderImage: #imageLiteral(resourceName: "icon_profile_picture"))
                view.contentMode = .scaleAspectFill
                view.clipsToBounds = true
                view.layer.cornerRadius = 2
                view.layer.masksToBounds = true
                view.layer.borderColor = UIColor.tpBorder().cgColor
                view.layer.borderWidth = 1
            },
            productReplyInfoView(comment: comment),
        ])
    }
    
    private func productReplyInfoView(comment: ProductTalkComment) -> NodeType {
        return Node<UIView>(identifier: "Reply-Info-View") { _, layout, _ in
            layout.marginLeft = 10
        }.add(children: [
            Node<UILabel>() { view, layout, _ in
                layout.height = 22
                view.font = .largeThemeMedium()
                view.textColor = .tpPrimaryBlackText()
                view.text = comment.isSeller ? comment.shopName : comment.userName
            },
            productReplyDescriptionView(comment: comment),
            Node<UILabel>() { view, layout, size in
                layout.marginTop = 10
                layout.marginBottom = 10
                layout.marginRight = 15
                layout.width = size.width - 130
                view.font = .title1Theme()
                view.textColor = .tpSecondaryBlackText()
                var commentMessage = ""
                if let commentDecode = comment.message.kv_decodeHTMLCharacterEntities() {
                    commentMessage = NSString.extracTKPMEUrl(commentDecode) as String
                }
                view.text = commentMessage
                view.numberOfLines = 4
            },
        ])
    }
    
    private func productReplyDescriptionView(comment: ProductTalkComment) -> NodeType {
        return Node<UIView>(identifier: "Reply-Description-View") { _, layout, _ in
            layout.flexDirection = .row
        }.add(children: [
            Node<UILabel>() { view, layout, _ in
                layout.height = comment.isSeller ? 16 : 0
                layout.width = comment.isSeller ? 43 : 0
                
                view.font = .superMicroTheme()
                view.textColor = .white
                view.backgroundColor = .tpDarkRed()
                view.text = comment.userLabel
                view.textAlignment = .center
                view.layer.cornerRadius = 2
                view.layer.masksToBounds = true
            },
            Node<UILabel>() { view, layout, _ in
                layout.marginLeft = 4
                layout.height = 16
                view.font = .microTheme()
                view.textColor = .tpDisabledBlackText()
                view.text = "- \(comment.publishTime)"
            },
        ])
    }
    
    private func productMoreView() -> NodeType {
        guard let productDetail = state.productDetail else { return NilNode() }
        
        let talkCount = productDetail.talkCount
        
        return Node<UIView>(identifier: "Product-More") { view, layout, _ in
            layout.height = 64
            layout.flexDirection = .row
            layout.alignContent = .center
            layout.justifyContent = .flexEnd
            
            let tapGestureRecognizer = UITapGestureRecognizer()
            _ = tapGestureRecognizer.rx.event.subscribe(onNext: { [unowned self] _ in
                self.didTapAllDiscussion(productDetail)
            })
            view.addGestureRecognizer(tapGestureRecognizer)
        }.add(children: [
            Node<UILabel>() { view, _, _ in
                view.font = .title1Theme()
                view.textColor = .tpGreen()
                view.text = "Lihat semua Diskusi (\(talkCount))"
                view.numberOfLines = 4
            },
            Node<UIImageView>(identifier: "more-icon", create: {
                let view = UIImageView(image: #imageLiteral(resourceName: "icon_carret_green"))
                view.transform = view.transform.rotated(by: CGFloat(Double.pi))
                return view
                
            }, configure: { _, layout, _ in
                layout.height = 18
                layout.width = 18
                layout.marginRight = 15
                layout.alignSelf = .center
            }),
        ])
    }
}
