//
//  AccountActivationSuccessViewController.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 9/13/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class AccountActivationSuccessViewController: UIViewController {
    
    private let name: String?
    var isFromCreatePassword = false
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var successImage: UIImageView!
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var headerLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var profileCompletionButton: UIButton!
    @IBOutlet private var shopButton: UIButton!
    
    init(name: String) {
        self.name = name
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AnalyticsManager.trackScreenName("Account Activation Success Page")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateViewAppearance()
    }
    
    private func updateViewAppearance() {
        self.view.addSubview(self.scrollView)
        
        let width = UI_USER_INTERFACE_IDIOM() == .pad ? 560 : UIScreen.main.bounds.size.width
        
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        
        self.scrollView.addSubview(self.successImage)
        self.scrollView.addSubview(self.contentView)
        
        self.successImage.snp.makeConstraints { make in
            make.top.left.right.equalTo(self.scrollView)
            make.width.equalTo(self.scrollView.snp.width)
            make.height.equalTo(self.scrollView.snp.width).multipliedBy(739.0 / 768.0)
        }
        
        self.contentView.snp.makeConstraints { make in
            make.top.equalTo(self.successImage.snp.bottom)
            make.bottom.equalTo(self.scrollView.snp.bottom)
            make.centerX.equalTo(self.scrollView)
            make.width.equalTo(width)
        }
    }
    
    private func setupView() {
        var welcomeString = ""
        
        if let name = self.name {
            welcomeString = "Halo \(name),\nSelamat Bergabung di Tokopedia"
        } else {
            welcomeString = "Halo,\nSelamat Bergabung di Tokopedia"
        }
        
        // Setup header
        var descriptionText = NSMutableAttributedString(string: welcomeString)
        var style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        style.alignment = .center
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            descriptionText.addAttribute(NSFontAttributeName, value: UIFont.semiboldSystemFont(ofSize: 16.0), range: NSRange(location: 0, length: welcomeString.characters.count))
        } else {
            descriptionText.addAttribute(NSFontAttributeName, value: UIFont.largeThemeSemibold(), range: NSRange(location: 0, length: welcomeString.characters.count))
        }
        
        descriptionText.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSRange(location: 0, length: welcomeString.characters.count))
        self.headerLabel.attributedText = descriptionText
        
        // Setup description
        welcomeString = "Sebelum memulai aktivitas di Tokopedia, kami sarankan untuk melengkapi profil Anda untuk menjadi verified account."
        descriptionText = NSMutableAttributedString(string: welcomeString)
        style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        style.alignment = .center
        if UI_USER_INTERFACE_IDIOM() == .pad {
            descriptionText.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 16.0), range: NSRange(location: 0, length: welcomeString.characters.count))
            descriptionText.addAttribute(NSFontAttributeName, value: UIFont.italicSystemFont(ofSize: 16.0), range: NSRange(location: 97, length: 16))
        } else {
            descriptionText.addAttribute(NSFontAttributeName, value: UIFont.largeTheme(), range: NSRange(location: 0, length: welcomeString.characters.count))
            descriptionText.addAttribute(NSFontAttributeName, value: UIFont.italicSystemFont(ofSize: 14.0), range: NSRange(location: 97, length: 16))
        }
        descriptionText.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSRange(location: 0, length: welcomeString.characters.count))
        self.descriptionLabel.attributedText = descriptionText
    }
    
    // MARK: Action Button
    
    @IBAction func onTapProfileCompletionButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        AnalyticsManager.trackEventName("clickActivation", category: GA_EVENT_CATEGORY_ACTIVATION, action: GA_EVENT_ACTION_CLICK, label: "Lengkapi Profil")
        NotificationCenter.default.post(name: NSNotification.Name("redirectToMore"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name("openProfileCompletion"), object: nil)
    }
    
    @IBAction func onTapShopNowButton(_ sender: Any) {
        AnalyticsManager.trackEventName("clickActivation", category: GA_EVENT_CATEGORY_ACTIVATION, action: GA_EVENT_ACTION_CLICK, label: "Mulai Belanja")
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(kTKPD_REDIRECT_TO_HOME), object: nil)
    }
    
}
