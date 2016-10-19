//
//  FreeReturnsConfirmationAlertView.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 9/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class FreeReturnsConfirmationAlertView: TKPDAlertView {
    
    var didComplain: () -> Void = {() in }
    
    var didOK: () -> Void = {() in}
    
    var didCancel: () -> Void = {() in}
    
    @IBOutlet var alertDescription: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.frame.size.width = 300
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @IBAction func didTapOKButton(sender: UIButton) {
        self.didOK()
    }
    
    @IBAction func didTapComplainButton(sender: UIButton) {
        self.didComplain()
    }
    
    @IBAction func didCancel(sender: UIButton) {
        self.didCancel()
    }
    
    func dismiss() {
        self.dismissWithClickedButtonIndex(0, animated: true)
    }
}
