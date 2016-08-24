//
//  OpenShopSuccessViewController.swift
//  Tokopedia
//
//  Created by Tokopedia on 6/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc(OpenShopSuccessViewController) public class OpenShopSuccessViewController: UITableViewController {

    public var shopDomain: NSString!
    public var shopName: NSString!
    public var shopUrl: NSString!
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet var headerView: UIView!
    @IBOutlet var footerView: UIView!
    @IBOutlet weak var addProductButton: UIButton!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        let nib = nibNameOrNil ?? "OpenShopSuccessViewController"
        super.init(nibName: nib, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Buka Toko"
        
        let emptyLeftButton = UIBarButtonItem(
            title: "",
            style: .Plain,
            target: self,
            action: nil
        )
        
        navigationItem.leftBarButtonItem = emptyLeftButton
        
        let doneButton = UIBarButtonItem(
            title: "Selesai",
            style: .Plain,
            target: self,
            action: #selector(OpenShopSuccessViewController.didTapDoneButton(_:))
        )
        
        navigationItem.rightBarButtonItem = doneButton
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center
        paragraphStyle.lineSpacing = 5
        let firstSentence = "Selamat!\nAnda telah berhasil membuka toko\n\(shopName)\n"
        let secondSentence = "Sekarang Anda sudah siap untuk mulai\nberjualan di Tokopedia"
        let attributedString = NSMutableAttributedString.init(string: firstSentence + secondSentence)
        attributedString.addAttributes([NSFontAttributeName: UIFont.title1ThemeMedium()!], range: NSMakeRange(0, firstSentence.characters.count))
        attributedString.addAttributes([NSParagraphStyleAttributeName: paragraphStyle], range: NSMakeRange(0, firstSentence.characters.count + secondSentence.characters.count))
        attributedString.addAttributes([NSFontAttributeName: UIFont.largeTheme()!], range: NSMakeRange(firstSentence.characters.count, secondSentence.characters.count))
        headerLabel.attributedText = attributedString
        headerLabel.numberOfLines = 7
        
        addProductButton.layer.cornerRadius = 5
        
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = footerView
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        if (cell == nil) {
            cell = UITableViewCell(style:.Default, reuseIdentifier: "cell")
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.textLabel?.numberOfLines = 0
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        let attributes = [NSFontAttributeName: UIFont.largeTheme()!, NSParagraphStyleAttributeName: paragraphStyle]
        
        if (indexPath.section == 0) {
            let text = shopUrl as String
            cell.textLabel?.attributedText = NSAttributedString.init(string: text, attributes: attributes)
            cell.textLabel?.textColor = UIColor.init(red: 0.0, green: 122.0/255.0, blue: 1, alpha: 1)
        } else if (indexPath.section == 1) {
            let text = "Secara otomatis toko Anda saat ini sudah dapat diakses oleh pengunjung Tokopedia.\n\nUntuk pengaturan, gunakan halaman pengaturan toko, dan jangan lewatkan kesempatan untuk melakukan transaksi pertama Anda."
            cell.textLabel?.attributedText = NSAttributedString.init(string: text, attributes: attributes)
        }

        return cell
    }
    
    override public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            return 44
        } else {
            return 172
        }
    }
    
    override public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "URL Toko"
        } else {
            return "Tambahkan Produk"
        }
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 0) {
            let container = ShopContainerViewController()
            container.data = ["shop_domain": shopDomain]
            navigationController?.pushViewController(container, animated: true)
        }
    }

    @IBAction func didTapAddProductButton(sender: UIButton) {
        let controller = ProductAddEditViewController()
        controller.type = 1
        let navigation = UINavigationController.init(rootViewController: controller)
        navigation.navigationBar.translucent = false
        navigationController?.presentViewController(navigation, animated: true, completion:nil)
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func didTapDoneButton(button: UIBarButtonItem) -> Void {
        navigationController!.popToRootViewControllerAnimated(true)
    }
    
}
