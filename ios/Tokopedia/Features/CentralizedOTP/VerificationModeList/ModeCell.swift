//
//  ModeCell.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 29/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

public struct ModeCellData {
    public let imageUrl: URL?
    public let text: String

    public init(imageUrl: URL?, text: String) {
        self.imageUrl = imageUrl
        self.text = text
    }
}

public class ModeCell: UIView {

    @IBOutlet private var contentView: UIView!
    @IBOutlet weak private var otpModeImage: UIImageView!
    @IBOutlet weak private var otpModeLabel: UILabel!
    public var modeCellData: ModeCellData!

    override public init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }

    private func xibSetup() {
        Bundle.main.loadNibNamed("ModeCell", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    public func setupView() {
        let attributedString = NSAttributedString(fromHTML: modeCellData.text, normalFont: UIFont.largeTheme(), boldFont: UIFont.largeThemeSemibold(), italicFont: UIFont.largeTheme())
        if let imageUrl = modeCellData.imageUrl {
            otpModeImage.setImageWith(imageUrl)
        }
        otpModeLabel.attributedText = attributedString
    }

}
