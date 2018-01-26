//
//  ProductTalkDetailHeaderViewController.swift
//  Tokopedia
//
//  Created by Hans Arijanto on 28/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

// displays the first message thread of a product discussion
class ProductTalkDetailHeaderViewController: UIViewController {
    
    // data
    var talk: TalkList
    
    // call backs
    var onTapUser   : ((TalkList) -> Void)? = nil
    var onTapProduct: ((TalkList) -> Void)? = nil
    
    // ui
    private let userProfilePicture : UIImageView = UIImageView() // rounded profile picture of pengguna (talk.talk_user_image)
    private let userLabelContainer : UIView      = UIView()      // green pengguna label container
    private let userLabel          : UILabel     = UILabel()     // the pengguna text label
    private let userNameLabel      : UILabel     = UILabel()     // pengguna username label (talk.talk_user_name)
    private let userRepIcon        : UIImageView = UIImageView() // pengguna reputation icon
    private let userRepPercentage  : UILabel     = UILabel()     // pengguna reputation percentage (talk.talk_user_reputation.positive_percentage)
    private let userTalkTimeLabel  : UILabel     = UILabel()     // pengguna talk creation time (talk.talk_create_time)
    private let separator          : UIView      = UIView()      // separator line
    
    private let productImage           : UIImageView = UIImageView() // product image (talk.talk_product_image)
    private let productNameLabel       : UILabel     = UILabel()     // product name label (talk.talk_product_name)
    private let firstMsgLabel          : UILabel     = UILabel()     // label that contains the first message of the discusstion (talk.talk_message.stringByStrippingHTML().kv_decodeHTMLCharacterEntities())
    
    let mainStack                        = UIStackView() // stack view utama vertical
    private let firstRowStack            = UIStackView() // horizontal pengguna stack
    private let innerPenggunaColumnStack = UIStackView() // vertical pengguna details stack
    private let firstDeepRowStack        = UIStackView() // pengguna credentials row (pengguna label + name)
    private let secondDeepRowStack       = UIStackView() // pengguna rep row (pengguna rep icon + %)
    private let secondRowStack           = UIStackView() // product  row
    private let innerProductColumnStack  = UIStackView() // product message column
    
