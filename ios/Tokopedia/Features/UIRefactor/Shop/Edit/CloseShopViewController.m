//
//  CloseShopViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 5/9/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "CloseShopViewController.h"
#import "AlertDatePickerView.h"
#import "CloseShopRequest.h"
#import <BlocksKit/BlocksKit.h>
#import "string_alert.h"
#define CENTER_VIEW_NORMAL_HEIGHT 305
#define VIEW_TRANSITION_DELAY 2

typedef NS_ENUM(NSInteger, CenterViewType){
    CenterViewAturJadwalButton,
    CenterViewFormView,
    CenterViewLoadingView,
    CenterViewSuccessView,
    CenterViewFailView
};

typedef NS_ENUM(NSInteger, AlertDatePickerType){
    AlertDatePickerMulaiDari,
    AlertDatePickerSampaiDengan
};

@interface CloseShopViewController ()<TKPDAlertViewDelegate, UIScrollViewDelegate, UITextViewDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UIButton *bukaTokoButton;
@property (strong, nonatomic) IBOutlet UIImageView *shopStatusIndicator;
@property (strong, nonatomic) IBOutlet UILabel *shopStatusLabel;
@property (strong, nonatomic) IBOutlet UILabel *shopScheduleDescriptionLabel;

@property (strong, nonatomic) IBOutlet UILabel *tutupTokoSekarangLabel;
@property (strong, nonatomic) IBOutlet UIImageView *scheduleIcon;
@property (strong, nonatomic) IBOutlet UIView *batalView;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *scrollViewHeight;

@property (strong, nonatomic) IBOutlet UIView *formView;
@property (strong, nonatomic) IBOutlet UIButton *batalButton;
@property (strong, nonatomic) IBOutlet UISwitch *tutupSekarangSwitch;
@property (strong, nonatomic) IBOutlet UIView *mulaiDariView;
@property (strong, nonatomic) IBOutlet UIButton *mulaiDariButton;
@property (strong, nonatomic) IBOutlet UIButton *sampaiDenganButton;
@property (strong, nonatomic) IBOutlet TKPDTextView *catatanTextView;
@property (strong, nonatomic) IBOutlet UIButton *ubahButtonCenter;
@property (strong, nonatomic) IBOutlet UIButton *ubahButtonRight;
@property (strong, nonatomic) IBOutlet UIButton *hapusButton;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UIView *catatanView;
@property (strong, nonatomic) IBOutlet UIView *sampaiDenganView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *hapusButtonWidth;

@property (strong, nonatomic) IBOutlet UIView *centerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *centerViewHeight;

@property (strong, nonatomic) IBOutlet UIView *aturJadwalTutupView;
@property (strong, nonatomic) IBOutlet UIButton *aturJadwalTutupButton;

@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) IBOutlet UIView *successView;
@property (strong, nonatomic) IBOutlet UILabel *catatanTextViewTitle;

@property (strong, nonatomic) IBOutlet UIView *failView;
@property (strong, nonatomic) IBOutlet UILabel *failLabel;

@property (strong, nonatomic) IBOutlet UILabel *explanationLabel;

@property BOOL isFormEnabled;
@end

@implementation CloseShopViewController{
    CloseShopRequest *_closeShopRequest;
    NSDate* _dateMulaiDari;
    NSDate* _dateSampaiDengan;
    BOOL textViewInitialValue;
    UIColor *lightGray;
    UIColor *darkGray;
    UIColor *positiveGreen;
    UIColor *negativeRed;
    UIColor *textGray;
    BOOL isLoading;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _closeShopRequest = [CloseShopRequest new];
    isLoading = NO;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self clearViewData];
    if(![_scheduleDetail.close_start isEqualToString:@""]){
        _dateMulaiDari = [self NSDatefromString:_scheduleDetail.close_start];
    }
    if(![_scheduleDetail.close_end isEqualToString:@""]){
        _dateSampaiDengan = [self NSDatefromString:_scheduleDetail.close_end];
    }
    [self initializeView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [AnalyticsManager trackScreenName:@"Close Shop Page"];
}

