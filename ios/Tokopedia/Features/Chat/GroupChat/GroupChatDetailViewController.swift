//
//  GroupChatDetailViewController.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 15/02/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import NativeNavigation
import RxSwift
import UIKit

internal class GroupChatDetailViewController: UIViewController {
    
    internal let props: [String: AnyObject]
    private var titleBarText: String?
    private var navbarImage: UIImage?
    private var totalParticipant: String?
    private let titleView: UILabel = UILabel()
    private let subtitleView: UILabel = UILabel()
    private var isNavbarTranslucent = false
    
    internal convenience init() {
        let userManager = UserAuthentificationManager()
        let auth = userManager.getUserLoginData()
        let defaultProps = ["authInfo": auth as AnyObject]
        self.init(initialProps: defaultProps)
    }
    
    internal init(initialProps: [String: AnyObject]) {
        self.props = initialProps
        super.init(nibName: nil, bundle: nil)
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initNavbarView()
        
        NotificationCenter.default.rx.notification(Notification.Name("SET_GROUPCHAT_NAVBAR"))
            .asDriverOnErrorJustComplete()
            .drive(onNext: { [weak self] notification in
                guard let `self` = self, let userInfo = notification.userInfo else {
                    return
                }
                
                if let titleBar = userInfo["titleBar"] as? String {
                    self.titleBarText = titleBar
                }
                
                if let hideNavbar = userInfo["setNavbarTranslucent"] as? Bool {
                    if hideNavbar {
                        self.initNavbarView()
                    } else {
                        self.showNavbarItem()
                    }
                }
                
                if let totalParticipant = userInfo["totalParticipant"] as? String {
                    self.setTitle(title: self.titleBarText, subtitle: totalParticipant)
                }
            })
            .disposed(by: self.rx_disposeBag)
        
        NotificationCenter.default.rx.notification(Notification.Name(GroupChatNotification))
            .asDriverOnErrorJustComplete()
            .drive(onNext: { notification in
                guard let userInfo = notification.userInfo , let reactManager = UIApplication.shared.reactBridge.module(for: ReactEventManager.self) as? ReactEventManager else {
                    return
                }
                
                if let applinks = userInfo["applinks"] as? String, let desc = userInfo["desc"] as? String, let tkpCode = userInfo["tkp_code"] as? Int {
                    let data = ["desc": desc, "tkpCode":tkpCode, "applinks": applinks] as [String: Any]
                    reactManager.sendNotification(toGroupChat: data)
                }
            })
            .disposed(by: self.rx_disposeBag)
        
        // Set bar button item
        let shareButton = UIBarButtonItem(image: #imageLiteral(resourceName: "share_ios"), style: .plain, target: self, action: #selector(self.tapShareButton(sender:)))
        shareButton.tag = 2308 // For React Tag Purposes
        self.navigationItem.rightBarButtonItem = shareButton
        
        // Do any additional setup after loading the view.
        let reactVC = ReactViewController(moduleName: "GroupChatDetail", props: self.props)
        self.addChildViewController(reactVC)
        self.view.addSubview(reactVC.view)
        reactVC.didMove(toParentViewController: self)
        reactVC.view.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
    }
    
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isNavbarTranslucent {
            self.initNavbarView()
        } else if !isNavbarTranslucent {
            self.showNavbarItem()
        }
    }
    
    internal override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        AnalyticsManager.trackEventName("clickBack", category: "groupchat room", action: "leave room", label: "")
    }
    
    @objc private func tapDismiss() {
        self.dismiss(animated: true)
    }
    
    internal override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Set Navbar
    private func initNavbarView() {
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        navigationBar?.isTranslucent = true
        navigationBar?.setBackgroundImage(UIImage(), for: .default)
        navigationBar?.backgroundColor = .clear
        navigationBar?.shadowImage = UIImage()
        if !self.isNavbarTranslucent {
            self.isNavbarTranslucent = true
        }
    }
    
    private func showNavbarItem() {
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        navigationBar?.isTranslucent = false
        navigationBar?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        if self.isNavbarTranslucent {
            self.isNavbarTranslucent = false
        }
    }
    
    // MARK: Set TitleBar
    private func setTitle(title: String?, subtitle: String?) {
        if let title = title, let subtitle = subtitle {
            self.titleView.text = title
            self.titleView.font = .boldSystemFont(ofSize: 16)
            self.titleView.textColor = .white
            self.titleView.textAlignment = .center
            self.titleView.sizeToFit()
            
            self.subtitleView.text = subtitle
            self.subtitleView.font = .systemFont(ofSize: 11)
            self.subtitleView.textColor = .white
            self.subtitleView.textAlignment = .center
            self.subtitleView.sizeToFit()
            
            let stackView = UIStackView(arrangedSubviews: [titleView, subtitleView])
            stackView.distribution = .equalCentering
            stackView.axis = .vertical
            
            let width = max(titleView.frame.size.width, subtitleView.frame.size.width)
            stackView.frame = CGRect(x: 0, y: 0, width: width, height: 35)
            
            titleView.sizeToFit()
            subtitleView.sizeToFit()
            
            self.navigationItem.titleView = stackView
        }
    }
    
    // MARK: UIBarButtonItem
    @objc private func tapShareButton(sender: UIBarButtonItem) {
        guard let reactManager = UIApplication.shared.reactBridge.module(for: ReactEventManager.self) as? ReactEventManager else {
            return
        }
        
        reactManager.didTapShare(onGroupChat: sender.tag)
    }
}