    init(talk: TalkList) {
        self.talk = talk
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        self.view.layoutMargins = UIEdgeInsets(top: 15.0, left: 15.0, bottom: 15.0, right: 15.0)

        // setup pengguna profile pic
        userProfilePicture.layer.cornerRadius  = 25.0
        userProfilePicture.layer.masksToBounds = true
        userProfilePicture.image = nil // default image
        userProfilePicture.snp.makeConstraints({ (make) in
            make.width.equalTo(50.0)
            make.height.equalTo(50.0)
        })
        
        // setup userLabel
        userLabelContainer.layer.cornerRadius = 2.0
        userLabelContainer.backgroundColor = UIColor(red: 0.275, green: 0.533, blue: 0.278, alpha: 1.00)
        userLabelContainer.layoutMargins = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
        
        userLabel.font = UIFont.microTheme()
        userLabel.textColor = .white
        userLabel.backgroundColor = .clear
        userLabel.text = "Pengguna"
        
        userLabelContainer.addSubview(userLabel)
        userLabel.snp.makeConstraints({ (make) in
            make.top.equalTo(userLabelContainer.snp.topMargin)
            make.left.equalTo(userLabelContainer.snp.leftMargin)
        })
        
        // setup pengguna username label
        userNameLabel.font            = UIFont.smallTheme()
        userNameLabel.textColor       = UIColor(red: 0.039, green: 0.494, blue: 0.027, alpha: 1.0)
        userNameLabel.backgroundColor = .clear
        userNameLabel.text            = "User Name"
        
        // setup pengguna rep
        userRepIcon.image           = #imageLiteral(resourceName: "icon_smile_small")
        userRepPercentage.font      = UIFont.smallTheme()
        userRepPercentage.textColor = UIColor(red: 0.620, green: 0.620, blue: 0.620, alpha: 1.0)
        userRepPercentage.text      = "00.0%"
        
        // setup pengguna talk creation time
        userTalkTimeLabel.font      = UIFont.microTheme()
        userTalkTimeLabel.textColor = UIColor(red: 0.784, green: 0.780, blue: 0.800, alpha: 1.0)
        userTalkTimeLabel.text      = "[00 January 0000, 00:00]"
        
        // setup separator
        let separatorTopSpacing             = UIView() // used for customs spacing (later in IOS 11 use stackview.setCustomSpacing)
        separatorTopSpacing.backgroundColor = .clear
        separatorTopSpacing.snp.makeConstraints({ (make) in
            make.height.equalTo(3.0)
        })
        
        let separatorBottomSpacing = UIView()
        separatorBottomSpacing.backgroundColor = .clear
        separatorBottomSpacing.snp.makeConstraints({ (make) in
            make.height.equalTo(10.0)
        })
        
        separator.backgroundColor = UIColor(red: 0.878, green: 0.878, blue: 0.878, alpha: 1.00)
        separator.snp.makeConstraints({ (make) in
            make.height.equalTo(1.0)
        })
        
        // setup product image
        productImage.image = nil
        productImage.snp.makeConstraints({ (make) in
            make.height.equalTo(70.0)
            make.width.equalTo(70.0)
        })
        
        productNameLabel.font = UIFont.smallThemeMedium()
        productNameLabel.text = "[Product Name]"
        
        // setup firstMsgLabel
        firstMsgLabel.font          = UIFont.largeTheme()
        firstMsgLabel.numberOfLines = 0
        firstMsgLabel.text          = "[First Message]"
        
        // setup content
        self.userProfilePicture.image = #imageLiteral(resourceName: "default-boy")
        if let imageURL = URL(string: talk.talk_user_image) {
            self.userProfilePicture.setImageWithUrl(imageURL, placeHolderImage: #imageLiteral(resourceName: "default-boy"))
        }
        
        self.productImage.image = #imageLiteral(resourceName: "icon_toped_loading_grey")
        if let imageURL = URL(string: talk.talk_product_image) {
            self.productImage.setImageWithUrl(imageURL, placeHolderImage: #imageLiteral(resourceName: "icon_toped_loading_grey"))
        }
        
        self.userNameLabel.text = talk.talk_user_name
        self.userRepPercentage.text = talk.talk_user_reputation.positive_percentage + "%"
        self.userTalkTimeLabel.text = talk.talk_create_time
        self.productNameLabel.text      = talk.talk_product_name
        
        if let firstMsgLabelText = talk.talk_message.strippingHTML().kv_decodeHTMLCharacterEntities() {
            let paragraphStyle         = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 5.0
            let attrString             = NSMutableAttributedString(string: firstMsgLabelText)
            attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
            
            self.firstMsgLabel.attributedText = attrString
        }
        
        // main vertical stack
        mainStack.axis         = .vertical
        mainStack.distribution = .equalSpacing
        mainStack.alignment    = .leading
        mainStack.spacing      = 0.0
        
        // pengguna horizontal stack
        firstRowStack.axis         = .horizontal
        firstRowStack.distribution = .equalSpacing
        firstRowStack.alignment    = .leading
        firstRowStack.spacing      = 10.0
        
        // pengguna details vertical stack
        innerPenggunaColumnStack.axis         = .vertical
        innerPenggunaColumnStack.distribution = .fillProportionally
        innerPenggunaColumnStack.alignment    = .leading
        innerPenggunaColumnStack.spacing      = 3.0
        
        // pengguna credentials horizontal stack
        firstDeepRowStack.axis         = .horizontal
        firstDeepRowStack.distribution = .equalSpacing
        firstDeepRowStack.alignment    = .leading
        firstDeepRowStack.spacing      = 4.0
        
        // penggune reputation horizontal stack
        secondDeepRowStack.axis         = .horizontal
        secondDeepRowStack.distribution = .equalSpacing
        secondDeepRowStack.alignment    = .leading
        secondDeepRowStack.spacing      = 4.0
        
        // product horizontal stack
        secondRowStack.axis         = .horizontal
        secondRowStack.distribution = .equalSpacing
        secondRowStack.alignment    = .leading
        secondRowStack.spacing      = 10.0
        
        // product inner column stack
        innerProductColumnStack.axis         = .vertical
        innerProductColumnStack.distribution = .equalSpacing
        innerProductColumnStack.alignment    = .leading
        innerProductColumnStack.spacing      = 4.0
        
        // fill pengguna name horizontal stack
        firstDeepRowStack.addArrangedSubview(userLabelContainer)
        firstDeepRowStack.addArrangedSubview(userNameLabel)
        
        // fill pengguna rep stack
        secondDeepRowStack.addArrangedSubview(userRepIcon)
        secondDeepRowStack.addArrangedSubview(userRepPercentage)
        
        // fill innter column stack
        innerPenggunaColumnStack.addArrangedSubview(firstDeepRowStack)
        innerPenggunaColumnStack.addArrangedSubview(secondDeepRowStack)
        innerPenggunaColumnStack.addArrangedSubview(userTalkTimeLabel)
        
        // fill first row stack view
        firstRowStack.addArrangedSubview(userProfilePicture)
        firstRowStack.addArrangedSubview(innerPenggunaColumnStack)
        
        // fill inner pegguna column label
        innerProductColumnStack.addArrangedSubview(productNameLabel)
        innerProductColumnStack.addArrangedSubview(firstMsgLabel)
        
        // fill second row stack view
        secondRowStack.addArrangedSubview(productImage)
        secondRowStack.addArrangedSubview(innerProductColumnStack)
        
        // fill main stack view
        mainStack.addArrangedSubview(firstRowStack)
        mainStack.addArrangedSubview(separatorTopSpacing)
        mainStack.addArrangedSubview(separator)
        mainStack.addArrangedSubview(separatorBottomSpacing)
        mainStack.addArrangedSubview(secondRowStack)
        
        // set main stack view constraints
        firstRowStack.snp.makeConstraints({ (make) in
            make.top.equalTo(10)
        })
        
        // add main stack view to vc view
        self.view.addSubview(mainStack)
        
        // set main stack view constraints
        mainStack.snp.makeConstraints({ (make) in
            make.top.equalTo(self.view.snp.topMargin)
            make.left.equalTo(self.view.snp.leftMargin)
            make.right.equalTo(self.view.snp.rightMargin)
        })
        
        // pin the view's bottom to the bottom of the stack view (this sizes by itself based on content)
        // this enables the view to dynamicly determine it's height
        self.view.snp.makeConstraints({ (make) in
            make.bottomMargin.equalTo(mainStack.snp.bottom).offset(10.0)
        })
        
        // pin separator to mainStack sides to dynamicly set it's width
        separator.snp.makeConstraints({ (make) in
            make.left.equalTo(mainStack.snp.left)
            make.right.equalTo(mainStack.snp.right)
        })
        
        // pin label container to label ends to make it dynamicly sized based on the content of the label
        userLabelContainer.snp.makeConstraints({ (make) in
            make.bottomMargin.equalTo(userLabel.snp.bottom)
            make.rightMargin.equalTo(userLabel.snp.right)
        })
        
        self.setupGestureRecognizers()
    }
    
    private func setupGestureRecognizers() {
        productImage.isUserInteractionEnabled = true
        productImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapProduct)))
        
