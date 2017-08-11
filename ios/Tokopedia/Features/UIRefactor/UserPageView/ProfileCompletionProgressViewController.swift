//
//  ProfileCompletionProgressViewController.swift
//  Tokopedia
//
//  Created by Valentina Widiyanti Amanda on 6/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
@objc(ProfileCompletionProgressViewController)
class ProfileCompletionProgressViewController: UIViewController, TKPDAlertViewDelegate {
    
    var profileCompleted: Int = 50
    var birthday: Date!
    var gender: String = ""
    var completionStep: Int = 0
    
    var phoneVerificationController: PhoneVerificationViewController!
    var userProfileInfo: ProfileCompletionInfo!
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet var phoneVerifContainer: UIView!
    //gender
    @IBOutlet var genderView: UIView!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var maleLabel: UILabel!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var femaleLabel: UILabel!
    @IBOutlet weak var genderLanjut: UIButton!
    //DOB
    @IBOutlet var birthdayView: UIView!
    @IBOutlet weak var birthdayButton: UIButton!
    @IBOutlet weak var dobLanjut: UIButton!
    //finish page
    @IBOutlet var finishPageView: UIView!
    @IBOutlet weak var seeProfileButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Lewati",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(tapLewati))
        
        self.setUserProgress()
        
        self.view.addSubview(contentView)
        contentView.mas_makeConstraints { make in
            make?.edges.equalTo()(self.view)
        }
        
        dobLanjut.layer.cornerRadius = 3
        genderLanjut.layer.cornerRadius = 3
        seeProfileButton.layer.cornerRadius = 3
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setWhite()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setProgressBar() {
        //progress color
        let progressBarTrack:UIColor = UIColor(red: 200.0/225.0, green: 200.0/225.0, blue: 220.0/225.0, alpha: 1)
        var progressBarColor:UIColor!
        switch profileCompleted {
        case 60:
            progressBarColor = UIColor(red: 127.0/225.0, green: 190.0/225.0, blue: 51.0/225.0, alpha: 1)
        case 70:
            progressBarColor = UIColor(red: 78.0/225.0, green: 188.0/225.0, blue: 74.0/225.0, alpha: 1)
        case 80:
            progressBarColor = UIColor(red: 39.0/225.0, green: 160.0/225.0, blue: 46.0/225.0, alpha: 1)
        case 90:
            progressBarColor = UIColor(red: 8.0/225.0, green: 132.0/225.0, blue: 31.0/225.0, alpha: 1)
        case 100:
            progressBarColor = UIColor(red: 0.0/225.0, green: 112.0/225.0, blue: 20.0/225.0, alpha: 1)
        default:
            progressBarColor = UIColor(red: 175.0/225.0, green: 213.0/225.0, blue: 100.0/225.0, alpha: 1)
        }
        
        self.progressLabel.text = "\(profileCompleted)%"
        self.progressBar.setProgress(Float(profileCompleted)/100.0, animated: true)
        self.progressBar.trackTintColor = progressBarTrack
        self.progressBar.progressTintColor = progressBarColor
    }
    
    func showCompletionStep() {
        guard profileCompleted < 100 else {
            activityIndicator.isHidden = true
            navigationItem.rightBarButtonItem = nil
            self.view.addSubview(finishPageView)
            finishPageView.mas_makeConstraints { make in
                make?.edges.equalTo()(self.view)
            }
            return
        }
        
        completionStep += 1
        
        guard let userProfileInfo = userProfileInfo else {
            return
        }
        
        if completionStep==1 && !userProfileInfo.phoneVerified {
            showPhoneCompletion()
        } else if completionStep==2 && userProfileInfo.bday=="0001-01-01T00:00:00Z" {
            showDOBCompletion()
        } else if completionStep==3 && (userProfileInfo.gender==3 || userProfileInfo.gender==0) {
            showGenderCompletion()
        } else {
            tapLewati()
        }
    }
    
    func setUserProgress() {
        UserRequest.getUserCompletion(onSuccess: { (profileInfo) in
            self.userProfileInfo = profileInfo
            self.profileCompleted = profileInfo.completion
            self.setProgressBar()
            self.showCompletionStep()
        })
    }
    
    func submitUserProfile(birthday: Date?, gender: String) {
        UserRequest.editProfile(birthday: birthday, gender: self.gender, onSuccess: { (profileInfo) in
            self.setUserProgress()
        }, onFailure: {
        })
    }
    
    func tapLewati() {
        if completionStep == 1 {
            phoneVerificationController?.view.removeFromSuperview()
        } else if completionStep == 2 {
            birthdayView.removeFromSuperview()
            AnalyticsManager.trackEventName("profileCompletion", category: "Fill Personal Information", action: "Fill Information Abandonment", label: "DOB")
        } else if completionStep == 3 {
            self.navigationController?.popViewController(animated: true)
            AnalyticsManager.trackEventName("profileCompletion", category: "Fill Personal Information", action: "Fill Information Abandonment", label: "Gender")
        } else {
            completionStep = 0
        }
        showCompletionStep()
    }
    
    
    //MARK: Profile Completion - Phone
    func showPhoneCompletion() -> Void {
        phoneVerificationController = PhoneVerificationViewController(phoneNumber: "", isFirstTimeVisit: false, didVerifiedPhoneNumber: goToNextPage)
        phoneVerificationController.view.frame = CGRect(x: 0, y: 40, width: self.contentView.frame.size.width, height: self.contentView.frame.size.height-40)
        self.addChildViewController(phoneVerificationController)
        contentView.addSubview(phoneVerificationController.view)
        
        phoneVerificationController.view.snp.makeConstraints { make in
            make.top.equalTo(self.progressBar.snp.bottom)
            make.height.equalTo(self.contentView.snp.height).offset(-97)
            make.left.equalTo(self.contentView.snp.left)
            make.right.equalTo(self.contentView.snp.right)
        }
    }
    
