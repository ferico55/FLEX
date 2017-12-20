//
//  TokopointsSectionViewController.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 12/4/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

enum TokopointsSectionViewType {
    case compact
    case normal
}

class TokopointsSectionViewController: UIViewController {

    @IBOutlet weak var lblPoints: UILabel!
    @IBOutlet weak var lblTier: UILabel!
    
    var drawerData: DrawerData
    
    init(drawerData: DrawerData, viewType: TokopointsSectionViewType = .normal) {
        self.drawerData = drawerData
        
        switch viewType {
        case .normal:
            super.init(nibName: "TokopointsSectionViewController", bundle: nil)
            break
        case .compact:
            super.init(nibName: "TokopointsSmallSectionViewController", bundle: nil)
            break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapResponse))
        gestureRecognizer.numberOfTapsRequired = 1
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(gestureRecognizer)
        
        arrangeDisplay()
    }
    
    func setDrawerData(drawerData: DrawerData) {
        self.drawerData = drawerData
        
        arrangeDisplay()
    }
    
    func arrangeDisplay() {
        // set values
        lblPoints.text = drawerData.userTier.rewardPointsString
        lblTier.text = drawerData.userTier.tierNameDescription
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tapResponse(_ sender: UITapGestureRecognizer) {
        AnalyticsManager.trackEventName(GA_EVENT_NAME_CLICK_TOKOPOINTS_HOMEPAGE, category: "homepage-tokopoints", action: "click point & tier status", label: "tokopoints")
        
        // redirect ke mainpage tokopoints
        let wv = WKWebViewController(urlString: drawerData.mainpageUrl)
        wv.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(wv, animated: true)
        wv.hidesBottomBarWhenPushed = false
    }

}
