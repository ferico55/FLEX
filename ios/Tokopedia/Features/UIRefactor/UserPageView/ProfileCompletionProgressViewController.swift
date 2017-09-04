//
//  ProfileCompletionProgressViewController.swift
//  Tokopedia
//
//  Created by Valentina Widiyanti Amanda on 6/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Moya
import Unbox
import RxSwift

@objc(ProfileCompletionProgressViewController)
class ProfileCompletionProgressViewController: UIViewController, TKPDAlertViewDelegate, NoResultDelegate {

    var profileCompleted: Int = 50
    var birthday: Date!
    var gender: Int = 0
    var completionStep: Int = 0

    var phoneVerificationController: PhoneVerificationViewController!
    var userProfileInfo: ProfileCompletionInfo!

    fileprivate var noResultView: NoResultReusableView!

    @IBOutlet weak var kelengkapanProfil: UILabel!

    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet var phoneVerifContainer: UIView!
    // gender
    @IBOutlet var genderView: UIView!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var maleLabel: UILabel!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var femaleLabel: UILabel!
    @IBOutlet weak var genderLanjut: UIButton!
    // DOB
    @IBOutlet var birthdayView: UIView!
    @IBOutlet weak var birthdayButton: UIButton!
    @IBOutlet weak var dobLanjut: UIButton!
    // finish page
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

        setUserProgress()

        view.addSubview(contentView)
        contentView.mas_makeConstraints { make in
            make?.edges.equalTo()(self.view)
        }

        dobLanjut.layer.cornerRadius = 3
        genderLanjut.layer.cornerRadius = 3
        seeProfileButton.layer.cornerRadius = 3

        // no result view
        noResultView = NoResultReusableView(frame: UIScreen.main.bounds)
        noResultView.delegate = self
        noResultView.backgroundColor = UIColor.white
        noResultView.generateAllElements("icon_no_data_grey.png", title: "Whoops!\nTidak ada koneksi Internet", desc: "Harap coba lagi", btnTitle: "Coba Kembali")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setWhite()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setProgressBar() {
        // progress color
        let progressBarTrack: UIColor = UIColor(red: 200.0 / 225.0, green: 200.0 / 225.0, blue: 220.0 / 225.0, alpha: 1)
        var progressBarColor: UIColor!
        switch profileCompleted {
        case 60:
            progressBarColor = UIColor(red: 127.0 / 225.0, green: 190.0 / 225.0, blue: 51.0 / 225.0, alpha: 1)
        case 70:
            progressBarColor = UIColor(red: 78.0 / 225.0, green: 188.0 / 225.0, blue: 74.0 / 225.0, alpha: 1)
        case 80:
            progressBarColor = UIColor(red: 39.0 / 225.0, green: 160.0 / 225.0, blue: 46.0 / 225.0, alpha: 1)
        case 90:
            progressBarColor = UIColor(red: 8.0 / 225.0, green: 132.0 / 225.0, blue: 31.0 / 225.0, alpha: 1)
        case 100:
            progressBarColor = UIColor(red: 0.0 / 225.0, green: 112.0 / 225.0, blue: 20.0 / 225.0, alpha: 1)
        default:
            progressBarColor = UIColor(red: 175.0 / 225.0, green: 213.0 / 225.0, blue: 100.0 / 225.0, alpha: 1)
        }

        progressLabel.text = "\(profileCompleted)%"
        progressBar.setProgress(Float(profileCompleted) / 100.0, animated: true)
        progressBar.trackTintColor = progressBarTrack
        progressBar.progressTintColor = progressBarColor
    }

    func showCompletionStep() {
        completionStep += 1

        guard profileCompleted < 100 else {
            activityIndicator.isHidden = true
            navigationItem.rightBarButtonItem = nil
            view.addSubview(finishPageView)
            finishPageView.mas_makeConstraints { make in
                make?.edges.equalTo()(self.view)
            }
            return
        }

        guard let userProfileInfo = userProfileInfo else {
            return
        }

        if completionStep == 1 && !userProfileInfo.phoneVerified {
            showPhoneCompletion()
        } else if completionStep == 2 && userProfileInfo.bday == "0001-01-01T00:00:00Z" {
            showDOBCompletion()
        } else if completionStep == 3 && (userProfileInfo.gender == 0) {
            showGenderCompletion()
        } else {
            tapLewati()
        }
    }

