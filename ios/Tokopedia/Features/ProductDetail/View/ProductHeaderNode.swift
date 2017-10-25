//
//  ProductHeaderNode.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 7/5/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render
import Lottie
import NSAttributedString_DDHTML

class ProductHeaderNode: ContainerNode {
    fileprivate var state: ProductDetailState
    fileprivate let didTapReview: (ProductUnbox) -> Void
    fileprivate let didTapDiscussion: (ProductUnbox) -> Void
    fileprivate let didTapCourier: (ProductUnbox) -> Void
    fileprivate let didTapWishlist: (Bool) -> Void
    fileprivate let updateWishlistState: (Bool) -> Void
    fileprivate let didTapProductEdit: (ProductUnbox) -> Void
    fileprivate let didTapProductImage: (Int) -> Void
    
    final let productImageHeightRatio: CGFloat = 1
    
    var pageControl: UIPageControl?
    var scrollView: UIScrollView?
    var headerViewWidth: CGFloat = 0.0
    
    var starRating: EDStarRating = {
        let star = EDStarRating(frame: CGRect(x: 0, y: 0, width: 80, height: 16))
        star.backgroundImage = nil
        star.starImage = UIImage(named: "icon_star_med.png")
        star.starHighlightedImage = UIImage(named: "icon_star_active_med.png")
        star.maxRating = 5
        star.horizontalMargin = 1
        star.rating = 0
        star.displayMode = UInt(EDStarRatingDisplayAccurate)
        
        return star
    }()
    
    init(identifier: String, state: ProductDetailState, didTapReview: @escaping (ProductUnbox) -> Void, didTapDiscussion: @escaping (ProductUnbox) -> Void, didTapCourier: @escaping (ProductUnbox) -> Void, didTapWishlist: @escaping (Bool) -> Void, updateWishlistState: @escaping (Bool) -> Void, didTapProductEdit: @escaping (ProductUnbox) -> Void, didTapProductImage: @escaping (Int) -> Void) {
        self.state = state
        self.didTapReview = didTapReview
        self.didTapDiscussion = didTapDiscussion
        self.didTapCourier = didTapCourier
        self.didTapWishlist = didTapWishlist
        self.updateWishlistState = updateWishlistState
        self.didTapProductEdit = didTapProductEdit
        self.didTapProductImage = didTapProductImage
        
        super.init(identifier: identifier)
        
        node.add(children: [
            container().add(children: [
                productScrollView(),
                productEmptyView(),
                GlobalRenderComponent.horizontalLine(identifier: "Header-Line-1", marginLeft: 0),
                productPageControl(),
                productTitleLabel(),
                productComponentPriceView(),
                GlobalRenderComponent.horizontalLine(identifier: "Header-Line-2", marginLeft: 0),
                Node(identifier: "Container-Box-View") { _, layout, _ in
                    layout.flexDirection = .row
                    layout.marginTop = 10
                    layout.marginBottom = 10
                }.add(children: [
                    reviewBoxView(),
                    discussionBoxView(),
                    courierBoxView()
                ]),
                GlobalRenderComponent.horizontalLine(identifier: "Header-Line-3", marginLeft: 0),
                headerActionButton()
            ])
        ])
    }
    
    private func container() -> NodeType {
        return Node<UIView>() { view, layout, size in
            layout.width = size.width
            layout.flexDirection = .column
            view.backgroundColor = .white
            view.isUserInteractionEnabled = true
        }
    }
    
