//
//  FeedKOLActivityComponentView.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 10/31/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render
import RxSwift
import NativeNavigation

class FeedKOLActivityComponentView: ComponentView<FeedCardKOLPostState> {
    private var onTapLongDescription: ((FeedCardKOLPostState) -> Void)!
    private var onTapLikeButton: ((FeedCardKOLPostState) -> Void)!
    private var onTapFollowButton: ((FeedCardKOLPostState) -> Void)!
    
    init(onTapLongDescription: @escaping ((FeedCardKOLPostState) -> Void), onTapLikeButton: @escaping ((FeedCardKOLPostState) -> Void), onTapFollowButton: @escaping ((FeedCardKOLPostState) -> Void)) {
        self.onTapLongDescription = onTapLongDescription
        self.onTapLikeButton = onTapLikeButton
        self.onTapFollowButton = onTapFollowButton
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func construct(state: FeedCardKOLPostState?, size: CGSize) -> NodeType {
        guard let state = state else {
            return Node<UIView>() { _, _, _ in
                
            }
        }
        
        return self.componentContainer(state: state, size: size)
    }
    
    private func componentContainer(state: FeedCardKOLPostState, size: CGSize) -> NodeType {
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
                self.horizontalLine(),
                self.headerView(state: state, size: size),
                self.contentImage(state: state, size: size),
                self.description(state: state, size: size),
                self.horizontalLine(),
                self.actionButtons(state: state, size: size)
            ]),
            self.blankSpace()
        ])
    }
    
    private func titleView(state: FeedCardKOLPostState, size: CGSize) -> NodeType {
        if state.isFollowed && !state.tempFollowing {
            return NilNode()
        }
        
        return Node<UIView>(identifier: "title-view") { view, layout, size in
            view.backgroundColor = .white
            
            layout.width = size.width
        }.add(child: Node<UILabel>(identifier: "title-label") { label, layout, _ in
            label.text = state.title == "" ? "Rekomendasi Untuk Anda" : state.title
            label.font = .largeThemeSemibold()
            label.textColor = UIColor.tpPrimaryBlackText()
            
            layout.marginLeft = 10
            layout.marginTop = 16
            layout.marginBottom = 16
        })
    }
    
    private func headerView(state: FeedCardKOLPostState, size: CGSize) -> NodeType {
        let influencerImage = Node<UIButton>() { button, _, _ in
            button.bk_(whenTapped: {
                if let url = URL(string: state.userURL) {
                    TPRoutes.routeURL(url)
                }
            })
        }.add(child: Node<UIImageView>() { view, layout, _ in
            layout.width = 52
            layout.height = 52
            
            view.cornerRadius = 26
            view.borderWidth = 1.0
            view.borderColor = .fromHexString("#e0e0e0")
            view.clipsToBounds = true
            
            view.setImageWith(URL(string: state.userPhoto), placeholderImage: #imageLiteral(resourceName: "grey-bg"))
        })
        
        let influencerInfo = Node<UIButton>() { button, layout, _ in
            layout.flexDirection = .column
            layout.flexShrink = 1
            layout.flexGrow = 1
            layout.marginLeft = 10
            
            button.rx.tap.subscribe(onNext: {
                
            }).disposed(by: self.rx_disposeBag)
        }.add(children: [
            Node<UILabel>() { label, layout, _ in
                layout.flexShrink = 1
                layout.marginBottom = 3
                
                label.numberOfLines = 1
                label.attributedText = self.influencerLabel(name: state.userName)
            },
            Node<UILabel>() { label, _, _ in
                label.text = state.isFollowed ? FeedService.feedCreateTimeFormatted(withCreatedTime: state.createTime) : state.userInfo
                label.font = .microTheme()
                label.textColor = .tpDisabledBlackText()
            }
        ])
        
        let followButton = Node<UIButton>() { button, layout, _ in
            button.setTitle(state.isFollowed ? " Following" : " Follow", for: .normal)
            button.setImage(state.isFollowed ? #imageLiteral(resourceName: "icon_kol_tick") : #imageLiteral(resourceName: "icon_plus_green"), for: .normal)
            button.backgroundColor = .white
            button.titleLabel?.font = .smallThemeSemibold()
            button.setTitleColor(state.isFollowed ? .tpSecondaryBlackText() : .tpGreen(), for: .normal)
            button.rx.tap
                .subscribe(onNext: {
                    var newState = state
                    newState.tempFollowing = true
                    
                    self.onTapFollowButton(newState)
                })
                .disposed(by: self.rx_disposeBag)
            
            layout.height = 50
            layout.width = 100
            layout.marginRight = 0
        }
        
        let authorContainer = Node<UIView>() { _, layout, _ in
            layout.flexDirection = .row
            layout.alignItems = .center
            layout.justifyContent = .spaceBetween
            layout.marginTop = 16
            layout.marginBottom = 16
            layout.marginLeft = 8
            layout.marginRight = 8
            
        }.add(children: [
            Node<UIView>() { _, layout, _ in
                layout.flexDirection = .row
                layout.alignItems = .center
                layout.flexShrink = 1
            }.add(children: [
                influencerImage,
                influencerInfo
            ]),
            (state.isFollowed && !state.tempFollowing) ? NilNode() : followButton
        ])
        
        return Node<UIView> { view, layout, size in
            layout.flexDirection = .column
            layout.width = size.width
            
            view.backgroundColor = .white
        }.add(children: [
            authorContainer,
            self.horizontalLine()
        ])
    }
    
    private func contentImage(state: FeedCardKOLPostState, size: CGSize) -> NodeType {
        return Node<UIImageView> { view, layout, _ in
            layout.width = (UI_USER_INTERFACE_IDIOM() == .pad) ? 560 : UIScreen.main.bounds.width
            
            view.contentMode = .scaleAspectFit
            view.setImageWith(URL(string: state.imageURL), placeholderImage: #imageLiteral(resourceName: "grey-bg"))
            view.isUserInteractionEnabled = true
            
            if let width = view.image?.size.width, let height = view.image?.size.height, height != 0 {
                let aspectRatio = width / height
                
                layout.height = layout.width / aspectRatio
            }
        }.add(child: (state.tagCaption != "") ? Node<UIView>() { view, layout, _ in
            layout.position = .absolute
            layout.bottom = 0
            layout.right = 0
            layout.padding = 5
            layout.height = 24
            layout.width = 175
            layout.justifyContent = .center
            layout.alignItems = .center
            
            view.backgroundColor = UIColor.black.withAlphaComponent(0.40)
            view.isUserInteractionEnabled = true
            
            let gestureRecognizer = UITapGestureRecognizer()
            gestureRecognizer.rx.event.subscribe(onNext: { _ in
                if let url = URL(string: state.tagURL) {
                    TPRoutes.routeURL(url)
                }
            }).disposed(by: self.rx_disposeBag)
            
            view.addGestureRecognizer(gestureRecognizer)
            
        }.add(child: Node<UILabel>() { label, layout, _ in
            layout.position = .absolute
            
            label.text = state.tagCaption
            label.font = .microThemeSemibold()
            label.textColor = .white
        }) : NilNode())
    }
    
    private func description(state: FeedCardKOLPostState, size: CGSize) -> NodeType {
        var descriptionString = NSString.convertHTML(state.description)
        
        return Node<TTTAttributedLabel>() { label, layout, _ in
            layout.marginTop = 14
            layout.marginLeft = 10
            layout.marginBottom = 8
            layout.marginRight = 10
            
            label.numberOfLines = 0
            label.font = .smallTheme()
            label.textColor = .tpSecondaryBlackText()
            label.isUserInteractionEnabled = true
            
            if descriptionString.characters.count > 150 {
                let substring = descriptionString.substring(to: descriptionString.index(descriptionString.startIndex, offsetBy: 150))
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 6
                
                let attString = NSMutableAttributedString(
                    string: "\(substring)... ",
                    attributes: [
                        NSFontAttributeName: UIFont.smallTheme(),
                        NSForegroundColorAttributeName: UIColor.tpSecondaryBlackText(),
                        NSParagraphStyleAttributeName: paragraphStyle
                    ]
                )
                
                attString.append(NSAttributedString(
                    string: "Read More",
                    attributes: [
                        NSFontAttributeName: UIFont.smallThemeMedium(),
                        NSForegroundColorAttributeName: UIColor.tpGreen(),
                        NSParagraphStyleAttributeName: paragraphStyle
                    ]
                ))
                
                let gestureRecognizer = UITapGestureRecognizer()
                gestureRecognizer.rx.event.subscribe(onNext: { _ in
                    let viewController = ReactViewController(
                        moduleName: "FeedKOLActivityComment",
                        props: ["cardState": state.dictionary as AnyObject]
                    )
                    viewController.hidesBottomBarWhenPushed = true
                    
                    UIApplication.topViewController()?
                        .navigationController?
                        .pushReactViewController(viewController, animated: true)
                }).disposed(by: self.rx_disposeBag)
                
                label.addGestureRecognizer(gestureRecognizer)
                
                if state.descriptionShownAll {
                    label.attributedText = NSAttributedString(
                        string: descriptionString,
                        attributes: [
                            NSFontAttributeName: UIFont.smallTheme(),
                            NSForegroundColorAttributeName: UIColor.tpSecondaryBlackText(),
                            NSParagraphStyleAttributeName: paragraphStyle
                        ]
                    )
                } else {
                    label.attributedText = attString
                }
                
            } else {
                label.attributedText = self.descriptionString(string: descriptionString)
            }
        }
    }
    
    private func actionButtons(state: FeedCardKOLPostState, size: CGSize) -> NodeType {
        return Node<UIView>() { _, layout, size in
            layout.flexDirection = .row
            layout.width = size.width
        }.add(children: [
            Node<UIButton>() { button, layout, size in
                button.setTitle(state.likeCount == 0 ? " Like" : " \(state.likeCount)", for: .normal)
                button.setImage(state.isLiked ? #imageLiteral(resourceName: "icon_kol_like_active") : #imageLiteral(resourceName: "icon_kol_like_inactive"), for: .normal)
                button.backgroundColor = .white
                button.titleLabel?.font = .largeThemeSemibold()
                button.setTitleColor(state.isLiked ? .tpGreen() : .tpDisabledBlackText(), for: .normal)
                
                button.rx.tap
                    .subscribe(onNext: {
                        let currentLikeCount = state.likeCount
                        var newState = state
                        newState.likeCount = (newState.isLiked) ? (currentLikeCount - 1) : (currentLikeCount + 1)
                        
                        self.onTapLikeButton(newState)
                    })
                    .disposed(by: self.rx_disposeBag)
                
                layout.height = 52.0
                layout.width = size.width / 2
            },
            Node<UIButton>() { button, layout, size in
                button.setTitle(state.commentCount == 0 ? " Comment" : " \(state.commentCount)", for: .normal)
                button.setImage(#imageLiteral(resourceName: "icon_kol_comment"), for: .normal)
                button.backgroundColor = .white
                button.titleLabel?.font = .largeThemeSemibold()
                button.setTitleColor(.tpDisabledBlackText(), for: .normal)
                
                button.rx.tap
                    .subscribe(onNext: {
                        let viewController = ReactViewController(
                            moduleName: "FeedKOLActivityComment",
                            props: ["cardState": state.dictionary as AnyObject]
                        )
                        viewController.hidesBottomBarWhenPushed = true
                        
                        UIApplication.topViewController()?
                            .navigationController?
                            .pushReactViewController(viewController, animated: true)
                    })
                    .disposed(by: self.rx_disposeBag)
                
                layout.height = 52.0
                layout.width = size.width / 2
            }
        ])
    }
    
    private func horizontalLine() -> NodeType {
        return Node<UIView>() { view, layout, _ in
            layout.height = 1
            
            view.backgroundColor = UIColor.fromHexString("#e0e0e0")
        }
    }
    
    private func blankSpace() -> NodeType {
        return Node<UIView>(identifier: "blank-space") { view, layout, size in
            layout.height = 15
            layout.width = size.width
            
            view.backgroundColor = .tpBackground()
        }
    }
    
    private func influencerLabel(name: String) -> NSMutableAttributedString {
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
    
    private func descriptionString(string: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        
        let attribute: [String: Any] = [
            NSFontAttributeName: UIFont.smallTheme(),
            NSForegroundColorAttributeName: UIColor.tpSecondaryBlackText(),
            NSParagraphStyleAttributeName: paragraphStyle
        ]
        
        return NSAttributedString(string: string, attributes: attribute)
    }
}