-(void)initializeView{
    [_activityIndicator startAnimating];
    [self registerForKeyboardNotifications];
    self.title = @"Status Toko";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Tutup" style: UIBarButtonItemStyleDone target:self action:@selector(didTapBackButton)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    lightGray = [UIColor colorWithRed:0.899 green:0.892 blue:0.899 alpha:1];
    darkGray = [UIColor colorWithRed:0.533 green:0.533 blue:0.533 alpha:1];
    textGray = [UIColor colorWithRed:0.415 green:0.415 blue:0.415 alpha:1];
    positiveGreen = [UIColor colorWithRed:0.206 green:0.684 blue:0.235 alpha:1];
    negativeRed = [UIColor colorWithRed:0.81 green:0.113 blue:0.13 alpha:1];
    
    CGRect mySizeWhenPresented = self.view.frame;
    [_aturJadwalTutupView setFrame:CGRectMake(_aturJadwalTutupView.frame.origin.x,
                                              _aturJadwalTutupView.frame.origin.y,
                                              mySizeWhenPresented.size.width-16,
                                              _aturJadwalTutupView.frame.size.height)];
    [_formView setFrame:CGRectMake(_formView.frame.origin.x,
                                   _formView.frame.origin.y,
                                   mySizeWhenPresented.size.width-16,
                                   _formView.frame.size.height)];
    [_loadingView setFrame:CGRectMake(_loadingView.frame.origin.x,
                                      _loadingView.frame.origin.y,
                                      mySizeWhenPresented.size.width-16,
                                      _loadingView.frame.size.height)];
    [_successView setFrame:CGRectMake(_successView.frame.origin.x,
                                      _successView.frame.origin.y,
                                      mySizeWhenPresented.size.width-16,
                                      _successView.frame.size.height)];
    [_failView setFrame:CGRectMake(_failView.frame.origin.x,
                                   _failView.frame.origin.y,
                                   mySizeWhenPresented.size.width-16,
                                   _failView.frame.size.height)];
    _hapusButtonWidth.constant = _formView.frame.size.width/2-1;
    
    [_scrollView setScrollEnabled:YES];
    _scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1000);
    _scrollViewHeight.constant = [UIScreen mainScreen].bounds.size.height;
    
    CALayer * externalBorder = [CALayer layer];
    externalBorder.frame = CGRectMake(-1, -1, _formView.frame.size.width+2, _formView.frame.size.height+2);
    externalBorder.borderColor = lightGray.CGColor;
    externalBorder.borderWidth = 1.0;
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing              = 5.0f;
    UIFont *font = [UIFont smallTheme];
    NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc]initWithString:_explanationLabel.text];
    [attribString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [_explanationLabel.text length])];
    [attribString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [_explanationLabel.text length])];
    
    _explanationLabel.attributedText = attribString;
    _explanationLabel.numberOfLines = 0;
    [_explanationLabel sizeToFit];
    [_catatanTextView setText:_closedNote];
    [_formView.layer addSublayer:externalBorder];
    _formView.layer.masksToBounds = NO;
    [_tutupSekarangSwitch setOn:NO];
    textViewInitialValue = YES;
    
    [_centerView addSubview:_aturJadwalTutupView];
    [_centerView addSubview:_formView];
    [_centerView addSubview:_loadingView];
    [_centerView addSubview:_successView];
    [_centerView addSubview:_failView];
    if(_scheduleDetail.close_status == CLOSE_STATUS_OPEN){
        _isFormEnabled = YES;
        [self adjustView:CenterViewAturJadwalButton withAnimation:YES];
    }else{
        _isFormEnabled = NO;
        [self adjustView:CenterViewFormView withAnimation:YES];
    }
}
- (IBAction)didTapBackButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Button Action
- (IBAction)aturJadwalTutupButtonTapped:(id)sender {
    _isFormEnabled = YES;
    [self adjustView:CenterViewFormView withAnimation:YES];
}
- (IBAction)batalButtonTapped:(id)sender {
    _isFormEnabled = NO;
    if(_scheduleDetail.close_status == CLOSE_STATUS_OPEN){
        [self adjustView:CenterViewAturJadwalButton withAnimation:YES];
        [self clearViewData];
    }else{
        [self adjustView:CenterViewFormView withAnimation:NO];
    }
    
}
- (IBAction)tutupSekarangSwitchValueChanged:(id)sender {
    if([_tutupSekarangSwitch isOn]){
        _dateMulaiDari = [NSDate date];
        if(_dateSampaiDengan && _dateSampaiDengan < _dateMulaiDari){
            _dateSampaiDengan = nil;
        }
        [self setDateButton];
        [_mulaiDariButton setEnabled:NO];
        [_mulaiDariButton setTitleColor:textGray forState:UIControlStateNormal];
    }else{
        _dateMulaiDari = nil;
        [self setDateButton];
        [_mulaiDariButton setEnabled:YES];
        [_mulaiDariButton setTitleColor:positiveGreen forState:UIControlStateNormal];
    }
}
- (IBAction)mulaiDariButtonTapped:(id)sender {
    AlertDatePickerView *datePicker = [AlertDatePickerView newview];
    datePicker.data = @{kTKPDALERTVIEW_DATATYPEKEY:@(kTKPDALERT_DATAALERTTYPECLOSESHOPKEY)};
    datePicker.tag = AlertDatePickerMulaiDari;
    datePicker.delegate = self;
    datePicker.isSetMinimumDate = YES;
    
    datePicker.startDate = [self addDays:1 toNSDate:[NSDate date]];
    [datePicker show];
}
- (IBAction)sampaiDenganButtonTapped:(id)sender {
    AlertDatePickerView *datePicker = [AlertDatePickerView newview];
    datePicker.data = @{kTKPDALERTVIEW_DATATYPEKEY:@(kTKPDALERT_DATAALERTTYPECLOSESHOPKEY)};
    datePicker.tag = AlertDatePickerSampaiDengan;
    datePicker.delegate = self;
    datePicker.isSetMinimumDate = YES;
    
    if(_dateMulaiDari){
        datePicker.startDate = [self addDays:1 toNSDate:_dateMulaiDari];
    }else{
        datePicker.startDate = [self addDays:1 toNSDate:[NSDate date]];
    }
    [datePicker show];
}
- (IBAction)submitButtonTapped:(id)sender {
    if(!isLoading && [self validateForm]){
        if([_tutupSekarangSwitch isOn]){
            [self closeShopFromNow];
        }else{
            if(_scheduleDetail.close_status == CLOSE_STATUS_OPEN){
                [self createCloseShopSchedule];
            }else if(_scheduleDetail.close_status == CLOSE_STATUS_CLOSED){
                [self extendCloseShopSchedule];
            }else if(_scheduleDetail.close_status == CLOSE_STATUS_CLOSE_SCHEDULED){
                [self createCloseShopSchedule];
            }
        }
    }
}

