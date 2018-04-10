//
//  OnboardingViewController.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 02/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc internal enum OnboardingAction: Int {
    case next = 1
    case prev = 0
    case cancel = -1
}

// ini bikin extension aja buat implement delegate nya
internal class OnboardingViewController: UIViewController {
    
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
    fileprivate let callback: (OnboardingAction) -> Void
    private let anchorView: UIView
    private let fromPresentedViewController: Bool
    
    public init(title: String,
         message: String,
         currentStep: Int,
         totalStep: Int,
         anchorView: UIView,
         presentingViewController: UIViewController,
         fromPresentedViewController: Bool,
         callback: @escaping (OnboardingAction) -> Void) {
        titleText = title
        messageText = message
        self.currentStep = currentStep
        self.totalStep = totalStep
        self.callback = callback
        self.anchorView = anchorView
        self.fromPresentedViewController = fromPresentedViewController
        superViewController = presentingViewController
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .popover
        popoverPresentationController?.delegate = self
        popoverPresentationController?.sourceRect = CGRect(x: anchorView.bounds.origin.x - 8, y: anchorView.bounds.origin.y - 8, width: anchorView.bounds.size.width + 16, height: anchorView.bounds.size.height + 16)
        popoverPresentationController?.sourceView = anchorView
        popoverPresentationController?.backgroundColor = UIColor.black
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
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
            
            if currentStep > 0 {
                let swipeRightGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
                swipeRightGestureRecognizer.direction = .right
                self.view.addGestureRecognizer(swipeRightGestureRecognizer)
            }
            
            if currentStep == totalStep - 1 {
                nextButton.setTitle("Mengerti", for: .normal)
            } else {
                nextButton.setTitle("Selanjutnya", for: .normal)
                
                let swipeLeftGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
                swipeLeftGestureRecognizer.direction = .left
                self.view.addGestureRecognizer(swipeLeftGestureRecognizer)
            }
            pageControl.currentPage = currentStep
            pageControl.numberOfPages = totalStep
            pageControl.isHidden = false
        }
        
        view.backgroundColor = UIColor.black
        
        overlayView = makeOverlayView()
        if let overlay = overlayView {
            if self.fromPresentedViewController {
                UIApplication.shared.keyWindow?.addSubview(overlay)
            } else {
                self.superViewController?.view.addSubview(overlay)
            }
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
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
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        overlayView?.removeFromSuperview()
    }
    
    // MARK: Onboarding methods
    public func showOnboarding() {
        if self.fromPresentedViewController {
            UIApplication.topViewController()?.present(self, animated: true, completion: nil)
        } else {
            UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: true, completion: nil)
        }
    }
    
    private func makeOverlayView() -> UIView {
        guard let window = UIApplication.shared.keyWindow?.rootViewController else {
            return UIView()
        }
        let overlayView = UIView(frame: window.view.frame)
        overlayView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        
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
    
    internal func handleSwipeGesture(gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left:
            self.btnNextTap(gesture)
        case .right:
            self.btnBackTap(gesture)
        default:
            print("default")
        }
    }
    
    // MARK: IBActions
    @IBAction private func btnNextTap(_ sender: Any) {
        dismiss(animated: true, completion: {
            self.callback(.next)
        })
    }
    
    @IBAction private func btnBackTap(_ sender: Any) {
        dismiss(animated: true, completion: {
            self.callback(.prev)
        })
    }
}

extension OnboardingViewController: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    public func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        callback(.cancel)
    }
}
