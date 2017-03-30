//
//  SettingTouchIDViewController.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 2/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import UIAlertController_Blocks
import LocalAuthentication


@objc(SettingTouchIDViewController)
class SettingTouchIDViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    fileprivate var touchIDList = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noResultView: NoResultReusableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Pengaturan Touch ID"
        self.touchIDList = TouchIDHelper.sharedInstance.loadTouchIDAccount()
        self.checkForDataAvailability()
        
        self.tableView.reloadData()
        self.tableView.tableFooterView = UIView()
        
        self.noResultView.generateAllElements("no-result.png",
                                              title: "Tidak ada Touch ID yang terdaftar.",
                                              desc: "Silahkan login ulang untuk menggunakan fitur ini.",
                                              btnTitle: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func removeButtonDidTap(_ index: Int) {
        AnalyticsManager.trackEventName("deleteTouchID", category: "Setting Touch ID", action: GA_EVENT_ACTION_CLICK, label: "Touch ID - Delete Attempt")
        
        UIAlertController.showAlert(in: self,
                                    withTitle: "Touch ID",
                                    message: "Apakah Anda ingin menghapus integrasi dengan akun ini?",
                                    cancelButtonTitle: "Tidak",
                                    destructiveButtonTitle: "Hapus",
                                    otherButtonTitles: nil) { (controller, action, buttonIndex) in
                                        if buttonIndex == controller.destructiveButtonIndex {
                                            let context = LAContext()
                                            context.localizedFallbackTitle = "";
                                            let reason = "Otentikasikan untuk Melanjutkan Proses"
                                            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (success, error) in
                                                if success {
                                                    DispatchQueue.main.async {
                                                        //Authentication was successful
                                                        self.removeTouchID(_: index)
                                                        
                                                        AnalyticsManager.trackEventName("deleteTouchID", category: "Setting Touch ID", action: GA_EVENT_ACTION_CLICK, label: "Touch ID - Delete Success")
                                                    }
                                                } else {
                                                    DispatchQueue.main.async {
                                                        //Authentication failed. Show alert indicating what error occurred
                                                        if let error = error as? LAError ,
                                                            error.code != LAError.userCancel {
                                                            AnalyticsManager.trackEventName("deleteTouchID", category: "Setting Touch ID", action: GA_EVENT_ACTION_CLICK, label: "Touch ID - Delete Cancel")
                                                            
                                                            UIAlertController.showAlert(in: self,
                                                                                        withTitle: "Touch ID",
                                                                                        message: error.localizedDescription,
                                                                                        cancelButtonTitle: "Ok",
                                                                                        destructiveButtonTitle: nil,
                                                                                        otherButtonTitles: nil,
                                                                                        tap: nil)
                                                        }
                                                    }
                                                }
                                            })
                                        } else {
                                            AnalyticsManager.trackEventName("deleteTouchID", category: "Setting Touch ID", action: GA_EVENT_ACTION_CLICK, label: "Touch ID - Delete Cancel")
                                        }
        }
    }

    func removeTouchID(_ index: Int) {
        let email = self.touchIDList[index]
        TouchIDHelper.sharedInstance.remove(forEmail: email)
        
        self.touchIDList.remove(at: index)
        self.tableView.reloadData()
        self.checkForDataAvailability()
    }
    
    func checkForDataAvailability() {
        if self.touchIDList.count > 0 {
            self.noResultView.isHidden = true
        } else {
            self.noResultView.isHidden = false
        }
    }
    
    // MARK: - UITableView Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.touchIDList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell?.textLabel?.font = UIFont.title2Theme()
            cell?.selectionStyle = .none
        }
        
        let removeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        removeButton.backgroundColor = UIColor.clear
        removeButton.setTitleColor(UIColor.red, for: .normal)
        removeButton.setTitle("Hapus", for: .normal)
        removeButton.titleLabel?.font = UIFont.title2Theme()
        removeButton.addTarget(self, action: #selector(removeButtonDidTap(_ :)), for: .touchUpInside)
        removeButton.bk_(whenTapped:{ [unowned self] in
            self.removeButtonDidTap(indexPath.row)
        })
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        view.backgroundColor = UIColor.clear
        view.addSubview(removeButton)
        view.isUserInteractionEnabled = true
        cell?.accessoryView = view
        
        if self.touchIDList.count > 0 {
            let email = self.touchIDList[indexPath.row]
            cell?.textLabel?.text = email
        }
        
        return cell!
    }
}
