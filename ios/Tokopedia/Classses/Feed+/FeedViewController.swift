//
//  FeedViewController.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 4/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render
import RxSwift
import RxCocoa
import ReSwift
import SnapKit
import Apollo

class FeedViewController: UIViewController {
    
    let refreshControl = UIRefreshControl()
    var feedState = FeedState()
    var feedWatcher: GraphQLQueryWatcher<FeedsQuery>?
    var feedCards: [FeedCardState] = []
    let footerView = UIView(frame: CGRect.zero)
    var page = 1
    var isRequesting = false
    let topAdsService = TopAdsService()
    var shouldRefreshData = false
    var currentCursor = ""
    var emptyStateButtonTapped = false
    var isRefreshing = false
    
    let feedCardSource = PublishSubject<[FeedCardState]>()
    
    var feedClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        let userManager = UserAuthentificationManager()
        
        let appVersion = UIApplication.getAppVersionString()
        
        let headers = ["Tkpd-UserId": userManager.getUserId(),
                       "Tkpd-SessionId": userManager.getMyDeviceToken(),
                       "X-Device": "ios-\(appVersion)",
                       "Device-Type": ((UI_USER_INTERFACE_IDIOM() == .phone) ? "iphone" : "ipad")]
        
        configuration.httpAdditionalHeaders = headers
        
