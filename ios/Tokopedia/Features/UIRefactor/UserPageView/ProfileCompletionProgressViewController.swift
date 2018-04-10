//
//  ProfileCompletionProgressViewController.swift
//  Tokopedia
//
//  Created by Valentina Widiyanti Amanda on 6/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Moya
import RxSwift
import UIKit
import Unbox

@objc(ProfileCompletionProgressViewController)
internal class ProfileCompletionProgressViewController: UIViewController, TKPDAlertViewDelegate, NoResultDelegate {

    private var profileCompleted: Int = 50
    private var birthday = Date()
    private var gender: Int = 0
    private var completionStep: Int = 0

    private var phoneVerificationController: PhoneVerificationViewController!
    private var userProfileInfo: ProfileCompletionInfo!

    fileprivate var noResultView: NoResultReusableView!

    @IBOutlet private weak var kelengkapanProfil: UILabel!

    @IBOutlet private weak var progressBar: UIProgressView!
    @IBOutlet private weak var progressLabel: UILabel!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private var phoneVerifContainer: UIView!
    // gender
    @IBOutlet private var genderView: UIView!
    @IBOutlet private weak var maleButton: UIButton!
    @IBOutlet private weak var maleLabel: UILabel!
    @IBOutlet private weak var femaleButton: UIButton!
    @IBOutlet private weak var femaleLabel: UILabel!
    @IBOutlet private weak var genderLanjut: UIButton!
    // DOB
    @IBOutlet private var birthdayView: UIView!
    @IBOutlet private weak var birthdayButton: UIButton!
    @IBOutlet private weak var dobLanjut: UIButton!
    // finish page
    @IBOutlet private var finishPageView: UIView!
    @IBOutlet private weak var seeProfileButton: UIButton!

    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    internal override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Lewati",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(tapLewati))

        setUserProgress()

        view.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
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

    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    internal override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func setProgressBar() {
        // progress color
        let progressBarTrack: UIColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.862745098, alpha: 1)
        var progressBarColor: UIColor
        switch profileCompleted {
        case 60:
            progressBarColor = #colorLiteral(red: 0.4980392157, green: 0.7450980392, blue: 0.2, alpha: 1)
        case 70:
            progressBarColor = #colorLiteral(red: 0.3058823529, green: 0.737254902, blue: 0.2901960784, alpha: 1)
        case 80:
            progressBarColor = #colorLiteral(red: 0.1529411765, green: 0.6274509804, blue: 0.1803921569, alpha: 1)
        case 90:
            progressBarColor = #colorLiteral(red: 0.03137254902, green: 0.5176470588, blue: 0.1215686275, alpha: 1)
        case 100:
            progressBarColor = #colorLiteral(red: 0, green: 0.4392156863, blue: 0.07843137255, alpha: 1)
        default:
            progressBarColor = #colorLiteral(red: 0.6862745098, green: 0.8352941176, blue: 0.3921568627, alpha: 1)
        }

