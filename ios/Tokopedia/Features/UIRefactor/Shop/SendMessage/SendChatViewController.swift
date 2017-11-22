//
//  SendChatViewController.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 10/19/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import NativeNavigation

class SendChatViewController: UIViewController {
    private var data: [String: String] = [:]
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(userID: String? = "",
                     shopID: String? = "",
                     name: String,
                     imageURL: String,
                     invoiceURL: String? = "",
                     productURL: String? = "",
                     source: String) {
        self.init()
        self.data = [
            "userID": userID ?? "",
            "shopID": shopID ?? "",
            "name": name,
            "imageURL": imageURL,
            "invoiceURL": invoiceURL ?? "",
            "productURL": productURL ?? "",
            "source": source,
        ]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let reactVC = ReactViewController(moduleName: "SendChat", props: ["data": self.data as AnyObject])
        
        self.addChildViewController(reactVC)
        self.view.addSubview(reactVC.view)
        reactVC.didMove(toParentViewController: self)
        
        reactVC.view.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        
        self.initTitleView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func initTitleView() {
        if let name = self.data["name"] {
            self.navigationItem.title = NSString.convertHTML(name)
        }
    }
}