    private func productEmptyView() -> NodeType {
        guard let productDetail = state.productDetail else { return NilNode() }
        
        if state.productDetailActivity != .inactive && state.productDetailActivity != .sellerInactive {
            return NilNode()
        }
        
        var title = productDetail.info.statusTitle
        if title == "0" || title == "" {
            title = "Stok Produk Kosong"
        }
        var message = productDetail.info.statusMessage
        if message == "0" || message == "" {
            message = "Untuk sementara produk ini tidak dijual. Silakan hubungi toko yang bersangkutan untuk informasi lebih lanjut"
        }
        
        switch productDetail.shop.status {
        case .closed:
            title = "Toko tutup sampai tanggal : \(productDetail.shop.closeUntil)"
            message = ""
        case .moderated:
            title = "Toko ini sedang dimoderasi"
            message = ""
        case .inactive:
            title = "Toko ini sedang tidak aktif"
            message = ""
        default:
            break
        }
        
        return Node { _, layout, size in
            layout.position = .absolute
            layout.top = 0
            layout.width = size.width
            layout.height = self.productImageHeightRatio * size.width
            layout.justifyContent = .center
        }.add(children: [
            Node<UIView>() { view, layout, size in
                layout.position = .absolute
                layout.top = 0
                layout.width = size.width
                layout.height = self.productImageHeightRatio * size.width
                layout.justifyContent = .center
                view.backgroundColor = .black
                view.alpha = 0.5
            },
            Node<UILabel>() { view, layout, _ in
                layout.alignSelf = .center
                view.font = .largeThemeMedium()
                view.textColor = .white
                view.text = title
            },
            Node<UILabel>() { view, layout, _ in
                layout.alignSelf = .center
                layout.margin = 20
                view.font = .microTheme()
                view.textColor = .white
                view.numberOfLines = 0
                view.textAlignment = .center
                view.text = message
            }
        ])
    }
    
    private func productImageView(imageUrl: String, tappable: Bool) -> NodeType {
        return Node<UIImageView>() { view, layout, size in
            layout.width = size.width
            layout.height = self.productImageHeightRatio * size.width
            view.backgroundColor = .lightGray
            view.contentMode = .scaleAspectFill
            view.clipsToBounds = true
            view.setImageWith(URL(string: imageUrl))
            view.isUserInteractionEnabled = true
            view.accessibilityLabel = "productImageView"
            if tappable {
                let tapGestureRecognizer = UITapGestureRecognizer()
                _ = tapGestureRecognizer.rx.event.subscribe(onNext: { [unowned self] _ in
                    let index = self.state.currentPage
                    self.didTapProductImage(index!)
                })
                view.addGestureRecognizer(tapGestureRecognizer)
            }
        }
    }
    
    private func productScrollView() -> NodeType {
        var imageNodes: [NodeType]
        if let images = state.productDetail?.images,
            images.count > 0 {
            imageNodes = images.map({ (image) -> NodeType in
                productImageView(imageUrl: image.normalURL, tappable: true)
            })
        } else if let initialData = self.state.initialData,
            let imageURL = initialData["imageURL"],
            imageURL != "" {
            imageNodes = [productImageView(imageUrl: imageURL, tappable: false)]
        } else {
            return Node<UIView>() { view, layout, size in
                layout.width = size.width
                layout.height = self.productImageHeightRatio * size.width
                layout.justifyContent = .center
                view.backgroundColor = .lightGray
                view.isUserInteractionEnabled = true
            }.add(child: Node<UIActivityIndicatorView>() { view, layout, _ in
                layout.width = 48
                layout.height = 48
                layout.alignSelf = .center
                view.activityIndicatorViewStyle = .gray
                view.startAnimating()
            })
            
        }
        
        return Node<UIScrollView>(identifier: "Product-Scroll-View") { view, layout, size in
            layout.width = size.width
            layout.height = self.productImageHeightRatio * size.width
            layout.flexDirection = .row
            layout.alignItems = .stretch
            view.showsHorizontalScrollIndicator = false
            view.isPagingEnabled = true
            view.bounces = false
            self.scrollView = view
            view.accessibilityLabel = "productScrollView"
            _ = view.rx.didScroll.subscribe(onNext: { [weak self] in
                guard let wself = self else { return }
                
                let offset = view.contentOffset
                wself.pageControl?.currentPage = Int(offset.x / view.bounds.size.width)
                wself.state.currentPage = Int(offset.x / view.bounds.size.width)
            })
            view.contentSize.width = size.width * CGFloat(imageNodes.count)
            
        }.add(children: imageNodes)
    }
    
