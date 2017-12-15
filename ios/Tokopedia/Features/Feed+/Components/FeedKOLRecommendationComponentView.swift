//
//  FeedKOLRecommendationComponentView.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 11/1/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render
import RxSwift

class FeedKOLRecommendationComponentView: ComponentView<FeedCardKOLRecommendationState> {
    private var onTapFollowUser: ((FeedCardKOLRecommendationState) -> Void)!
    var currentState: FeedCardKOLRecommendationState = FeedCardKOLRecommendationState()
    
    init(onTapFollowUser: @escaping ((FeedCardKOLRecommendationState) -> Void)) {
        self.onTapFollowUser = onTapFollowUser
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func construct(state: FeedCardKOLRecommendationState?, size: CGSize) -> NodeType {
        guard let state = state else {
            return Node<UIView>() { _, _, _ in
                
            }
        }
        
        self.currentState = state
        return self.componentContainer(state: state, size: size)
    }
    
    private func componentContainer(state: FeedCardKOLRecommendationState, size: CGSize) -> NodeType {
        return Node<UIView>() { _, layout, size in
            layout.flexDirection = .column
            layout.width = size.width
        }.add(children: [
            Node<UIView>() { view, layout, size in
                layout.flexDirection = .column
                layout.width = size.width
                
                view.borderWidth = 1
                view.borderColor = .fromHexString("#e0e0e0")
            }.add(children: [
                self.titleView(state: state, size: size),
                self.celebScrollView(state: state, size: size),
                self.seeMore(state: state, size: size)
            ]),
            self.blankSpace()
        ])
    }
    
    private func titleView(state: FeedCardKOLRecommendationState, size: CGSize) -> NodeType {
        return Node<UIView>() { view, layout, size in
            view.backgroundColor = .white
            
            layout.width = size.width
        }.add(child: Node<UILabel>() { label, layout, _ in
            label.text = state.title == "" ? "Explore Posting dari Celebgram Favoritmu" : state.title
            label.font = .largeThemeSemibold()
            label.textColor = .tpPrimaryBlackText()
            
            layout.marginLeft = 10
            layout.marginTop = 16
            layout.marginBottom = 16
            layout.marginRight = 10
        })
    }
    
    private func celebScrollView(state: FeedCardKOLRecommendationState, size: CGSize) -> NodeType {
        var cards: [NodeType] = []
        
        state.users.forEach { user in
            cards.append(self.celebCard(user: user))
        }
        
        return Node<UIScrollView>() { view, layout, size in
            view.backgroundColor = .white
            view.alwaysBounceVertical = false
            view.contentSize = CGSize(width: CGFloat(155 * state.users.count), height: size.height)
            
            layout.width = size.width
            layout.height = 190
            layout.flexDirection = .row
            layout.alignItems = .center
        }.add(children: cards)
    }
    
    private func celebCard(user: FeedCardKOLRecommendedUserState) -> NodeType {
        return Node<UIView>() { view, layout, _ in
            layout.height = 174
            layout.width = 140
            layout.marginLeft = 10
            layout.marginRight = 5
            layout.padding = 10
            
            layout.flexDirection = .column
            layout.alignItems = .center
            
            view.layer.shadowColor = UIColor.fromHexString("#e0e0e0").cgColor
            view.layer.shadowOpacity = 0.75
            view.layer.borderWidth = 1.0
            view.layer.shadowOffset = CGSize(width: 0, height: 0)
            view.layer.borderColor = UIColor.fromHexString("#e0e0e0").cgColor
            
            view.cornerRadius = 6
            view.backgroundColor = .white
            view.isUserInteractionEnabled = true
            
            let gestureRecognizer = UITapGestureRecognizer()
            gestureRecognizer.rx.event.subscribe(onNext: { _ in
                if let url = URL(string: user.userURL) {
                    TPRoutes.routeURL(url)
                }
            }).disposed(by: self.rx_disposeBag)
            
            view.addGestureRecognizer(gestureRecognizer)
        }.add(children: [
            Node<UIImageView>() { view, layout, _ in
                layout.width = 60
                layout.height = 60
                layout.marginTop = 5
                
                view.cornerRadius = 30
                view.borderWidth = 1.0
                view.borderColor = .fromHexString("#e0e0e0")
                view.clipsToBounds = true
                
                view.setImageWith(URL(string: user.userPhoto), placeholderImage: #imageLiteral(resourceName: "grey-bg"))
            },
            Node<UILabel>() { label, layout, _ in
                layout.flexShrink = 1
                layout.marginTop = 5
                
                label.numberOfLines = 1
                label.attributedText = self.celebNameLabel(name: user.userName)
            },
            Node<UILabel>() { label, _, _ in
                label.text = user.userInfo
                label.font = .microTheme()
                label.textColor = .tpDisabledBlackText()
            },
            Node<UIButton>() { button, layout, _ in
                layout.marginTop = 10
                layout.height = 32
                layout.width = 120
                
                button.setTitle(user.isFollowed ? "Following" : "Follow", for: .normal)
                button.backgroundColor = user.isFollowed ? .white : .tpGreen()
                button.titleLabel?.font = .microThemeMedium()
                button.setTitleColor(user.isFollowed ? .tpDisabledBlackText() : .white, for: .normal)
                button.cornerRadius = 3
                
                if user.isFollowed {
                    button.borderWidth = 1
                    button.borderColor = .tpDisabledBlackText()
                }
                
                button.rx.tap
                    .subscribe(onNext: {
                        var newState = self.currentState
                        
                        for (index, element) in newState.users.enumerated() {
                            if element.userID == user.userID {
                                newState.justFollowedUserID = user.userID
                                newState.justFollowedUserIndex = index
                            }
                        }
                        
                        self.onTapFollowUser(newState)
                        
                    })
                    .disposed(by: self.rx_disposeBag)
            }
        ])
    }
    
    private func seeMore(state: FeedCardKOLRecommendationState, size: CGSize) -> NodeType {
        return Node<UIView>() { _, layout, size in
            layout.flexDirection = .row
            layout.justifyContent = .flexEnd
            layout.alignItems = .center
            layout.width = size.width
            layout.padding = 10
        }.add(children: [
            Node<UIButton>() { button, layout, _ in
                button.setTitle("Explore Lebih Lanjut", for: .normal)
                button.titleLabel?.font = .title2ThemeMedium()
                button.setTitleColor(.tpGreen(), for: .normal)
                
                layout.marginRight = 8
                
                button.rx.tap
                    .subscribe(onNext: {
                        if let url = URL(string: state.redirectURL) {
                            TPRoutes.routeURL(url)
                        }
                    })
                    .disposed(by: self.rx_disposeBag)
            },
            Node<UIImageView>() { view, layout, _ in
                view.image = #imageLiteral(resourceName: "icon_forward")
                view.tintColor = .tpGreen()
                
                layout.height = 18
                layout.width = 12
            }
        ])
    }
    
    private func blankSpace() -> NodeType {
        return Node<UIView>(identifier: "blank-space") { view, layout, size in
            layout.height = 15
            layout.width = size.width
            
            view.backgroundColor = .tpBackground()
        }
    }
    
    private func celebNameLabel(name: String) -> NSMutableAttributedString {
        let bold: [String: Any] = [
            NSFontAttributeName: UIFont.largeThemeSemibold(),
            NSForegroundColorAttributeName: UIColor.tpPrimaryBlackText()
        ]
        
        let attachment = NSTextAttachment()
        attachment.image = #imageLiteral(resourceName: "icon_kol_badge")
        attachment.bounds = CGRect(x: 0, y: -3, width: 14, height: 14)
        
        let badge = NSAttributedString(attachment: attachment)
        
        let string = NSMutableAttributedString()
        string.append(badge)
        string.append(NSAttributedString(string: " \(name)", attributes: bold))
        
        return string
    }
}
