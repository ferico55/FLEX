//
//  CCReaderViewController.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 7/5/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc protocol CCReaderDelegate {
    func didScanCard(cardInfo: CardIOCreditCardInfo)
}

class CCReaderViewController: UIViewController, CardIOViewDelegate{

    @IBOutlet var cardIOView: CardIOView!
    var delegate: CCReaderDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (!CardIOUtilities.canReadCardWithCamera()) {
            // Hide your "Scan Card" button, remove the CardIOView from your view, and/or take other appropriate action...
        } else {
            self.cardIOView.delegate = self;
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        CardIOUtilities.preload()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didSelectCancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: CardIO Delegate
    
    func cardIOView(cardIOView: CardIOView!, didScanCard cardInfo: CardIOCreditCardInfo!) {
        if ((cardInfo) != nil) {
            if let delegate = delegate {
                delegate.didScanCard(cardInfo)
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            NSLog("User canceled payment info");
        }
    }

}