    private func productPageControl() -> NodeType {
        guard let count = state.productDetail?.images.count else { return NilNode() }
        
        return Node<UIPageControl>(identifier: "Product-Page-Control") { view, layout, size in
            let productPagePadding: CGFloat = 30.0
            layout.top = self.productImageHeightRatio * size.width - productPagePadding
            layout.position = .absolute
            view.currentPageIndicatorTintColor = .tpGreen()
            view.pageIndicatorTintColor = .white
            if let scrollView = self.scrollView, size.width > 0 {
                view.currentPage = Int(scrollView.contentOffset.x / size.width)
            } else {
                view.currentPage = 0
            }
            view.numberOfPages = count
            view.isUserInteractionEnabled = false
            
            for dotView in view.subviews {
                dotView.layer.cornerRadius = dotView.frame.size.height / 2
                dotView.layer.borderColor = UIColor.tpGreen().cgColor
                dotView.layer.borderWidth = 0.5
            }
            
            self.pageControl = view
        }
    }
    
    private func headerActionButton() -> NodeType {
        if state.productDetailActivity == .normal || state.productDetailActivity == .inactive || state.productDetailActivity == .replacement {
            return wishlistButton()
        } else if state.productDetailActivity == .seller || state.productDetailActivity == .sellerInactive {
            return editProductButton()
        }
        
        return NilNode()
    }
    
    private func wishlistButton() -> NodeType {
        guard let _ = state.productDetail else { return NilNode() }
        
        return Node<UIView>(identifier: "Wishlist-Button") { view, layout, size in
            layout.width = 48
            layout.height = 48
            layout.position = .absolute
            layout.top = self.productImageHeightRatio * size.width - 24
            layout.right = 15
            view.layer.cornerRadius = 24
            view.layer.masksToBounds = true
            view.backgroundColor = .white
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.5
            view.layer.shadowOffset = CGSize(width: -15, height: 20)
            view.layer.shadowRadius = 10
            view.accessibilityLabel = "wishlistButton"
        }.add(child: wishlistLottie(isWishlisted: state.isWishlist))
    }
    
    private func wishlistLottie(isWishlisted: Bool) -> NodeType {
        if isWishlisted {
            return Node<LOTAnimationView>(identifier: "Wishlisted-Lottie", create: {
                let view = LOTAnimationView(name: "deactivateWishlist")
                return view
                
            }, configure: { view, layout, size in
                layout.width = 48
                layout.height = 48
                layout.position = .absolute
                layout.top = 0
                layout.left = 0
                view.loopAnimation = false
                view.contentMode = .scaleAspectFill
                view.backgroundColor = .clear
                
                let tapGestureRecognizer = UITapGestureRecognizer()
                _ = tapGestureRecognizer.rx.event.subscribe(onNext: { [unowned self] _ in
                    let userAuthManager = UserAuthentificationManager()
                    if let _ = userAuthManager.getUserId(),
                        userAuthManager.isLogin {
                        view.play(completion: { animationFinished in
                            self.updateWishlistState(false)
                        })
                    }
                    self.didTapWishlist(false)
                })
                view.addGestureRecognizer(tapGestureRecognizer)
            } )
        }
        
        return Node<LOTAnimationView>(identifier: "Wishlist-Lottie", create: {
            let view = LOTAnimationView(name: "activateWishlist")
            return view
        
        }, configure: { view, layout, size in
            layout.width = 48
            layout.height = 48
            layout.position = .absolute
            layout.top = 0
            layout.left = 0
            view.loopAnimation = false
            view.contentMode = .scaleAspectFill
            view.backgroundColor = .clear
            
            let tapGestureRecognizer = UITapGestureRecognizer()
            _ = tapGestureRecognizer.rx.event.subscribe(onNext: { [unowned self] _ in
                let userAuthManager = UserAuthentificationManager()
                if let _ = userAuthManager.getUserId(),
                    userAuthManager.isLogin {
                    view.play(completion: { animationFinished in
                        self.updateWishlistState(true)
                    })
                }
                self.didTapWishlist(true)
            })
            view.addGestureRecognizer(tapGestureRecognizer)
        } )
    }
    
