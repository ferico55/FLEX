//
//  OnboardingViewController.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 3/24/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import EAIntroView
import JLPermissions
import Lottie
import MoEngage_iOS_SDK
import RxCocoa
import RxSwift
import UIKit

private struct OnBoardingPage {
    public let backgroundColor: UIColor
    public let lottieName: String
    public let title: String
    public let subtitle: String
    public let pageView: UIView
}

@objc
internal class IntroViewController: UIViewController, EAIntroDelegate {
    @IBOutlet fileprivate var presentationContainer: UIView!
    
    fileprivate var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = UIColor.tpDisabledWhiteText()
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.numberOfPages = 5
        pageControl.currentPage = 0
        pageControl.accessibilityIdentifier = "pageControl"
        return pageControl
    }()
    
    private let skipButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let startButton = UIButton(type: .system)
    
    private let onboardings = [
        OnBoardingPage(backgroundColor: #colorLiteral(red: 0.2588235294, green: 0.7098039216, blue: 0.2862745098, alpha: 1), lottieName: "onboarding1", title: "Bebas Beli Apa Saja", subtitle: "Tersedia jutaan produk dari merchant & official store tepercaya", pageView: UIView()),
        OnBoardingPage(backgroundColor: #colorLiteral(red: 0, green: 0.7019607843, blue: 0.7960784314, alpha: 1), lottieName: "onboarding2", title: "Bayar Tagihan Bebas Cemas", subtitle: "Tagihan mulai BPJS, gas, hingga air bisa terbayar tanpa was-was", pageView: UIView()),
        OnBoardingPage(backgroundColor: #colorLiteral(red: 0.9450980392, green: 0.5568627451, blue: 0.1058823529, alpha: 1), lottieName: "onboarding3", title: "Pesan Kebutuhan Liburan", subtitle: "Dapatkan tiket kereta, wahana rekreasi, dan event seru bebas antre", pageView: UIView()),
        OnBoardingPage(backgroundColor: #colorLiteral(red: 0.2588235294, green: 0.7098039216, blue: 0.2862745098, alpha: 1), lottieName: "onboarding4", title: "Ajukan Asuransi hingga Modal", subtitle: "Lengkapi kebutuhan finansial mulai kartu kredit hingga pinjaman modal", pageView: UIView()),
        OnBoardingPage(backgroundColor: #colorLiteral(red: 0, green: 0.7019607843, blue: 0.7960784314, alpha: 1), lottieName: "onboarding5", title: "Jual Barang Ciptakan Peluang", subtitle: "Buka toko gratis, nikmati transaksi mudah, aman, dan dikunjungi jutaan pembeli", pageView: UIView()),
    ]
    private var introView: EAIntroView!
    private let disposeBag = DisposeBag()
    private var currentPage = 0
    private let superBounds = UIScreen.main.bounds
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        AnalyticsManager.trackScreenName("Onboarding")
        
        let pages = setupPageViews()
        self.setupNextButton()
        self.setupSkipButton()
        self.setupStartButton()
        
        introView = {
            let view = EAIntroView(frame: superBounds, andPages: pages)
            view?.pageControl = pageControl
            view?.swipeToExit = false
            view?.show(in: presentationContainer)
            view?.skipButton = nil
            view?.backgroundColor = UIColor.clear
            view?.delegate = self
            return view
        }()
    }
    
    // MARK: view setup
    private func setupPageViews() -> [EAIntroPage] {
        var pages: [EAIntroPage] = []
        for (index, onboarding) in self.onboardings.enumerated() {
            let view = onboarding.pageView
            self.view.addSubview(view)
            view.backgroundColor = onboarding.backgroundColor

            let lottieView = self.configureLottie(superView: view, lottieName: onboarding.lottieName)
            let titleLabel = self.configureTitle(superView: view, title: onboarding.title)
            let subtitleLabel = self.configureSubtitle(superView: view, subtitle: onboarding.subtitle)
            
            if let page = EAIntroPage(customView: view) {
                page.onPageDidAppear = { [weak self] in
                    guard let `self` = self else {
                        return
                    }
                    self.animateText(titleLabel: titleLabel, subtitleLabel: subtitleLabel)
                    lottieView.animationProgress = 0
                    lottieView.play()
                    self.currentPage = index
                    if index == 4 {
                        self.playLastPage(isForward: true)
                    }
                }
                page.onPageDidDisappear = { [weak self] in
                    titleLabel.isHidden = true
                    subtitleLabel.isHidden = true

                    guard let `self` = self else {
                        return
                    }
                    self.currentPage = index
                    if index == 4 {
                        self.playLastPage(isForward: false)
                    }
                }
                pages.append(page)
            }
        }
        return pages
    }
    
    private func setupSkipButton() {
        self.skipButton.setTitle("Lewati", for: .normal)
        self.skipButton.tintColor = UIColor.white
        self.skipButton.accessibilityIdentifier = "skipButton"
        self.view.addSubview(self.skipButton)
        self.skipButton.snp.makeConstraints { [weak self] make in
            guard let `self` = self else {
                return
            }
            make.bottom.equalTo(self.view).offset(-36)
            make.left.equalTo(self.view).offset(16)
        }
        
        self.skipButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else {
                return
            }
            self.markOnboardingPlayed()
            self.navigateToMainViewControllerWithPage(.search)
        }).addDisposableTo(self.disposeBag)
    }
    
    private func setupStartButton() {
        self.startButton.setTitle("Mulai Sekarang", for: .normal)
        self.startButton.tintColor = #colorLiteral(red: 0, green: 0.7019607843, blue: 0.7960784314, alpha: 1)
        self.startButton.accessibilityIdentifier = "startButton"
        self.startButton.backgroundColor = UIColor.white
        self.startButton.cornerRadius = 3
        self.startButton.isHidden = true
        self.view.addSubview(self.startButton)
        self.startButton.snp.makeConstraints { [weak self] make in
            guard let `self` = self else {
                return
            }
            make.height.equalTo(48)
            make.width.equalTo(self.view).offset(-64)
            make.bottom.equalTo(self.view).offset(-32)
            make.centerX.equalTo(self.view)
        }
        
        self.startButton.rx.tap.asObservable()
            .throttle(1.0, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.markOnboardingPlayed()
                self.navigateToMainViewControllerWithPage(.default)
            })
            .addDisposableTo(self.disposeBag)
    }
    
    private func setupNextButton() {
        self.nextButton.setTitle("", for: .normal)
        self.nextButton.setImage(#imageLiteral(resourceName: "onboarding_next"), for: .normal)
        self.nextButton.tintColor = UIColor.white
        self.nextButton.accessibilityIdentifier = "nextButton"
        self.nextButton.cornerRadius = 16
        self.view.addSubview(self.nextButton)
        self.nextButton.snp.makeConstraints { [weak self] make in
            guard let `self` = self else {
                return
            }
            make.width.equalTo(32)
            make.height.equalTo(32)
            make.bottom.equalTo(self.view).offset(-36)
            make.right.equalTo(self.view).offset(-16)
        }
        
        self.nextButton.rx.tap.asObservable()
            .throttle(1.0, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.currentPage += 1
                self.introView.scrollToPage(for: UInt(self.currentPage), animated: true)
            })
            .addDisposableTo(self.disposeBag)
    }
    
    private func configureLottie(superView: UIView, lottieName: String) -> LOTAnimationView {
        let lottieView = LOTAnimationView(name: lottieName)
        lottieView.contentMode = .scaleAspectFit
        lottieView.animationSpeed = 1.0
        superView.addSubview(lottieView)
        lottieView.snp.makeConstraints { make in
            make.top.equalTo(self.superBounds.size.height/10)
            make.left.equalTo(superView).offset(0)
            make.right.equalTo(superView).offset(0)
            make.height.equalTo(self.superBounds.size.height / 2)
        }
        return lottieView
    }

    private func configureTitle(superView: UIView, title: String) -> UILabel {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.title2ThemeSemibold()
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.setText(title, animated: false)
        titleLabel.isHidden = true
        superView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(superView).offset(self.superBounds.size.height / 10 * (UIDevice.current.userInterfaceIdiom == .phone ? 6.25 : 7))
            make.centerX.equalTo(superView)
        }
        
        return titleLabel
    }
    
    private func configureSubtitle(superView: UIView, subtitle: String) -> UILabel {
        let subtitleLabel = UILabel()
        subtitleLabel.font = UIFont.smallTheme()
        subtitleLabel.textColor = UIColor.white
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        subtitleLabel.setText(subtitle, animated: false)
        subtitleLabel.isHidden = true
        superView.addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { [weak self] make in
            guard let `self` = self else {
                return
            }
            let titleTopOffset = self.superBounds.size.height / 10 * (UIDevice.current.userInterfaceIdiom == .phone ? 6.25 : 7)
            make.top.equalTo(superView).offset(titleTopOffset + 15 + 8) // title top offset + title font size + margin
            make.width.equalTo(superView).offset(-64)
            make.centerX.equalTo(superView)
        }
        
        return subtitleLabel
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // for some reason the introView's frame is distorted
        introView.frame = self.view.bounds
    }
    
    // MARK: Animation
    private func playLastPage(isForward: Bool) {
        UIView.animate(withDuration: 0.7) { [weak self] in
            guard let `self` = self else {
                return
            }
            var x: CGFloat
            if isForward {
                x = self.superBounds.size.width / 2 - self.nextButton.frame.size.width / 2
            } else {
                x = self.superBounds.size.width - self.nextButton.frame.size.width - 16
            }
            self.nextButton.frame = CGRect(x: x, y: self.nextButton.frame.origin.y, width: self.nextButton.frame.size.width, height: self.nextButton.frame.size.height)
        }
        
        CATransaction.begin()

        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = isForward ? 1.0 : 0.0
        fadeAnimation.toValue = isForward ? 0.0 : 1.0
        fadeAnimation.duration = 0.7
        fadeAnimation.isRemovedOnCompletion = false
        fadeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        self.skipButton.layer.add(fadeAnimation, forKey: "opacity")
        self.pageControl.layer.add(fadeAnimation, forKey: "opacity")
        
        let startFadeAnimation = CABasicAnimation(keyPath: "opacity")
        startFadeAnimation.fromValue = isForward ? 0.0 : 1.0
        startFadeAnimation.toValue = isForward ? 1.0 : 0.0
        startFadeAnimation.duration = 1.0
        startFadeAnimation.isRemovedOnCompletion = false
        startFadeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        self.startButton.layer.add(startFadeAnimation, forKey: "opacity")

        CATransaction.setCompletionBlock { [weak self] in
            guard let `self` = self else {
                return
            }
            self.skipButton.isHidden = isForward
            self.pageControl.isHidden = isForward
            self.startButton.isHidden = !isForward
        }

        CATransaction.commit()
    }
    
    private func animateText(titleLabel: UILabel, subtitleLabel: UILabel) {
        CATransaction.begin()
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 0.0
        fadeAnimation.toValue = 1.0
        fadeAnimation.duration = 0.7
        fadeAnimation.isRemovedOnCompletion = false
        fadeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        titleLabel.layer.add(fadeAnimation, forKey: "opacity")
        subtitleLabel.layer.add(fadeAnimation, forKey: "opacity")
        
        let titleTranslationAnimation = CABasicAnimation(keyPath: "position")
        titleTranslationAnimation.fromValue = CGPoint(x: 0,y: titleLabel.center.y)
        titleTranslationAnimation.toValue = CGPoint(x: titleLabel.center.x, y: titleLabel.center.y)
        titleTranslationAnimation.duration = 0.5
        titleTranslationAnimation.isRemovedOnCompletion = false
        titleTranslationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        titleLabel.layer.add(titleTranslationAnimation, forKey: "position")
        
        let subtitleTranslationAnimation = CABasicAnimation(keyPath: "position")
        subtitleTranslationAnimation.fromValue = CGPoint(x: 0,y: subtitleLabel.center.y)
        subtitleTranslationAnimation.toValue = CGPoint(x: subtitleLabel.center.x, y: subtitleLabel.center.y)
        subtitleTranslationAnimation.duration = 0.8
        subtitleTranslationAnimation.isRemovedOnCompletion = false
        subtitleTranslationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        subtitleLabel.layer.add(subtitleTranslationAnimation, forKey: "position")
        
        CATransaction.setCompletionBlock {
            titleLabel.isHidden = false
            subtitleLabel.isHidden = false
        }
        
        CATransaction.commit()
    }
    
    // MARK: Utility function
    private func navigateToMainViewControllerWithPage(_ page: MainViewControllerPage) {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        window.backgroundColor = UIColor.clear
        let nextViewController = MainViewController(page: page)
        
        nextViewController?.view.frame = self.view.frame

        //need to call this to prevent stale notification observer
        introView.hide(withFadeOutDuration: 1)

        UIView.transition(
            with: window,
            duration: 0.5,
            options: .transitionCrossDissolve,
            animations: {
                window.rootViewController = nextViewController
            },
            completion: { [weak self] completed in
                guard let `self` = self else {
                    return
                }
                self.activePushNotification()
            })
    }
    
    private func activePushNotification() {
        let permission = JLNotificationPermission.sharedInstance()

        permission.isExtraAlertEnabled = false
        permission.authorize(withTitle: "\"Tokopedia\" Ingin Mengirimi Anda Pemberitahuan", message: "Pemberitahuan dapat berupa peringatan, suara, dan ikon tanda. Ini dapat dikonfigurasi di Pengaturan.", cancelTitle: "Jangan Izinkan", grantTitle: "OKE") { (_, _) in
            // do nothing
        }
    }
    
    private func markOnboardingPlayed() {
        UserDefaults.standard.set(true, forKey: "has_shown_onboarding")
        UserDefaults.standard.synchronize()
    }
}
