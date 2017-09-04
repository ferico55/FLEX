//
//  InsertCardNumberView.h
//  WidgetBCAFramework
//
//  Created by PT Bank Central Asia Tbk on 7/12/16.
//  Copyright © 2016 PT Bank Central Asia Tbk. All rights reserved.
//

#import "BaseView.h"
#import "BCADelegate.h"
#import "InsertOTPView.h"
#import "CustomTextField.h"


@interface InsertCardNumberView : BaseView <UITextFieldDelegate>

@property (nonatomic, weak) id <BCADelegate> delegate;

@property (weak, nonatomic) IBOutlet CustomTextField *cardNumberTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *limitTextField;
@property (weak, nonatomic) IBOutlet UILabel *infoLimitLabel;
@property (weak, nonatomic) IBOutlet UIView *infoLimitView;
@property (weak, nonatomic) IBOutlet UIView *backgroundLimitView;
@property (weak, nonatomic) IBOutlet UILabel *limittextLabel;
@property (weak, nonatomic) IBOutlet UIButton *clearCardNumberTextButton;
@property (weak, nonatomic) IBOutlet UIButton *clearLimitTextButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet XCOButton *nextButton;

@property (weak, nonatomic) UIView *masterView;

@property (nonatomic) InsertOTPView *insertOTPView;

- (IBAction)nextButtonAction:(UIButton *)sender;

- (IBAction)backgroundTapAction:(UITapGestureRecognizer *)sender;

- (IBAction)infoLimitButtonAction:(UIButton *)sender;

- (IBAction)helpButtonAction:(UIButton *)sender;

- (IBAction)okInfoLimitButtonAction:(UIButton *)sender;

- (IBAction)clearCardNumberTextButtonAction:(UIButton *)sender;

- (IBAction)clearLimitTextButtonAction:(UIButton *)sender;

- (IBAction)limitTextLabelTapAction:(UITapGestureRecognizer *)sender;

- (void) removeView;

@end
