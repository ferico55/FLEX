//
//  NotificationTableViewController.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/14/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import NativeNavigation

@objc protocol NotificationTableViewControllerDelegate {
    @objc optional func pushViewController(viewController: UIViewController)
    @objc optional func navigateUsingTPRoutes(urlString: String)
}

class NotificationTableViewController: UITableViewController, NewOrderDelegate, ShipmentConfirmationDelegate {
    
    private let cellTitles1 = ["Chat", "Diskusi", "Ulasan", "Layanan Pengguna", "Pusat Resolusi"]
    private let cellTitles2 = ["Order Baru", "Konfirmasi Pengiriman", "Status Pengiriman", "Daftar Transaksi"]
    private let cellTitles3 = ["Pesanan dibatalkan", "Status Pembayaran", "Status Pemesanan", "Konfirmasi Penerimaan", "Daftar Transaksi"]
    private let headerTitles = ["Kotak Masuk", "Penjualan", "Pembelian"]
    private var userHasShop : Bool = false
    
    private var notification : NotificationData? = nil
    var delegate : NotificationTableViewControllerDelegate? = nil
    
    private var _splitViewController: UISplitViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "NotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "notificationTableViewCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // UA
        AnalyticsManager.trackScreenName("Top Notification Center")
    }
    
    func setNotification(notification: NotificationData) {
        self.notification = notification
        self.userHasShop = UserAuthentificationManager().userHasShop()
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        
        switch section {
        case 0:
            numberOfRows = 5
            break
        case 1:
            numberOfRows = 4
            break
        case 2:
            numberOfRows = 5
            break
        default:
            break
        }
        
        return numberOfRows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationTableViewCell", for: indexPath) as! NotificationTableViewCell
        
        cell.isHidden = false
        
        let section = indexPath.section
        let row = indexPath.row
        
        var count = 0
        var indicatorAllowed = true
        
        if (section == 0) {
            cell.lblTitle.text = cellTitles1[row]
            
            if (row == 0) {
                count = notification?.inbox?.message ?? 0
            }
            else if (row == 1) {
                count = notification?.inbox?.talk ?? 0
            }
            else if (row == 2) {
                count = notification?.inbox?.review ?? 0
            }
            else if (row == 3) {
                count = notification?.inbox?.ticket ?? 0
            }
            else if (row == 4) {
                count = notification?.resolution ?? 0
            }
        }
        else if (section == 1) {
            cell.lblTitle.text = cellTitles2[row]
            indicatorAllowed = false
            
            if (row == 0) {
                count = notification?.sales?.newOrder ?? 0
                if (count == 0) {
                    cell.isHidden = true
                }
            }
            else if (row == 1) {
                count = notification?.sales?.shippingConfirm ?? 0
                if (count == 0) {
                    cell.isHidden = true
                }
            }
            else if (row == 2) {
                count = notification?.sales?.shippingStatus ?? 0
                if (count == 0) {
                    cell.isHidden = true
                }
            }
            
            if (!userHasShop) {
                cell.isHidden = true
            }
        }
        else {
            cell.lblTitle.text = cellTitles3[row]
            indicatorAllowed = false
            
            if (row == 0) {
                count = notification?.purchase?.reorder ?? 0
                if (count == 0) {
                    cell.isHidden = true
                }
            }
            else if (row == 1) {
                count = notification?.purchase?.paymentConfirm ?? 0
                if (count == 0) {
                    cell.isHidden = true
                }
            }
            else if (row == 2) {
                count = notification?.purchase?.orderStatus ?? 0
                if (count == 0) {
                    cell.isHidden = true
                }
            }
            else if (row == 3) {
                count = notification?.purchase?.deliveryConfirm ?? 0
                if (count == 0) {
                    cell.isHidden = true
                }
            }
        }
        
        cell.lblCount.text = "\(count)"
        if (count == 0) {
            cell.lblCount.isHidden = true
            cell.unreadIndicator.isHidden = true
        }
        else {
            cell.lblCount.isHidden = false
            if (indicatorAllowed) {
                cell.unreadIndicator.isHidden = false
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        
        header?.textLabel?.font = UIFont.title2ThemeMedium()
        header?.textLabel?.textColor = UIColor(red: 77.0/255.0, green: 77.0/255.0, blue: 77.0/255.0, alpha: 1)
        header?.backgroundView?.alpha = 0.7
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        let row = indexPath.row
        
        var count = 1
        
        if (section == 1) {
            if (!userHasShop) {
                count = 0
            }
            else if (row == 0) {
                count = notification?.sales?.newOrder ?? 0
            }
            else if (row == 1) {
                count = notification?.sales?.shippingConfirm ?? 0
            }
            else if (row == 2) {
                count = notification?.sales?.shippingStatus ?? 0
            }
            
            if (count == 0) {
                return 0
            }
        }
        else if (section == 2) {
            if (row == 0) {
                count = notification?.purchase?.reorder ?? 0
            }
            else if (row == 1) {
                count = notification?.purchase?.paymentConfirm ?? 0
            }
            else if (row == 2) {
                count = notification?.purchase?.orderStatus ?? 0
            }
            else if (row == 3) {
                count = notification?.purchase?.deliveryConfirm ?? 0
            }
            
            if (count == 0) {
                return 0
            }
        }
        
        return 44
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 1 && !userHasShop) {
            return 0
        }
        
        return 34
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = indexPath.section
        let row = indexPath.row
        
        if (section == 0) {
            switch row {
            case 0:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "Message")
                
                self.delegate?.navigateUsingTPRoutes?(urlString: "tokopedia://topchat")
                
                break
                
            case 1:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "Product Discussion")
                
                if (UIDevice.current.userInterfaceIdiom == .pad) {
                    let controller = InboxTalkSplitViewController()
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
                
                break
                
            case 2:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "Review")
                
                let userManager = UserAuthentificationManager()
                let auth = userManager.getUserLoginData() as AnyObject
                
                var reviewReactViewController = UIViewController()
                if (UIDevice.current.userInterfaceIdiom == .pad) {
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
                
                break
                
            case 3:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "Layanan Pengguna")
                
                let userManager = UserAuthentificationManager()
                let webViewController = WKWebViewController(urlString: userManager.webViewUrl(fromUrl: "https://m.tokopedia.com/help/ticket-list/mobile"), title: "Help")
                
                self.delegate?.pushViewController?(viewController: webViewController)
                
                break
                
            case 4:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "Resolution Center")
                
                if (UIDevice.current.userInterfaceIdiom == .pad) {
                    let controller = InboxResolSplitViewController()
                    controller.hidesBottomBarWhenPushed = true
                    
                    self.delegate?.pushViewController?(viewController: controller)
                }
                else {
                    let controller = InboxResolutionCenterTabViewController()
                    controller.hidesBottomBarWhenPushed = true
                    
                    self.delegate?.pushViewController?(viewController: controller)
                }
                
                break
            default:
                break
            }
        }
        else if (section == 1) {
            switch row {
            case 0:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "New Order")
                
                let controller = SalesNewOrderViewController()
                controller.delegate = self
                controller.hidesBottomBarWhenPushed = true
                
                self.delegate?.pushViewController?(viewController: controller)
                
                break
                
            case 1:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "Delivery Confirmation")
                
                let controller = ShipmentConfirmationViewController()
                controller.delegate = self
                controller.hidesBottomBarWhenPushed = true
                
                self.delegate?.pushViewController?(viewController: controller)
                
                break
                
            case 2:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "Delivery Status")
                
                let controller = ShipmentStatusViewController()
                controller.hidesBottomBarWhenPushed = true
                
                self.delegate?.pushViewController?(viewController: controller)
                
                break
                
            case 3:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "Sales Transaction List")
                
                let controller = SalesTransactionListViewController()
                controller.hidesBottomBarWhenPushed = true
                
                self.delegate?.pushViewController?(viewController: controller)
                
                break
            default:
                break
            }
        }
        else if (section == 2) {
            switch row {
            case 0:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "Canceled Order")
                
                let vc = TxOrderStatusViewController()
                vc.action = "get_tx_order_list"
                vc.isCanceledPayment = true
                vc.viewControllerTitle = "Pesanan Dibatalkan"
                vc.hidesBottomBarWhenPushed = true
                
                self.delegate?.pushViewController?(viewController: vc)
                
                break
                
            case 1:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "Order Status")
                
                let vc = TxOrderConfirmedViewController()
                vc.hidesBottomBarWhenPushed = true
                
                self.delegate?.pushViewController?(viewController: vc)
                
                break
                
            case 2:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "Order Status")
                
                let vc = TxOrderStatusViewController()
                vc.action = "get_tx_order_status"
                vc.viewControllerTitle = "Status Pemesanan"
                vc.hidesBottomBarWhenPushed = true
                
                self.delegate?.pushViewController?(viewController: vc)
                
                break
                
            case 3:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "Receive Confirmation")
                
                let vc = TxOrderStatusViewController()
                vc.action = "get_tx_order_deliver"
                vc.viewControllerTitle = "Konfirmasi Penerimaan"
                vc.hidesBottomBarWhenPushed = true
                
                self.delegate?.pushViewController?(viewController: vc)
                
                break
                
            case 4:
                AnalyticsManager.trackEventName(GA_EVENT_NAME_EVENT_TOP_NAV, category: GA_EVENT_CATEGORY_TOP_NAV, action: GA_EVENT_ACTION_CLICK_NOTIFICATION_ICON, label: "Order Transaction List")
                
                let vc = TxOrderStatusViewController()
                vc.action = "get_tx_order_list"
                vc.viewControllerTitle = "Daftar Transaksi"
                vc.hidesBottomBarWhenPushed = true
                
                self.delegate?.pushViewController?(viewController: vc)
                
                break
            default:
                break
            }
        }
        
    }
    
    // ShipmentConfirmationDelegate
    func viewController(_ viewController: UIViewController!, numberOfProcessedOrder totalOrder: Int) {
        // do nothing
    }
}
