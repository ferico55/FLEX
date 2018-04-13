//
//  TokoCashQRCodeViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 27/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import AVFoundation
import Lottie
import RxCocoa
import RxSwift
import UIKit

public class TokoCashQRCodeViewController: UIViewController {
    // outlet
    @IBOutlet private weak var cameraAccessView: UIView!
    @IBOutlet private weak var cameraAccessButton: UIButton!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var QRCodeView: UIView!
    @IBOutlet private weak var scanImageView: UIImageView!
    @IBOutlet private weak var flashButton: UIButton!
    
    // var
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private var videoCaptureDevice: AVCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    private var device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    private var output = AVCaptureMetadataOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureSession = AVCaptureSession()
    private var isDrawOverlay = false
    private let animation = LOTAnimationView(name: "Scan-QR")
    private let isTorchActive = Variable(false)
    fileprivate let identifier = Variable("")
    
    // navigator
    private lazy var navigator: TokoCashQRCodeNavigator = {
        let nv = TokoCashQRCodeNavigator(navigationController: self.navigationController)
        return nv
    }()
    
    // view model
    private var viewModel: TokoCashQRCodeViewModel
    
    public init() {
        viewModel = TokoCashQRCodeViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Scan Kode QR"
        AnalyticsManager.trackScreenName("QR Scanner")
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        configureActivityIndicator()
        bindViewModel()
    }
    
    private func bindViewModel() {
        
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let viewDidLayoutSubviews = rx.sentMessage(#selector(UIViewController.viewDidLayoutSubviews))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let viewWillDisappear = rx.sentMessage(#selector(UIViewController.viewWillDisappear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let input = TokoCashQRCodeViewModel.Input(trigger: viewWillAppear,
                                                  triggerviewDidLayoutSubviews: viewDidLayoutSubviews,
                                                  triggerDissapear: viewWillDisappear,
                                                  cameraAccessTrigger: cameraAccessButton.rx.tap.asDriver(),
                                                  hasTorch: Driver.of(device?.hasTorch ?? false),
                                                  isTorchAvailable: Driver.of(device?.isTorchAvailable ?? false),
                                                  isTorchActive: isTorchActive.asDriver(),
                                                  identifier: identifier.asDriver())
        let output = viewModel.transform(input: input)
        
        output.needRequestAccess.drive().disposed(by: rx_disposeBag)
        output.cameraSetting.drive(onNext: navigator.toAppSetting).disposed(by: rx_disposeBag)
        
        output.setupCameraView.drive(onNext: { [weak self] _ in
            self?.setupCamera()
            self?.drawOverlay()
        }).disposed(by: rx_disposeBag)
        
        output.runCamera.drive(onNext: { [weak self] isRunning in
            guard isRunning else {
                if self?.captureSession.isRunning == true {
                    self?.captureSession.stopRunning()
                }
                return
            }
            if self?.captureSession.isRunning == false {
                self?.identifier.value = ""
                self?.captureSession.startRunning()
            }
        }).disposed(by: rx_disposeBag)
        
        output.isHidePermission
            .drive(cameraAccessView.rx.isHidden)
            .disposed(by: rx_disposeBag)
        
        output.isHideScanView
            .drive(onNext: { [weak self] isHidden in
                self?.messageLabel.isHidden = isHidden
                self?.QRCodeView.isHidden = isHidden
            })
            .disposed(by: rx_disposeBag)
        
        output.isHideFlashButton
            .drive(flashButton.rx.isHidden)
            .disposed(by: rx_disposeBag)
        
        output.flashButtonImage
            .drive(flashButton.rx.image(for: .normal))
            .disposed(by: rx_disposeBag)
        
        output.activityIndicator
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: rx_disposeBag)
        
        output.validationColor
            .drive(onNext: { [weak self] color in
                self?.scanImageView.tintColor = color
            }).disposed(by: rx_disposeBag)
        
        output.QRInfo.delay(0.3)
            .drive(onNext: { [weak self] data in
                guard let QRInfo = data else { return }
                self?.navigator.toQRPayment(QRInfo)
            })
            .disposed(by: rx_disposeBag)
        
        output.triggerCampaign
            .delay(0.3)
            .drive(onNext: { url in
                AnalyticsManager.trackEventName("campaignEvent", category: "trigger based campaign", action: "scan qr code - success", label: url.absoluteString)
                TPRoutes.routeURL(url as URL)
            })
            .disposed(by: rx_disposeBag)
        
        output.failedMessage
            .drive(onNext: { [weak self] message in
                StickyAlertView.showErrorMessage(message)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    self?.identifier.value = ""
                })
            }).disposed(by: rx_disposeBag)
    }
    
    private func configureActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        let barButton = UIBarButtonItem(customView: activityIndicator)
        navigationItem.setRightBarButton(barButton, animated: true)
    }
    
    private func setupCamera() {
        
        let input = try? AVCaptureDeviceInput(device: videoCaptureDevice)
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        if let videoPreviewLayer = self.previewLayer {
            videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer.frame = view.bounds
            view.layer.addSublayer(videoPreviewLayer)
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code]
        } else {
            debugPrint("Could not add metadata output")
        }
        
        flashButton.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
    }
    
    @objc private func toggleFlash() {
        guard let device = device, device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            let torchOn = !device.isTorchActive
            try device.setTorchModeOnWithLevel(1.0)
            device.torchMode = torchOn ? .on : .off
            isTorchActive.value = torchOn
            device.unlockForConfiguration()
        } catch {
            debugPrint(error)
        }
    }
    
    private func drawOverlay() {
        if !isDrawOverlay {
            let overlayView = UIView(frame: view.bounds)
            overlayView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5400000215)
            
            let overlayRect = QRCodeView.frame
            
            let maskLayer = CAShapeLayer()
            let path = UIBezierPath(rect: overlayView.frame)
            let innerPath = UIBezierPath(roundedRect: overlayRect, cornerRadius: 12.0)
            
            path.append(innerPath)
            maskLayer.fillRule = kCAFillRuleEvenOdd
            maskLayer.path = path.cgPath
            overlayView.layer.mask = maskLayer
            
            view.addSubview(overlayView)
            view.bringSubview(toFront: messageLabel)
            view.bringSubview(toFront: QRCodeView)
            view.bringSubview(toFront: flashButton)
            
            configureAnimation()
            
            isDrawOverlay = true
        }
    }
    
    private func configureAnimation() {
        animation.frame = CGRect(x: 8.0, y: 8.0, width: QRCodeView.frame.width - 16, height: QRCodeView.frame.height - 16)
        animation.backgroundColor = .clear
        animation.loopAnimation = true
        QRCodeView.addSubview(animation)
        
        animation.translatesAutoresizingMaskIntoConstraints = true
        animation.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleBottomMargin]
        
        animation.play()
    }
    
    @objc private func didBecomeActive() {
        if !animation.isAnimationPlaying {
            animation.play()
        }
    }
    
    @objc private func willEnterForeground() {
        if animation.isAnimationPlaying {
            animation.pause()
        }
    }
}

extension TokoCashQRCodeViewController: AVCaptureMetadataOutputObjectsDelegate {
    public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        guard let metadata = metadataObjects.first else { return }
        let readableObject = metadata as! AVMetadataMachineReadableCodeObject
        identifier.value = readableObject.stringValue
    }
}
