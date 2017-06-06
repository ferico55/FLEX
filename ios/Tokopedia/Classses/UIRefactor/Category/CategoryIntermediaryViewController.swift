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

struct IntermediaryState: StateType {
    var intermediaryViewController: CategoryIntermediaryViewController?
    var categoryIntermediaryResult: CategoryIntermediaryResult?
    var categoryIntermediaryNonHiddenChildren: [CategoryIntermediaryChild]?
    var categoryIntermediaryNotExpandedChildren: [CategoryIntermediaryChild]?
    var isCategorySubviewExpanded: Bool!
    var categoryIntermediaryHotListItems: [CategoryIntermediaryHotListItem] = []
    var ads = [PromoResult]()
}

class IntermediaryViewComponent: ComponentView<IntermediaryState> {
    
    override func construct(state: IntermediaryState?, size: CGSize) -> NodeType {
        let containerView = Node<UIScrollView>{ scrollView, layout, size in
            scrollView.backgroundColor = UIColor.tpBackground()
            
            layout.width = size.width
            layout.height = size.height
        }
        
        containerView.add(child: Node<UIRefreshControl>() { refreshControl, layout, size in
            refreshControl.endRefreshing()
            layout.height = 0
            refreshControl.bk_addEventHandler({ (sender) in
                state?.intermediaryViewController?.requestHotlist()
            }, for: .valueChanged)
        })
        
        guard let categoryIntermediaryResult = state?.categoryIntermediaryResult,
            let categoryIntermediaryNonHiddenChildren = state?.categoryIntermediaryNonHiddenChildren,
            let categoryIntermediaryNotExpandedChildren = state?.categoryIntermediaryNotExpandedChildren else {
                return containerView
        }
        
        let bannerView = Node<UIImageView> { view, layout, size in
            if let headerImage = categoryIntermediaryResult.headerImage {
                view.setImageWith(URL(string: (headerImage)))
            }
            view.contentMode = .scaleAspectFill
            layout.justifyContent = .center
            layout.alignItems = .flexStart
            layout.height = 150
            view.clipsToBounds = true
            if UI_USER_INTERFACE_IDIOM() == .phone {
                layout.marginLeft = -200
            }
        }
        
        let titleLabel = Node<UILabel> { label, layout, size in
            label.text = categoryIntermediaryResult.name.uppercased()
            label.textColor = UIColor.white
            if #available(iOS 8.2, *) {
                label.font = UIFont.systemFont(ofSize: 24, weight: UIFontWeightLight)
            } else {
                label.font = UIFont.systemFont(ofSize: 24)
            }
            label.shadowColor = UIColor.tpDisabledBlackText()
            label.shadowOffset = CGSize(width: 1, height: 1)
            if UI_USER_INTERFACE_IDIOM() == .phone {
                layout.marginLeft = 215
            } else {
                layout.marginLeft = 20
            }
        }
        
        let subCategoryView = Node<CategoryIntermediarySubCategoryView> { [unowned self] view, layout, size in
            view.setIsRevamp(isRevamp: (state?.categoryIntermediaryResult?.isRevamp)!)
            let isNeedSeeMoreButton = (state?.categoryIntermediaryNonHiddenChildren?.count)! > self.maximumNotExpandedCategory() ? true : false
            
            if state?.isCategorySubviewExpanded == false {
                view.setChildrenData(categoryChildren: (state?.categoryIntermediaryNotExpandedChildren)!, isNeedSeeMoreButton: isNeedSeeMoreButton)
                layout.height = ceil((CGFloat((categoryIntermediaryNotExpandedChildren.count)) / 3.0)) * 140 + (isNeedSeeMoreButton ? 38 : 0)
            } else {
                view.setChildrenData(categoryChildren: (state?.categoryIntermediaryNonHiddenChildren)!, isNeedSeeMoreButton: isNeedSeeMoreButton)
                layout.height = ceil((CGFloat((categoryIntermediaryNonHiddenChildren.count)) / 3.0)) * 140 + (isNeedSeeMoreButton ? 38 : 0)
            }
            
            view.didTapSeeAllButton = { [unowned self] in
                self.state?.isCategorySubviewExpanded = !(state?.isCategorySubviewExpanded)!
                self.render(in: CGSize(width: UIScreen.main.bounds.size.width, height: size.height))
            }
        }
        