- (IBAction)ubahButtonCenterTapped:(id)sender {
    _isFormEnabled = YES;
    [self adjustView:CenterViewFormView withAnimation:NO];
}

- (IBAction)ubahButtonRightTapped:(id)sender {
    _isFormEnabled = YES;
    [self adjustView:CenterViewFormView withAnimation:NO];
}

- (IBAction)hapusButtonTapped:(id)sender {
    if(!isLoading){
        [self abortCloseShopSchedule];
    }
}

- (IBAction)bukaTokoTapped:(id)sender {
    if(!isLoading){
        [self openShop];
    }
}

- (BOOL)validateForm{
    BOOL isValidationSuccess = YES;
    if(_dateMulaiDari == nil){
        [_mulaiDariButton setTitleColor:negativeRed forState:UIControlStateNormal];
        isValidationSuccess = NO;
    }else{
        [_mulaiDariButton setTitleColor:positiveGreen forState:UIControlStateNormal];
    }
    
    if(_dateSampaiDengan == nil){
        [_sampaiDenganButton setTitleColor:negativeRed forState:UIControlStateNormal];
        isValidationSuccess = NO;
    }else{
        [_sampaiDenganButton setTitleColor:positiveGreen forState:UIControlStateNormal];
    }
    
    if(_catatanTextView.text == nil || [_catatanTextView.text isEqualToString:@""]){
        [_catatanTextViewTitle setTextColor:negativeRed];
        isValidationSuccess = NO;
    }else{
        [_catatanTextViewTitle setTextColor:textGray];
    }
    
    return isValidationSuccess;
}

