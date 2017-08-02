//
//  PromoViewController.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 12/9/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class PromoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        AnalyticsManager.trackScreenName("Promo Page")
        let promoView = PromoView()
        self.view.addSubview(promoView)
        promoView.mas_makeConstraints { (make) in
            make?.edges.mas_equalTo()(self.view)
        }
        promoView.didTapPromoDetail = { webViewController in
            webViewController.strTitle = "Promo"
            self.navigationController?.pushViewController(webViewController, animated: true)
        }
        promoView.onTapLinkWithUrl = { url in
            if url.absoluteString == "https://www.tokopedia.com/" {
                self.navigationController?.popViewController(animated: true)
            }
        }
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
