//
//  ConfirmAlertViewController.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 12/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class ConfirmAlertViewController: UIViewController {
    @IBOutlet private weak var problemLabel: UILabel!
    @IBOutlet private weak var solutionLabel: UILabel!
    @IBOutlet private weak var popView: UIView!
    var complainButtonHandler: (()->Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.animatePopView()
    }
    private func setupUI() {
        guard let data = RCManager.shared.rcCreateStep1Data else {return}
        self.problemLabel.text = data.titleForItemsAdded
        self.solutionLabel.text = data.titleForSolution
    }
    @IBAction private func cancelTapped(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction private func complainTapped(sender: UIButton) {
        self.complainButtonHandler?()
        self.dismiss(animated: true, completion: nil)
    }
    private func animatePopView() {
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