#pragma mark - Request Method
- (void)closeShopFromNow{
    isLoading = YES;
    [self adjustView:CenterViewLoadingView withAnimation:NO];
    [_closeShopRequest requestActionCloseShopFromNowUntil:[self stringFromNSDate:_dateSampaiDengan]
                                                closeNote:_catatanTextView.text
                                                onSuccess:^(CloseShopResponse *result) {
                                                    if([result.data.is_success isEqualToString:@"1"]){
                                                        _scheduleDetail.close_status = CLOSE_STATUS_CLOSED;
                                                        _scheduleDetail.close_start = [self stringFromNSDate:_dateMulaiDari];
                                                        _scheduleDetail.close_end = [self stringFromNSDate:_dateSampaiDengan];
                                                        _isFormEnabled = NO;
                                                        [self adjustView:CenterViewSuccessView withAnimation:NO];
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_EDITSHOPPOSTNOTIFICATIONNAMEKEY
                                                                                                            object:nil
                                                                                                          userInfo:nil];
                                                    }else{
                                                        [self setFailLabelTextWithError:result.message_error];
                                                        [self adjustView:CenterViewFailView withAnimation:NO];
                                                    }
                                                    
                                                    [self.delegate didChangeShopStatus];
                                                    [self returnToFormViewWithDelay];
                                                    [_tutupSekarangSwitch setOn:NO];
                                                    isLoading = NO;
                                                }
                                                onFailure:^(NSError *error) {
                                                    [self setFailLabelTextWithError:@[@"Kendala koneksi internet"]];
                                                    [self adjustView:CenterViewFailView withAnimation:NO];
                                                    isLoading = NO;
                                                }];
}

-(void)createCloseShopSchedule{
    isLoading = YES;
    [self adjustView:CenterViewLoadingView withAnimation:NO];
    [_closeShopRequest requestActionCloseShopFrom:[self stringFromNSDate:_dateMulaiDari]
                                            until:[self stringFromNSDate:_dateSampaiDengan]
                                        closeNote:_catatanTextView.text
                                        onSuccess:^(CloseShopResponse *result) {
                                            if([result.data.is_success isEqualToString:@"1"]){
                                                _scheduleDetail.close_status = CLOSE_STATUS_CLOSE_SCHEDULED;
                                                _scheduleDetail.close_start = [self stringFromNSDate:_dateMulaiDari];
                                                _scheduleDetail.close_end = [self stringFromNSDate:_dateSampaiDengan];
                                                _isFormEnabled = NO;
                                                [self adjustView:CenterViewSuccessView withAnimation:NO];
                                                [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_EDITSHOPPOSTNOTIFICATIONNAMEKEY
                                                                                                    object:nil
                                                                                                  userInfo:nil];
                                            }else{
                                                [self setFailLabelTextWithError:result.message_error];
                                                [self adjustView:CenterViewFailView withAnimation:NO];
                                            }
                                            [self.delegate didChangeShopStatus];
                                            [self returnToFormViewWithDelay];
                                            isLoading = NO;
                                        }
                                        onFailure:^(NSError *error) {
                                            [self setFailLabelTextWithError:@[@"Kendala koneksi internet"]];
                                            [self adjustView:CenterViewFailView withAnimation:NO];
                                            
                                            [self returnToFormViewWithDelay];
                                            isLoading = NO;
                                        }];
}

