//
//  NotificationTableViewController.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/14/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import NativeNavigation
import UIKit

@objc internal protocol NotificationTableViewControllerDelegate {
    @objc optional func pushViewController(viewController: UIViewController)
    @objc optional func navigateUsingTPRoutes(urlString: String)
}

internal class NotificationTableViewController: UITableViewController, NewOrderDelegate, ShipmentConfirmationDelegate {
    
    private let cellTitles: [[String]] = [
        ["Chat", "Diskusi", "Ulasan", "Layanan Pengguna", "Info Penjual"],
        ["Order Baru", "Konfirmasi Pengiriman", "Status Pengiriman", "Daftar Transaksi"],
        ["Pesanan dibatalkan", "Status Pembayaran", "Status Pemesanan", "Konfirmasi Penerimaan", "Daftar Transaksi"],
        ["Sebagai Pembeli", "Sebagai Penjual"]
    ]
    private let headerTitles = ["Kotak Masuk", "Penjualan", "Pembelian", "Komplain Saya"]
    private var userHasShop : Bool = false
    
    private var notification : NotificationData?
    internal weak var delegate : NotificationTableViewControllerDelegate?
    
    private var _splitViewController: UISplitViewController?
    
    internal override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "NotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "notificationTableViewCell")
        tableView.sectionFooterHeight = 0
    }

    internal override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // UA
        AnalyticsManager.trackScreenName("Top Notification Center")
    }
    
    internal func setNotification(notification: NotificationData) {
        self.notification = notification
        self.userHasShop = UserAuthentificationManager().userHasShop()
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    internal override func numberOfSections(in tableView: UITableView) -> Int {
        return headerTitles.count
    }

    internal override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        
        switch section {
        case 0:
            numberOfRows = UserAuthentificationManager().userHasShop() ? 5 : 4
        case 3:
            numberOfRows = UserAuthentificationManager().userHasShop() ? 2 : 1
        default:
            numberOfRows = cellTitles[section].count
        }
        
        return numberOfRows
    }

    internal override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationTableViewCell", for: indexPath) as! NotificationTableViewCell
        
        cell.isHidden = false
        
        let section = indexPath.section
        let row = indexPath.row
        
        var count = 0
        var indicatorAllowed = true
        
        cell.lblTitle.text = cellTitles[section][row]
        
        if section == 0 {
            if row == 0 {
                count = notification?.inbox?.message ?? 0
            }
            else if row == 1 {
                count = notification?.inbox?.talk ?? 0
            }
            else if row == 2 {
                count = notification?.inbox?.review ?? 0
            }
            else if row == 3 {
                count = notification?.inbox?.ticket ?? 0
            }
            else if row == 4 {
                count = notification?.sellerInfoNotif ?? 0
            }
        }
        else if section == 1 {
            indicatorAllowed = false
            
            if row == 0 {
                count = notification?.sales?.newOrder ?? 0
                if count == 0 {
                    cell.isHidden = true
                }
            }
            else if row == 1 {
                count = notification?.sales?.shippingConfirm ?? 0
                if count == 0 {
                    cell.isHidden = true
                }
            }
            else if row == 2 {
                count = notification?.sales?.shippingStatus ?? 0
                if count == 0 {
                    cell.isHidden = true
                }
            }
            
            if !userHasShop {
                cell.isHidden = true
            }
        }
        else if section == 2 {
            indicatorAllowed = false
            
            if row == 0 {
                count = notification?.purchase?.reorder ?? 0
                if count == 0 {
                    cell.isHidden = true
                }
            }
            else if row == 1 {
                count = notification?.purchase?.paymentConfirm ?? 0
                if count == 0 {
                    cell.isHidden = true
                }
            }
            else if row == 2 {
                count = notification?.purchase?.orderStatus ?? 0
                if count == 0 {
                    cell.isHidden = true
                }
            }
            else if row == 3 {
                count = notification?.purchase?.deliveryConfirm ?? 0
                if count == 0 {
                    cell.isHidden = true
                }
            }
        }
        else if section == 3 {
            if row == 0 {
                count = notification?.resolutionAsBuyer ?? 0
            }
            else if row == 1 {
                count = notification?.resolutionAsSeller ?? 0
            }
        }
        
        cell.lblCount.text = "\(count)"
        if count == 0 {
            cell.lblCount.isHidden = true
            cell.unreadIndicator.isHidden = true
        }
        else {
            cell.lblCount.isHidden = false
            if indicatorAllowed {
                cell.unreadIndicator.isHidden = false
            }
        }

        return cell
    }
    
    internal override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 && !userHasShop {
            return nil
        }
        let header = UITableViewHeaderFooterView(frame: .zero)

        header.textLabel?.text = headerTitles[section]
        let view = UIView(frame: header.bounds)
        view.backgroundColor = UIColor.groupTableViewBackground
        header.backgroundView = view
        header.backgroundView?.alpha = 0.7

        return header
    }
    
    internal override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.font = UIFont.title2ThemeMedium()
        header?.textLabel?.textColor = UIColor.tpPrimaryBlackText()
    }

    internal override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        let row = indexPath.row
        
        var count = 1
        
        if section == 1 {
            if !userHasShop {
                count = 0
            }
            else if row == 0 {
                count = notification?.sales?.newOrder ?? 0
            }
            else if row == 1 {
                count = notification?.sales?.shippingConfirm ?? 0
            }
            else if row == 2 {
                count = notification?.sales?.shippingStatus ?? 0
            }
            
            if count == 0 {
                return 0
            }
        }
        else if section == 2 {
            if row == 0 {
                count = notification?.purchase?.reorder ?? 0
            }
            else if row == 1 {
                count = notification?.purchase?.paymentConfirm ?? 0
            }
            else if row == 2 {
                count = notification?.purchase?.orderStatus ?? 0
            }
            else if row == 3 {
                count = notification?.purchase?.deliveryConfirm ?? 0
            }
            
            if count == 0 {
                return 0
            }
        }
        
        return 44
    }
    
    internal override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 && !userHasShop {
            return 0.1
        }
        
        return 34
    }
    
    internal override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0 {
            switch row {
            case 0:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "Message")
                
                self.delegate?.navigateUsingTPRoutes?(urlString: "tokopedia://topchat")
            case 1:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "Product Discussion")
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    let controller = InboxTalkSplitViewController()
                    controller.hidesBottomBarWhenPushed = true
                    self.delegate?.pushViewController?(viewController: controller)
                }
                else {
                    let controller = TKPDTabViewController()
                    controller.hidesBottomBarWhenPushed = true
                    controller.inboxType = InboxType.talk
                    
                    let allTalk = InboxTalkViewController()
                    allTalk.inboxTalkType = InboxTalkType.all
                    allTalk.delegate = controller
                    
                    let myProductTalk = InboxTalkViewController()
                    myProductTalk.inboxTalkType = InboxTalkType.myProduct
                    myProductTalk.delegate = controller
                    
                    let followingTalk = InboxTalkViewController()
                    followingTalk.inboxTalkType = InboxTalkType.following
                    followingTalk.delegate = controller
                    
                    controller.viewControllers = [allTalk, myProductTalk, followingTalk]
                    controller.tabTitles = ["Semua", "Produk Saya", "Ikuti"]
                    controller.menuTitles = ["Semua Diskusi", "Belum Dibaca"]
                    
                    self.delegate?.pushViewController?(viewController: controller)
                }
            case 2:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "Review")
                
                let userManager = UserAuthentificationManager()
                let auth = userManager.getUserLoginData() as AnyObject
                
                var reviewReactViewController = UIViewController()
                if UIDevice.current.userInterfaceIdiom == .pad {
                    let props: [String: AnyObject] = ["authInfo": auth]
                    let masterModule = ReactModule(name: "InboxReview", props: props)
                    let detailModule = ReactModule(name: "InvoiceDetailScreen", props: props)
                    reviewReactViewController = ReactSplitViewController(masterModule: masterModule, detailModule: detailModule)
                }
                else {
                    let props: [String: AnyObject] = ["authInfo": auth]
                    reviewReactViewController = ReactViewController(moduleName: "InboxReview", props:props)
                    
                }
                
                reviewReactViewController.hidesBottomBarWhenPushed = true
                    
                self.delegate?.pushViewController?(viewController: reviewReactViewController)
            case 3:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "Layanan Pengguna")
                
                let userManager = UserAuthentificationManager()
                let webViewController = WKWebViewController(urlString: userManager.webViewUrl(fromUrl: "https://m.tokopedia.com/help/ticket-list/mobile"), title: "Help")
                
                self.delegate?.pushViewController?(viewController: webViewController)
            case 4:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "Seller Info")
                
                let controller = SellerInfoInboxViewController()
                controller.hidesBottomBarWhenPushed = true
                self.delegate?.pushViewController?(viewController: controller)
            default:
                break
            }
        }
        else if section == 1 {
            switch row {
            case 0:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "New Order")
                
                let controller = SalesNewOrderViewController()
                controller.delegate = self
                controller.hidesBottomBarWhenPushed = true
                
                self.delegate?.pushViewController?(viewController: controller)
            case 1:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "Delivery Confirmation")
                
                let controller = ShipmentConfirmationViewController()
                controller.delegate = self
                controller.hidesBottomBarWhenPushed = true
                
                self.delegate?.pushViewController?(viewController: controller)
            case 2:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "Delivery Status")
                
                let controller = ShipmentStatusViewController()
                controller.hidesBottomBarWhenPushed = true
                
                self.delegate?.pushViewController?(viewController: controller)
            case 3:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "Sales Transaction List")
                
                let controller = SalesTransactionListViewController()
                controller.hidesBottomBarWhenPushed = true
                
                self.delegate?.pushViewController?(viewController: controller)
            default:
                break
            }
        }
        else if section == 2 {
            switch row {
            case 0:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "Canceled Order")
                
                let vc = TxOrderStatusViewController()
                vc.action = "get_tx_order_list"
                vc.isCanceledPayment = true
                vc.viewControllerTitle = "Pesanan Dibatalkan"
                vc.hidesBottomBarWhenPushed = true
                
                self.delegate?.pushViewController?(viewController: vc)
            case 1:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "Order Status")
                
                let vc = TxOrderConfirmedViewController()
                vc.hidesBottomBarWhenPushed = true
                
                self.delegate?.pushViewController?(viewController: vc)
            case 2:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "Order Status")
                
                let vc = TxOrderStatusViewController()
                vc.action = "get_tx_order_status"
                vc.viewControllerTitle = "Status Pemesanan"
                vc.hidesBottomBarWhenPushed = true
                
                self.delegate?.pushViewController?(viewController: vc)
            case 3:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "Receive Confirmation")
                
                let vc = TxOrderStatusViewController()
                vc.action = "get_tx_order_deliver"
                vc.viewControllerTitle = "Konfirmasi Penerimaan"
                vc.hidesBottomBarWhenPushed = true
                
                self.delegate?.pushViewController?(viewController: vc)
            case 4:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "Order Transaction List")
                
                let vc = TxOrderStatusViewController()
                vc.action = "get_tx_order_list"
                vc.viewControllerTitle = "Daftar Transaksi"
                vc.hidesBottomBarWhenPushed = true
                
                self.delegate?.pushViewController?(viewController: vc)
            default:
                break
            }
        }
        else if section == 3 {
            var userType = ComplaintUserType.customer
            if row == 1 {
                userType = .seller
            }
            let vc = ComplaintsViewController(userType: userType)
            vc.hidesBottomBarWhenPushed = true
            self.delegate?.pushViewController?(viewController: vc)
        }
    }
    
    // ShipmentConfirmationDelegate
    internal func viewController(_ viewController: UIViewController!, numberOfProcessedOrder totalOrder: Int) {
        // do nothing
    }
}