    private func editProductButton() -> NodeType {
        guard let productDetail = state.productDetail else { return NilNode() }
        
        return Node<UIButton>(identifier: "Edit-Product-Button") { view, layout, size in
            layout.width = 48
            layout.height = 48
            layout.position = .absolute
            layout.top = self.productImageHeightRatio * size.width - 24
            layout.right = 15
            view.layer.cornerRadius = 24
            view.layer.masksToBounds = true
            view.backgroundColor = .white
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.5
            view.layer.shadowOffset = CGSize(width: -15, height: 20)
            view.layer.shadowRadius = 10
            view.setImage(UIImage(named: "icon_edit_plain"), for: .normal)
            _ = view.rx.tap.subscribe(onNext: { [unowned self] _ in
                self.didTapProductEdit(productDetail)
            })
        }
    }
    
    private func productTitleLabel() -> NodeType {
        return Node<UILabel>(identifier: "Product-Title-Label") { view, layout, _ in
            layout.marginTop = 22
            layout.marginLeft = 15
            layout.marginRight = 67
            view.numberOfLines = 0
            view.font = .title1ThemeSemibold()
            
            var productName = ""
            if let initialData = self.state.initialData,
                let initialDataName = initialData["name"] {
                productName = initialDataName
            }
            
            if let productDetail = self.state.productDetail {
                productName = productDetail.name
            }
            
            view.text = productName.kv_decodeHTMLCharacterEntities()
            view.textColor = .tpPrimaryBlackText()
        }
    }
    
    private func productComponentPriceView() -> NodeType {
        return Node(identifier: "Product-Campaign-Price-View") { _, layout, _ in
            layout.flexDirection = .column
            }.add(children: [
                productOriginalPriceView(),
                productPriceView(),
                productCashbackView(),
                productComponentOfficialStoreTag(),
                productPricePromoView()
                ])
    }
    
    private func productOriginalPriceView() -> NodeType {
        guard let originalPrice = state.productDetail?.campaign?.original_price else {
            return NilNode()
        }
        
        return Node<UILabel>(identifier: "Product-Original-Price-View") { view, layout, _ in
            layout.marginTop = 11
            layout.marginLeft = 15
            view.font = .microTheme()
            view.textColor = .tpSecondaryBlackText()
            let price = NSAttributedString(string: originalPrice, attributes: [NSStrikethroughStyleAttributeName: 2])
            view.attributedText = price
        }
    }
    
    private func productPriceView() -> NodeType {
        var marginTop: CGFloat = 11
        var marginBottom: CGFloat = 10
        if let _ = state.productDetail?.campaign?.percentage_amount {
            marginTop = 2
            marginBottom = 10
        }
        return Node(identifier: "Product-Price-View") { _, layout, _ in
            layout.flexDirection = .row
            layout.marginTop = marginTop
            layout.marginLeft = 15
            layout.marginBottom = marginBottom
        }.add(children: [
            productPriceLabel(),
            productDiscountView()
        ])
    }
    
    private func productPriceLabel() -> NodeType {
        return Node<UILabel>(identifier: "Product-Price-Label") { view, _, _ in
            view.font = .title1ThemeSemibold()
            view.textColor = .tpOrange()
            
            if let initialData = self.state.initialData,
                let initialDataPrice = initialData["price"] {
                view.text = "\(initialDataPrice)"
            }
            
            if let productDetail = self.state.productDetail {
                view.text = productDetail.info.price
            }
        }
    }
    
    private func productCashbackView() -> NodeType {
        guard let cashback = state.productDetail?.cashback,
            cashback != "" else {
            return NilNode()
        }
        
        return Node(identifier: "Product-Cashback-View") { _, layout, _ in
                layout.flexDirection = .row
                layout.paddingRight = 4
                layout.height = 20
                layout.marginLeft = 15
                layout.marginBottom = 10
            
            }.add(children: [
                Node<UILabel>(identifier: "Product-Cashback-Label") { view, layout, _ in
                    view.textColor = .tpSecondaryBlackText()
                    view.font = .microTheme()
                    view.layer.cornerRadius = 4
                    view.layer.masksToBounds = true
                    view.textAlignment = .left
                    view.attributedText = NSAttributedString(fromHTML: "Dapatkan <font color=\"#42b549\">Cashback \(cashback)</font> ke Tokocash", normalFont: UIFont.microTheme(),boldFont: UIFont.microThemeSemibold(), italicFont: UIFont.microThemeSemibold())
                    view.accessibilityLabel = "cashbackLabel"
                    
                    layout.marginRight = 5
                },
                Node<UIImageView> { view, layout, _ in
                    view.image = UIImage(named: "icon-wallet")
                    layout.width = 20
                    layout.height = 20
                }
            ])
        
    }
    