-(void)extendCloseShopSchedule{
    isLoading = YES;
    [self adjustView:CenterViewLoadingView withAnimation:NO];
    [_closeShopRequest requestActionExtendCloseShopUntil:[self stringFromNSDate:_dateSampaiDengan]
                                               closeNote:_catatanTextView.text
                                               onSuccess:^(CloseShopResponse *result) {
                                                   if([result.data.is_success isEqualToString:@"1"]){
                                                       _scheduleDetail.close_status = CLOSE_STATUS_CLOSED;
                                                       _scheduleDetail.close_start = [self stringFromNSDate:_dateMulaiDari];
                                                       _scheduleDetail.close_end = [self stringFromNSDate:_dateSampaiDengan];
                                                       _isFormEnabled = NO;
                                                       [self adjustView:CenterViewSuccessView withAnimation:NO];
                                                       [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_EDITSHOPPOSTNOTIFICATIONNAMEKEY
                                                                                                           object:nil
                                                                                                         userInfo:nil];
                                                   }else{
                                                       [self setFailLabelTextWithError:result.message_error];
                                                       [self adjustView:CenterViewFailView withAnimation:NO];
                                                   }
                                                   [self.delegate didChangeShopStatus];
                                                   [self returnToFormViewWithDelay];
                                                   isLoading = NO;
                                               } onFailure:^(NSError *error) {
                                                   [self setFailLabelTextWithError:@[@"Kendala koneksi internet"]];
                                                   [self adjustView:CenterViewFailView withAnimation:NO];
                                                   
                                                   [self returnToFormViewWithDelay];
                                                   isLoading = NO;
                                               }];
}

-(void)abortCloseShopSchedule{
    isLoading = YES;
    [self adjustView:CenterViewLoadingView withAnimation:NO];
    [_closeShopRequest requestActionAbortCloseScheduleOnSuccess:^(CloseShopResponse *result) {
        if([result.data.is_success isEqualToString:@"1"]){
            _scheduleDetail.close_status = CLOSE_STATUS_OPEN;
            _scheduleDetail.close_start = [self stringFromNSDate:_dateMulaiDari];
            _scheduleDetail.close_end = [self stringFromNSDate:_dateSampaiDengan];
            _isFormEnabled = YES;
            [self clearViewData];
            [self adjustView:CenterViewSuccessView withAnimation:NO];
            [self.delegate didChangeShopStatus];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_EDITSHOPPOSTNOTIFICATIONNAMEKEY
                                                                object:nil
                                                              userInfo:nil];
        }else{
            [self setFailLabelTextWithError:result.message_error];
            [self adjustView:CenterViewFailView withAnimation:NO];
        }
        [self returnToFormViewWithDelay];
        isLoading = NO;
    } onFailure:^(NSError *error) {
        [self setFailLabelTextWithError:@[@"Kendala koneksi internet"]];
        [self adjustView:CenterViewFailView withAnimation:NO];
        
        [self returnToFormViewWithDelay];
        isLoading = NO;
    }];
}

-(void)openShop{
    isLoading = YES;
    [self adjustView:CenterViewLoadingView withAnimation:YES];
    [_closeShopRequest requestActionOpenShopOnSuccess:^(CloseShopResponse *result) {
        if([result.data.is_success isEqualToString:@"1"]){
            _scheduleDetail.close_status = CLOSE_STATUS_OPEN;
            [self clearViewData];
            
            _isFormEnabled = YES;
            [self adjustView:CenterViewSuccessView withAnimation:YES];
            [self.delegate didChangeShopStatus];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_EDITSHOPPOSTNOTIFICATIONNAMEKEY
                                                                object:nil
                                                              userInfo:nil];
        }else{
            [self setFailLabelTextWithError:result.message_error];
            [self adjustView:CenterViewFailView withAnimation:NO];
        }
        [self returnToFormViewWithDelay];
        
        isLoading = NO;
    } onFailure:^(NSError *error) {
        [self setFailLabelTextWithError:@[@"Kendala koneksi internet"]];
        [self adjustView:CenterViewFailView withAnimation:NO];
        
        [self returnToFormViewWithDelay];
        isLoading = NO;
    }];

}

