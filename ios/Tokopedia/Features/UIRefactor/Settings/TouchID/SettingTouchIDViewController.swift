//
//  SettingTouchIDViewController.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 2/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import LocalAuthentication

@objc(SettingTouchIDViewController)
class SettingTouchIDViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    fileprivate var touchIDList = [String]()
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var noResultView: NoResultReusableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Pengaturan \(NSString.authenticationType())"
        self.touchIDList = TouchIDHelper.sharedInstance.loadTouchIDAccount()
        self.checkForDataAvailability()
        
        self.tableView.reloadData()
        self.tableView.tableFooterView = UIView()
        
        self.noResultView.generateAllElements("no-result.png",
                                              title: "Tidak ada \(NSString.authenticationType()) yang terdaftar.",
                                              desc: "Silakan login ulang untuk menggunakan fitur ini.",
                                              btnTitle: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func removeButtonDidTap(_ index: Int) {
        AnalyticsManager.trackEventName("deleteTouchID", category: "Setting \(NSString.authenticationType())", action: GA_EVENT_ACTION_CLICK, label: "\(NSString.authenticationType()) - Delete Attempt")
        
        let alertController = UIAlertController(title: "\(NSString.authenticationType())", message: "Apakah Anda ingin menghapus integrasi dengan akun ini?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Tidak", style: .default) { _ in
            AnalyticsManager.trackEventName("deleteTouchID", category: "Setting \(NSString.authenticationType())", action: GA_EVENT_ACTION_CLICK, label: "\(NSString.authenticationType()) - Delete Cancel")
        })
        
        alertController.addAction(UIAlertAction(title: "Hapus", style: .destructive) { _ in
            let context = LAContext()
            context.localizedFallbackTitle = "";
            let reason = "Otentikasikan untuk Melanjutkan Proses"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (success, error) in
                if success {
                    DispatchQueue.main.async {
                        //Authentication was successful
                        self.removeTouchID(_: index)
                        
                        AnalyticsManager.trackEventName("deleteTouchID", category: "Setting \(NSString.authenticationType())", action: GA_EVENT_ACTION_CLICK, label: "\(NSString.authenticationType()) - Delete Success")
                    }
                } else {
                    DispatchQueue.main.async {
                        //Authentication failed. Show alert indicating what error occurred
                        if let error = error as? LAError ,
                            error.code != LAError.userCancel {
                            AnalyticsManager.trackEventName("deleteTouchID", category: "Setting \(NSString.authenticationType())", action: GA_EVENT_ACTION_CLICK, label: "\(NSString.authenticationType()) - Delete Cancel")
                            
                            let alertController = UIAlertController(title: "\(NSString.authenticationType())", message: error.localizedDescription, preferredStyle: .alert)
                            
                            alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            })
        })
        self.present(alertController, animated: true, completion: nil)
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
        let removeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        removeButton.backgroundColor = .clear
        removeButton.setTitleColor(.red, for: .normal)
        removeButton.setTitle("Hapus", for: .normal)
        removeButton.titleLabel?.font = .title2Theme()
        removeButton.addTarget(self, action: #selector(removeButtonDidTap(_ :)), for: .touchUpInside)
        removeButton.bk_(whenTapped:{ [unowned self] in
            self.removeButtonDidTap(indexPath.row)
        })
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        view.backgroundColor = UIColor.clear
        view.addSubview(removeButton)
        view.isUserInteractionEnabled = true
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        cell.textLabel?.font = .title2Theme()
        cell.selectionStyle = .none
        cell.accessoryView = view
        
        if self.touchIDList.count > 0 {
            let email = self.touchIDList[indexPath.row]
            cell.textLabel?.text = email
        }
        
        return cell
    }
}
