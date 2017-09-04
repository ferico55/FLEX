//
//  EditDailyLimitView.h
//  BCAXCOWidget
//
//  Created by PT Bank Central Asia Tbk on 7/25/16.
//  Copyright © 2016 PT Bank Central Asia Tbk. All rights reserved.
//

#import "BCAXCOWidget.h"
#import "InsertOTPView.h"
#import "BCADelegate.h"

@interface EditDailyLimitView : BaseView <UITextFieldDelegate>

@property (nonatomic, weak) id <BCADelegate> delegate;

@property (strong, nonatomic) NSString *limitHarianString;

@property (weak, nonatomic) IBOutlet UILabel *cardNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *nomorKartuLabel;
@property (weak, nonatomic) IBOutlet UILabel *limitHarianLabel;
@property (weak, nonatomic) IBOutlet UILabel *limittextLabel;
@property (weak, nonatomic) IBOutlet UITextField *limitTextField;
@property (weak, nonatomic) IBOutlet UIView *infoLimitView;
@property (weak, nonatomic) IBOutlet UIView *backgroundLimitView;
@property (weak, nonatomic) IBOutlet UILabel *infoLimitLabel;
@property (weak, nonatomic) IBOutlet UIButton *clearLimitTextButton;
//@property (weak, nonatomic) IBOutlet UILabel *boldLabel;
@property (weak, nonatomic) IBOutlet XCOButton *nextButton;

@property (weak, nonatomic) UIView *masterView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;


@property (nonatomic) InsertOTPView *insertOTPView;

- (IBAction)nextButton:(UIButton *)sender;

- (IBAction)helpButton:(UIButton *)sender;

- (IBAction)infoLimitButtonAction:(UIButton *)sender;

- (IBAction)backgroundTapAction:(UITapGestureRecognizer *)sender;

- (IBAction)okInfoLimitButtonAction:(UIButton *)sender;

- (IBAction)clearLimitTextButtonAction:(UIButton *)sender;

- (void) removeView;


@end
