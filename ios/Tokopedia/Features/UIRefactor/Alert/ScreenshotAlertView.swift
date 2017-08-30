//
//  ScreenshotAlertView.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/22/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class ScreenshotAlertView: TKPDAlertView {

    @IBOutlet private var screenshotImage: UIImageView!
    
    @IBOutlet private var shareButton: UIButton!
    
    @IBOutlet private var closeButton: UIButton!
    
    var onTapShare: ((Any) -> Void)? = nil
    var onTapReport: (() -> Void)? = nil
    var onTapClose: (() -> Void)? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.frame.size.width = 300
    }
    
    func setImage(_ image: UIImage) {
        self.screenshotImage.image = image
    }

    
    @IBAction func didTapShareButton(_ sender: Any) {
        self.dismiss()
        self.onTapShare?(sender)
    }
    
    @IBAction func didTapCloseButton(_ sender: Any) {
        self.dismiss()
        self.onTapClose?()
    }
    
    private func dismiss() {
        self.dismiss(withClickedButtonIndex: 0, animated: true)
    }
    

}
