//
//  CategoryIntermediaryViewController.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 4/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render
import RestKit
import BlocksKit
import youtube_ios_player_helper

struct IntermediaryState: StateType {
    var intermediaryViewController: CategoryIntermediaryViewController?
    var categoryIntermediaryResult: CategoryIntermediaryResult?
    var categoryIntermediaryNonHiddenChildren: [CategoryIntermediaryChild]?
    var categoryIntermediaryNotExpandedChildren: [CategoryIntermediaryChild]?
    var isCategorySubviewExpanded: Bool!
    var categoryIntermediaryHotListItems: [CategoryIntermediaryHotListItem] = []
    var ads = [PromoResult]()
    var banner: iCarousel?
    var pageControl: StyledPageControl?
    var officialStoreHomeItems: [OfficialStoreHomeItem]?
    var topAdsHeadline: PromoResult?
}

class IntermediaryViewComponent: ComponentView<IntermediaryState> {
    
    var parentViewController: UIViewController?
    
    override func construct(state: IntermediaryState?, size: CGSize) -> NodeType {
        let containerView = Node<UIScrollView> { scrollView, layout, size in
            scrollView.backgroundColor = UIColor.tpBackground()
            scrollView.accessibilityLabel = "intermediaryScrollView"
            layout.width = size.width
            layout.height = size.height
        }
        
        containerView.add(child: Node<UIRefreshControl>() { refreshControl, layout, _ in
            refreshControl.endRefreshing()
            layout.height = 0
            refreshControl.bk_addEventHandler({ _ in
                state?.intermediaryViewController?.requestHotlist()
            }, for: .valueChanged)
        })
        
        guard let categoryIntermediaryResult = state?.categoryIntermediaryResult,
            let categoryIntermediaryNonHiddenChildren = state?.categoryIntermediaryNonHiddenChildren,
            let categoryIntermediaryNotExpandedChildren = state?.categoryIntermediaryNotExpandedChildren else {
            return containerView
        }
        
        let bannerView = Node<UIView>() { view, layout, _ in
            layout.height = 150
            view.clipsToBounds = true
            view.accessibilityLabel = "intermediaryBanner"
            if (state?.banner?.numberOfItems)! > 0 {
                view.addSubview((state?.banner)!)
                state?.banner?.snp.makeConstraints({ make in
                    make.edges.equalTo(view)
                })
                
                if (state?.banner?.numberOfItems)! > 1 {
                    view.addSubview((state?.pageControl)!)
                    state?.pageControl?.snp.makeConstraints({ make in
                        make.centerX.equalTo(view.snp.centerX)
                        make.bottom.equalTo(view.snp.bottom).offset(-5)
                        make.width.equalTo(12 * (state?.banner?.numberOfItems)!)
                        make.height.equalTo(12)
                    })
                } else {
                    state?.banner?.isScrollEnabled = false
                }
            } else {
                let headerImageView: UIImageView = {
                    let headerImageView = UIImageView()
                    headerImageView.contentMode = .scaleAspectFill
                    return headerImageView
                }()
                headerImageView.clipsToBounds = true
                headerImageView.contentMode = .scaleAspectFill
                view.addSubview(headerImageView)
                headerImageView.snp.makeConstraints({ make in
                    make.edges.equalTo(view)
                })
                
                headerImageView.setImageWith(URL(string: (categoryIntermediaryResult.headerImage!)))
                let label = UILabel()
                view.addSubview(label)
                if UI_USER_INTERFACE_IDIOM() == .phone {
                    headerImageView.snp.updateConstraints({ make in
                        make.left.equalTo(view.snp.left).offset(-100)
                    })
                }
                label.text = categoryIntermediaryResult.name.uppercased()
                label.textColor = UIColor.white
                if #available(iOS 8.2, *) {
                    label.font = UIFont.systemFont(ofSize: 24, weight: UIFontWeightLight)
                } else {
                    label.font = UIFont.systemFont(ofSize: 24)
                }
                label.shadowColor = UIColor.tpDisabledBlackText()
                label.shadowOffset = CGSize(width: 1, height: 1)
                label.snp.makeConstraints({ make in
                    make.centerY.equalTo(view.snp.centerY)
                    make.left.equalTo(view.snp.left).offset(15)
                })
            }
        }
        