        let url = URL(string: NSString.feedsMobileSiteUrl() + "/graphql")!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.userDidLogin), name: NSNotification.Name(rawValue: TKPDUserDidLoginNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didSwipeHomeTab), name: NSNotification.Name(rawValue: "didSwipeHomeTab"), object: nil)
        
        self.view.backgroundColor = .tpBackground()
        self.setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        AnalyticsManager.trackScreenName("Feed Page")
        if self.shouldRefreshData {
            self.refreshFeed()
        }
    }
    
    private func setupView() {
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.backgroundColor = .tpBackground()
        self.tableView.separatorStyle = .none
        self.tableView.showsVerticalScrollIndicator = false
        
        self.refreshControl.addTarget(self, action: #selector(self.refreshFeed), for: .valueChanged)
        
        self.footerView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 40)
        self.footerView.backgroundColor = .clear
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.footerView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        activityIndicator.snp.makeConstraints { make in
            make.centerX.equalTo(self.footerView)
            make.centerY.equalTo(self.footerView)
        }
        
        self.tableView.addSubview(self.refreshControl)
        
        feedCardSource.asObservable()
            .bindTo(self.tableView.rx.items) { _, _, item in
                let cell = ComponentTableViewCell<FeedComponentView>()
                cell.mountComponentIfNecessary(
                    FeedComponentView(
                        viewController: self,
                        onTopAdsStateChanged: { [weak self] state in
                            guard let `self` = self else { return }
                            
                            var newCard = FeedCardState()
                            newCard.topads = state
                            
                            let cards = self.feedCards
                            
                            for (index, element) in cards.enumerated() {
                                if element.topads?.topAds?[0].result_id == state.topAds?[0].result_id {
                                    self.feedCards.remove(at: index)
                                    self.feedCards.insert(newCard, at: index)
                                }
                            }
                            
                            self.feedCardSource.onNext(self.feedCards)
                        },
                        onEmptyStateButtonPressed: { [weak self] errorType in
                            guard let `self` = self else { return }
                            
                            self.emptyStateButtonTapped = true
                            
                            if errorType == .emptyFeed {
                                NotificationCenter.default.post(name: Notification.Name("didSwipeHomePage"), object: self, userInfo: ["page": 5])
                            } else {
                                var newCard = FeedCardState()
                                newCard.isEmptyState = true
                                newCard.errorType = errorType
                                newCard.refreshButtonIsLoading = true
                                
                                self.feedCards.removeFirst()
                                self.feedCards = [newCard] + self.feedCards
                                self.feedCardSource.onNext(self.feedCards)
                                
                                self.refreshFeed()
                            }
                        },
                        onReloadNextPagePressed: { [weak self] in
                            guard let `self` = self else { return }
                            
                            var newCard = FeedCardState()
                            newCard.isNextPageError = true
                            newCard.nextPageReloadIsLoading = true
                            
                            self.feedCards.removeLast()
                            self.feedCards.append(newCard)
                            
                            self.feedCardSource.onNext(self.feedCards)
                            
                            self.loadFeed(cursor: self.currentCursor, shouldTrackMoengage: false)
                        }
                    )
                )
                cell.state = item
                cell.isUserInteractionEnabled = true
                return cell
            }
            .disposed(by: rx_disposeBag)
        
        self.view.addSubview(tableView)
        tableView.mas_makeConstraints { make in
            if self.feedState.oniPad {
                _ = make?.left.mas_equalTo()(self.view.mas_left)?.offset()(104)
                _ = make?.right.mas_equalTo()(self.view.mas_right)?.offset()(-104)
                _ = make?.top.mas_equalTo()(self.view)?.offset()(15)
                _ = make?.bottom.mas_equalTo()(self.view.mas_bottom)
            } else {
                _ = make?.edges.mas_equalTo()(self.view)
            }
        }
        
        self.tableView.rx_reachedBottom
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                if self.feedState.hasNextPage && !self.isRequesting {
                    self.isRefreshing = false
                    self.loadFeed(cursor: self.feedState.cursor, shouldTrackMoengage: false)
                }
            })
            .disposed(by: rx_disposeBag)
        
        self.loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @objc private func refreshFeed() {
        self.page = 1
        self.isRefreshing = true
        self.feedClient = self.reinitApolloClient()
        self.feedCards = []
        self.loadFeed(cursor: "", shouldTrackMoengage: false)
    }
    
    private func loadData() {
        self.page = 1
        self.isRefreshing = true
        self.feedClient = self.reinitApolloClient()
        self.feedCards = []
        self.loadFeed(cursor: "", shouldTrackMoengage: true)
    }
    
    private func loadFeed(cursor: String, shouldTrackMoengage: Bool) {
        self.currentCursor = cursor
        let userManager = UserAuthentificationManager()
        let userID = userManager.getUserId()
        
        self.isRequesting = true
        
        if self.isRequesting {
            if !self.isRefreshing || !self.emptyStateButtonTapped {
                self.tableView.tableFooterView = self.footerView
            }
            
            self.feedWatcher = self.feedClient.watch(query: FeedsQuery(userId: Int(userID!)!, limit: 5, cursor: cursor, page: self.page)) { result, error in
                if let error = error {
                    if shouldTrackMoengage {
                        AnalyticsManager.moEngageTrackEvent(withName: "Feed_Screen_Launched", attributes: ["logged_in_status": true,
                                                                                                           "is_feed_empty": true])
                    }
                    NSLog("Error while fetching query: \(error.localizedDescription)")
                    self.feedState = FeedStateManager().initFeedState(queryResult: nil)
                    self.loadContent(onPage: self.page, total: -1)
                    self.tableView.tableFooterView = nil
                    self.isRequesting = false
                    return
                }
                
                if result?.errors != nil {
                    if shouldTrackMoengage {
                        AnalyticsManager.moEngageTrackEvent(withName: "Feed_Screen_Launched", attributes: ["logged_in_status": true,
                                                                                                           "is_feed_empty": true])
                    }
                    self.feedState = FeedStateManager().initFeedState(queryResult: nil)
                    self.loadContent(onPage: self.page, total: -1)
                    self.tableView.tableFooterView = nil
                    self.isRequesting = false
                    return
                }
                
                if shouldTrackMoengage {
                    AnalyticsManager.moEngageTrackEvent(withName: "Feed_Screen_Launched", attributes: ["logged_in_status": true,
                                                                                                       "is_feed_empty": false])
                }
                
                self.feedState = FeedStateManager().initFeedState(queryResult: (result?.data)!)
                
                self.loadContent(onPage: self.page, total: self.feedState.totalData)
            }
        }
    }
    
    private func loadContent(onPage page: Int, total: Int) {
        if self.feedCards.count > 0 {
            if (self.feedCards.last?.isNextPageError)! && self.feedCards.last?.topads?.topAds == nil {
                self.feedCards.removeLast()
            }
        }
        
        if total > 1 {
            self.feedCards += self.feedState.feedCards
            self.feedCardSource.onNext(self.feedCards)
            self.loadTopAdsContent(onPage: page, totalData: total)
            
            if self.feedState.hasNextPage {
                self.page += 1
            }
        } else {
            if page > 1 {
                var tryAgain = FeedCardState()
                tryAgain.isNextPageError = true
                
                self.feedState.hasNextPage = false
                self.feedState.feedCards = [tryAgain]
                
                self.feedCards += self.feedState.feedCards
                self.feedCardSource.onNext(self.feedCards)
            } else {
                var emptyStateCard = FeedCardState()
                emptyStateCard.isEmptyState = true
                emptyStateCard.errorType = (total < 0) ? .serverError : .emptyFeed
                
                self.feedState.feedCards = [emptyStateCard]
                self.feedCards = self.feedState.feedCards
                self.feedCardSource.onNext(self.feedCards)
                self.loadTopAdsContent(onPage: page, totalData: total)
            }
        }
        
        self.refreshControl.endRefreshing()
        self.tableView.tableFooterView = nil
        self.isRequesting = false
    }
    
    private func loadTopAdsContent(onPage page: Int, totalData: Int) {
        let filter = totalData > 1 ? TopAdsFilter(source: .favoriteProduct, ep: .random, numberOfProductItems: 4, numberOfShopItems: 1, page: page, searchKeyword: "", isRecommendationCategory: true) : TopAdsFilter(source: .favoriteProduct, ep: .shop, numberOfProductItems: 0, numberOfShopItems: 3, page: 1, searchKeyword: "", isRecommendationCategory: true)
        
        self.topAdsService.getTopAds(
            topAdsFilter: filter,
            onSuccess: { [weak self] ads in
                guard let `self` = self else { return }
                
                guard ads.count > 0 else { return }
                
                if totalData > 1 {
                    var card = FeedCardState()
                    card.topads = TopAdsFeedPlusState(topAds: ads, isDoneFavoriteShop: false, isLoadingFavoriteShop: false, currentViewController: self)
                    
                    self.feedCards = self.feedCards + [card]
                    self.feedCardSource.onNext(self.feedCards)
                } else {
                    for ad in ads {
                        var topAdsCard = FeedCardState()
                        topAdsCard.topads = TopAdsFeedPlusState(topAds: [ad], isDoneFavoriteShop: false, isLoadingFavoriteShop: false, currentViewController: self)
                        self.feedState.feedCards.append(topAdsCard)
                    }
                    
                    self.feedCards = self.feedState.feedCards
                    self.feedCardSource.onNext(self.feedCards)
                }
            },
            onFailure: { _ in
                
            }
        )
    }
    
    private func reinitApolloClient() -> ApolloClient {
        let configuration = URLSessionConfiguration.default
        let userManager = UserAuthentificationManager()
        
        let appVersion = UIApplication.getAppVersionString()
        
        let headers = ["Tkpd-UserId": userManager.getUserId(),
                       "Tkpd-SessionId": userManager.getMyDeviceToken(),
                       "X-Device": "ios-\(appVersion)",
                       "Device-Type": ((UI_USER_INTERFACE_IDIOM() == .phone) ? "iphone" : "ipad")]
        
        configuration.httpAdditionalHeaders = headers
        
        let url = URL(string: NSString.feedsMobileSiteUrl() + "/graphql")!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }
    
    @objc private func userDidLogin() {
        self.shouldRefreshData = true
        self.feedCards = []
        self.feedCardSource.onNext(self.feedCards)
    }
    
    @objc private func didSwipeHomeTab(_ notification: NSNotification) {
        let userInfo = notification.userInfo
        let tag = userInfo?["tag"] as? NSInteger
        
        if tag == 1 {
            NotificationCenter.default.addObserver(self, selector: #selector(self.userDidTappedTabBar), name: NSNotification.Name(rawValue: "TKPDUserDidTappedTapBar"), object: nil)
        } else {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "TKPDUserDidTappedTapBar"), object: nil)
        }
    }
    
    @objc private func userDidTappedTabBar() {
        self.tableView.scrollToTop()
    }
    
    @objc private func scrollToTop() {
        if self.feedCards.count > 0 {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
}
