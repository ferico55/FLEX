//
//  FeedDetailViewController.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 4/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render
import RxSwift
import RxCocoa
import Apollo

@objc(FeedDetailViewController)
class FeedDetailViewController: UIViewController {
    
    var feedHeader: FeedDetailHeaderComponentView!
    var feedAction: FeedDetailActionComponentView!
    var feedDetailState = FeedDetailState()
    let feedDetailProductSource = PublishSubject<[FeedDetailProductState]>()
    let feedDetailSource = PublishSubject<FeedDetailState>()
    var feedDetailProducts: [FeedDetailProductState] = []
    var page: Int = 1
    let footerView = UIView(frame: CGRect.zero)
    var isRequesting = false
    let tableView = UITableView()
    
    var feedDetailWatcher: GraphQLQueryWatcher<FeedDetailQuery>?
    fileprivate let activityID: String!
    
    lazy var feedDetailClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        let userManager = UserAuthentificationManager()
        
        let appVersion = UIApplication.getAppVersionString()
        
        let loginData = userManager.getUserLoginData()
        let tokenType = loginData?["oAuthToken.tokenType"] as? String ?? ""
        let accessToken = loginData?["oAuthToken.accessToken"] as? String ?? ""
        let accountsAuth = "\(tokenType) \(accessToken)" as String
        
        let headers = ["Tkpd-UserId": userManager.getUserId(),
                       "Tkpd-SessionId": userManager.getMyDeviceToken(),
                       "X-Device": "ios-\(appVersion)",
                       "Device-Type": ((UI_USER_INTERFACE_IDIOM() == .phone) ? "iphone" : "ipad"),
                       "Accounts-Authorization": accountsAuth]
        
        configuration.httpAdditionalHeaders = headers
        
        let url = URL(string: NSString.graphQLURL())!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    
    init(activityID: String) {
        self.activityID = activityID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Detail Feed"
        self.view.backgroundColor = .tpBackground()
        
        self.footerView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 40)
        self.footerView.backgroundColor = .clear
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.footerView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        activityIndicator.snp.makeConstraints { make in
            make.centerX.equalTo(self.footerView)
            make.centerY.equalTo(self.footerView)
        }
        
        self.loadFeedDetail(withPage: self.page)
        
        feedHeader = FeedDetailHeaderComponentView()
        
        self.view.addSubview(feedHeader)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.backgroundColor = .tpBackground()
        tableView.separatorStyle = .none
        
        feedAction = FeedDetailActionComponentView()
        
        feedDetailProductSource
            .asObservable()
            .bindTo(tableView.rx.items) { tableView, _, item in
                let cell = ComponentTableViewCell<FeedDetailProductCellComponentView>()
                cell.mountComponentIfNecessary(FeedDetailProductCellComponentView())
                cell.state = item
                cell.isUserInteractionEnabled = true
                cell.render(in: tableView.frame.size)
                return cell
            }
            .disposed(by: rx_disposeBag)
        
        self.view.addSubview(tableView)
        
        if UI_USER_INTERFACE_IDIOM() == .phone {
            self.view.addSubview(self.feedAction)
            
            self.tableView.mas_makeConstraints { make in
                _ = make?.top.mas_equalTo()(self.feedHeader.mas_bottom)
                _ = make?.left.mas_equalTo()(self.view)
                _ = make?.right.mas_equalTo()(self.view)
                _ = make?.bottom.mas_equalTo()(self.view)?.offset()(-51)
            }
        } else {
            self.tableView.mas_makeConstraints { make in
                _ = make?.top.mas_equalTo()(self.feedHeader.mas_bottom)
                _ = make?.left.mas_equalTo()(self.view)?.offset()(104)
                _ = make?.right.mas_equalTo()(self.view)?.offset()(-104)
                _ = make?.bottom.mas_equalTo()(self.view)
            }
        }
        
        self.tableView.rx_reachedBottom
            .subscribe(onNext: { [weak self] _ in
                if (self?.feedDetailState.hasNextPage)! && !(self?.isRequesting)! {
                    self?.loadFeedDetail(withPage: (self?.page)!)
                }
            })
            .disposed(by: rx_disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        AnalyticsManager.trackScreenName("Feed Detail Page")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func loadFeedDetail(withPage page: Int) {
        self.isRequesting = true
        
        if self.isRequesting {
            self.tableView.tableFooterView = self.footerView
            
            self.feedDetailWatcher = self.feedDetailClient.watch(query: FeedDetailQuery(detailID: self.activityID, pageDetail: page, limitDetail: 30)) { result, error in
                if let error = error {
                    StickyAlertView.showErrorMessage([error.localizedDescription])
                    self.navigationController?.popViewController(animated: true)
                    
                    self.tableView.tableFooterView = nil
                    self.isRequesting = false
                    return
                }
                
                if result?.errors != nil {
                    self.tableView.tableFooterView = nil
                    self.isRequesting = false
                    return
                }
                
                self.feedDetailState = FeedDetailStateManager.initFeedDetailState(with: (result?.data)!)
                
                if self.feedDetailState.isEmpty {
                    self.navigationController?.popViewController(animated: true)
                    StickyAlertView.showErrorMessage(["Feed ini telah dihapus"])
                    
                    return
                }
                
                self.feedDetailProducts += self.feedDetailState.content.product
                self.page = self.page + 1
                self.feedHeader.state = self.feedDetailState
                self.feedAction.state = self.feedDetailState
                self.feedDetailSource.onNext(self.feedDetailState)
                self.feedDetailProductSource.onNext(self.feedDetailProducts)
                
                self.tableView.tableFooterView = nil
                self.isRequesting = false
                
                self.feedHeader.render(in: self.view.frame.size)
                if UI_USER_INTERFACE_IDIOM() == .phone {
                    self.feedAction.render(in: self.view.frame.size)
                    self.feedAction.frame.origin.y = self.view.frame.size.height - 51
                    
                    self.feedHeader.frame.origin.x = 0
                    self.feedHeader.frame.origin.y = 0
                } else {
                    self.feedHeader.frame.origin.y = 20
                    self.feedHeader.frame.origin.x = (UIScreen.main.bounds.size.width - 560) / 2
                }
            }
        }
        
    }
}
