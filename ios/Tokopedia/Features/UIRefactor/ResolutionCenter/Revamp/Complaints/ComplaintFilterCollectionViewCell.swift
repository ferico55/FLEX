//
//  ComplaintFilterCollectionViewswift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 30/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

internal class ComplaintFilterCollectionViewCell: UICollectionViewCell {
    @IBOutlet internal weak var lblStatus: UILabel!
    
    internal override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.shadowColor = UIColor.tpLine().cgColor
                layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
                layer.shadowRadius = 2.0
                layer.shadowOpacity = 1.0
                layer.masksToBounds = false
                
                layer.borderColor = UIColor.tpGreen().cgColor
                layer.borderWidth = 1
                
                backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.9960784314, blue: 0.9529411765, alpha: 1)
                lblStatus.textColor = .tpGreen()
                lblStatus.font = UIFont.mediumSystemFont(ofSize: 11)
            }
            else {
                layer.shadowColor = UIColor.clear.cgColor
                
                layer.borderColor = UIColor.tpBorder().cgColor
                layer.borderWidth = 1
                
                backgroundColor = .white
                lblStatus.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.7)
                lblStatus.font = UIFont.systemFont(ofSize: 11)
            }
        }
    }
    
    internal override func awakeFromNib() {
        super.awakeFromNib()
    }
}
