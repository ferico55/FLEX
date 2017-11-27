//
//  OnboardingViewController.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 02/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc public protocol OnboardingViewControllerDelegate: NSObjectProtocol {
    func didTapNextButton()
    func didTapBackButton()
    func didDimissOnboarding()
}

// ini bikin extension aja buat implement delegate nya
class OnboardingViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet private var nextButton: UIButton!
    @IBOutlet private var pageControl: UIPageControl!
    @IBOutlet private var backButton: UIButton!
    
    var titleText: String?
    var messageText: String?
    var currentStep: Int = 1
    var totalStep: Int = 1
    var delegate: OnboardingViewControllerDelegate?
    weak var superViewController: UIViewController?
    var overlayView: UIView? = nil

    init(title: String, message: String, currentStep: Int, totalStep: Int, anchorView: UIView, presentingViewController: UIViewController) {
        titleText = title
        messageText = message
        self.currentStep = currentStep
        self.totalStep = totalStep
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .popover
        self.popoverPresentationController?.delegate = self
        self.popoverPresentationController?.sourceRect = CGRect(x: anchorView.bounds.origin.x - 8, y: anchorView.bounds.origin.y - 8, width: anchorView.bounds.size.width + 16, height: anchorView.bounds.size.height + 16)
        self.popoverPresentationController?.sourceView = anchorView
        self.popoverPresentationController?.backgroundColor = UIColor.black
        
        self.overlayView = makeOverlayView(presentingViewController: presentingViewController, anchorView: anchorView)
        self.superViewController = presentingViewController
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showOnboarding() {
        guard let presentingViewController = self.superViewController else {
            return
        }
        
        presentingViewController.view.addSubview(self.overlayView!)
        presentingViewController.present(self, animated: true, completion: nil)
    }
    
    func makeOverlayView(presentingViewController: UIViewController, anchorView: UIView) -> UIView {
        let overlayView = UIView(frame: presentingViewController.view.frame)
        overlayView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        let overlayRect = anchorView.convert(anchorView.bounds, to: nil)
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(rect: overlayView.frame)
        let innerPath = UIBezierPath(rect: overlayRect)
        
        path.append(innerPath)
        maskLayer.fillRule = kCAFillRuleEvenOdd
        maskLayer.path = path.cgPath
        overlayView.layer.mask = maskLayer
        
        return overlayView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleFont = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.attributedText = NSAttributedString(string: titleText ?? "", attributes: [NSFontAttributeName: titleFont])
        let messageFont = UIFont.systemFont(ofSize: 14)
        messageLabel.attributedText = NSAttributedString(string: messageText ?? "", attributes: [NSFontAttributeName: messageFont])
        pageControl.isUserInteractionEnabled = false

        if totalStep == 1 {
            pageControl.isHidden = true
            backButton.isHidden = true
            nextButton.setTitle("Mengerti", for: .normal)
        } else {
            backButton.isHidden = currentStep == 0
            if currentStep == totalStep - 1 {
                nextButton.setTitle("Mengerti", for: .normal)
            } else {
                nextButton.setTitle("Selanjutnya", for: .normal)
            }
            pageControl.currentPage = currentStep
            pageControl.numberOfPages = totalStep
            pageControl.isHidden = false
        }
        
        self.view.backgroundColor = UIColor.black
    }
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
        self.view.superview?.layer.cornerRadius = 8;
        
        var additionalHeight:CGFloat = 0
        var firstHeight = titleLabel.frame.size.height
        
        // -16 for the padding around the label, 8 point for both left and right
        let constraint = CGSize(width: self.view.frame.size.width - 16, height: CGFloat.max)
        let context = NSStringDrawingContext()
        let boundingBox = titleLabel.attributedText?.boundingRect(with: constraint, options: .usesLineFragmentOrigin, context: context).size
        guard let newTitleHeight = boundingBox?.height else { return }
        additionalHeight += newTitleHeight - firstHeight
        
        firstHeight = messageLabel.frame.size.height
        let messageBoundingBox = messageLabel.attributedText?.boundingRect(with: constraint, options: .usesLineFragmentOrigin, context: context).size
        guard let newMessageHeight = messageBoundingBox?.height else { return }
        additionalHeight += newMessageHeight - firstHeight

        let size = self.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize);
        self.preferredContentSize = CGSize(width: self.view.frame.width, height: size.height + additionalHeight)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        overlayView?.removeFromSuperview()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        self.delegate?.didDimissOnboarding()
    }
    
    @IBAction func btnNextTap(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.delegate?.didTapNextButton()
        })
    }
    
    @IBAction func btnBackTap(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.delegate?.didTapBackButton()
        })
    }
}
