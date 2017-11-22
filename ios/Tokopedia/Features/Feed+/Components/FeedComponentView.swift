//
//  FeedComponentView.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 4/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render
import RxSwift
import Lottie

class FeedComponentView: ComponentView<FeedCardState> {
    
    private weak var viewController: UIViewController?
    private var onTopAdsStateChanged: ((TopAdsFeedPlusState) -> Void)
    private var onEmptyStateButtonPressed: ((FeedErrorType) -> Void)
    private var onReloadNextPagePressed: (() -> Void)
    private var onTapKOLLongDescription: ((FeedCardKOLPostState) -> Void)!
    private var onTapKOLLike: ((FeedCardKOLPostState) -> Void)!
    private var onTapFollowKOLPost: ((FeedCardKOLPostState) -> Void)!
    private var onTapFollowKOLRecommendation: ((FeedCardKOLRecommendationState) -> Void)!
    private var pageIndex = Variable(Int())
    private var scrollViewPageIndex = 0
    
    init(viewController: UIViewController,
         onTopAdsStateChanged: @escaping ((TopAdsFeedPlusState) -> Void),
         onEmptyStateButtonPressed: @escaping ((FeedErrorType) -> Void),
         onReloadNextPagePressed: @escaping (() -> Void),
         onTapKOLLongDescription: @escaping ((FeedCardKOLPostState) -> Void),
         onTapKOLLike: @escaping ((FeedCardKOLPostState) -> Void),
         onTapFollowKOLPost: @escaping ((FeedCardKOLPostState) -> Void),
         onTapFollowKOLRecommendation: @escaping ((FeedCardKOLRecommendationState) -> Void)) {
        self.viewController = viewController
        self.onTopAdsStateChanged = onTopAdsStateChanged
        self.onEmptyStateButtonPressed = onEmptyStateButtonPressed
        self.onReloadNextPagePressed = onReloadNextPagePressed
        self.onTapKOLLongDescription = onTapKOLLongDescription
        self.onTapKOLLike = onTapKOLLike
        self.onTapFollowKOLPost = onTapFollowKOLPost
        self.onTapFollowKOLRecommendation = onTapFollowKOLRecommendation
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func construct(state: FeedCardState?, size: CGSize) -> NodeType {
        guard let state = state, let vc = self.viewController else {
            return Node<UIView> { _, _, _ in
                
            }
        }
        
        let topAdsComponent = TopAdsFeedPlusComponentView(favoriteCallback: { state in
            self.onTopAdsStateChanged(state)
        })
        
        let kolPostComponent = FeedKOLActivityComponentView(
            onTapLongDescription: { state in
                self.onTapKOLLongDescription(state)
            },
            onTapLikeButton: { state in
                self.onTapKOLLike(state)
            },
            onTapFollowButton: { state in
                self.onTapFollowKOLPost(state)
        })
        
        let recommendationKOLComponent = FeedKOLRecommendationComponentView(
            onTapFollowUser: { state in
                self.onTapFollowKOLRecommendation(state)
            }
        )
        
        switch state.content.type {
        case .emptyState:
            return FeedEmptyStateComponentView(onButtonPressed: self.onEmptyStateButtonPressed).construct(state: state, size: size)
        case .nextPageError:
            return FeedNextPageErrorComponentView(onReloadNextPagePressed: self.onReloadNextPagePressed).construct(state: state, size: size)
        case .inspiration:
            return FeedInspirationComponentView().construct(state: state.content.inspiration, size: size)
        case .officialStoreBrand, .officialStoreCampaign:
            return FeedOfficialStoreComponentView().construct(state: state.content, size: size)
        case .promotion:
            return FeedPromotionComponentView(viewController: vc).construct(state: state, size: size)
        case .toppicks:
            return FeedToppicksComponentView().construct(state: state.content, size: size)
        case .topAds:
            return topAdsComponent.construct(state: state.topads, size: size)
        case .KOLPost, .followedKOLPost:
            return kolPostComponent.construct(state: state.content.kolPost, size: size)
        case .KOLRecommendation:
            return recommendationKOLComponent.construct(state: state.content.kolRecommendation, size: size)
        case .newProduct, .editProduct:
            return FeedActivityComponentView(viewController: vc).construct(state: state, size: size)
        default:
            return Node<UIView>() { _, _, _ in
                
            }
        }
    }
}
