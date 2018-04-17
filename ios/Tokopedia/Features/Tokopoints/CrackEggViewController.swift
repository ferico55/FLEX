//
//  CrackEggViewController.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 21/03/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Apollo
import AudioToolbox
import AVFoundation
import RxSwift
import UIKit

internal class CrackEggViewController: UIViewController {
    
    @IBOutlet private weak var bgView: UIImageView!
    @IBOutlet private weak var imgSmall: UIImageView!
    @IBOutlet private weak var lblEggsRemainingDescription: UILabel!
    @IBOutlet private weak var viewEggsRemainingCounter: UIView!
    @IBOutlet private weak var lblEggsRemainingCounter: UILabel!
    @IBOutlet private weak var viewTimer: UIView!
    @IBOutlet private weak var lblTimer: UILabel!
    @IBOutlet private weak var btnShop: UIButton!
    @IBOutlet private weak var imgDialog: UIImageView!
    @IBOutlet private weak var lblDialog: UILabel!
    @IBOutlet private weak var viewBlocker: UIView!
    @IBOutlet private weak var viewError: UIView!
    @IBOutlet private weak var viewEggExpired: UIView!
    @IBOutlet private weak var eggWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var eggCenterYConstraint: NSLayoutConstraint!
    @IBOutlet private weak var eggView: EggView!
    @IBOutlet private weak var rewardView: RewardView!
    @IBOutlet private weak var rayView: RayView!
    
    private var eggContainerHeight: CGFloat = 0
    private let isPad = (UIDevice.current.userInterfaceIdiom == .pad)
    private let apolloClient: ApolloClient = {
        guard let url = URL(string: NSString.graphQLURL()) else {
            fatalError("GraphQL URL is not valid")
        }
        
        let configuration = URLSessionConfiguration.default
        let userManager = UserAuthentificationManager()
        
        let appVersion = UIApplication.getAppVersionString()
        
        let loginData = userManager.getUserLoginData()
        let tokenType = loginData?["oAuthToken.tokenType"] as? String ?? ""
        let accessToken = loginData?["oAuthToken.accessToken"] as? String ?? ""
        let accountsAuth = "\(tokenType) \(accessToken)" as String
        
        let headers: [AnyHashable: Any] = [
            "Tkpd-UserId"               : userManager.getUserId(),
            "Tkpd-SessionId"            : userManager.getMyDeviceToken(),
            "X-Device"                  : "ios-\(appVersion)",
            "Device-Type"               : ((UI_USER_INTERFACE_IDIOM() == .phone) ? "iphone" : "ipad"),
            "Accounts-Authorization"    : accountsAuth,
            "Content-Type"              : "application/json"
        ]
        
        configuration.httpAdditionalHeaders = headers
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    
    private var currentToken: TokopointsTokenQuery.Data.TokopointsToken?
    private var rewardFetched = false
    private var crackResult: CrackResultMutation.Data.CrackResult?
    private var isReadyToCrack = false
    private var soundPlayer: AVAudioPlayer?
    private var retryAction: (() -> Void)?
    private let eventView = "luckyEggView"
    private let eventClick = "luckyEggClick"
    private var timerDisposeBag = DisposeBag()
    private var idleTimerDisposeBag = DisposeBag()
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "TokoPoints"
        
        // set font, shadow, and corner radius
        if isPad {
            lblTimer.font = UIFont(name: "Menlo", size: 40)
        }
        else {
            lblTimer.font = UIFont(name: "Menlo", size: 20)
        }
        
        lblTimer.layer.shadowColor = #colorLiteral(red: 0.9843137255, green: 0.9058823529, blue: 0.3176470588, alpha: 1)
        lblTimer.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        lblTimer.layer.shadowRadius = 4.0
        lblTimer.layer.shadowOpacity = 0.54
        lblTimer.layer.masksToBounds = false
        
        viewTimer.layer.borderColor = #colorLiteral(red: 1, green: 0.6352941176, blue: 0.7882352941, alpha: 1)
        viewTimer.layer.borderWidth = 3
        
        btnShop.layer.shadowColor = UIColor.black.cgColor
        btnShop.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        btnShop.layer.shadowRadius = 8.0
        btnShop.layer.shadowOpacity = 0.3
        btnShop.layer.masksToBounds = false
        btnShop.layer.cornerRadius = 4
        
        viewEggsRemainingCounter.layer.shadowColor = UIColor.black.cgColor
        viewEggsRemainingCounter.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        viewEggsRemainingCounter.layer.shadowRadius = 4.0
        viewEggsRemainingCounter.layer.shadowOpacity = 0.24
        viewEggsRemainingCounter.layer.masksToBounds = false
        
        initEmptyEgg()
        rewardView.onDismiss = { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.requestToken()
        }
        
        if UserAuthentificationManager().isLogin {
            requestToken()
        }
    }
    