#pragma mark - Date Picker Delegate
-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSDate *date = [alertView.data objectForKey:@"datepicker"];
    if(alertView.tag == AlertDatePickerMulaiDari){
        _dateMulaiDari = date;
        if(_dateSampaiDengan && ([_dateSampaiDengan compare:_dateMulaiDari] == NSOrderedAscending)){
            _dateSampaiDengan = nil;
        }
        [self setDateButton];
        [_mulaiDariButton setTitleColor:positiveGreen forState:UIControlStateNormal];
    }else if(alertView.tag == AlertDatePickerSampaiDengan){
        _dateSampaiDengan = date;
        [self setDateButton];
        [_sampaiDenganButton setTitleColor:positiveGreen forState:UIControlStateNormal];
    }
}

-(NSString*)stringFromNSDate:(NSDate*)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/YYYY"];
    return [formatter stringFromDate:date];
}

-(NSDate*)NSDatefromString:(NSString*)date{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    }
    return [dateFormatter dateFromString:date];
}

-(NSDate*)addDays:(NSInteger)days toNSDate:(NSDate*)date{
    return [date dateByAddingTimeInterval:60*60*24*days];
}

-(void)setDateButton{
    if(_dateMulaiDari){
        [_mulaiDariButton setTitle:[self stringFromNSDate:_dateMulaiDari]
                          forState:UIControlStateNormal];
    }else{
        [_mulaiDariButton setTitle:@"Pilih Tanggal"
                          forState:UIControlStateNormal];
    }
    if(_dateSampaiDengan){
        [_sampaiDenganButton setTitle:[self stringFromNSDate:_dateSampaiDengan]
                             forState:UIControlStateNormal];
    }else{
        [_sampaiDenganButton setTitle:@"Pilih Tanggal"
                             forState:UIControlStateNormal];
    }
}

#pragma mark - TextView Delegate

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        NSDictionary* info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        _scrollView.contentInset = contentInsets;
        _scrollView.scrollIndicatorInsets = contentInsets;
        
        CGRect aRect = self.view.frame;
        aRect.size.height -= kbSize.height;
        if (!CGRectContainsPoint(aRect, _catatanTextView.frame.origin) ) {
            CGPoint scrollPoint = CGPointMake(0.0, _catatanTextView.frame.origin.y+kbSize.height );
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
}