    private func productDiscountView() -> NodeType {
        guard let percentage = state.productDetail?.campaign?.percentage_amount else {
            return NilNode()
        }
        
        return Node<UILabel>(identifier: "Product-Discount-View") { view, layout, _ in
            layout.paddingLeft = 4
            layout.paddingRight = 4
            layout.height = 18
            layout.marginLeft = 5
            view.backgroundColor = .tpRed()
            view.textColor = .white
            view.font = .microTheme()
            view.layer.cornerRadius = 4
            view.layer.masksToBounds = true
            view.textAlignment = .center
            view.text = "\(percentage)%OFF"
        }
    }
    
    private func productComponentOfficialStoreTag() -> NodeType {
        guard let isOfficialStore = state.productDetail?.shop.isOfficial else {
            return NilNode()
        }
        
        if isOfficialStore {
            return Node<UILabel>(identifier: "Product-Official-Store-Tag") { view, layout, _ in
                layout.height = 16
                layout.width = 313
                layout.marginLeft = 15
                layout.marginBottom = 10
                view.textColor = .tpDarkPurple()
                view.font = .microTheme()
                view.text = "Produk dari Brand Resmi"
                }.add(children: [
                    Node<UIImageView>() { view, layout, _ in
                        layout.width = 16
                        layout.height = 16
                        layout.alignSelf = .center
                        view.image = UIImage(named: "badge_official")
                    }])
        }
        
        return NilNode()
    }
    
