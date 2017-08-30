//
//  ProductDetailReviewNode.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 8/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render
import RxSwift

class ProductDetailReviewNode: ContainerNode {
    fileprivate let state: ProductDetailState
    fileprivate let didTapAllReview: (ProductUnbox) -> Void
    
    var pageControl: UIPageControl?
    var scrollView: UIScrollView?
    
    init(identifier: String, state: ProductDetailState, didTapAllReview: @escaping (ProductUnbox) -> Void) {
        self.state = state
        self.didTapAllReview = didTapAllReview
        
        super.init(identifier: identifier)
        
        guard let reviews = state.productDetail?.mostHelpfulReviews,
            reviews.count > 0
        else { return }
        
        node.add(children: [
            container().add(children: [
                GlobalRenderComponent.horizontalLine(identifier: "Recommendation-Line-1", marginLeft: 0),
                titleLabel(),
                productReviewListView(),
                productPageControl(),
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
            view.text = "Ulasan Paling Membantu"
            view.textColor = .tpPrimaryBlackText()
            view.font = .largeThemeMedium()
        }
    }
    
    private func productReviewListView() -> NodeType {
        guard let reviews = state.productDetail?.mostHelpfulReviews.map({ (review) -> NodeType in
            productReviewFrameView(review: review)
        }) else { return NilNode() }
        
        return Node<UIScrollView>(identifier: "Review-Scroll-View") { view, layout, size in
            layout.width = size.width
            layout.height = 190
            layout.flexDirection = .row
            layout.alignItems = .stretch
            
            view.showsHorizontalScrollIndicator = false
            view.isPagingEnabled = true
            view.bounces = true
            self.scrollView = view
            
            _ = view.rx.didScroll.subscribe(onNext: { [weak self] in
                guard let wself = self else { return }
                
                let offset = view.contentOffset
                wself.pageControl?.currentPage = Int(offset.x / view.bounds.size.width)
            })
            view.contentSize.width = size.width * CGFloat(reviews.count)
        }.add(children: reviews)
        
    }
    
    private func productReviewFrameView(review: ProductReview) -> NodeType {
        return Node<UIView>(identifier: "Review-Frame-View") { view, layout, size in
            layout.marginLeft = 15
            layout.marginRight = 15
            layout.width = size.width - 30
            
            view.layer.borderColor = UIColor.tpLine().cgColor
            view.layer.borderWidth = 1
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 4
        }.add(child: productReviewView(review: review))
    }
    
    private func productReviewView(review: ProductReview) -> NodeType {
        return Node<UIView>(identifier: "Review-Frame-View") { _, layout, _ in
            layout.flexDirection = .row
        }.add(children: [
            Node<UIImageView>() { view, layout, _ in
                layout.marginLeft = 15
                layout.marginTop = 15
                layout.width = 48
                layout.height = 48
                
                view.setImageWith(URL(string: review.reviewerImage), placeholderImage: #imageLiteral(resourceName: "icon_profile_picture"))
                view.layer.cornerRadius = 4
                view.layer.masksToBounds = true
                view.layer.borderColor = UIColor.tpBorder().cgColor
                view.layer.borderWidth = 1
            },
            productReviewInfoView(review: review),
        ])
    }
    
    private func productReviewInfoView(review: ProductReview) -> NodeType {
        return Node<UIView>(identifier: "Review-Info-View") { _, layout, _ in
            layout.marginLeft = 10
        }.add(children: [
            Node<UILabel>() { view, layout, _ in
                layout.marginTop = 15
                layout.height = 22
                view.font = .largeThemeMedium()
                view.textColor = .tpPrimaryBlackText()
                view.text = review.reviewerName
            },
            Node<UILabel>() { view, layout, _ in
                layout.marginBottom = 6
                layout.height = 16
                view.font = .microTheme()
                view.textColor = .tpDisabledBlackText()
                view.text = review.publishTime
            },
            Node<EDStarRating>() { view, layout, _ in
                layout.width = 80
                layout.height = 13
                layout.flexShrink = 1
                view.isUserInteractionEnabled = true
                
                view.backgroundImage = nil
                view.starImage = UIImage(named: "icon_star_med.png")
                view.starHighlightedImage = UIImage(named: "icon_star_active_med.png")
                view.maxRating = 5
                view.horizontalMargin = 1
                view.rating = 0
                view.displayMode = UInt(EDStarRatingDisplayAccurate)
                view.rating = Float(review.rating / 20)
            },
            Node<UILabel>() { view, layout, size in
                layout.marginTop = 5
                layout.marginBottom = 15
                layout.marginRight = 15
                layout.width = size.width - 120
                view.font = .title1Theme()
                view.textColor = .tpSecondaryBlackText()
                var reviewMessage = ""
                if let reviewDecode = review.message.kv_decodeHTMLCharacterEntities() {
                    reviewMessage = NSString.extracTKPMEUrl(reviewDecode) as String
                }
                view.text = reviewMessage
                view.numberOfLines = 4
            },
            Node<UIImageView>() { view, layout, size in
                layout.position = .absolute
                layout.top = 18
                layout.right = 15
                layout.width = 50
                layout.height = 34
                
                view.image = UIImage(named: "icon_quote_green")
            }
        ])
    }
    
    private func productPageControl() -> NodeType {
        guard let count = state.productDetail?.mostHelpfulReviews.count else { return NilNode() }
        
        return Node<UIPageControl>(identifier: "Product-Page-Control") { view, layout, size in
            layout.height = 50
            layout.alignSelf = .center
            view.currentPageIndicatorTintColor = .tpGreen()
            view.pageIndicatorTintColor = .tpBackground()
            if let scrollView = self.scrollView, size.width > 0 {
                view.currentPage = Int(scrollView.contentOffset.x / size.width)
            } else {
                view.currentPage = 0
            }
            view.numberOfPages = count
            view.isUserInteractionEnabled = false
            
            for dotView in view.subviews {
                dotView.layer.cornerRadius = dotView.frame.size.height / 2
                dotView.layer.borderColor = UIColor.tpBorder().cgColor
                dotView.layer.borderWidth = 0.5
            }
            
            self.pageControl = view
        }
    }
    
    private func productMoreView() -> NodeType {
        guard let productDetail = state.productDetail else { return NilNode() }
        
        let reviewCount = productDetail.reviewCount
        
        return Node<UIView>(identifier: "Product-More") { view, layout, _ in
            layout.height = 64
            layout.flexDirection = .row
            layout.alignContent = .center
            layout.justifyContent = .flexEnd
            
            let tapGestureRecognizer = UITapGestureRecognizer()
            _ = tapGestureRecognizer.rx.event.subscribe(onNext: { [unowned self] _ in
                self.didTapAllReview(productDetail)
            })
            view.addGestureRecognizer(tapGestureRecognizer)
        }.add(children: [
            Node<UILabel>() { view, _, _ in
                view.font = .title1Theme()
                view.textColor = .tpGreen()
                view.text = "Lihat semua Ulasan (\(reviewCount))"
                view.numberOfLines = 4
            },
            Node<UIImageView>(identifier: "more-icon", create: {
                let view = UIImageView(image:#imageLiteral(resourceName: "icon_carret_green"))
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