    func setUserProgress() {
        UserRequest.getUserCompletion(onSuccess: { profileInfo in
            self.kelengkapanProfil.isHidden = false
            self.progressBar.isHidden = false
            self.progressLabel.isHidden = false
            self.navigationItem.rightBarButtonItem?.accessibilityElementsHidden = false
            self.userProfileInfo = profileInfo
            self.profileCompleted = profileInfo.completion
            self.setProgressBar()
            self.showCompletionStep()
        }, onFailure: {
            self.showEmptyStatePage()
        })
    }

    func submitUserProfile(birthday: Date?, gender _: Int) {
        UserRequest.editProfile(birthday: birthday, gender: gender, onSuccess: { _ in
            self.setUserProgress()
            if self.completionStep == 3 {
                if !self.userProfileInfo.phoneVerified || self.userProfileInfo.bday == "0001-01-01T00:00:00Z" || self.gender == 0 {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.contentView.addSubview(self.finishPageView)
                    AnalyticsManager.trackEventName("profileCompletion", category: "Fill Personal Information", action: "Success", label: "Profile Complete")
                }
            }
        }, onFailure: {
            self.showEmptyStatePage()
            self.setDisable()
            self.completionStep -= 1
        })
    }

    func tapLewati() {
        if completionStep == 1 {
            phoneVerificationController?.view.removeFromSuperview()
        } else if completionStep == 2 {
            birthdayView.removeFromSuperview()
            AnalyticsManager.trackEventName("profileCompletion", category: "Fill Personal Information", action: "Fill Information Abandonment", label: "DOB")
        } else if completionStep == 3 {
            navigationController?.popViewController(animated: true)
            AnalyticsManager.trackEventName("profileCompletion", category: "Fill Personal Information", action: "Fill Information Abandonment", label: "Gender")
        } else {
            completionStep = 0
        }
        showCompletionStep()
    }

    public func buttonDidTapped(_: Any!) {
        noResultView.removeFromSuperview()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Lewati",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(tapLewati))
        setUserProgress()
    }

    func setDisable() {
        if completionStep == 2 {
            dobLanjut.isEnabled = false
            dobLanjut.isUserInteractionEnabled = false
            dobLanjut.backgroundColor = .fromHexString("E0E0E0")
            dobLanjut.setTitleColor(.fromHexString("A6A6A6"), for: .disabled)
        } else if completionStep == 3 {
            maleButton.isSelected = false
            maleLabel.textColor = UIColor.tpSecondaryBlackText()
            maleLabel.font = UIFont.smallTheme()
            femaleButton.isSelected = false
            femaleLabel.textColor = UIColor.tpSecondaryBlackText()
            femaleLabel.font = UIFont.smallTheme()

            genderLanjut.isEnabled = false
            genderLanjut.isUserInteractionEnabled = false
            genderLanjut.backgroundColor = .fromHexString("E0E0E0")
            genderLanjut.setTitleColor(.fromHexString("A6A6A6"), for: .disabled)
        }
    }

    func showEmptyStatePage() {
        kelengkapanProfil.isHidden = true
        progressBar.isHidden = true
        progressLabel.isHidden = true
        navigationItem.rightBarButtonItem = nil
        view.addSubview(noResultView)
    }

