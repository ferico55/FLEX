//
//  NotificationBarButton.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/13/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class NotificationBarButton: UIBarButtonItem, NotificationTableViewControllerDelegate, NotificationManagerDelegate {
    
    private let lblCount = UILabel()
    
    private let notificationManager = NotificationManager()
    private let notificationView = NotificationTableViewController()
    private var notificationWindow: UIWindow? = nil
    private var triangleView: UIImageView? = nil
    private var parentViewController: UIViewController? = nil
    
    private var tableViewOriginY: CGFloat = 0.0
    
    private var isOpen = false
    
    required override init() {
        super.init()
    }
    
    init(parentViewController: UIViewController) {
        super.init()
        
        lblCount.frame = CGRect(x: 22, y: 0, width: 17, height: 17)
        lblCount.font = .microTheme()
        lblCount.backgroundColor = .red
        lblCount.textColor = .white
        lblCount.layer.cornerRadius = 10
        lblCount.clipsToBounds = true
        lblCount.tag = 1
        lblCount.isHidden = true
        lblCount.textAlignment = .center
        
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "notifikasi.png"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 25)
        button.addSubview(lblCount)
        
        self.customView = button
        
        // add tap action
        self.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonTapped)))
        
        // set notification manager delegate
        notificationManager.delegate = self
        
        // set notification view delegate
        notificationView.delegate = self
        
        // set parent view controller
        self.parentViewController = parentViewController
        
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let navigationBarHeight = parentViewController.navigationController?.navigationBar.frame.height ?? 0
        tableViewOriginY = statusBarHeight + navigationBarHeight
        
        // set window
        initNotificationWindow()
        
        // add triangle to notification window
        let screenWidth = UIScreen.main.bounds.size.width
        triangleView = UIImageView(image: #imageLiteral(resourceName: "icon_triangle_grey"))
        triangleView?.contentMode = .scaleAspectFill
        triangleView?.clipsToBounds = true
        triangleView?.frame = CGRect(x: screenWidth - 40, y: tableViewOriginY - 5, width: 10, height: 5)
        notificationWindow?.addSubview(triangleView!)
        
        // add observer for status bar frame change
        NotificationCenter.default.addObserver(self, selector: #selector(statusBarDidChangeFrame), name: NSNotification.Name.UIApplicationDidChangeStatusBarFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRead), name: NSNotification.Name(rawValue: "NotificationRead"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUpdate(_:)), name: NSNotification.Name(rawValue: "NotificationUpdate"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadNotifications), name: NSNotification.Name(rawValue: "reloadNotification"), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initNotificationWindow() {
        notificationWindow = UIWindow(frame: UIScreen.main.bounds)
        notificationWindow?.backgroundColor = .clear
        notificationWindow?.clipsToBounds = true
        
        // set tap area to close notification window
        let tapView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: tableViewOriginY))
        tapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideNotificationView(sender:))))
        notificationWindow?.addSubview(tapView)
        
        // set view frame and content inset
        var notificationTableFrame = notificationView.view.frame
        notificationTableFrame.origin.y = tableViewOriginY
        notificationTableFrame.size.height = UIScreen.main.bounds.size.height
        notificationTableFrame.size.width = UIScreen.main.bounds.size.width
        
        notificationView.tableView.frame = notificationTableFrame
        notificationView.tableView.tableFooterView = UIView()
        
        notificationView.tableView.contentInset = UIEdgeInsetsMake(0, 0, tableViewOriginY, 0)
        
        notificationView.view.frame = notificationTableFrame
        
        // set blurred transparent background
        let tView = UIVisualEffectView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        tView.effect = UIBlurEffect(style: .light)
        notificationView.tableView.backgroundView = tView
        
        notificationWindow?.addSubview(notificationView.view)
    }
    
    func notificationUpdate(_ notification: Notification) {
        if let count = notification.userInfo?["count"], let totalCount = count as? Int {
            setCount(count: totalCount)
        }
        
        if let read = notification.userInfo?["isRead"], let isRead = read as? Bool {
            setRead(read: isRead)
        }
    }
    
    private func setCount(count: Int) {
        DispatchQueue.main.async {
            self.lblCount.text = count > 99 ? "99+" : String(count)
            if (count > 0) {
                self.lblCount.isHidden = false
                
                self.resizeLabel()
            }
            else {
                self.lblCount.isHidden = true
            }
        }
    }
    
    func notificationRead() {
        setRead(read: true)
    }
    
    private func setRead(read: Bool) {
        DispatchQueue.main.async {
            if (read) {
                self.lblCount.backgroundColor = UIColor(red: 10.0/255.0, green: 126.0/255.0, blue: 7.0/255.0, alpha: 1.0)
                
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
            else if !self.isOpen {
                self.lblCount.backgroundColor = .red
            }
        }
    }
    
    private func resizeLabel() {
        let x = lblCount.frame.origin.x
        let y = lblCount.frame.origin.y
        let height = lblCount.frame.size.height
        
        lblCount.sizeToFit()
        
        let width = lblCount.frame.size.width
        
        // increase width by 10 for padding
        lblCount.frame = CGRect(x: x, y: y, width: width + 10, height: height)
    }
    
    func buttonTapped() {
        // show notification view in window
        
        AnalyticsManager.trackEventName("clickTopedIcon", category: GA_EVENT_CATEGORY_NOTIFICATION, action: GA_EVENT_ACTION_CLICK, label: "Bell Notification")
        
        notificationWindow?.makeKeyAndVisible()
        
        // animate
        notificationWindow?.transform = (notificationWindow?.transform.scaledBy(x: 0.1, y: 0.1))!
        notificationWindow?.isHidden = false
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: UIViewAnimationOptions(rawValue: 0), animations: {
            self.notificationWindow?.transform = .identity
            self.notificationWindow?.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: nil)
        
        let orientation = UIApplication.shared.statusBarOrientation
        self.notificationWindow?.frame = screenBounds()
        notificationWindow?.transform = transformForOrientation(orientation: orientation)
        
        // set read
        setRead(read: true)
        
        isOpen = true
        
        // run in background
        DispatchQueue.global().async {
            // reset notification
            self.notificationManager.resetNotifications()
        }
    }
    
    func hideNotificationView(sender: UITapGestureRecognizer) {
        hideNotificationView(callback: nil)
    }
    
    func hideNotificationView(callback: ((_ isComplete: Bool) -> Void)?) {
        // hide notification window
        UIView.animate(withDuration: 0.2, animations: {
            self.notificationWindow?.transform = (self.notificationWindow?.transform.scaledBy(x: 0.01, y: 0.01))!
        }) { (isComplete) in
            self.notificationWindow?.isHidden = true
            self.isOpen = false
            callback?(isComplete)
        }
    }
    
    @objc func reloadNotifications() {
        notificationManager.loadNotifications()
    }
    
    private func transformForOrientation(orientation: UIInterfaceOrientation) -> CGAffineTransform {
        switch orientation {
        case UIInterfaceOrientation.landscapeLeft:
            return CGAffineTransform(rotationAngle: CGFloat(-90 * Double.pi / 180))
        case UIInterfaceOrientation.landscapeRight:
            return CGAffineTransform(rotationAngle: CGFloat(90 * Double.pi / 180))
        case UIInterfaceOrientation.portraitUpsideDown:
            return CGAffineTransform(rotationAngle: CGFloat(180 * Double.pi / 180))
        default:
            return CGAffineTransform(rotationAngle: 0.0)
        }
    }
    
    // SwiftNotificationTableViewControllerDelegate
    func pushViewController(viewController: UIViewController) {
        self.hideNotificationView { (_) in
            self.parentViewController?.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func navigateUsingTPRoutes(urlString: String) {
        self.hideNotificationView { (_) in
            TPRoutes.routeURL(URL(string: urlString)!)
        }
    }
    
    // NotificationManagerDelegate
    func notificationManager(_ notificationManager: Any, notificationLoaded notification: Any) {
        guard let notificationData: NotificationData = notification as? NotificationData else {
            return
        }
        
        setCount(count: notificationData.totalNotif)
        
        if (notificationData.incrNotif > 0) {
            setRead(read: false)
        }
        else {
            setRead(read: true)
        }
        
        notificationView.setNotification(notification: notificationData)
        
        // set cart count
        if (notificationData.totalCart > 0) {
            parentViewController?.tabBarController?.viewControllers?[3].tabBarItem.badgeValue = String(notificationData.totalCart)
        }
        else {
            parentViewController?.tabBarController?.viewControllers?[3].tabBarItem.badgeValue = nil
        }
        
        let prefs = UserDefaults.standard
        prefs.set(String(notificationData.totalCart), forKey: "total_cart")
        prefs.synchronize()
    }
    
    // notification observer action
    func statusBarDidChangeFrame(notification: NSNotification) {
        let orientation = UIApplication.shared.statusBarOrientation
        notificationWindow?.frame = screenBounds()
        
        notificationWindow?.transform = transformForOrientation(orientation: orientation)
        
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        triangleView?.frame = CGRect(x: screenWidth-40, y: tableViewOriginY - 5, width: 10, height: 5)
    }
    
    func screenBounds() -> CGRect {
        var bounds = UIScreen.main.bounds
        if (UIScreen.main.responds(to: #selector(getter: UIScreen.fixedCoordinateSpace))) {
            let currentCoordSpace = UIScreen.main.coordinateSpace
            let portraitCoordSpace = UIScreen.main.fixedCoordinateSpace
            bounds = portraitCoordSpace.convert(bounds, from: currentCoordSpace)
        }
        
        return bounds
    }
}
