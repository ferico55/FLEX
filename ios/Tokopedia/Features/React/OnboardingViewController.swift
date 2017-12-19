//
//  OnboardingViewController.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 02/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc enum OnboardingAction: Int {
    case next = 1
    case prev = 0
    case cancel = -1
}

// ini bikin extension aja buat implement delegate nya
class OnboardingViewController: UIViewController {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet private var nextButton: UIButton!
    @IBOutlet private var pageControl: UIPageControl!
    @IBOutlet private var backButton: UIButton!
    
    private let titleText: String
    private let messageText: String
    private let currentStep: Int
    private let totalStep: Int
    private weak var superViewController: UIViewController?
    private var overlayView: UIView?
    private let callback: (OnboardingAction) -> Void
    private let anchorView: UIView
    
    init(title: String, message: String, currentStep: Int, totalStep: Int, anchorView: UIView, presentingViewController: UIViewController, callback: @escaping (OnboardingAction) -> Void) {
        titleText = title
        messageText = message
        self.currentStep = currentStep
        self.totalStep = totalStep
        self.callback = callback
        self.anchorView = anchorView
        superViewController = presentingViewController
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .popover
        popoverPresentationController?.delegate = self
        popoverPresentationController?.sourceRect = CGRect(x: anchorView.bounds.origin.x - 8, y: anchorView.bounds.origin.y - 8, width: anchorView.bounds.size.width + 16, height: anchorView.bounds.size.height + 16)
        popoverPresentationController?.sourceView = anchorView
        popoverPresentationController?.backgroundColor = UIColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleFont = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.attributedText = NSAttributedString(string: titleText, attributes: [NSFontAttributeName: titleFont])
        let messageFont = UIFont.systemFont(ofSize: 14)
        messageLabel.attributedText = NSAttributedString(string: messageText, attributes: [NSFontAttributeName: messageFont])
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
        
        view.backgroundColor = UIColor.black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.superview?.layer.cornerRadius = 8
        
        var additionalHeight: CGFloat = 0
        var firstHeight = titleLabel.frame.size.height
        
        // -16 for the padding around the label, 8 point for both left and right
        let constraint = CGSize(width: view.frame.size.width - 16, height: CGFloat.max)
        let context = NSStringDrawingContext()
        let boundingBox = titleLabel.attributedText?.boundingRect(with: constraint, options: .usesLineFragmentOrigin, context: context).size
        guard let newTitleHeight = boundingBox?.height else { return }
        additionalHeight += newTitleHeight - firstHeight
        
        firstHeight = messageLabel.frame.size.height
        let messageBoundingBox = messageLabel.attributedText?.boundingRect(with: constraint, options: .usesLineFragmentOrigin, context: context).size
        guard let newMessageHeight = messageBoundingBox?.height else { return }
        additionalHeight += newMessageHeight - firstHeight
        let size = view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        preferredContentSize = CGSize(width: view.frame.width, height: size.height + additionalHeight)
        
        overlayView = makeOverlayView()
        if let overlay = overlayView {
            self.superViewController?.view.addSubview(overlay)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        overlayView?.removeFromSuperview()
    }
    
    // MARK: Onboarding methods
    func showOnboarding() {
        self.superViewController?.present(self, animated: true, completion: nil)
    }
    
    func makeOverlayView() -> UIView {
        guard let superVC = self.superViewController else {
            return UIView()
        }
        let overlayView = UIView(frame: superVC.view.frame)
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
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        callback(.cancel)
    }
    
    // MARK: IBActions
    @IBAction func btnNextTap(_ sender: Any) {
        dismiss(animated: true, completion: {
            self.callback(.next)
        })
    }
    
    @IBAction func btnBackTap(_ sender: Any) {
        dismiss(animated: true, completion: {
            self.callback(.prev)
        })
    }
}

extension OnboardingViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
