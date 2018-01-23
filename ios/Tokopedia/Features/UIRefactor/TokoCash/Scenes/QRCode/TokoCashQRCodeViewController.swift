//
//  TokoCashQRCodeViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 27/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation
import Lottie

class TokoCashQRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var QRCodeView: UIView!
    @IBOutlet weak var scanImageView: UIImageView!
    @IBOutlet weak var flashButton: UIButton!
    
    // view model
    var viewModel: TokoCashQRCodeViewModel!
    
    var videoCaptureDevice: AVCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    var device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    var output = AVCaptureMetadataOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var captureSession = AVCaptureSession()
    var identifier = Variable("")
    var isTorchActive =  Variable(false)
    var drawOverlay = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCamera()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession.isRunning == false) {
            identifier.value = ""
            captureSession.startRunning()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if (!drawOverlay) {
            
            let overlayView = UIView(frame: view.frame)
            overlayView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            
            let overlayRect = QRCodeView.frame
            
            let maskLayer = CAShapeLayer()
            let path = UIBezierPath(rect: overlayView.frame)
            let innerPath =  UIBezierPath(roundedRect: overlayRect, cornerRadius: 10.0)
            
            path.append(innerPath)
            maskLayer.fillRule = kCAFillRuleEvenOdd
            maskLayer.path = path.cgPath
            overlayView.layer.mask = maskLayer
            
            self.view.addSubview(overlayView)
            
            view.bringSubview(toFront: messageLabel)
            view.bringSubview(toFront: QRCodeView)
            view.bringSubview(toFront: flashButton)
            
            let animation = LOTAnimationView(name: "Scan-QR")
            animation.frame = CGRect(x: 8.0, y: 8.0, width: QRCodeView.frame.width - 16, height: QRCodeView.frame.height - 16)
            animation.backgroundColor = .clear
            animation.loopAnimation = true
            QRCodeView.addSubview(animation)
            
            animation.translatesAutoresizingMaskIntoConstraints = true
            animation.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleBottomMargin]
            
            animation.play()
            
            drawOverlay = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    private func setupCamera() {
        
        let input = try? AVCaptureDeviceInput(device: videoCaptureDevice)
        
        if self.captureSession.canAddInput(input) {
            self.captureSession.addInput(input)
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        if let videoPreviewLayer = self.previewLayer {
            videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer.frame = self.view.bounds
            view.layer.addSublayer(videoPreviewLayer)
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if self.captureSession.canAddOutput(metadataOutput) {
            self.captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code]
        } else {
            print("Could not add metadata output")
        }
        
        flashButton.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        assert(viewModel != nil)
        
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let input = TokoCashQRCodeViewModel.Input(trigger: viewWillAppear,
                                                  hasTorch : Driver.of(device?.hasTorch ?? false),
                                                  isTorchAvailable: Driver.of(device?.isTorchAvailable ?? false),
                                                  isTorchActive: isTorchActive.asDriver(),
                                                  identifier: identifier.asDriver())
        let output = viewModel.transform(input: input)
        
        output.showFlashButton
            .drive(flashButton.rx.isHidden)
            .disposed(by: rx_disposeBag)
        
        output.flashButtonImage
            .drive(flashButton.rx.image(for: .normal))
            .disposed(by: rx_disposeBag)
        
        output.validationColor
            .drive(onNext: { color in
                self.scanImageView.tintColor = color
            }).disposed(by: rx_disposeBag)
        
        output.QRInfo
            .drive()
            .disposed(by: rx_disposeBag)
        
        output.failedMessage
            .drive(onNext: { message in
                StickyAlertView.showErrorMessage([message])
            }).disposed(by: rx_disposeBag)
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        guard let metadata = metadataObjects.first  else { return }
        let readableObject = metadata as! AVMetadataMachineReadableCodeObject
        identifier.value = readableObject.stringValue
    }
    
    func toggleFlash() {
        guard let device = device, device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            let torchOn = !device.isTorchActive
            try device.setTorchModeOnWithLevel(1.0)
            device.torchMode = torchOn ? .on : .off
            self.isTorchActive.value = torchOn
            device.unlockForConfiguration()
        } catch {
            debugPrint(error)
        }
    }
}