    internal override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // set height
        eggContainerHeight = eggView.frame.height
        viewTimer.layer.cornerRadius = viewTimer.frame.height / 2
        viewEggsRemainingCounter.layer.cornerRadius = viewEggsRemainingCounter.frame.height / 2
    }
    
    internal override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        eggView.setAnchorPoints()
    }
    
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch UIDevice.current.screenType {
        case .iPhone4:
            eggCenterYConstraint.constant = -20
        case .iPhone5, .iPhone6:
            eggCenterYConstraint.constant = -25
        case .iPhone6Plus, .iPhoneX:
            lblDialog.font = UIFont.boldSystemFont(ofSize: 14)
            lblEggsRemainingCounter.font = UIFont.boldSystemFont(ofSize: 12)
            eggCenterYConstraint.constant = -35
        default:
            lblDialog.font = UIFont.boldSystemFont(ofSize: 22)
            lblEggsRemainingCounter.font = UIFont.boldSystemFont(ofSize: 17)
            eggCenterYConstraint.constant = -40
        }
        eggView.layoutIfNeeded()
    }
    
    private func initEmptyEgg() {
        eggView.setEmptyEgg()
        
        bgView.image = #imageLiteral(resourceName: "egg-bg-normal")
        if let title = currentToken?.home?.emptyState?.title {
            lblDialog.isHidden = false
            lblDialog.text = title
            imgDialog.isHidden = false
        }
        else {
            lblDialog.isHidden = true
            imgDialog.isHidden = true
        }
        if let buttonText = currentToken?.home?.emptyState?.buttonText {
            btnShop.setTitleWithoutAnimation(buttonText)
            btnShop.isHidden = false
        }
        else {
            btnShop.isHidden = true
        }
        imgSmall.isHidden = true
        viewEggsRemainingCounter.isHidden = true
        lblEggsRemainingDescription.isHidden = true
        viewBlocker.isHidden = true
        rewardView.isHidden = true
        viewError.isHidden = true
        viewEggExpired.isHidden = true
        eggView.isUserInteractionEnabled = false
        rayView.stopAnimating()
        viewTimer.isHidden = true
        
        if let imageSize = eggView.getEggImageSize() {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                self.eggWidthConstraint.constant = self.eggContainerHeight * imageSize.width / imageSize.height
                self.eggView.layoutIfNeeded()
            }
        }
    }
    
    private func requestToken() {
        viewBlocker.isHidden = false
        eggView.isUserInteractionEnabled = false
        currentToken = nil
        isReadyToCrack = false
        timerDisposeBag = DisposeBag()
        idleTimerDisposeBag = DisposeBag()
        
        apolloClient.rx.fetch(query: TokopointsTokenQuery()).subscribe(onSuccess: { [weak self] data in
            guard let `self` = self else {
                return
            }
            
            if let statusCode = data.tokopointsToken?.resultStatus?.code, statusCode == "403", let status = data.tokopointsToken?.resultStatus?.status, status == "REQUEST_DENIED" {
                NetworkProvider<ReactTarget>().handleErrorRequest(responseType: ResponseType(response: status), urlString: NSString.graphQLURL()).subscribe(onError: { [weak self] _ in
                    guard let `self` = self else {
                        return
                    }
                    
                    self.requestToken()
                }).disposed(by: self.rx_disposeBag)
                
                return
            }
            
            self.viewBlocker.isHidden = true
            
            guard let token = data.tokopointsToken else {
                self.showError(onRetry: { [weak self] in
                    guard let `self` = self else {
                        return
                    }
                    self.viewError.isHidden = true
                    self.viewBlocker.isHidden = false
                    self.requestToken()
                })
                
                return
            }
            
            self.currentToken = token
            
            guard let sumToken = token.sumToken, sumToken > 0 else {
                self.initEmptyEgg()
                return
            }
            
            if !token.hasRequiredProperties() {
                self.showError(onRetry: { [weak self] in
                    guard let `self` = self else {
                        return
                    }
                    self.viewError.isHidden = true
                    self.viewBlocker.isHidden = false
                    self.requestToken()
                })
                
                return
            }
            
            // start timer first
            if let currentUserToken = token.home?.tokensUser,
                let timeRemaining = currentUserToken.timeRemainingSeconds,
                timeRemaining > 0,
                currentUserToken.isShowTime == true
            {
                self.updateTimerLabel(timeRemaining: timeRemaining)
                self.setupTimer(seconds: timeRemaining)
            }
            
            // download / load assets
            self.viewBlocker.isHidden = false
            self.downloadAllAssets()
        }, onError: { [weak self] error in
            guard let `self` = self else {
                return
            }
            
            self.showError(onRetry: { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.viewError.isHidden = true
                self.viewBlocker.isHidden = false
                self.requestToken()
            })
        }).disposed(by: rx_disposeBag)
    }
    
    internal func downloadAllAssets() {
        
        guard let userToken = currentToken?.home?.tokensUser else {
            return
        }
        
        EggAssetsService.getAssets(token: userToken).subscribe(onNext: { [weak self] eggAsset in
            guard let `self` = self else {
                return
            }
            
            if let eggAsset = eggAsset {
                self.eggView.eggAsset = eggAsset
                self.eggView.showOnboardingIfNeeded()
                
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else {
                        return
                    }
                    
                    self.eggWidthConstraint.constant = self.eggContainerHeight * eggAsset.topImage.size.width / eggAsset.topImage.size.height
                    self.eggView.layoutIfNeeded()
                }
                
                self.initViews(eggAsset: eggAsset)
            }
            else {
                self.showError(onRetry: { [weak self] in
                    guard let `self` = self else {
                        return
                    }
                    self.viewError.isHidden = true
                    self.downloadAllAssets()
                })
            }
        }).disposed(by: rx_disposeBag)
    }
    
    private func showError(onRetry: (() -> Void)?) {
        viewBlocker.isHidden = true
        viewError.isHidden = false
        retryAction = onRetry
    }
    
    private func initViews(eggAsset: EggAsset) {
        viewBlocker.isHidden = true
        rewardView.isHidden = true
        viewError.isHidden = true
        viewEggExpired.isHidden = true
        
        bgView.image = eggAsset.bgImage
        imgSmall.image = eggAsset.smallImage
        imgSmall.isHidden = false
        
        guard let currentUserToken = currentToken?.home?.tokensUser,
            let sumToken = self.currentToken?.sumToken,
            let countingMessages = self.currentToken?.home?.countingMessage,
            countingMessages.count >= 2,
            let countingMessage0 = countingMessages[0],
            let countingMessage1 = countingMessages[1]
        else {
            showError(onRetry: { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.viewError.isHidden = true
                self.viewBlocker.isHidden = false
                self.requestToken()
            })
            
            return
        }
        
        imgDialog.isHidden = false
        lblDialog.isHidden = false
        lblDialog.text = currentUserToken.title
        btnShop.isHidden = true
        
        viewTimer.isHidden = currentUserToken.isShowTime != true ? true : false
        
        eggView.isUserInteractionEnabled = true
        eggView.showOnboardingIfNeeded()
        
        viewEggsRemainingCounter.isHidden = false
        lblEggsRemainingCounter.text = sumToken > 99 ? "99+" : String(sumToken)
        
        lblEggsRemainingDescription.isHidden = false
        let str = countingMessages.flatMap{ $0 }.joined(separator: " ")
        let attrString = NSMutableAttributedString(string: str)
        attrString.addAttribute(NSForegroundColorAttributeName, value: #colorLiteral(red: 0.7725490196, green: 0.9764705882, blue: 0.3843137255, alpha: 1), range: NSRange(location: countingMessage0.count + 1, length: countingMessage1.count))
        lblEggsRemainingDescription.attributedText = attrString
        
        if let tokenId = currentToken?.floating?.tokenId {
            AnalyticsManager.trackEventName(eventView, category: "lucky egg - crack the egg", action: "impression", label: String(tokenId))
        }
        
        rayView.startAnimating()
        setupIdleTimer()
        
        isReadyToCrack = true
    }
    
    private func setupTimer(seconds: Int) {
        Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .takeWhile { count -> Bool in
                return count <= seconds
            }
            .map { seconds - $0 }
            .subscribe(onNext: { [weak self] timeRemaining in
                guard let `self` = self else {
                    return
                }
                
                self.updateTimerLabel(timeRemaining: timeRemaining)
                
                if timeRemaining == 0 {
                    self.requestToken()
                }
            }).disposed(by: timerDisposeBag)
    }
    
    private func updateTimerLabel(timeRemaining: Int) {
        let hours = timeRemaining / 3600
        let minutes = (timeRemaining - (hours * 3600)) / 60
        let secondsRemaining = timeRemaining - (hours * 3600) - (minutes * 60)
        
        let strHours = String(format: "%02d", hours)
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", secondsRemaining)
        let stringValue = "\(strHours):\(strMinutes):\(strSeconds)"
        let attrString = NSMutableAttributedString(string: stringValue)
        attrString.addAttribute(NSKernAttributeName, value: 2, range: NSRange(location: 0, length: stringValue.count))
        lblTimer.attributedText = attrString
    }
    
    private func setupIdleTimer() {
        Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .filter { count -> Bool in
                return count % 5 == 0
            }
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else {
                    return
                }
                
                self.eggView.shake()
            }).disposed(by: idleTimerDisposeBag)
    }
    
    @IBAction private func onTap(_ sender: Any) {
        crack()
    }
    
    private func crack() {
        UserDefaults.standard.set(true, forKey: "tokopointsEggOnboardingShown-\(UserAuthentificationManager().getUserId())")
        eggView.showOnboardingIfNeeded()

        imgDialog.isHidden = true
        lblDialog.isHidden = true
        viewTimer.isHidden = true
        
        timerDisposeBag = DisposeBag()
        idleTimerDisposeBag = DisposeBag()

        playSound(fileName: "Crack")
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

        rewardFetched = false
        fetchCrackResult()
        shakeToCrack()

        if let tokenId = self.currentToken?.floating?.tokenId {
            AnalyticsManager.trackEventName(self.eventClick, category: "lucky egg - crack the egg", action: "click on egg", label: String(tokenId))
        }
    }
    
    private func shakeToCrack() {
        eggView.shake(crack: true) { [weak self] in
            guard let `self` = self else {
                return
            }
            
            if self.rewardFetched {
               self.showReward()
            }
            else {
                self.shakeToCrack()
            }
        }
    }
    
    private func fetchCrackResult() {
        self.crackResult = nil
        
        guard let tokenUserId = currentToken?.home?.tokensUser?.tokenUserId, let campaignId = currentToken?.home?.tokensUser?.campaignId else {
            self.rewardFetched = true
            return
        }
        
        apolloClient.rx.perform(mutation: CrackResultMutation(tokenUserID: tokenUserId, campaignID: campaignId)).subscribe(onSuccess: { [weak self] data in
            guard let `self` = self else {
                return
            }
            
            guard let crackResult = data.crackResult,
                let statusValue = crackResult.resultStatus?.statusValue,
                let _ = crackResult.imageUrl
            else {
                self.rewardFetched = true
                
                self.showError(onRetry: { [weak self] in
                    guard let `self` = self else {
                        return
                    }
                    self.viewError.isHidden = true
                    self.crack()
                })
                return
            }
            
            if statusValue == .ok || statusValue == .isAlreadyCracked {
                self.crackResult = crackResult
                self.rewardView.crackResult = crackResult
                
                self.downloadRewardAsset()
            }
            else {
                if statusValue == .tokenExpired || statusValue == .campaignExpired {    // token user expired, campaign expired
                    self.rewardFetched = true
                    self.viewEggExpired.isHidden = false
                }
                else if statusValue == .requestDenied {
                    NetworkProvider<ReactTarget>().handleErrorRequest(responseType: ResponseType(response: "REQUEST_DENIED"), urlString: NSString.graphQLURL()).subscribe(onError: { [weak self] _ in
                        guard let `self` = self else {
                            return
                        }

                        self.fetchCrackResult()

                    }).disposed(by: self.rx_disposeBag)
                }
                else {
                    self.rewardFetched = true
                    
                    self.showError(onRetry: { [weak self] in
                        guard let `self` = self else {
                            return
                        }
                        self.viewError.isHidden = true
                        self.crack()
                    })
                }
                return
            }
        }, onError: { [weak self] error in
            guard let `self` = self else {
                return
            }
            self.rewardFetched = true
            
            self.showError(onRetry: { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.viewError.isHidden = true
                self.crack()
            })
        }).disposed(by: rx_disposeBag)
    }
    
    private func downloadRewardAsset() {
        guard let crackResult = crackResult else {
            return
        }
        EggAssetsService.getRewardAsset(crackResult: crackResult).subscribe(onNext: { [weak self] rewardImage in
            guard let `self` = self else {
                return
            }
            
            if let rewardImage = rewardImage {
                self.rewardView.imageReward = rewardImage
            }
            else {
                self.crackResult = nil
                self.showError(onRetry: { [weak self] in
                    guard let `self` = self else {
                        return
                    }
                    self.viewError.isHidden = true
                    self.crack()
                })
            }
            
            self.rewardFetched = true
        }).disposed(by: rx_disposeBag)
    }
    
    private func showReward() {
        guard let crackResult = crackResult else {
            return
        }

        AnalyticsManager.trackEventName(self.eventView, category: "lucky egg - rewards page", action: "impression", label: crackResult.benefitType ?? "")

        playSound(fileName: "Reward")
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        let totalDuration = 0.98
        eggView.crackOpen(duration: totalDuration * 0.25)
        rewardView.showReward(duration: totalDuration)
    }
    
    private func playSound(fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else { return }
        if let player = soundPlayer {
            player.stop()
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            soundPlayer = try AVAudioPlayer(contentsOf: url)
            guard let player = soundPlayer else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }

    internal override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction private func btnRetryDidTapped(_ sender: Any) {
        AnalyticsManager.trackEventName(self.eventClick, category: "lucky egg - error page", action: "click coba lagi", label: "")
        retryAction?()
    }
    
    @IBAction private func btnCloseErrorDidTapped(_ sender: Any) {
        AnalyticsManager.trackEventName(self.eventClick, category: "lucky egg - error page", action: "click close button", label: "")
        retryAction?()
    }
    
    @IBAction private func btnShopDidTapped(_ sender: Any) {
        if let applink = currentToken?.home?.emptyState?.buttonApplink, let title = currentToken?.home?.emptyState?.buttonText {
            AnalyticsManager.trackEventName(self.eventClick, category: "lucky egg - empty page", action: "click", label: title)
            TPRoutes.routeURL(URL(string: applink))
        }
    }
    
    @IBAction private func btnCloseExpiredDidTapped(_ sender: Any) {
        AnalyticsManager.trackEventName(self.eventClick, category: "lucky egg - error expired token", action: "click close button", label: "")
        dismissOverlayAndRefresh(sender)
    }
    
    @IBAction private func btnOkExpiredDidTapped(_ sender: Any) {
        AnalyticsManager.trackEventName(self.eventClick, category: "lucky egg - error expired token", action: "click ok", label: "")
        dismissOverlayAndRefresh(sender)
    }
    
    private func dismissOverlayAndRefresh(_ sender: Any) {
        (sender as? UIButton)?.superview?.isHidden = true
        requestToken()
    }
}
