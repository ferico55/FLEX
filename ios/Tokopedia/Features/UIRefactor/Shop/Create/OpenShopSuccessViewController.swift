//
//  OpenShopSuccessViewController.swift
//  Tokopedia
//
//  Created by Tokopedia on 6/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import NativeNavigation
import UIKit

@objc(OpenShopSuccessViewController) open class OpenShopSuccessViewController: UITableViewController {

    open var shopDomain: NSString!
    open var shopName: NSString!
    open var shopUrl: NSString!
    
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private var headerView: UIView!
    @IBOutlet private var footerView: UIView!
    @IBOutlet private weak var addProductButton: UIButton!
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let nib = nibNameOrNil ?? "OpenShopSuccessViewController"
        super.init(nibName: nib, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Buka Toko"
        
        let emptyLeftButton = UIBarButtonItem(
            title: "",
            style: .plain,
            target: self,
            action: nil
        )
        
        navigationItem.leftBarButtonItem = emptyLeftButton
        
        let doneButton = UIBarButtonItem(
            title: "Selesai",
            style: .plain,
            target: self,
            action: #selector(OpenShopSuccessViewController.didTapDoneButton(_:))
        )
        
        navigationItem.rightBarButtonItem = doneButton
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 5
        let firstSentence = "Selamat!\nAnda telah berhasil membuka toko\n\(shopName)\n"
        let secondSentence = "Sekarang Anda sudah siap untuk mulai\nberjualan di Tokopedia"
        let attributedString = NSMutableAttributedString(string: firstSentence + secondSentence)
        attributedString.addAttributes([NSFontAttributeName: UIFont.title1ThemeMedium()!], range: NSMakeRange(0, firstSentence.characters.count))
        attributedString.addAttributes([NSParagraphStyleAttributeName: paragraphStyle], range: NSMakeRange(0, firstSentence.characters.count + secondSentence.characters.count))
        attributedString.addAttributes([NSFontAttributeName: UIFont.largeTheme()!], range: NSMakeRange(firstSentence.characters.count, secondSentence.characters.count))
        headerLabel.attributedText = attributedString
        headerLabel.numberOfLines = 7
        
        addProductButton.layer.cornerRadius = 5
        
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = footerView
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override open func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell!
        if cell == nil {
            cell = UITableViewCell(style:.default, reuseIdentifier: "cell")
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
            cell?.textLabel?.numberOfLines = 0
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        let attributes = [NSFontAttributeName: UIFont.largeTheme()!, NSParagraphStyleAttributeName: paragraphStyle]
        
        if indexPath.section == 0 {
            let text = shopUrl as String
            cell?.textLabel?.attributedText = NSAttributedString(string: text, attributes: attributes)
            cell?.textLabel?.textColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        } else if indexPath.section == 1 {
            let text = "Secara otomatis toko Anda saat ini sudah dapat diakses oleh pengunjung Tokopedia.\n\nUntuk pengaturan, gunakan halaman pengaturan toko, dan jangan lewatkan kesempatan untuk melakukan transaksi pertama Anda."
            cell?.textLabel?.attributedText = NSAttributedString(string: text, attributes: attributes)
        }

        return cell!
    }
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 44
        } else {
            return 172
        }
    }
    
    override open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "URL Toko"
        } else {
            return "Tambahkan Produk"
        }
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let container = ShopViewController()
            container.data = ["shop_domain": shopDomain]
            navigationController?.pushViewController(container, animated: true)
        }
    }

    @IBAction private func didTapAddProductButton(_ sender: UIButton) {
        let userAuthManager = UserAuthentificationManager()
        let vc = ReactViewController(moduleName: "AddProductScreen", props: [
            "authInfo": userAuthManager.getUserLoginData() as AnyObject
            ])
        let navigation = UINavigationController(rootViewController: vc)
        navigation.navigationBar.isTranslucent = false
        navigationController?.present(navigation, animated: true, completion:nil)
        navigationController?.popToRootViewController(animated: true)
    }
    
    internal func didTapDoneButton(_ button: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }
    
}