        let subCategoryView = Node<CategoryIntermediarySubCategoryView> { [unowned self] view, layout, size in
            view.setIsRevamp(isRevamp: categoryIntermediaryResult.isRevamp)
            view.accessibilityLabel = "intermediarySubcategory"
            let isNeedSeeMoreButton = (state?.categoryIntermediaryNonHiddenChildren?.count)! > self.maximumNotExpandedCategory() ? true : false
            
            if state?.isCategorySubviewExpanded == false {
                view.setChildrenData(categoryChildren: (state?.categoryIntermediaryNotExpandedChildren)!, isNeedSeeMoreButton: isNeedSeeMoreButton)
                layout.height = ceil((CGFloat((categoryIntermediaryNotExpandedChildren.count)) / 3.0)) * 140 + (isNeedSeeMoreButton ? 38 : 0)
            } else {
                view.setChildrenData(categoryChildren: (state?.categoryIntermediaryNonHiddenChildren)!, isNeedSeeMoreButton: isNeedSeeMoreButton)
                layout.height = ceil((CGFloat((categoryIntermediaryNonHiddenChildren.count)) / 3.0)) * 140 + (isNeedSeeMoreButton ? 38 : 0)
            }
            
            view.didTapSeeAllButton = { [unowned self] in
                AnalyticsManager .trackEventName(GA_EVENT_CLICK_INTERMEDIARY,
                    category: "\(GA_EVENT_INTERMEDIARY_PAGE) -  \(String(describing: categoryIntermediaryNonHiddenChildren.first?.rootCategoryId))",
                    action: "Navigation",
                    label: "Expand Subcategory")
                self.state?.isCategorySubviewExpanded = !(state?.isCategorySubviewExpanded)!
                self.render(in: CGSize(width: UIScreen.main.bounds.size.width, height: size.height))
            }
        }
        
        let topAdsHeadlineView = Node<TopAdsHeadlineView> { [unowned self] topAdsHeadlineView, layout, size in
            guard let topAdsHeadline = self.state?.topAdsHeadline else { return }
            layout.width = size.width
            layout.height = 88
            topAdsHeadlineView.setInfo(topAdsHeadline)
            topAdsHeadlineView.hideSeparatorView()
        }
        
        func generateCuratedListView() -> Node<UIView> {
            let curatedListView = Node<UIView> { view, layout, _ in
                view.backgroundColor = UIColor.tpLine()
                layout.flexDirection = .column
                layout.justifyContent = .flexStart
                layout.marginTop = 15
            }
            
            return curatedListView
        }
        
        func borderView() -> NodeType {
            let borderView = Node<UIView>() { view, layout, _ in
                view.backgroundColor = .tpLine()
                layout.height = 0.75
            }
            
            return borderView
        }
        
