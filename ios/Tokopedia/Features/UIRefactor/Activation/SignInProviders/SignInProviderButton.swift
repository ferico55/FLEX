//
//  SignInProviderButton.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 28/03/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

public class SignInProviderButton: UIView {
    
    @IBOutlet weak var providerButton: UIButton!
    @IBOutlet weak var providerImageView: UIImageView!
    
    public class func instanceFromNib() -> SignInProviderButton {
        let view = UINib(nibName: "SignInProviderButton", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SignInProviderButton
        return view
    }

}