        progressLabel.text = "\(profileCompleted)%"
        progressBar.setProgress(Float(profileCompleted) / 100.0, animated: true)
        progressBar.trackTintColor = progressBarTrack
        progressBar.progressTintColor = progressBarColor
    }

    private func showCompletionStep() {
        completionStep += 1

        guard profileCompleted < 100 else {
            activityIndicator.isHidden = true
            navigationItem.rightBarButtonItem = nil
            view.addSubview(finishPageView)
            finishPageView.snp.makeConstraints({ make in
                make.edges.equalTo(self.view)
            })
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

    private func setUserProgress() {
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

    private func submitUserProfile(birthday: Date?, gender _: Int) {
        UserRequest.editProfile(birthday: birthday, gender: gender, onSuccess: { _ in
            self.setUserProgress()
            if self.completionStep == 3 {
                if let manager = UIApplication.shared.reactBridge.module(for: ReactEventManager.self) as? ReactEventManager {
                    manager.sendProfileEditedEvent()
                }
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

    @objc private func tapLewati() {
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

    internal func buttonDidTapped(_: Any!) {
        noResultView.removeFromSuperview()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Lewati",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(tapLewati))
        setUserProgress()
    }

    private func setDisable() {
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

    private func showEmptyStatePage() {
        kelengkapanProfil.isHidden = true
        progressBar.isHidden = true
        progressLabel.isHidden = true
        navigationItem.rightBarButtonItem = nil
        view.addSubview(noResultView)
    }

    // MARK: Profile Completion - Phone
    private func showPhoneCompletion() {
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

    private func goToNextPage() {
        phoneVerificationController.willMove(toParentViewController: self)
        phoneVerificationController.view.removeFromSuperview()
        phoneVerificationController.removeFromParentViewController()
        setUserProgress()
    }

    // MARK: Profile Completion - DOB
    private func showDOBCompletion() {
        birthdayButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.18), for: .normal)
        birthdayButton.contentHorizontalAlignment = .left
        contentView.addSubview(birthdayView)
        birthdayView.snp.makeConstraints { make in
            make.top.equalTo(self.progressBar.snp.bottom).offset(40)
            make.height.equalTo(self.contentView.snp.height).offset(-97)
            make.width.equalTo(self.contentView.snp.width)
        }
        AnalyticsManager.trackScreenName("Profile Completion - Date of Birth Page")
    }

    @IBAction private func tapBirthdayButton(_: Any) {
        guard let birthdayPicker = AlertDatePickerView.newview() as? AlertDatePickerView else {
            return
        }

        birthdayPicker.delegate = self
        birthdayPicker.isSetMinimumDate = true
        birthdayPicker.data = ["type": kTKPDALERT_DATAALERTTYPEREGISTERKEY.rawValue]
        birthdayPicker.show()
        AnalyticsManager.trackEventName("profileCompletion", category: "Fill Personal Information", action: GA_EVENT_ACTION_CLICK, label: "DOB")
    }

    @objc(alertView:clickedButtonAtIndex:) internal func alertView(_ alertView: TKPDAlertView, clickedButtonAt _: Int) {
        let date: Date! = (alertView.data["datepicker"] as? Date)
        birthday = date
        birthdayButton.setTitle(string(fromDate: date), for: .normal)
        birthdayButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.7), for: .normal)
        dobLanjut.isUserInteractionEnabled = true
        dobLanjut.backgroundColor = .tpGreen()
        dobLanjut.isEnabled = true
        dobLanjut.setTitleColor(.white, for: .normal)
    }

    private func string(fromDate date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: date)
    }

    @IBAction private func tapDOBLanjut(_: Any) {
        submitUserProfile(birthday: birthday, gender: 0)
        phoneVerifContainer.removeFromSuperview()
        birthdayView.removeFromSuperview()
    }

    // MARK: Profile Completion - Gender
    private func showGenderCompletion() {
        contentView.addSubview(genderView)
        genderView.snp.makeConstraints { make in
            make.top.equalTo(self.progressBar.snp.bottom).offset(40)
            make.height.equalTo(self.contentView.snp.height).offset(-97)
            make.width.equalTo(self.contentView.snp.width)
            make.centerX.equalToSuperview()
        }
        AnalyticsManager.trackScreenName("Profile Completion - Gender Page")
    }

    @IBAction private func tapMale() {
        gender = 1
        maleButton.isSelected = true
        femaleButton.isSelected = false
        genderLanjut.isUserInteractionEnabled = true
        genderLanjut.backgroundColor = .tpGreen()
        genderLanjut.isEnabled = true
        genderLanjut.setTitleColor(.white, for: .normal)
        maleLabel.textColor = .tpGreen()
        maleLabel.font = UIFont.smallThemeSemibold()
        femaleLabel.textColor = UIColor.tpSecondaryBlackText()
        femaleLabel.font = UIFont.smallTheme()
        AnalyticsManager.trackEventName("profileCompletion", category: "Fill Personal Information", action: GA_EVENT_ACTION_CLICK, label: "Gender")
    }

    @IBAction private func tapFemale() {
        gender = 2
        maleButton.isSelected = false
        femaleButton.isSelected = true
        genderLanjut.isUserInteractionEnabled = true
        genderLanjut.backgroundColor = .tpGreen()
        genderLanjut.isEnabled = true
        genderLanjut.setTitleColor(.white, for: .normal)
        maleLabel.textColor = UIColor.tpSecondaryBlackText()
        maleLabel.font = UIFont.smallTheme()
        femaleLabel.textColor = .tpGreen()
        femaleLabel.font = UIFont.smallThemeSemibold()
        AnalyticsManager.trackEventName("profileCompletion", category: "Fill Personal Information", action: "Click", label: "Gender")
    }

    @IBAction private func tapGenderLanjut(_: Any) {
        submitUserProfile(birthday: nil, gender: gender)
        phoneVerifContainer.removeFromSuperview()
        birthdayView.removeFromSuperview()
    }

    // MARK: finish page
    @IBAction private func tapSeeProfile(_: Any) {
        navigationController?.popViewController(animated: true)
    }
}