        func titleView(title: String) -> NodeType {
            let titleContainerView = Node<UIView>() { view, layout, size in
                view.backgroundColor = .white
                layout.justifyContent = .spaceBetween
                layout.width = size.width
            }.add(children: [borderView(), Node<UIView>() { _, layout, _ in
                layout.justifyContent = .center
                layout.height = 58
                }.add(child: Node<UILabel>() { label, layout, _ in
                    if #available(iOS 8.2, *) {
                        label.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightSemibold)
                    } else {
                        label.font = UIFont.systemFont(ofSize: 16)
                    }
                    label.textColor = UIColor.tpPrimaryBlackText()
                    label.adjustsFontSizeToFitWidth = true
                    label.minimumScaleFactor = 0.5
                    label.text = title
                    layout.marginLeft = 10
            }), borderView()])
            
            return titleContainerView
        }
        
        func generateCuratedListProductContainer() -> Node<UIView> {
            let curatedListProductContainer = Node<UIView> { view, layout, _ in
                layout.flexDirection = .row
                layout.justifyContent = .flexStart
                layout.flexWrap = .wrap
                layout.marginBottom = 0.5
                view.backgroundColor = UIColor.tpBackground()
                view.accessibilityLabel = "productCuratedCell"
            }
            
            return curatedListProductContainer
        }
        
        func totalProductPerRowNeededBasedOnDevice() -> CGFloat {
            return (UI_USER_INTERFACE_IDIOM() == .phone ? 2 : 4)
        }
        
        func horizontalRectangleHotList(hotListItem: CategoryIntermediaryHotListItem) -> NodeType {
            return Node<UIView>(create: {
                let view = UIView()
                view.accessibilityLabel = "horizontalHotlist"
                view.bk_(whenTapped: {
                    AnalyticsManager.trackEventName(GA_EVENT_CLICK_INTERMEDIARY, category: "\(GA_EVENT_INTERMEDIARY_PAGE) -  \(categoryIntermediaryResult.rootCategoryId)", action: GA_EVENT_ACTION_HOTLIST, label: hotListItem.title)
                    TPRoutes.routeURL(URL(string: hotListItem.url)!)
                })
                return view
            }, configure: { view, layout, size in
                view.borderWidth = 0.5
                view.borderColor = .tpLine()
                
                layout.flexGrow = 2
                layout.flexBasis = size.width / (UI_USER_INTERFACE_IDIOM() == .phone ? 1 : 2)
            }).add(child: Node<UIImageView>() { view, layout, _ in
                layout.margin = 10
                layout.aspectRatio = 15 / 7
                view.layer.cornerRadius = 3
                view.clipsToBounds = true
                view.contentMode = .scaleAspectFill
                guard let hotListImg = hotListItem.img else { return }
                guard let hotListImgUrl = URL(string: hotListImg.url) else { return }
                view.setImageWith(hotListImgUrl)
            })
        }
        
        func squareHotList(hotListItem: CategoryIntermediaryHotListItem) -> NodeType {
            
            return Node<UIView>(create: {
                let view = UIView()
                view.accessibilityLabel = "squareHotlist"
                view.bk_(whenTapped: {
                    AnalyticsManager.trackEventName(GA_EVENT_CLICK_INTERMEDIARY, category: "\(GA_EVENT_INTERMEDIARY_PAGE) -  \(categoryIntermediaryResult.rootCategoryId)", action: GA_EVENT_ACTION_HOTLIST, label: hotListItem.title)
                    TPRoutes.routeURL(URL(string: "\(hotListItem.url)")!)
                })
                
                return view
            }, configure: { view, layout, size in
                view.borderWidth = 0.5
                view.borderColor = .tpLine()
                layout.flexGrow = 1
                layout.flexBasis = size.width / (UI_USER_INTERFACE_IDIOM() == .phone ? 2 : 4)
                
            }).add(child: Node<UIImageView>() { view, layout, _ in
                layout.margin = 10
                layout.aspectRatio = 1
                view.layer.cornerRadius = 3
                view.clipsToBounds = true
                guard let hotListImgSquare = hotListItem.imgSquare else { return }
                guard let hotListImgSquareUrl = URL(string: hotListImgSquare.url) else { return }
                view.setImageWith(hotListImgSquareUrl)
            })
        }
        
        func verticalRectangleHotList(hotListItem: CategoryIntermediaryHotListItem) -> NodeType {
            return Node<UIView>(create: {
                let view = UIView()
                view.accessibilityLabel = "verticalHotlist"
                view.bk_(whenTapped: {
                    AnalyticsManager.trackEventName(GA_EVENT_CLICK_INTERMEDIARY, category: "\(GA_EVENT_INTERMEDIARY_PAGE) -  \(categoryIntermediaryResult.rootCategoryId)", action: GA_EVENT_ACTION_HOTLIST, label: hotListItem.title)
                    TPRoutes.routeURL(URL(string: hotListItem.url)!)
                })
                return view
            }, configure: { view, layout, size in
                layout.width = size.width / totalProductPerRowNeededBasedOnDevice()
                layout.alignItems = .stretch
                view.borderWidth = 0.5
                view.borderColor = .tpLine()
            }).add(children: [Node<UIImageView>() { view, layout, _ in
                layout.margin = 10
                layout.aspectRatio = 7.0 / 10
                view.layer.cornerRadius = 3
                view.clipsToBounds = true
                guard let imgPortrait = hotListItem.imgPortrait else { return }
                guard let imgPortraitUrl = URL(string: imgPortrait.url) else { return }
                view.setImageWith(imgPortraitUrl)
            }])
        }
        
        func getTopicContainerView() -> NodeType {
            return Node<UIView>() { view, layout, _ in
                layout.marginTop = 15
                layout.justifyContent = .flexStart
                layout.flexDirection = .column
                view.backgroundColor = .white
            }
        }
        
        func getVideoView() -> NodeType {
            return getTopicContainerView().add(children: [Node<UILabel>() { label, layout, _ in
                    layout.marginTop = 20
                    layout.marginLeft = 10
                    layout.marginRight = 10
                    
                    label.text = categoryIntermediaryResult.video?.title
                    label.textColor = .tpPrimaryBlackText()
                    label.font = UIFont.smallThemeMedium()
                    label.textAlignment = .center
                },
                Node<UILabel>() { label, layout, _ in
                    layout.marginTop = 20
                    layout.marginLeft = 10
                    layout.marginRight = 10
                    
                    label.numberOfLines = 0
                    label.text = categoryIntermediaryResult.video?.videoDescription
                    label.textColor = .tpDisabledBlackText()
                    label.font = UIFont.microTheme()
                    label.textAlignment = .center
                    
                }
                , Node<YTPlayerView>() { playerView, layout, size in
                    layout.marginTop = 10
                    layout.marginBottom = 15
                    layout.height = 150
                    layout.width = size.width
                    playerView.accessibilityLabel = "intermediaryVideo"
                    playerView.backgroundColor = .green
                    playerView.delegate = state?.intermediaryViewController
                    
                    playerView.load(withVideoId: ((categoryIntermediaryResult.video?.videoUrl)?.components(separatedBy: "/").last!)!, playerVars: [
                        "origin": "https://www.tokopedia.com",
                        "showinfo": "0"
                    ])
                }
            ])
        }
        
        func officialStoreContentLeftPlusRightMargin() -> CGFloat {
            return 10
        }
        
        func officialStoreData(officialStoreHomeItem: OfficialStoreHomeItem) -> NodeType {
            return Node<UIView>(create: {
                let view = UIView()
                view.bk_(whenTapped: {
                    AnalyticsManager.trackEventName(GA_EVENT_CLICK_INTERMEDIARY, category: "\(GA_EVENT_INTERMEDIARY_PAGE) -  \(categoryIntermediaryResult.rootCategoryId)", action: "Official Store", label: officialStoreHomeItem.shopName)
                    let viewController = ShopViewController()
                    viewController.data = [
                        "shop_id": officialStoreHomeItem.shopId
                    ]
                    
                    state?.intermediaryViewController?.navigationController?.pushViewController(viewController, animated: true)
                })
                
                return view
            }, configure: { view, layout, size in
                layout.alignItems = .stretch
                view.accessibilityIdentifier = "osView"
                view.clipsToBounds = true
                view.layer.cornerRadius = 3
                view.layer.borderWidth = 1
                view.layer.borderColor = UIColor.tpLine().cgColor
                layout.margin = 5
                layout.width = ((size.width - officialStoreContentLeftPlusRightMargin()) / (UI_USER_INTERFACE_IDIOM() == .phone ? 3.0 : 6.0)) - layout.margin * 2
            }).add(child: Node<UIImageView>() { imageView, layout, _ in
                layout.aspectRatio = 1
                imageView.accessibilityLabel = "officialStoreCell"
                imageView.layer.cornerRadius = 3
                imageView.contentMode = .scaleAspectFit
                layout.margin = 10
                imageView.setImageWith(URL(string: officialStoreHomeItem.imageUrl))
            })
        }
        
        func generateOfficialStoreData() -> [NodeType] {
            var views: [NodeType] = []
            for officialStoreHomeItem in (state?.officialStoreHomeItems)! {
                views.append(officialStoreData(officialStoreHomeItem: officialStoreHomeItem))
            }
            
            return views
        }
        
        func getOfficialStoreContentView() -> NodeType {
            return Node<UIView>() { view, layout, _ in
                layout.flexDirection = .row
                layout.justifyContent = .flexStart
                layout.alignItems = .flexStart
                layout.flexWrap = .wrap
                layout.margin = 5
                // still need marginBottom to be set, becasuse layout.margin itself is not working
                layout.marginBottom = 5
                view.backgroundColor = .white
            }.add(children: generateOfficialStoreData())
        }
        
        func seeAllContainerView() -> NodeType {
            if (state?.officialStoreHomeItems?.count)! > 6 {
                return Node<UIView>(create: {
                    let view = UIView()
                    view.bk_(whenTapped: {
                        TPRoutes.routeURL(URL(string: "www.tokopedia.com")!)
                    })
                    return view
                }, configure: { _, layout, _ in
                    layout.justifyContent = .flexEnd
                    layout.flexDirection = .row
                }).add(children: [Node<UILabel>() { label, layout, _ in
                        layout.marginTop = 15
                        layout.marginBottom = 15
                        layout.marginRight = 5
                        label.text = "Lihat Semua"
                        label.font = UIFont.largeThemeMedium()
                        label.textColor = .tpGreen()
                    },
                    Node<UIImageView>() { imageView, layout, _ in
                        imageView.image = UIImage(named: "icon_forward")
                        imageView.tintColor = .tpGreen()
                        imageView.contentMode = .scaleAspectFit
                        layout.marginTop = 15
                        layout.marginBottom = 15
                        layout.marginRight = 15
                    }
                    
                ])
            } else {
                return NilNode()
            }
        }
        
        func getOfficialStoreContainerView() -> NodeType {
            return getTopicContainerView().add(children: [
                titleView(title: "Official Store"),
                getOfficialStoreContentView(),
                borderView(),
                seeAllContainerView()
            ])
        }
        
        func generateCuratedProductCell(curatedProduct: CategoryIntermediaryProduct) -> Node<ProductCell> {
            let curatedProductCell = Node<ProductCell>(
                create: {
                    let content = UINib(nibName: "ProductCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ProductCell
                    return content
                }
            , configure: { cell, layout, _ in
                let cellSize = ProductCellSize.sizeWithType(1)
                layout.width = cellSize.width
                layout.height = cellSize.height
                
                let productModelView = ProductModelView()
                
                productModelView.productName = curatedProduct.name
                productModelView.productPrice = curatedProduct.price
                productModelView.productThumbUrl = curatedProduct.imageUrl
                productModelView.productShop = curatedProduct.shop.name
                productModelView.shopLocation = curatedProduct.shop.location
                productModelView.isGoldShopProduct = curatedProduct.shop.isGold
                productModelView.badges = curatedProduct.badges
                productModelView.labels = curatedProduct.labels
                productModelView.productId = String(curatedProduct.id)
                productModelView.isOnWishlist = curatedProduct.isOnWishlist
                
                cell.viewModel = productModelView
                cell.removeWishlistButton()
                cell.parentViewController = state?.intermediaryViewController
                cell.applinks = curatedProduct.applinks
                if let delegate = state?.intermediaryViewController {
                    cell.delegate = delegate
                }
                cell.bk_(whenTapped: {
                    AnalyticsManager.trackEventName(GA_EVENT_CLICK_INTERMEDIARY, category: "\(GA_EVENT_INTERMEDIARY_PAGE) -  \(categoryIntermediaryResult.rootCategoryId)", action: "Curated \(cell.viewModel.productName)", label: cell.viewModel.productName)
                    TPRoutes.routeURL(URL(string: cell.applinks)!)
                })
            })

            return curatedProductCell
        }
        
        containerView.add(children: [
            bannerView,
            subCategoryView,
            topAdsHeadlineView
        ])
        
        if (state?.categoryIntermediaryHotListItems.count)! > 0 {
            let hotListContainerView = Node<UIView>() { _, layout, _ in
                layout.marginTop = 15
                layout.flexDirection = .column
                layout.justifyContent = .flexStart
                layout.alignItems = .stretch
            }.add(children: [titleView(title: "Hot List"),
                             Node<UIView>() { view, layout, _ in
                                 layout.flexDirection = .row
                                 layout.flexWrap = .wrap
                                 view.backgroundColor = .white
                             }.add(children:
                                 (state?.categoryIntermediaryHotListItems.enumerated().map({ index, hotListItem in
                                     
                                     if index == 0 {
                                         return horizontalRectangleHotList(hotListItem: hotListItem)
                                     } else if index == 1 || index == 2 {
                                         return squareHotList(hotListItem: hotListItem)
                                     }
                                     
                                     return verticalRectangleHotList(hotListItem: hotListItem)
                                 }))!
                                 
            )])
            
            containerView.add(child: hotListContainerView)
        }
        
        if (state?.officialStoreHomeItems?.count)! > 0 {
            containerView.add(child: getOfficialStoreContainerView())
        }
        
        if (state?.ads.count)! > 0 {
            containerView.add(child: TopAdsNode(ads: (state?.ads)!))
        }
        
        if let sections = categoryIntermediaryResult.curatedProduct?.sections {
            for (sectionIndex, curatedListSections) in sections.enumerated() {
                let curatedListView = generateCuratedListView()
                
                curatedListView.add(children: [titleView(title: (sections[sectionIndex].title))])
                let curatedListProductContainer = generateCuratedListProductContainer()
                for (productIndex,curatedProduct) in curatedListSections.products.enumerated() {
                    if productIndex < 4 {
                        curatedListProductContainer.add(child: generateCuratedProductCell(curatedProduct: curatedProduct))
                    }
                }
                curatedListView.add(child: curatedListProductContainer)
                containerView.add(child: curatedListView)
            }
        }
        
        if categoryIntermediaryResult.video?.videoUrl != nil {
            containerView.add(child: getVideoView())
        }
        
        containerView.add(child: Node<UIView>() { view, layout, _ in
            view.backgroundColor = .tpBackground()
            layout.flexDirection = .row
            layout.alignItems = .center
            
        }.add(children: [Node<UIButton>(create: {
            let button = UIButton()
            button.bk_(whenTapped: {
                let navigateController = NavigateViewController()
                navigateController.navigateToIntermediaryCategory(from: state?.intermediaryViewController, withCategoryId: categoryIntermediaryResult.id, categoryName: categoryIntermediaryResult.name, isIntermediary: false)
            })
            return button
        }, configure: { button, layout, _ in
                layout.marginTop = 25
                layout.marginBottom = 25
                layout.marginLeft = 10
                layout.marginRight = 10
                layout.height = 52
                layout.flexGrow = 1
                button.accessibilityLabel = "seeAllCategory"
                button.backgroundColor = .tpGreen()
                button.layer.cornerRadius = 3
                button.setTitle("Lihat Produk \(categoryIntermediaryResult.name) Lainnya", for: .normal)
                if #available(iOS 8.2, *) {
                    button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightSemibold)
                } else {
                    button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                }
        })]))
        
        return containerView
    }
    
    // MARK: Common Function
    private func maximumNotExpandedCategory() -> Int {
        return 9
    }
}