# pragma mark - Toggle View
- (void)adjustView:(CenterViewType)centerViewType withAnimation:(BOOL)useAnimation{
    if(centerViewType == CenterViewAturJadwalButton){
        _centerViewHeight.constant = _aturJadwalTutupView.frame.size.height;
        [_aturJadwalTutupView setHidden:NO];
        [_formView setHidden:YES];
        [_loadingView setHidden:YES];
        [_successView setHidden:YES];
        [_failView setHidden:YES];
        _centerViewHeight.constant = _aturJadwalTutupView.frame.size.height;
        [_centerView bringSubviewToFront:_aturJadwalTutupView];
        
        if(useAnimation){
            [_centerView setAlpha:0];
            [UIView animateWithDuration:0.6f animations:^{
                [_centerView setAlpha:1];
            }];
            useAnimation = NO;
        }
        
    }else if(centerViewType == CenterViewFormView){
        if(_isFormEnabled){
            _centerViewHeight.constant = _formView.frame.size.height - 1;
        }else{
            _centerViewHeight.constant = _formView.frame.size.height - _batalView.frame.size.height - 10;
        }
        [_aturJadwalTutupView setHidden:YES];
        [_formView setHidden:NO];
        [_loadingView setHidden:YES];
        [_successView setHidden:YES];
        [_failView setHidden:YES];
        [_centerView bringSubviewToFront:_formView];
        
        if(useAnimation){
            [_centerView setAlpha:0];
            [UIView animateWithDuration:0.6f animations:^{
                [_centerView setAlpha:1];
            }];
            useAnimation = NO;
        }
    }else if(centerViewType == CenterViewLoadingView){
        _centerViewHeight.constant = _loadingView.frame.size.height;
        [_aturJadwalTutupView setHidden:YES];
        [_formView setHidden:YES];
        [_loadingView setHidden:NO];
        [_successView setHidden:YES];
        [_failView setHidden:YES];
        [_centerView bringSubviewToFront:_loadingView];
    }else if(centerViewType == CenterViewSuccessView){
        _centerViewHeight.constant = _successView.frame.size.height;
        [_aturJadwalTutupView setHidden:YES];
        [_formView setHidden:YES];
        [_loadingView setHidden:YES];
        [_successView setHidden:NO];
        [_failView setHidden:YES];
        [_centerView bringSubviewToFront:_successView];
    }else if(centerViewType == CenterViewFailView){
        _centerViewHeight.constant = _failView.frame.size.height;
        [_aturJadwalTutupView setHidden:YES];
        [_formView setHidden:YES];
        [_loadingView setHidden:YES];
        [_successView setHidden:YES];
        [_failView setHidden:NO];
        [_centerView bringSubviewToFront:_successView];
    }else{
        [self adjustView:CenterViewAturJadwalButton withAnimation:NO];
    }
    
    //DESIGN CENTER VIEW
    if(_scheduleDetail.close_status == CLOSE_STATUS_OPEN){
        _tutupTokoSekarangLabel.text = @"Tutup Toko Sekarang";
        [_tutupSekarangSwitch setHidden:NO];
        [_scheduleIcon setHidden:YES];
        
        //button in form footer
        [_submitButton setHidden:NO];
        [_hapusButton setHidden:YES];
        [_ubahButtonRight setHidden:YES];
        [_ubahButtonCenter setHidden:YES];
        
        _shopStatusLabel.text = @"Buka";
        _shopStatusIndicator.image = [UIImage imageNamed:@"icon_open.png"];
        _shopScheduleDescriptionLabel.text = @"Tidak ada jadwal";
        
        //button buka toko
        [_bukaTokoButton setEnabled:NO];
        [_bukaTokoButton setBackgroundColor:lightGray];
        
    }else if(_scheduleDetail.close_status == CLOSE_STATUS_CLOSED){
        _tutupTokoSekarangLabel.text = @"JADWAL TUTUP";
        [_tutupSekarangSwitch setHidden:YES];
        [_scheduleIcon setHidden:NO];
        [_scheduleIcon setImage:[UIImage imageNamed:@"icon_time_green.png"]];
        
        //button in form footer
        if(_isFormEnabled){
            [_submitButton setHidden:NO];
            [_hapusButton setHidden:YES];
            [_ubahButtonRight setHidden:YES];
            [_ubahButtonCenter setHidden:YES];
        }else{
            [_submitButton setHidden:YES];
            [_hapusButton setHidden:YES];
            [_ubahButtonRight setHidden:YES];
            [_ubahButtonCenter setHidden:NO];
        }
        
        _shopStatusLabel.text = @"Tutup";
        _shopStatusIndicator.image = [UIImage imageNamed:@"icon_closed.png"];
        _shopScheduleDescriptionLabel.text = [NSString stringWithFormat:@"Sampai dengan %@, 23:59 WIB", _scheduleDetail.close_end];
        
        //button buka toko
        [_bukaTokoButton setEnabled:YES];
        [_bukaTokoButton setBackgroundColor:positiveGreen];
        
        [_mulaiDariButton setTitle:_scheduleDetail.close_start forState:UIControlStateNormal];
        [_sampaiDenganButton setTitle:_scheduleDetail.close_end forState:UIControlStateNormal];
    }else{
        //OPEN WITH CLOSE SCHEDULE
        _tutupTokoSekarangLabel.text = @"JADWAL TUTUP";
        [_tutupSekarangSwitch setHidden:YES];
        [_scheduleIcon setHidden:NO];
        [_scheduleIcon setImage:[UIImage imageNamed:@"icon_time_grey.png"]];
        
        //button in form footer
        if(_isFormEnabled){
            [_submitButton setHidden:NO];
            [_hapusButton setHidden:YES];
            [_ubahButtonRight setHidden:YES];
            [_ubahButtonCenter setHidden:YES];
        }else{
            [_submitButton setHidden:YES];
            [_hapusButton setHidden:NO];
            [_ubahButtonRight setHidden:NO];
            [_ubahButtonCenter setHidden:YES];
        }
        
        _shopStatusLabel.text = @"Buka";
        _shopStatusIndicator.image = [UIImage imageNamed:@"icon_open.png"];
        _shopScheduleDescriptionLabel.text = [NSString stringWithFormat:@"Jadwal Tutup %@", _scheduleDetail.close_start];
        
        //button buka toko
        [_bukaTokoButton setEnabled:NO];
        [_bukaTokoButton setBackgroundColor:lightGray];
        
        [_mulaiDariButton setTitle:_scheduleDetail.close_start forState:UIControlStateNormal];
        [_sampaiDenganButton setTitle:_scheduleDetail.close_end forState:UIControlStateNormal];
    }
    
    //SETTING BUTTON BATAL
    if(_isFormEnabled){
        if(_scheduleDetail.close_status == CLOSE_STATUS_CLOSED){
            [_mulaiDariButton setEnabled:NO];
            [_mulaiDariButton setTitleColor:darkGray forState:UIControlStateNormal];
        }else{
            [_mulaiDariButton setEnabled:YES];
            [_mulaiDariButton setTitleColor:positiveGreen forState:UIControlStateNormal];
        }
        [_sampaiDenganButton setEnabled:YES];
        _catatanTextView.editable = YES;
        [_sampaiDenganButton setTitleColor:positiveGreen forState:UIControlStateNormal];
        [_catatanTextView setTextColor:[UIColor blackColor]];
        
    }else{
        [_mulaiDariButton setEnabled:NO];
        [_sampaiDenganButton setEnabled:NO];
        _catatanTextView.editable = NO;
        
        [_mulaiDariButton setTitleColor:textGray forState:UIControlStateNormal];
        [_sampaiDenganButton setTitleColor:textGray forState:UIControlStateNormal];
        [_catatanTextView setTextColor:textGray];
    }
}

