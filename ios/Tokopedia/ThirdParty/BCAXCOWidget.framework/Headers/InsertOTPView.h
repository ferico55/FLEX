//
//  InsertOTPView.h
//  WidgetBCAFramework
//
//  Created by PT Bank Central Asia Tbk on 7/13/16.
//  Copyright © 2016 PT Bank Central Asia Tbk. All rights reserved.
//

#import "BaseView.h"
#import "BCADelegate.h"
#import "CustomTextField.h"
#import "XCOButton.h"

@interface InsertOTPView : BaseView <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) id <BCADelegate> delegate;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phoneNumberTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *phoneNumberInfoView;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet CustomTextField *OTPTextField;
@property (nonatomic) NSArray *msisdnList;
@property (nonatomic) NSString *selectedMSISDN;
@property (weak, nonatomic) IBOutlet UIImageView *otpIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *otpLabel;
@property (weak, nonatomic) IBOutlet UILabel *otpCountLabel;
@property (weak, nonatomic) IBOutlet XCOButton *resendOTPButton;
@property (weak, nonatomic) IBOutlet UIView *infoOTPView;
@property (weak, nonatomic) IBOutlet UIView *infoOTPBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *selectedMSISDNLabel;
@property (weak, nonatomic) IBOutlet UIButton *clearOTPTextButton;
@property (weak, nonatomic) IBOutlet XCOButton *submitButton;
@property (weak, nonatomic) IBOutlet XCOButton *cancelButton;

@property (nonatomic) UIButton *termsAndConditionButton;
@property (nonatomic) UILabel *termsAndConditionLabel;
@property (nonatomic) BOOL termsAndConditionSelected;

@property (weak, nonatomic) UIView *masterView;

- (IBAction)sendOTPButtonAction:(UIButton *)sender;
- (IBAction)cancelOTPButtonAction:(UIButton *)sender;


- (IBAction)resendOTPButtonAction:(UIButton *)sender;
- (IBAction)helpButtonAction:(UIButton *)sender;
- (IBAction)backgroundTapGestureAction:(UITapGestureRecognizer *)sender;
- (IBAction)clearOTPTextButtonAction:(UIButton *)sender;


- (IBAction)submitButton:(UIButton *)sender;

- (void)setCardNumber:(NSString *)string;
- (void)setMaxLimit:(NSString *)string;
- (void)setCurrentType:(NSString *)pTypeTransaction;

@end