class CategoryIntermediaryViewController: UIViewController, ProductCellDelegate {
    
    private var uiSearchController: UISearchController!
    private var intermediaryView: IntermediaryViewComponent!
    fileprivate var categoryIntermediaryResult: CategoryIntermediaryResult!
    private var carouselDataSource: CarouselDataSource!
    fileprivate var videoFirstTimePlaying = true
    
    fileprivate lazy var safeAreaView: UIView = {
        let view = UIView(frame: CGRect.zero)
        
        view.backgroundColor = .clear
        
        return view
    }()
    
    func changeWishlist(forProductId productId: String, withStatus isOnWishlist: Bool) {
        guard let curatedProduct = categoryIntermediaryResult.curatedProduct else { return }
        guard let sections = curatedProduct.sections else { return }
        for section in sections {
            let product = section.products.first { $0.id == productId }
            product?.isOnWishlist = isOnWishlist
        }
    }
    
    // MARK: Network Manager
    private lazy var hotListNetworkManager: TokopediaNetworkManager = {
        var hotListNetworkManager = TokopediaNetworkManager()
        hotListNetworkManager.isUsingHmac = true
        return hotListNetworkManager
    }()
    
    private lazy var officialStoreNetworkManager: TokopediaNetworkManager = {
        var officialStoreNetworkManager = TokopediaNetworkManager()
        officialStoreNetworkManager.isUsingHmac = true
        return officialStoreNetworkManager
    }()
    