    // MARK: Profile Completion - Phone
    func showPhoneCompletion() {
        phoneVerificationController = PhoneVerificationViewController(phoneNumber: "", isFirstTimeVisit: false, didVerifiedPhoneNumber: goToNextPage)
        phoneVerificationController.view.frame = CGRect(x: 0, y: 40, width: contentView.frame.size.width, height: contentView.frame.size.height - 40)
        addChildViewController(phoneVerificationController)
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

    // MARK: Profile Completion - DOB
    func showDOBCompletion() {
        birthdayButton.setTitleColor(UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.18), for: .normal)
        birthdayButton.contentHorizontalAlignment = .left
        contentView.addSubview(birthdayView)
        birthdayView.snp.makeConstraints { make in
            make.top.equalTo(self.progressBar.snp.bottom).offset(40)
            make.height.equalTo(self.contentView.snp.height).offset(-97)
            make.width.equalTo(self.contentView.snp.width)
        }
        AnalyticsManager.trackScreenName("Profile Completion - Date of Birth Page")
    }

    @IBAction func tapBirthdayButton(_: Any) {
        let birthdayPicker: AlertDatePickerView = AlertDatePickerView.newview() as! AlertDatePickerView
        birthdayPicker.delegate = self
        birthdayPicker.show()
        AnalyticsManager.trackEventName("profileCompletion", category: "Fill Personal Information", action: GA_EVENT_ACTION_CLICK, label: "DOB")
    }

    @objc(alertView:clickedButtonAtIndex:) func alertView(_ alertView: TKPDAlertView, clickedButtonAt _: Int) {
        let date: Date! = (alertView.data["datepicker"] as? Date)
        birthday = date
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

    @IBAction func tapDOBLanjut(_: Any) {
        submitUserProfile(birthday: birthday, gender: 0)
        phoneVerifContainer.removeFromSuperview()
        birthdayView.removeFromSuperview()
    }

    // MARK: Profile Completion - Gender
    func showGenderCompletion() {
        contentView.addSubview(genderView)
        genderView.snp.makeConstraints { make in
            make.top.equalTo(self.progressBar.snp.bottom).offset(40)
            make.height.equalTo(self.contentView.snp.height).offset(-97)
            make.width.equalTo(self.contentView.snp.width)
            make.centerX.equalToSuperview()
        }
        AnalyticsManager.trackScreenName("Profile Completion - Gender Page")
    }

    @IBAction func tapMale() {
        gender = 1
        maleButton.isSelected = true
        femaleButton.isSelected = false
        genderLanjut.isUserInteractionEnabled = true
        genderLanjut.backgroundColor = .tpGreen()
        genderLanjut.isEnabled = true
        genderLanjut.setTitleColor(.white, for: .normal)
        maleLabel.textColor = UIColor(red: 66.0 / 255.0, green: 181.0 / 255.0, blue: 73.0 / 255.0, alpha: 1)
        maleLabel.font = UIFont.smallThemeSemibold()
        femaleLabel.textColor = UIColor.tpSecondaryBlackText()
        femaleLabel.font = UIFont.smallTheme()
        AnalyticsManager.trackEventName("profileCompletion", category: "Fill Personal Information", action: GA_EVENT_ACTION_CLICK, label: "Gender")
    }

    @IBAction func tapFemale() {
        gender = 2
        maleButton.isSelected = false
        femaleButton.isSelected = true
        genderLanjut.isUserInteractionEnabled = true
        genderLanjut.backgroundColor = .tpGreen()
        genderLanjut.isEnabled = true
        genderLanjut.setTitleColor(.white, for: .normal)
        maleLabel.textColor = UIColor.tpSecondaryBlackText()
        maleLabel.font = UIFont.smallTheme()
        femaleLabel.textColor = UIColor(red: 66.0 / 255.0, green: 181.0 / 255.0, blue: 73.0 / 255.0, alpha: 1)
        femaleLabel.font = UIFont.smallThemeSemibold()
        AnalyticsManager.trackEventName("profileCompletion", category: "Fill Personal Information", action: "Click", label: "Gender")
    }

    @IBAction func tapGenderLanjut(_: Any) {
        submitUserProfile(birthday: nil, gender: gender)
        phoneVerifContainer.removeFromSuperview()
        birthdayView.removeFromSuperview()
    }

    // MARK: finish page
    @IBAction func tapSeeProfile(_: Any) {
        navigationController?.popViewController(animated: true)
    }
}
