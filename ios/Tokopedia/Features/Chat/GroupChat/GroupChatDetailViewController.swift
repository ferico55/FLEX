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
    
    internal let props : [String:AnyObject]
    private var titleBarText: String?
    private var navbarImage: UIImage?
    private var totalParticipant: String?
    private let titleView: UILabel = UILabel()
    private let subtitleView: UILabel = UILabel()
    
    internal convenience init(){
        let userManager = UserAuthentificationManager()
        let auth = userManager.getUserLoginData()
        let defaultProps = ["authInfo": auth as AnyObject]
        self.init(initialProps: defaultProps)
    }
    
    internal init(initialProps: [String:AnyObject]) {
        self.props = initialProps
        super.init(nibName: nil, bundle: nil)
    }
    
    required internal init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.rx.notification(Notification.Name("SET_GROUPCHAT_NAVBAR"))
            .asDriverOnErrorJustComplete()
            .drive(onNext: { [weak self] notification in
                guard let `self` = self, let userInfo = notification.userInfo else {
                    return
                }
                
                if let imageUrl = userInfo["imageUrl"] as? String {
                    self.imageFromServerURL(urlString: imageUrl)
                }
                
                if let titleBar = userInfo["titleBar"] as? String, let totalParticipant = userInfo["totalParticipant"] as? String {
                    self.titleBarText = titleBar
                    self.totalParticipant = totalParticipant
                }
                
                if let totalParticipant = userInfo["totalParticipant"] as? String {
                    self.setTitle(title: self.titleBarText, subtitle: totalParticipant)
                }
            })
            .disposed(by: self.rx_disposeBag)
        
        // Set bar button item
        let shareButton = UIBarButtonItem(image: #imageLiteral(resourceName: "share_ios"), style: .plain, target: self, action: #selector(self.tapShareButton(sender:)))
        shareButton.tag = 2308 // For React Tag Purposes
        let infoButton = UIBarButtonItem(image: #imageLiteral(resourceName: "whiteInfo") , style: .plain, target: self, action: #selector(self.tapInfoButton(sender:)))
        self.navigationItem.rightBarButtonItems = [shareButton,infoButton]
        
        // Do any additional setup after loading the view.
        let reactVC = ReactViewController(moduleName: "GroupChatDetail", props: self.props)
        self.addChildViewController(reactVC)
        self.view.addSubview(reactVC.view)
        reactVC.didMove(toParentViewController: self)
        reactVC.view.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
    }
    
    override internal func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navBar = self.navigationController?.navigationBar ,self.navbarImage != nil {
            UIApplication.shared.statusBarStyle = .lightContent
            navBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Set Navbar
    private func initNavbarView() {
        if let image = self.navbarImage, let navBar = self.navigationController?.navigationBar {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.titleView.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                self.subtitleView.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                UIApplication.shared.statusBarStyle = .lightContent
                navBar.setBackgroundImage(image, for: .default)
                navBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            }
        }
    }
    
    // MARK: Set TitleBar
    private func setTitle(title:String?, subtitle:String?) {
        if let title = title, let subtitle = subtitle {
            titleView.text = title
            titleView.font = .boldSystemFont(ofSize: 16)
            titleView.textAlignment = .center
            titleView.sizeToFit()
            
            subtitleView.text = subtitle
            subtitleView.font = .systemFont(ofSize: 11)
            subtitleView.textAlignment = .center
            subtitleView.sizeToFit()
            
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
    @objc private func tapShareButton(sender: UIBarButtonItem){
        let reactManager = UIApplication.shared.reactBridge.module(for: ReactEventManager.self) as! ReactEventManager
        reactManager.didTapShare(onGroupChat: sender.tag)
    }
    
    @objc private func tapInfoButton(sender: UIBarButtonItem){
        let reactManager = UIApplication.shared.reactBridge.module(for: ReactEventManager.self) as! ReactEventManager
        reactManager.didTapInfoOnGroupChat()
    }
    
    // MARK: Get Image Async
    private func imageFromServerURL(urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        let urlRequest = URLRequest(url: url)
        let imageView = UIImageView()
        imageView.setImageWithUrlRequest(urlRequest, success: { [weak self] (_, _, image, _) in
            guard let `self` = self else {
                return
            }
            self.navbarImage = image
            self.initNavbarView()
        }, failure: nil)
    }
}