    // MARK: View Controller Delegate Function
    init(categoryIntermediaryResult: CategoryIntermediaryResult) {
        super.init(nibName: nil, bundle: nil)
        self.categoryIntermediaryResult = categoryIntermediaryResult
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .tpBackground()
        
        let pageControl = StyledPageControl()
        pageControl.pageControlStyle = PageControlStyleDefault
        pageControl.coreNormalColor = UIColor(red: 214.0 / 255.0, green: 214.0 / 255.0, blue: 214.0 / 255.0, alpha: 1)
        pageControl.coreSelectedColor = UIColor(red: 255.0 / 255.0, green: 87.0 / 255.0, blue: 34.0 / 255, alpha: 1)
        pageControl.diameter = 11
        pageControl.gapWidth = 5
        
        pageControl.numberOfPages = categoryIntermediaryResult.banner!.images.count
        let slider = iCarousel(frame: .zero)
        
        self.carouselDataSource = CarouselDataSource(banner: categoryIntermediaryResult.banner!.images, pageControl: pageControl, type: .category, slider: slider)
        carouselDataSource.didSelectBanner = { [unowned self] banner, index in
            AnalyticsManager.trackEventName(GA_EVENT_CLICK_INTERMEDIARY, category: "\(GA_EVENT_INTERMEDIARY_PAGE) - \(self.categoryIntermediaryResult.rootCategoryId)", action: "Banner Click", label: banner.bannerTitle)
        }
        self.carouselDataSource.navigationDelegate = navigationController
        
        slider.dataSource = self.carouselDataSource
        slider.delegate = self.carouselDataSource
        slider.decelerationRate = 0.5
        
        self.carouselDataSource.startBannerAutoScroll()
        
        intermediaryView = IntermediaryViewComponent()
        intermediaryView.state = IntermediaryState(intermediaryViewController: self,
                                                   categoryIntermediaryResult: categoryIntermediaryResult,
                                                   categoryIntermediaryNonHiddenChildren: categoryIntermediaryResult.nonHiddenChildren,
                                                   categoryIntermediaryNotExpandedChildren: categoryIntermediaryResult.nonExpandedChildren,
                                                   isCategorySubviewExpanded: false, categoryIntermediaryHotListItems: [],
                                                   ads: [],
                                                   banner: slider,
                                                   pageControl: pageControl,
                                                   officialStoreHomeItems: [],
                                                   topAdsHeadline: nil)
        intermediaryView.state?.categoryIntermediaryResult = categoryIntermediaryResult
        intermediaryView.state?.categoryIntermediaryNonHiddenChildren = categoryIntermediaryResult.nonHiddenChildren
        intermediaryView.state?.categoryIntermediaryNotExpandedChildren = categoryIntermediaryResult.nonExpandedChildren
        
        let backButtonItem = UIBarButtonItem(image: UIImage(named: "icon_arrow_white"), style: .plain, target: self, action: #selector(CategoryIntermediaryViewController.back))
        
        self.view.addSubview(self.safeAreaView)
        
        self.safeAreaView.addSubview(self.intermediaryView)
        
        self.safeAreaView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.safeAreaView.topAnchor.constraint(equalTo: self.view.safeAreaTopAnchor, constant: 0),
            self.safeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaBottomAnchor, constant: 0),
            self.safeAreaView.rightAnchor.constraint(equalTo: self.view.safeAreaRightAnchor, constant: 0),
            self.safeAreaView.leftAnchor.constraint(equalTo: self.view.safeAreaLeftAnchor, constant: 0)
            ])
        
        intermediaryView.render(in: self.safeAreaView.bounds.size)
        
        self.navigationItem.leftBarButtonItem = backButtonItem
        
        requestHotlist()
        requestTopAdsHeadline(departmentId: categoryIntermediaryResult.id)
        AnalyticsManager.trackScreenName("Browse Category - \(categoryIntermediaryResult.id)")
    }
    
    func back() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let searchController = SearchViewController()
        
        uiSearchController = UISearchController(searchResultsController: searchController)
        searchController.searchBar = uiSearchController.searchBar
        uiSearchController.setSearchBarToTop(viewController: self, title: categoryIntermediaryResult.name)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.definesPresentationContext = false
        self.uiSearchController.isActive = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.definesPresentationContext = true
        self.uiSearchController.searchResultsController?.view.isHidden = true
    }
    
    // MARK: API
    private func requestOfficialStore() {
        _ = NetworkProvider<MojitoTarget>()
            .request(.requestOfficialStore(categoryId: categoryIntermediaryResult.id))
            .map(to: [OfficialStoreHomeItem.self], fromKey: "data")
            .subscribe(onNext: { [weak self] result in
                guard let `self` = self else { return }
                self.intermediaryView.state?.officialStoreHomeItems = result
                self.intermediaryView.render(in: self.safeAreaView.bounds.size)
            })
    }
    
    func requestHotlist() {
        self.hotListNetworkManager.request(withBaseUrl: NSString.aceUrl(), path: "/hoth/hotlist/v1/category", method: .GET, parameter: ["categories": categoryIntermediaryResult.id, "perPage": "7"], mapping: CategoryIntermediaryHotListResponse.mapping(), onSuccess: { [unowned self] mappingResult, _ in
            let result: NSDictionary = (mappingResult as RKMappingResult).dictionary() as NSDictionary
            let categoryIntermediaryHotListResponse: CategoryIntermediaryHotListResponse = result[""] as! CategoryIntermediaryHotListResponse
            self.intermediaryView.state?.categoryIntermediaryHotListItems = categoryIntermediaryHotListResponse.list
            self.intermediaryView.render(in: self.safeAreaView.bounds.size)
            
            self.requestOfficialStore()
            
            let filter = TopAdsFilter(source: .intermediary, departementId: self.categoryIntermediaryResult.id)
            
            TopAdsService().getTopAds(topAdsFilter: filter, onSuccess: { [weak self] ads in
                guard let `self` = self else { return }
                
                self.intermediaryView.state?.ads = ads
                self.intermediaryView.render(in: self.safeAreaView.bounds.size)
                
            }, onFailure: { _ in })
            
        }, onFailure: { _ in
            
        })
    }
    
    func requestTopAdsHeadline(departmentId: String) {
        TopAdsService().requestTopAdsHeadline(departmentId: departmentId, onSuccess: { (topAdsHeadline) in
            self.intermediaryView.state?.topAdsHeadline = topAdsHeadline
        }) { (error) in
            
        }
    }
}

extension CategoryIntermediaryViewController: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.webView?.allowsInlineMediaPlayback = false
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        if state == .playing && videoFirstTimePlaying {
            AnalyticsManager.trackEventName(GA_EVENT_CLICK_INTERMEDIARY, category: "\(GA_EVENT_INTERMEDIARY_PAGE) -  \(categoryIntermediaryResult.rootCategoryId)", action: "Video Click", label: categoryIntermediaryResult.video?.title)
            videoFirstTimePlaying = false
        }
    }
}
