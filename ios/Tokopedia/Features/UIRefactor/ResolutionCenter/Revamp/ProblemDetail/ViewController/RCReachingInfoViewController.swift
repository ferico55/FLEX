//
//  RCReachingInfoViewController.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 23/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class RCReachingInfoViewController: UIViewController {
    @IBOutlet private var infoLabel: UILabel!
    @IBOutlet private var timerView: RCCountdownTimerView!
    @IBOutlet private var popView: UIView!
    var problemItem: RCProblemItem?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.animatePopView()
    }
    func setupUI() {
        guard let problemItem = self.problemItem else { return }
        if let date = problemItem.getStatus(isDelivered: false)?.info?.date {
            self.timerView.deliveryDate = date
        }
        let regFont = UIFont.systemFont(ofSize: 14.0)
        let semiBoldFont = UIFont.semiboldSystemFont(ofSize: 14.0) ?? UIFont.boldSystemFont(ofSize: 14.0)
        let color = UIColor(white: 0.0, alpha: 0.54)
        let part1 = NSAttributedString(string: "Untuk pengiriman menggunakan", attributes: [NSFontAttributeName:regFont, NSForegroundColorAttributeName:color])
        let mutableString = NSMutableAttributedString(attributedString: part1)
        if let shippingName = problemItem.order?.shipping.name, let detailName = problemItem.order?.shipping.detail.name {
            let part2String = String(format: "\n%@ %@\n",shippingName , detailName)
            let part2 = NSAttributedString(string: part2String, attributes: [NSFontAttributeName:semiBoldFont, NSForegroundColorAttributeName:color])
            mutableString.append(part2)
        }
        let part3 = NSAttributedString(string: "komplain “barang belum diterima” dapat dilakukan setelah:", attributes: [NSFontAttributeName:regFont, NSForegroundColorAttributeName:color])
        mutableString.append(part3)
        self.infoLabel.attributedText = mutableString
    }
    @IBAction private func cancelTapped(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction private func closedTapped(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    func animatePopView() {
        let identityAnimation = CGAffineTransform.identity
        let scaleOfIdentity = identityAnimation.scaledBy(x: 0.1, y: 0.1)
        self.popView.transform = scaleOfIdentity
        UIView.animateKeyframes(withDuration: 0.5, delay: 0.0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.2, animations: {
                let scaleOfIdentity = identityAnimation.scaledBy(x: 1, y: 1)
                self.popView.transform = scaleOfIdentity
            })
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.15, animations: {
                let scaleOfIdentity = identityAnimation.scaledBy(x: 0.98, y: 0.98)
                self.popView.transform = scaleOfIdentity
            })
            UIView.addKeyframe(withRelativeStartTime: 0.35, relativeDuration: 0.15, animations: {
                self.popView.transform = identityAnimation
            })
        }, completion: nil)
    }
}