        func generateCuratedListView() -> Node<UIView>{
            let curatedListView = Node<UIView> { view, layout, size in
                view.backgroundColor = UIColor.tpLine()
                layout.flexDirection = .column
                layout.justifyContent = .flexStart
                layout.marginTop = 15
            }
            
            return curatedListView
        }
        
        func borderView() -> NodeType {
            let borderView = Node<UIView>() { view, layout, size in
                view.backgroundColor = .tpLine()
                layout.height = 0.75
            }
            
            return borderView
        }
        
        func titleView(title: String) -> NodeType {
            let titleContainerView = Node<UIView>() { view, layout, size in
                view.backgroundColor = .white
                layout.justifyContent = .spaceBetween
                }.add(children: [borderView(), Node<UIView>() { view, layout, size in
                    layout.justifyContent = .center
                    layout.height = 58
                    }.add(child: Node<UILabel>() { label, layout, size in
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
            let curatedListProductContainer = Node<UIView> { view, layout, size in
                layout.flexDirection = .row
                layout.justifyContent = .flexStart
                layout.flexWrap = .wrap
                layout.marginBottom = 0.5
                view.backgroundColor = UIColor.tpBackground()
            }
            
            return curatedListProductContainer
        }
        
        func totalProductPerRowNeededBasedOnDevice() -> CGFloat{
            return (UI_USER_INTERFACE_IDIOM() == .phone ? 2 : 4)
        }
        
        
        func generateCuratedProductCell(curatedProduct: CategoryIntermediaryProduct) -> Node<ProductCell> {
            let curatedProductCell = Node<ProductCell>(
                create: {
                    let content = UINib(nibName: "ProductCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ProductCell
                    
                    
                    return content
            }
            ) { cell, layout, size in
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
                
                cell.setViewModel(productModelView)
                cell.removeWishlistButton()
                cell.parentViewController = state?.intermediaryViewController
                cell.applinks = curatedProduct.applinks
                cell.delegate = state?.intermediaryViewController as! ProductCellDelegate
                cell.bk_(whenTapped: {
                    AnalyticsManager.trackEventName(GA_EVENT_CLICK_INTERMEDIARY, category: GA_EVENT_INTERMEDIARY_PAGE, action: "Curated \(curatedProduct.name)", label: curatedProduct.name)
                    TPRoutes.routeURL(URL(string: curatedProduct.applinks)!)
                })
            }
            return curatedProductCell
        }
        
        ////////////////////////////////////////////
        bannerView.add(child: titleLabel)
        containerView.add(children: [
            bannerView,
            subCategoryView,
            TopAdsNode(ads: state?.ads ?? [])
            ]);
        
        if let curatedProduct = state?.categoryIntermediaryResult?.curatedProduct {
            for (sectionIndex, curatedListSections) in curatedProduct.sections.enumerated() {
                let curatedListView = generateCuratedListView()
                
                curatedListView.add(children: [titleView(title: (curatedProduct.sections[sectionIndex].title))])
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
        
        if (state?.categoryIntermediaryHotListItems.count)! > 0 {
            let hotListContainerView = Node<UIView>() {view, layout, size in
                layout.marginTop = 15
                layout.flexDirection = .column
                layout.justifyContent = .flexStart
                layout.alignItems = .stretch
                }.add(children: [titleView(title: "Hot List"),
                                 Node<UIView>() { view, layout, size in
                                    layout.flexDirection = .row
                                    layout.flexWrap = .wrap
                                    view.backgroundColor = .white
                                    }.add(children: (state?.categoryIntermediaryHotListItems.map { child in
                                        return Node<UIView>() { view, layout, size in
                                            layout.width = size.width / totalProductPerRowNeededBasedOnDevice()
                                            layout.alignItems = .stretch
                                            view.borderWidth = 0.5
                                            view.borderColor = .tpLine()
                                            view.bk_(whenTapped: {
                                                AnalyticsManager.trackEventName(GA_EVENT_CLICK_INTERMEDIARY, category: GA_EVENT_INTERMEDIARY_PAGE, action: GA_EVENT_ACTION_HOTLIST, label: child.title)
                                                TPRoutes.routeURL(URL(string:"\(child.url)")!)
                                            })
                                            
                                            }.add(children: [Node<UIImageView>() { view, layout, size in
                                                layout.margin = 10
                                                layout.aspectRatio = 7.0/10
                                                view.setImageWith(URL(string: (child.image.url)))
                                                view.layer.cornerRadius = 3
                                                view.clipsToBounds = true
                                                }])
                                        })!)
                    ])
            
            containerView.add(child: hotListContainerView)
        }
        
        containerView.add(child: Node<UIView>() { view, layout, size in
            view.backgroundColor = .tpBackground()
            layout.flexDirection = .row
            layout.alignItems = .center
            
            }.add(children: [Node<UIButton>() { button, layout, size in
                layout.marginTop = 25
                layout.marginBottom = 25
                layout.marginLeft = 10
                layout.marginRight = 10
                layout.height = 52
                layout.flexGrow = 1
                button.backgroundColor = .tpGreen()
                button.layer.cornerRadius = 3
                button.setTitle("Lihat Produk \(categoryIntermediaryResult.name) Lainnya", for: .normal)
                if #available(iOS 8.2, *) {
                    button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightSemibold)
                } else {
                    button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                }
                
                button.bk_(whenTapped: {
                    let navigateController = NavigateViewController()
                    navigateController.navigateToIntermediaryCategory(from: state?.intermediaryViewController, withCategoryId: state?.categoryIntermediaryResult?.id, categoryName: state?.categoryIntermediaryResult?.name, isIntermediary: false)
                })
                }]))
        
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
    private var categoryIntermediaryResult: CategoryIntermediaryResult!
    
    func changeWishlist(forProductId productId: String, withStatus isOnWishlist: Bool) {
        guard let curatedProduct = categoryIntermediaryResult.curatedProduct else { return }
        for section in curatedProduct.sections {
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
        
        intermediaryView = IntermediaryViewComponent()
        intermediaryView.state = IntermediaryState(intermediaryViewController: self, categoryIntermediaryResult: categoryIntermediaryResult, categoryIntermediaryNonHiddenChildren: categoryIntermediaryResult.nonHiddenChildren, categoryIntermediaryNotExpandedChildren: categoryIntermediaryResult.nonExpandedChildren, isCategorySubviewExpanded: false, categoryIntermediaryHotListItems: [], ads: [])
        intermediaryView.state?.categoryIntermediaryResult = categoryIntermediaryResult
        intermediaryView.state?.categoryIntermediaryNonHiddenChildren = categoryIntermediaryResult.nonHiddenChildren
        intermediaryView.state?.categoryIntermediaryNotExpandedChildren = categoryIntermediaryResult.nonExpandedChildren
        intermediaryView.render(in: self.view.bounds.size)
        
        let backButtonItem = UIBarButtonItem(image: UIImage(named:"icon_arrow_white"), style: .plain, target: self, action: #selector(CategoryIntermediaryViewController.back))
        
        self.view.addSubview(self.intermediaryView)
        
        self.navigationItem.leftBarButtonItem = backButtonItem
        
        requestHotlist()
        AnalyticsManager.trackScreenName("Browse Category - \(categoryIntermediaryResult.id)")
    }
    
    func back() {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let searchController = SearchViewController()
        searchController.presentController = self
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
        self.definesPresentationContext = true;
        self.uiSearchController.searchResultsController?.view.isHidden = true;
    }
    
    // MARK: API
    func requestHotlist() {
        hotListNetworkManager.request(withBaseUrl: NSString.aceUrl(), path: "/hoth/hotlist/v1/category", method: .GET, parameter: ["categories" : categoryIntermediaryResult.id, "perPage" : "4"], mapping: CategoryIntermediaryHotListResponse.mapping(), onSuccess: { [unowned self] (mappingResult, operation) in
            let result: NSDictionary = (mappingResult as RKMappingResult).dictionary() as NSDictionary
            let categoryIntermediaryHotListResponse: CategoryIntermediaryHotListResponse = result[""] as! CategoryIntermediaryHotListResponse
            self.intermediaryView.state?.categoryIntermediaryHotListItems = categoryIntermediaryHotListResponse.list
            self.intermediaryView.render(in: self.view.bounds.size)
            let filter = TopAdsFilter(source: .intermediary, departementId: self.categoryIntermediaryResult.id)
            
            TopAdsService().getTopAds(topAdsFilter: filter, onSuccess: { [weak self] ads in
                guard let `self` = self else { return }
                
                self.intermediaryView.state?.ads = ads
                self.intermediaryView.render(in: self.view.bounds.size)
                
                }, onFailure: { error in })
            }, onFailure: {error in
                
        })
    }
    
    // MARK: Common Function
    
}


