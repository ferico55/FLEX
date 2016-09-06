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
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5
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
    
    func dismiss() {
        self.dismissWithClickedButtonIndex(0, animated: true)
    }
}
