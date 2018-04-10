//
//  FeedViewController.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 4/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Apollo
import Render
import ReSwift
import RxCocoa
import RxSwift
import SnapKit
import UIKit

internal class FeedViewController: UIViewController, UITableViewDelegate {
    
    private let refreshControl = UIRefreshControl()
    private var feedState = FeedState()
    private var feedWatcher: GraphQLQueryWatcher<FeedsQuery>?
    private var feedCards: [FeedCardState] = []
    private let footerView = UIView(frame: CGRect.zero)
    private var page = 1
    private var isRequesting = false
    private var shouldRefreshData = false
    private var currentCursor = ""
    private var emptyStateButtonTapped = false
    private var isRefreshing = false
    private var row = 0

    private let feedCardSource = PublishSubject<[FeedCardState]>()
    
    private var feedClient: ApolloClient = {
        guard let url = URL(string: NSString.graphQLURL()) else {
            fatalError("GraphQL URL is not valid")
        }
        
        let configuration = URLSessionConfiguration.default
        let userManager = UserAuthentificationManager()
        
        let appVersion = UIApplication.getAppVersionString()
        
        let loginData = userManager.getUserLoginData()
        let tokenType = loginData?["oAuthToken.tokenType"] as? String ?? ""
        let accessToken = loginData?["oAuthToken.accessToken"] as? String ?? ""
        let accountsAuth = "\(tokenType) \(accessToken)" as String
        
        let headers: [AnyHashable: Any] = ["Tkpd-UserId": userManager.getUserId(),
                                           "Tkpd-SessionId": userManager.getMyDeviceToken(),
                                           "X-Device": "ios-\(appVersion)",
                                           "Device-Type": ((UI_USER_INTERFACE_IDIOM() == .phone) ? "iphone" : "ipad"),
                                           "Accounts-Authorization": accountsAuth]
        
        configuration.httpAdditionalHeaders = headers
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    
    private let tableView = UITableView()
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.userDidLogin), name: NSNotification.Name(rawValue: TKPDUserDidLoginNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didSwipeHomeTab), name: NSNotification.Name(rawValue: "didSwipeHomeTab"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onDeleteComment(notification:)), name: NSNotification.Name(rawValue: "OnDeleteComment"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onCreateComment(notification:)), name: NSNotification.Name(rawValue: "OnCreateComment"), object: nil)
        
        self.view.backgroundColor = .tpBackground()
        self.setupView()
    }
    
    override internal func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        AnalyticsManager.trackScreenName("Feed Page")
        if self.shouldRefreshData {
            self.shouldRefreshData = false
            self.refreshFeed()
        }
    }
    
    private func setupView() {
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 1000
        self.tableView.backgroundColor = .tpBackground()
        self.tableView.separatorStyle = .none
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.accessibilityLabel = "feedView"
        self.tableView.delegate = self
        self.refreshControl.addTarget(self, action: #selector(self.refreshFeed), for: .valueChanged)
        
        self.footerView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 40)
        self.footerView.backgroundColor = .clear
        self.tableView.rx.didScroll.buffer(timeSpan: 0.2, count: 10000, scheduler: MainScheduler.instance)
            .filter { !$0.isEmpty }.subscribe(
                onNext: { [weak self] _ in
                    guard let `self` = self else { return }
                    guard let count = self.tableView.indexPathsForVisibleRows?.count, count > 0, let row = self.tableView.indexPathsForVisibleRows?[0].row, row < self.feedCards.count else { return }
                    if self.feedCards[row].page > 0 && self.feedCards[row].row > 0 && !self.feedCards[row].isImpression {
                        AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_IMPRESSION, label: "\(self.feedCards[row].page).\(self.feedCards[row].row) - Product Feed")
                        AnalyticsManager.trackFeedImpression(card: self.feedCards[row])
                        self.feedCards[row].isImpression = true
                        
                        if self.feedCards[row].content.isKOLContent {
                            AnalyticsManager.trackKOLImpression(cardContent: self.feedCards[row].content)
                        }
                        
                        if self.feedCards[row].content.isTopAds {
                            AnalyticsManager.trackTopAdsImpression(content: self.feedCards[row].content)
                        }
                    }
                }
            ).disposed(by: rx_disposeBag)
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.footerView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        activityIndicator.snp.makeConstraints { make in
            make.centerX.equalTo(self.footerView)
            make.centerY.equalTo(self.footerView)
        }
        
        self.tableView.addSubview(self.refreshControl)
        
        feedCardSource.asObservable()
            .bindTo(self.tableView.rx.items) { _, index, item in
                let cell = ComponentTableViewCell<FeedComponentView>()
                cell.backgroundColor = .clear
                cell.mountComponentIfNecessary(
                    FeedComponentView(
                        viewController: self,
                        onEmptyStateButtonPressed: { [weak self] errorType in
                            guard let `self` = self else {
                                return
                            }
                            
                            self.onEmptyStateButtonPressed(errorType: errorType)
                        },
                        onReloadNextPagePressed: { [weak self] in
                            guard let `self` = self else {
                                return
                            }
                            
                            self.onReloadNextPageButtonPressed()
                        },
                        onTapKOLLongDescription: { [weak self] state in
                            guard let `self` = self else {
                                return
                            }
                            
                            self.onTapExpandKOLActivityDescription(state: state, row: index)
                        },
                        onTapKOLLike: { [weak self] state in
                            guard let `self` = self else {
                                return
                            }
                            
                            self.onTapLikeButton(state: state, row: index)
                        },
                        onTapFollowKOLPost: { [weak self] state in
                            guard let `self` = self else {
                                return
                            }
                            
                            self.onTapFollowKOLPost(state: state, row: index)
                        },
                        onTapFollowKOLRecommendation: { [weak self] state in
                            guard let `self` = self else {
                                return
                            }
                            
                            self.onTapFollowKOLRecommendation(state: state, row: index)
                        },
                        onTapFavoriteTopAdsShop: { [weak self] state in
                            guard let `self` = self else {
                                return
                            }
                            
                            self.onTapFavoriteTopAdsShop(state: state, row: index)
                        }
                    )
                )
                cell.state = item
                cell.isUserInteractionEnabled = true
                return cell
            }
            .disposed(by: self.rx_disposeBag)
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            if self.feedState.oniPad {
                make.left.equalTo(self.view.snp.left).offset(104)
                make.right.equalTo(self.view.snp.right).offset(-104)
                make.top.equalTo(self.view).offset(16)
                make.bottom.equalTo(self.view.snp.bottom)
            } else {
                make.edges.equalTo(self.view)
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
    
    override internal func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override internal func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @objc private func refreshFeed() {
        self.page = 1
        self.row = 0
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
            
            guard let userID = userID, let intUserID = Int(userID) else {
                return
            }
            
            self.feedWatcher = self.feedClient.watch(query: FeedsQuery(userID: intUserID, limit: 3, cursor: cursor, source: "feeds")) { result, error in
                if let error = error {
                    if shouldTrackMoengage {
                        AnalyticsManager.moEngageTrackEvent(withName: "Feed_Screen_Launched", attributes: ["logged_in_status": true,
                                                                                                           "is_feed_empty": true])
                    }
                    NSLog("Error while fetching query: \(error.localizedDescription)")
                    self.feedState = FeedStateManager().initFeedState(queryResult: nil, page: self.page, row: &self.row)
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
                    self.feedState = FeedStateManager().initFeedState(queryResult: nil, page: self.page, row: &self.row)
                    self.loadContent(onPage: self.page, total: -1)
                    self.tableView.tableFooterView = nil
                    self.isRequesting = false
                    return
                }
                
                if shouldTrackMoengage {
                    AnalyticsManager.moEngageTrackEvent(withName: "Feed_Screen_Launched", attributes: ["logged_in_status": true,
                                                                                                       "is_feed_empty": false])
                }
                
                guard let data = result?.data else {
                    return
                }
                
                self.feedState = FeedStateManager().initFeedState(queryResult: data, page: self.page, row: &self.row)
                
                self.loadContent(onPage: self.page, total: self.feedState.totalData)
            }
        }
    }
    
    private func loadContent(onPage page: Int, total: Int) {
        if self.feedCards.count > 0, let isNextPageError = self.feedCards.last?.isNextPageError {
            if isNextPageError {
                self.feedCards.removeLast()
            }
        }
        
        if total > 2 {
            self.feedCards.append(contentsOf: self.feedState.feedCards)
            self.feedCardSource.onNext(self.feedCards)
            self.isRequesting = false
            
            if self.feedState.hasNextPage {
                self.page += 1
            }
        } else {
            if page > 1 {
                var tryAgain = FeedCardState()
                tryAgain.isNextPageError = true
                tryAgain.content.type = .nextPageError
                
                self.feedState.hasNextPage = false
                self.feedState.feedCards = [tryAgain]
                
                self.feedCards.append(contentsOf: self.feedState.feedCards)
                self.feedCardSource.onNext(self.feedCards)
            } else {
                var emptyStateCard = FeedCardState()
                emptyStateCard.isEmptyState = true
                emptyStateCard.content.type = .emptyState
                emptyStateCard.errorType = (total < 0) ? .serverError : .emptyFeed
                
                self.feedState.feedCards = [emptyStateCard]
                self.feedCards.append(contentsOf: self.feedState.feedCards)
                self.feedCardSource.onNext(self.feedCards)
                self.isRequesting = false
            }
        }
        
        self.refreshControl.endRefreshing()
        self.tableView.tableFooterView = nil
    }
    
    private func reinitApolloClient() -> ApolloClient {
        guard let url = URL(string: NSString.graphQLURL()) else {
            fatalError("GraphQL URL is not valid")
        }
        
        let configuration = URLSessionConfiguration.default
        let userManager = UserAuthentificationManager()
        
        let appVersion = UIApplication.getAppVersionString()
        
        let loginData = userManager.getUserLoginData()
        let tokenType = loginData?["oAuthToken.tokenType"] as? String ?? ""
        let accessToken = loginData?["oAuthToken.accessToken"] as? String ?? ""
        let accountsAuth = "\(tokenType) \(accessToken)" as String
        
        let headers: [AnyHashable: Any] = ["Tkpd-UserId": userManager.getUserId(),
                                           "Tkpd-SessionId": userManager.getMyDeviceToken(),
                                           "X-Device": "ios-\(appVersion)",
                                           "Device-Type": ((UI_USER_INTERFACE_IDIOM() == .phone) ? "iphone" : "ipad"),
                                           "Accounts-Authorization": accountsAuth]
        
        configuration.httpAdditionalHeaders = headers
        
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
    
    private func onEmptyStateButtonPressed(errorType: FeedErrorType) {
        self.emptyStateButtonTapped = true
        
        if errorType == .emptyFeed {
            NotificationCenter.default.post(name: Notification.Name("didSwipeHomePage"), object: self, userInfo: ["page": 5])
        } else {
            var newCard = FeedCardState()
            newCard.content.type = .emptyState
            newCard.isEmptyState = true
            newCard.errorType = errorType
            newCard.refreshButtonIsLoading = true
            
            self.feedCards.removeFirst()
            self.feedCards = [newCard] + self.feedCards
            self.feedCardSource.onNext(self.feedCards)
            
            self.refreshFeed()
        }
    }
    
    private func onReloadNextPageButtonPressed() {
        var newCard = FeedCardState()
        newCard.content.type = .nextPageError
        newCard.isNextPageError = true
        newCard.nextPageReloadIsLoading = true
        
        if self.feedCards.count > 0 {
            self.feedCards.removeLast()
            self.feedCards.append(newCard)
        }
        
        self.feedCardSource.onNext(self.feedCards)
        
        self.loadFeed(cursor: self.currentCursor, shouldTrackMoengage: false)
    }
    
    private func onTapLikeButton(state: FeedCardKOLPostState, row: Int) {
        self.feedClient.perform(mutation: DoLikeKolPostMutation(idPost: state.cardID, action: state.isLiked ? 0 : 1)) { result, _ in
            if result?.data?.doLikeKolPost?.data?.success == 1 {
                var newCard = FeedCardState()
                newCard.content.kolPost = state
                newCard.content.kolPost?.isLiked = !state.isLiked
                newCard.content.type = .KOLPost
                
                self.feedCards[row] = newCard
                
                self.feedCardSource.onNext(self.feedCards)
            }
        }
    }
    
    private func onTapExpandKOLActivityDescription(state: FeedCardKOLPostState, row: Int) {
        var newCard = FeedCardState()
        newCard.content.kolPost = state
        newCard.content.type = .KOLPost
        
        self.feedCards[row] = newCard
        
        self.feedCardSource.onNext(self.feedCards)
    }
    
    private func onTapFollowKOLRecommendation(state: FeedCardKOLRecommendationState, row: Int) {
        if state.users.count > 0 && state.justFollowedUserIndex >= 0 {
            self.feedClient.perform(mutation: DoFollowKolMutation(userID: state.justFollowedUserID, action: state.users[state.justFollowedUserIndex].isFollowed ? 0 : 1)) { result, _ in
                if result?.data?.doFollowKol?.data?.status == 1 {
                    var newCard = FeedCardState()
                    newCard.content.type = .KOLRecommendation
                    newCard.content.kolRecommendation = state
                    newCard.content.kolRecommendation?.users[state.justFollowedUserIndex].isFollowed = !(state.users[state.justFollowedUserIndex].isFollowed)
                    
                    self.feedCards[row] = newCard
                    
                    self.feedCardSource.onNext(self.feedCards)
                }
            }
        }
        
    }
    
    private func onTapFollowKOLPost(state: FeedCardKOLPostState, row: Int) {
        self.feedClient.perform(mutation: DoFollowKolMutation(userID: state.userID, action: state.isFollowed ? 0 : 1)) { result, _ in
            if result?.data?.doFollowKol?.data?.status == 1 {
                var newCard = FeedCardState()
                newCard.content.kolPost = state
                newCard.content.kolPost?.isFollowed = !(state.isFollowed)
                newCard.content.type = .KOLPost
                
                self.feedCards[row] = newCard
                
                self.feedCardSource.onNext(self.feedCards)
            }
        }
    }
    
    @objc private func onDeleteComment(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let state = userInfo["state"] as? [String: Any] {
            var newState = FeedCardKOLPostState(stateDict: state)
            newState.commentCount = newState.commentCount - 1
            
            var newCard = FeedCardState()
            newCard.content.kolPost = newState
            newCard.content.type = .KOLPost
            
            for (index, element) in self.feedCards.enumerated() where element.content.kolPost?.cardID == newState.cardID {
                self.feedCards[index] = newCard
            }
            
            self.feedCardSource.onNext(self.feedCards)
        }
    }
    
    @objc private func onCreateComment(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let state = userInfo["state"] as? [String: Any] {
            var newState = FeedCardKOLPostState(stateDict: state)
            newState.commentCount = newState.commentCount + 1
            
            var newCard = FeedCardState()
            newCard.content.kolPost = newState
            newCard.content.type = .KOLPost
            
            for (index, element) in self.feedCards.enumerated() where element.content.kolPost?.cardID == newState.cardID {
                 self.feedCards[index] = newCard
            }
            
            self.feedCardSource.onNext(self.feedCards)
        }
    }
    
    private func onTapFavoriteTopAdsShop(state: FeedTopAdsShopState, row: Int) {
        let loadingState = self.newFeedTopAdsShopState(oldState: state, isLoading: true)
        self.feedCards[row] = loadingState
        self.feedCardSource.onNext(feedCards)
        
        FavoriteShopRequest
            .requestActionButtonFavoriteShop(
                state.shopID,
                withAdKey: "",
                onSuccess: {  _ in
                    var finishedCard = self.newFeedTopAdsShopState(oldState: state, isLoading: false)
                    finishedCard.content.topads?.shop.isFavoritedShop = !(state.isFavoritedShop)
                    
                    self.feedCards[row] = finishedCard
                    self.feedCardSource.onNext(self.feedCards)
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateFavoriteShop"), object: nil)
                },
                onFailure: {
                    var finishedCard = self.newFeedTopAdsShopState(oldState: state, isLoading: false)
                    
                    self.feedCards[row] = finishedCard
                    self.feedCardSource.onNext(self.feedCards)
                }
            )
    }
    
    private func newFeedTopAdsShopState(oldState: FeedTopAdsShopState, isLoading: Bool) -> FeedCardState {
        var newCard = FeedCardState()
        newCard.content.type = .topAdsShop
        newCard.content.topads = FeedCardTopAdsState()
        newCard.content.topads?.shop = oldState
        newCard.content.topads?.shop.buttonIsLoading = isLoading
        
        return newCard
    }
}