    fileprivate func goToNextPage() {
        phoneVerificationController.willMove(toParentViewController: self)
        phoneVerificationController.view.removeFromSuperview()
        phoneVerificationController.removeFromParentViewController()
        setUserProgress()
    }
    
    
    //MARK: Profile Completion - DOB
    func showDOBCompletion() -> Void {
        birthdayButton.setTitleColor(UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.18), for: .normal)
        birthdayButton.contentHorizontalAlignment = .left
        self.contentView.addSubview(birthdayView)
        birthdayView.snp.makeConstraints { make in
            make.top.equalTo(self.progressBar.snp.bottom).offset(40)
            make.height.equalTo(self.contentView.snp.height).offset(-97)
            make.width.equalTo(self.contentView.snp.width)
        }
        AnalyticsManager.trackScreenName("Profile Completion - Date of Birth Page")
    }
    
    @IBAction func tapBirthdayButton(_ sender: Any) {
        let birthdayPicker:AlertDatePickerView = AlertDatePickerView.newview() as! AlertDatePickerView
        birthdayPicker.delegate = self
        birthdayPicker.show()
        AnalyticsManager.trackEventName("profileCompletion", category: "Fill Personal Information", action: GA_EVENT_ACTION_CLICK, label: "DOB")
    }
    
    @objc(alertView:clickedButtonAtIndex:) func alertView(_ alertView: TKPDAlertView, clickedButtonAt buttonIndex: Int) {
        let date: Date! = (alertView.data["datepicker"] as? Date)
        self.birthday = date
        birthdayButton.setTitle(string(fromDate: date), for: .normal)
        birthdayButton.setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.7), for: .normal)
        dobLanjut.isUserInteractionEnabled = true
        dobLanjut.backgroundColor = .tpGreen()
        dobLanjut.isEnabled = true
        dobLanjut.setTitleColor(.white, for: .normal)
    }
    
    func string(fromDate date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: date)
    }
    
    @IBAction func tapDOBLanjut(_ sender: Any) {
        phoneVerifContainer.removeFromSuperview()
        birthdayView.removeFromSuperview()
        submitUserProfile(birthday: self.birthday, gender: "")
    }
    
    //MARK: Profile Completion - Gender
    func showGenderCompletion() -> Void {
        self.contentView.addSubview(genderView)
        genderView.snp.makeConstraints { make in
            make.top.equalTo(self.progressBar.snp.bottom).offset(40)
            make.height.equalTo(self.contentView.snp.height).offset(-97)
            make.width.equalTo(self.contentView.snp.width)
            make.centerX.equalToSuperview()
        }
        AnalyticsManager.trackScreenName("Profile Completion - Gender Page")
    }
    
    @IBAction func tapMale() {
        self.gender = "1"
        maleButton.isSelected = true
        femaleButton.isSelected = false
        genderLanjut.isUserInteractionEnabled = true
        genderLanjut.backgroundColor = .tpGreen()
        genderLanjut.isEnabled = true
        genderLanjut.setTitleColor(.white, for: .normal)
        maleButton.isUserInteractionEnabled = false
        femaleButton.isUserInteractionEnabled = true
        maleLabel.textColor = UIColor(red: 66.0/255.0, green: 181.0/255.0, blue: 73.0/255.0, alpha: 1)
        maleLabel.font = UIFont.smallThemeSemibold()
        femaleLabel.textColor = UIColor.tpSecondaryBlackText()
        femaleLabel.font = UIFont.smallTheme()
        AnalyticsManager.trackEventName("profileCompletion", category: "Fill Personal Information", action: GA_EVENT_ACTION_CLICK, label: "Gender")
    }
    
    @IBAction func tapFemale() {
        self.gender = "2"
        maleButton.isSelected = false
        femaleButton.isSelected = true
        genderLanjut.isUserInteractionEnabled = true
        genderLanjut.backgroundColor = .tpGreen()
        genderLanjut.isEnabled = true
        genderLanjut.setTitleColor(.white, for: .normal)
        femaleButton.isUserInteractionEnabled = false
        maleButton.isUserInteractionEnabled = true
        maleLabel.textColor = UIColor.tpSecondaryBlackText()
        maleLabel.font = UIFont.smallTheme()
        femaleLabel.textColor = UIColor(red: 66.0/255.0, green: 181.0/255.0, blue: 73.0/255.0, alpha: 1)
        femaleLabel.font = UIFont.smallThemeSemibold()
        AnalyticsManager.trackEventName("profileCompletion", category: "Fill Personal Information", action: "Click", label: "Gender")
    }
    
    @IBAction func tapGenderLanjut(_ sender: Any) {
        phoneVerifContainer.removeFromSuperview()
        birthdayView.removeFromSuperview()
        submitUserProfile(birthday: nil, gender: self.gender)
        if !userProfileInfo.phoneVerified || userProfileInfo.bday=="0001-01-01T00:00:00Z" {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            self.contentView.addSubview(finishPageView)
            AnalyticsManager.trackEventName("profileCompletion", category: "Fill Personal Information", action: "Success", label: "Profile Complete")
        }
    }
    
    //MARK: finish page
    @IBAction func tapSeeProfile(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
