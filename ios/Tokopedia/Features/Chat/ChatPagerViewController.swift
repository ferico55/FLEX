//
//  ChatPagerViewController.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 12/02/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import NativeNavigation
import RxSwift
import UIKit

internal enum ChatPagerType: Int {
    case topchat = 0, groupchat
}

internal class ChatPagerViewController: UIViewController {
    @IBOutlet private weak var tabStackView: UIStackView!
    @IBOutlet private weak var pagerWrapper: UIView!
    @IBOutlet private weak var pagerWrapperTop: NSLayoutConstraint!
    
    internal var pageViewController: UIPageViewController
    internal var indexPage = 0
    private var isViewSetup = false
    private var isNavItemTap = false
    private let appLink: String?
    
    fileprivate lazy var tabViews: [TabView] = {
        [
            TabView(image: #imageLiteral(resourceName: "TopChat"), labelText: "Personal"),
            TabView(image: #imageLiteral(resourceName: "GroupChat"), labelText: "Channel")
        ]
    }()
    
    fileprivate lazy var pages: [UIViewController] = {
        [
            self.setupTopChatVC(),
            self.setupGroupChatVC()
        ]
    }()
    
    internal init(initialPage: ChatPagerType, appLink: String? = nil) {
        self.appLink = appLink
        self.indexPage = initialPage.rawValue
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        super.init(nibName: nil, bundle: nil)
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.rx.notification(Notification.Name("SET_CHAT_TAB"))
            .asDriverOnErrorJustComplete()
            .drive(onNext: { [weak self] notification in
                guard let `self` = self, let userInfo = notification.userInfo else {
                    return
                }
                
                // MARK: This should be initial init
                if let hideTabBar = userInfo["hideTabBar"] as? Bool {
                    self.toggleTabBar(toggle: hideTabBar)
                    self.showNavbarItem(show: !hideTabBar)
                }
                
                if let setToAtur = userInfo["setToAtur"] as? Bool {
                    self.navigationItem.rightBarButtonItem?.title = "Atur"
                    self.toggleTabBar(toggle: false)
                    self.isNavItemTap = false
                }
            })
            .disposed(by: self.rx_disposeBag)
        
        // Do any additional setup after loading the view.
        if !GroupChatTweaks.alwaysShowGroupChat() {
            self.pagerWrapperTop.constant = 0
            self.tabStackView.isHidden = true
            self.view.setNeedsLayout()
        }
        self.navigationItem.title = self.indexPage == ChatPagerType.topchat.rawValue ? "Chat" : "Channel"
        self.setupStackView()
    }
    
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.indexPage == ChatPagerType.groupchat.rawValue {
            AnalyticsManager.trackScreenName("/group-chat-list")
        }
    }
    
    internal override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !self.isViewSetup {
            self.setupPageVc()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Selector
    @objc fileprivate func didTapAtur() {
        self.isNavItemTap = !self.isNavItemTap
        self.toggleTabBar(toggle: self.isNavItemTap)
        self.view.setNeedsLayout()
        if self.isNavItemTap {
            self.navigationItem.rightBarButtonItem?.title = "Selesai"
        } else {
            self.navigationItem.rightBarButtonItem?.title = "Atur"
        }
        
        if let reactManager = UIApplication.shared.reactBridge.module(for: ReactEventManager.self) as? ReactEventManager {
            reactManager.didTapAturOnTopChat()
        }
    }
    
    // MARK: Setup Stack View
    private func setupStackView() {
        // Remove placeholder button that used to avoid bad constraint on XIB
        if let placeHolderButton = self.tabStackView.subviews.first {
            self.tabStackView.removeArrangedSubview(placeHolderButton)
            placeHolderButton.removeFromSuperview()
        }
        
        for (index, view) in self.tabViews.enumerated() {
            if index == self.indexPage {
                view.setupActive(isActive: true)
            }
            view.tabIndex = index
            view.delegate = self
            self.tabStackView.addArrangedSubview(view)
        }
    }
    
    // MARK: Setup Pager VC
    private func setupPageVc() {
        self.pageViewController.setViewControllers([pages[self.indexPage]], direction: .forward, animated: true, completion: nil)
        self.addChildViewController(self.pageViewController)
        self.pagerWrapper.addSubview(self.pageViewController.view)
        self.pageViewController.view.snp.makeConstraints { [weak self] make in
            guard let `self` = self else {
                return
            }
            make.edges.equalTo(self.pagerWrapper)
        }
        self.pageViewController.didMove(toParentViewController: self)
        
        if self.indexPage == ChatPagerType.topchat.rawValue {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Atur", style: .plain, target: self, action: #selector(self.didTapAtur))
        } else {
            self.navigationItem.setRightBarButton(nil, animated: false)
        }
        
        self.isViewSetup = true
    }
    
    // MARK: Setup TopChat VC
    private func setupTopChatVC() -> UIViewController {
        let userManager = UserAuthentificationManager()
        let auth = userManager.getUserLoginData()
        var viewController: UIViewController
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            let userID = userManager.getUserId()
            let name = userManager.getUserFullName()
            let shopName = userManager.getShopName()
            let masterModule = ReactModule(name: "TopChatMain", props: [
                "authInfo": auth as AnyObject,
                "fromIpad": true as AnyObject
            ])
            let detailModule = ReactModule(name: "TopChatDetail", props: [
                "fromIpad": true as AnyObject,
                "statusBarHeight": UIApplication.shared.statusBarFrame.height as AnyObject,
                "user_id": userID as AnyObject,
                "full_name": name as AnyObject,
                "shop_name": shopName as AnyObject
            ])
            
            viewController = ReactSplitViewController(masterModule: masterModule, detailModule: detailModule, showNavigationBar: true)
        } else {
            viewController = ReactViewController(moduleName: "TopChatMain", props: ["authInfo": auth as AnyObject, "fromIpad": false as AnyObject])
        }
        
        return viewController
    }
    
    // MARK: Setup GroupChat VC
    private func setupGroupChatVC() -> UIViewController {
        let userManager = UserAuthentificationManager()
        let auth = userManager.getUserLoginData()
        var props = ["authInfo": auth as AnyObject]
        
        if let channel_uuid = self.appLink {
            props["channel_uuid"] = channel_uuid as AnyObject
        }
        
        let viewController = ReactViewController(moduleName: "GroupChatMain", props: props)
        
        return viewController
    }
    
    // MARK: Page Navigator
    fileprivate func gotopage(toIndex: Int) {
        var direction: UIPageViewControllerNavigationDirection
        if self.indexPage <= toIndex {
            direction = .forward
        } else {
            direction = .reverse
        }
        
        if self.indexPage < toIndex {
            for i in 0 ... toIndex {
                self.pageViewController.setViewControllers([pages[i]], direction: direction, animated: true, completion: nil)
            }
        } else {
            for i in stride(from: self.indexPage, through: toIndex, by: -1) {
                self.pageViewController.setViewControllers([pages[i]], direction: direction, animated: i == toIndex, completion: nil)
            }
        }
        
        if toIndex == ChatPagerType.topchat.rawValue {
            self.navigationItem.title = "Chat"
        } else {
            AnalyticsManager.trackScreenName("/group-chat-list")
            self.navigationItem.title = "Channel"
        }
        
        self.indexPage = toIndex
    }
    
    // MARK: Toggling Tab Bar
    private func toggleTabBar(toggle: Bool) {
        if GroupChatTweaks.alwaysShowGroupChat() {
            self.pagerWrapperTop.constant = toggle ? 0 : 104
            self.tabStackView.isHidden = toggle
            self.view.setNeedsLayout()
        }
    }
    
    private func showNavbarItem(show: Bool) {
        if show {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Atur", style: .plain, target: self, action: #selector(self.didTapAtur))
        } else {
            self.navigationItem.setRightBarButton(nil, animated: false)
        }
    }
}

extension ChatPagerViewController: TabViewDelegate {
    public func didPressButton(index: Int) {
        let prevActiveIndex = indexPage
        
        guard index != prevActiveIndex else {
            return
        }
        
        let userManager = UserAuthentificationManager()
        
        if index == ChatPagerType.topchat.rawValue && userManager.isLogin {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Atur", style: .plain, target: self, action: #selector(self.didTapAtur))
        }
        else if index == ChatPagerType.topchat.rawValue {
            AuthenticationService.shared.ensureLoggedInFromViewController(self) {
                TPRoutes.routeURL(URL(string: "tokopedia://topchat")!)
            }
            return
        }
        else {
            AnalyticsManager.trackEventName("clickInboxChat", category: "inbox-chat", action: "click on community tab", label: "")
            self.navigationItem.setRightBarButton(nil, animated: false)
        }
        
        self.tabViews[prevActiveIndex].setupActive(isActive: false)
        self.tabViews[index].setupActive(isActive: true)
        self.gotopage(toIndex: index)
        
    }
}