        productNameLabel.isUserInteractionEnabled = true
        productNameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapProduct)))
        
        userProfilePicture.isUserInteractionEnabled = true
        userProfilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapUser)))
        
        userLabelContainer.isUserInteractionEnabled = true
        userLabelContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapUser)))
        
        userNameLabel.isUserInteractionEnabled = true
        userNameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapUser)))
        
        userRepIcon.isUserInteractionEnabled = true
        userRepIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapRep(_:))))
        
        userRepPercentage.isUserInteractionEnabled = true
        userRepPercentage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapRep(_:))))
    }
    
    // MARK: Gesture Recognizers
    func didTapProduct() {
        self.onTapProduct?(talk)
    }
    
    func didTapUser() {
        self.onTapUser?(talk)
    }
    
    func didTapRep(_ sender: UITapGestureRecognizer) {
        let paddingRightLeftContent: Int32 = 10
        let viewContentPopUp = UIView(frame: CGRect(x: 0.0, y: 0.0, width: Double((CWidthItemPopUp*3)+paddingRightLeftContent), height: Double(CHeightItemPopUp)))
        let tempSmileyAndMedal = SmileyAndMedal()
        tempSmileyAndMedal.showPopUpSmiley(viewContentPopUp, andPadding: paddingRightLeftContent, withReputationNetral: talk.talk_user_reputation.neutral, withRepSmile: talk.talk_user_reputation.positive, withRepSad: talk.talk_user_reputation.negative, with: nil)
        
        if let cmPopTipView = CMPopTipView(customView: viewContentPopUp) {
            cmPopTipView.backgroundColor    = .white
            cmPopTipView.animation          = .slide
            cmPopTipView.dismissTapAnywhere = true
            cmPopTipView.leftPopUp          = true
            cmPopTipView.presentPointing(at: userRepPercentage, in: self.view, animated: true)
        }
    }
    
    // MARK: Life Cycle
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
}