- (void)returnToFormViewWithDelay{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(VIEW_TRANSITION_DELAY * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self adjustView:CenterViewFormView withAnimation:NO];
    });
}

- (void)setFailLabelTextWithError:(NSArray *)texts{
    NSString *joinedString = @"";
    if ([texts count] > 1) {
        joinedString = [NSString stringWithFormat:@"\u25CF %@", [[texts valueForKey:@"description"] componentsJoinedByString:@"\n\u25CF "]];
    } else if ([texts count] == 1){
        joinedString = [texts objectAtIndex:0]?:@"";
    } else {
        joinedString = @"";
    }
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment                = NSTextAlignmentCenter;
    paragraphStyle.lineSpacing              = 5.0f;
    
    joinedString = [NSString convertHTML:joinedString];
    UIFont *font = [UIFont largeThemeMedium];
    
    NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc]initWithString:joinedString];
    [attribString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [joinedString length])];
    [attribString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [joinedString length])];
    
    _failLabel.attributedText = attribString;
    _failLabel.numberOfLines = 0;
}

- (void)clearViewData {
    _dateMulaiDari = nil;
    _dateSampaiDengan = nil;
    [self setDateButton];
    _catatanTextView.text = @"";
    [_tutupSekarangSwitch setOn:NO];
}
@end