    private func productPricePromoView() -> NodeType {
        guard let endDate = state.productDetail?.campaign?.end_date else {
            return NilNode()
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let endPromoDate = formatter.date(from:endDate),
            endPromoDate > Date(),
            endPromoDate.timeIntervalSinceNow < 24 * 60 * 60 else {
                return NilNode()
        }
        
        return Node(identifier: "Product-Promo-View") { _, layout, _ in
            layout.flexDirection = .row
            layout.marginLeft = 15
            layout.marginBottom = 22
        }.add(children: [
            productPricePromoLabel(),
            productPriceTimerView()
        ])
    }
    
    private func productPricePromoLabel() -> NodeType {
        return Node<UILabel>(identifier: "Product-Price-Promo-Label") { view, layout, _ in
            layout.height = 20
            view.textColor = .tpSecondaryBlackText()
            view.font = .microTheme()
            view.text = "Promo berakhir dalam : "
        }
    }
    
    private func productPriceTimerView() -> NodeType {
        guard let expiredDate = state.productDetail?.campaign?.end_date else {
            return NilNode()
        }
        
        return Node<UILabel>(identifier: "Product-Price-Promo-Label") { view, layout, _ in
            layout.height = 20
            layout.width = 110
            view.textColor = .tpGreen()
            view.font = .microTheme()
            view.layer.borderWidth = 1.0
            view.layer.borderColor = UIColor.tpGreen().cgColor
            view.layer.cornerRadius = 10
            view.layer.masksToBounds = true
            view.textAlignment = .center
            view.text = self.timeRemainingString(withEndPromo: expiredDate)
        }
    }
    
    private func reviewBoxView() -> NodeType {
        
        var reviewCount = "0"
        var productRating = "0"
        if let productDetail = state.productDetail {
            reviewCount = productDetail.reviewCount
            productRating = productDetail.rating.qualityStarRate
        }
        
        return Node<UIView>(identifier: "Review-Box-View") { view, layout, _ in
            layout.flexGrow = 1
            layout.flexShrink = 1
            layout.flexBasis = 10
            
            if let productDetail = self.state.productDetail {
                let tapGestureRecognizer = UITapGestureRecognizer()
                _ = tapGestureRecognizer.rx.event.subscribe(onNext: { [unowned self] _ in
                    self.didTapReview(productDetail)
                })
                view.addGestureRecognizer(tapGestureRecognizer)
            }
            
        }.add(children: [
            Node<UIView>() { view, layout, _ in
                layout.width = 80
                layout.height = 32
                layout.alignSelf = .center
                layout.flexShrink = 1
                view.isUserInteractionEnabled = true
                self.starRating.center = CGPoint(x: layout.width / 2, y: layout.height / 2)
                self.starRating.rating = Float(productRating)!
                view.addSubview(self.starRating)
            },
            Node<UILabel>() { view, layout, _ in
                layout.alignSelf = .center
                view.accessibilityLabel = "reviewButton"
                view.text = "\(reviewCount) Ulasan"
                view.textColor = .tpGreen()
                view.highlightedTextColor = .tpLightGreen()
                view.font = .microTheme()
                view.isUserInteractionEnabled = true
            }
        ])
    }
    
    private func discussionBoxView() -> NodeType {
        
        var talkCount = "0"
        if let productDetail = state.productDetail {
            talkCount = productDetail.talkCount
        }
        
        return Node<UIView>(identifier: "Review-Discussion-View") { view, layout, _ in
            layout.flexGrow = 1
            layout.flexShrink = 1
            layout.flexBasis = 10
            
            if let productDetail = self.state.productDetail {
                let tapGestureRecognizer = UITapGestureRecognizer()
                _ = tapGestureRecognizer.rx.event.subscribe(onNext: { [unowned self] _ in
                    self.didTapDiscussion(productDetail)
                })
                view.addGestureRecognizer(tapGestureRecognizer)
            }
            
        }.add(children: [
            Node<UIImageView>() { view, layout, _ in
                layout.width = 32
                layout.height = 32
                layout.alignSelf = .center
                view.image = UIImage(named: "icon_discussion_green")
                view.isUserInteractionEnabled = true
            },
            Node<UILabel>() { view, layout, _ in
                layout.alignSelf = .center
                view.text = "\(talkCount) Diskusi"
                view.textColor = .tpGreen()
                view.highlightedTextColor = .tpLightGreen()
                view.font = .microTheme()
                view.isUserInteractionEnabled = true
            }
        ])
    }
    
    private func courierBoxView() -> NodeType {
        
        var shipments = 0
        if let productDetail = state.productDetail {
            shipments = productDetail.shipments.count
        }
        
        return Node<UIButton>(identifier: "Review-Courier-View") { view, layout, _ in
            layout.flexGrow = 1
            layout.flexShrink = 1
            layout.flexBasis = 10
            
            if let productDetail = self.state.productDetail {
                let tapGestureRecognizer = UITapGestureRecognizer()
                _ = tapGestureRecognizer.rx.event.subscribe(onNext: { [unowned self] _ in
                    self.didTapCourier(productDetail)
                })
                view.addGestureRecognizer(tapGestureRecognizer)
            }
            
        }.add(children: [
            Node<UIImageView>() { view, layout, _ in
                layout.width = 32
                layout.height = 32
                layout.alignSelf = .center
                view.image = UIImage(named: "icon_courier_green")
                view.isUserInteractionEnabled = true
            },
            Node<UILabel>() { view, layout, _ in
                layout.alignSelf = .center
                view.text = "\(shipments) Kurir"
                view.textColor = .tpGreen()
                view.highlightedTextColor = .tpLightGreen()
                view.font = .microTheme()
                view.isUserInteractionEnabled = true
            }
        ])
    }
    
    private func timeRemainingString(withEndPromo endPromo: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let endPromoDate = formatter.date(from: endPromo) else {
            return "00h : 00m : 00s"
        }
        
        let currentDate = Date()
        
        let unitFlags = Set<Calendar.Component>([.month, .day, .hour, .minute, .second])
        let components = Calendar.current.dateComponents(unitFlags, from: currentDate, to: endPromoDate)
        
        let hourComponent = components.hour ?? 0
        let minuteComponent = components.minute ?? 0
        let secondComponent = components.second ?? 0
        
        return "\(String(format: "%02d", hourComponent))h : \(String(format: "%02d", minuteComponent))m : \(String(format: "%02d", secondComponent))s"
    }
    
}
