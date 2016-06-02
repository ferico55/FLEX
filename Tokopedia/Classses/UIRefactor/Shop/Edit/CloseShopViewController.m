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

@interface CloseShopViewController ()<TKPDAlertViewDelegate, UIScrollViewDelegate, UITextViewDelegate>
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

@property (strong, nonatomic) IBOutlet UIView *centerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *centerViewHeight;

@property (strong, nonatomic) IBOutlet UIView *aturJadwalTutupView;
@property (strong, nonatomic) IBOutlet UIButton *aturJadwalTutupButton;

@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) IBOutlet UIView *successView;

@property (strong, nonatomic) IBOutlet UIView *failView;
@property (strong, nonatomic) IBOutlet UILabel *failLabel;

@property (strong, nonatomic) IBOutlet UILabel *explanationLabel;

@property CenterViewType centerViewType;
@property BOOL isFormEnabled;
@end

@implementation CloseShopViewController{
    CloseShopRequest *_closeShopRequest;
    NSDate* _dateMulaiDari;
    NSDate* _dateSampaiDengan;
    BOOL textViewInitialValue;
    BOOL useAnimation;
    UIColor *lightGray;
    UIColor *darkGray;
    UIColor *positiveGreen;
    UIColor *negativeRed;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _closeShopRequest = [CloseShopRequest new];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if(_scheduleDetail.close_start && ![_scheduleDetail.close_start isEqualToString:@""]){
        _dateMulaiDari = [self NSDatefromString:_scheduleDetail.close_start];
    }
    if(_scheduleDetail.close_end && ![_scheduleDetail.close_end isEqualToString:@""]){
        _dateSampaiDengan = [self NSDatefromString:_scheduleDetail.close_end];
    }
    
    [self initializeView];
}

-(void)initializeView{
    [_activityIndicator startAnimating];
    [self registerForKeyboardNotifications];
    
    lightGray = [UIColor colorWithRed:0.882 green:0.882 blue:0.882 alpha:1];
    darkGray = [UIColor colorWithRed:0.533 green:0.533 blue:0.533 alpha:1];
    positiveGreen = [UIColor colorWithRed:0.206 green:0.684 blue:0.235 alpha:1];
    negativeRed = [UIColor colorWithRed:1 green:0.912 blue:0.912 alpha:1];
    
    //self.scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [_scrollView setScrollEnabled:YES];
    _scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1000);
    _scrollViewHeight.constant = [UIScreen mainScreen].bounds.size.height;
    
    CALayer * externalBorder = [CALayer layer];
    externalBorder.frame = CGRectMake(-1, -1, _formView.frame.size.width+2, _formView.frame.size.height+2);
    //externalBorder.borderColor = [UIColor colorWithRed:0.914 green:0.914 blue:0.914 alpha:1].CGColor;
    externalBorder.borderColor = darkGray.CGColor;
    externalBorder.borderWidth = 1.0;
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing              = 5.0f;
    
    UIFont *gothamTwelve = [UIFont fontWithName:@"GothamBook" size:12.0f];
    
    NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc]initWithString:_explanationLabel.text];
    [attribString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [_explanationLabel.text length])];
    [attribString addAttribute:NSFontAttributeName value:gothamTwelve range:NSMakeRange(0, [_explanationLabel.text length])];
    
    _explanationLabel.attributedText = attribString;
    _explanationLabel.numberOfLines = 0;
    [_explanationLabel sizeToFit];

    [_catatanTextView setText:_closedNote];
    
    [_formView.layer addSublayer:externalBorder];
    _formView.layer.masksToBounds = NO;
    [_tutupSekarangSwitch setOn:NO];
    
    if(_scheduleDetail.close_status == CLOSE_STATUS_OPEN){
        _centerViewType = CenterViewAturJadwalButton;
        _isFormEnabled = YES;
    }else{
        _centerViewType = CenterViewFormView;
        _isFormEnabled = NO;
    }
    
    textViewInitialValue = YES;
    
    [_centerView addSubview:_aturJadwalTutupView];
    [_centerView addSubview:_formView];
    [_centerView addSubview:_loadingView];
    [_centerView addSubview:_successView];
    [_centerView addSubview:_failView];
    useAnimation = YES;
    [self adjustView];
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
    // Dispose of any resources that can be recreated.
}


#pragma mark - Button Action
- (IBAction)aturJadwalTutupButtonTapped:(id)sender {
    _centerViewType = CenterViewFormView;
    _isFormEnabled = YES;
    useAnimation = YES;
    [self adjustView];
}
- (IBAction)batalButtonTapped:(id)sender {
    _isFormEnabled = NO;
    if(_scheduleDetail.close_status == CLOSE_STATUS_OPEN){
        _centerViewType = CenterViewAturJadwalButton;
        useAnimation = YES;
    }
    [self adjustView];
}
- (IBAction)tutupSekarangSwitchValueChanged:(id)sender {
    if([_tutupSekarangSwitch isOn]){
        _dateMulaiDari = [NSDate date];
        if(_dateSampaiDengan && _dateSampaiDengan < _dateMulaiDari){
            _dateSampaiDengan = nil;
        }
        [self setDateButton];
        [_mulaiDariButton setEnabled:NO];
    }else{
        [_mulaiDariButton setEnabled:YES];
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
    if([self validateForm]){
        _centerViewType = CenterViewLoadingView;
        [self adjustView];
        if([_tutupSekarangSwitch isOn]){
            [_closeShopRequest requestActionCloseShopFromNowUntil:[self stringFromNSDate:_dateSampaiDengan]
                                                        closeNote:_catatanTextView.text
                                                        onSuccess:^(CloseShopResponse *result) {
                                                            if(result.data.is_success){
                                                                _centerViewType = CenterViewSuccessView;
                                                                _scheduleDetail.close_status = CLOSE_STATUS_CLOSED;
                                                                _scheduleDetail.close_start = [self stringFromNSDate:_dateMulaiDari];
                                                                _scheduleDetail.close_end = [self stringFromNSDate:_dateSampaiDengan];
                                                                _isFormEnabled = NO;
                                                                [self adjustView];
                                                            }else{
                                                                _centerViewType = CenterViewFailView;
                                                                [self setFailLabelTextWithError:result.message_error];
                                                                [self adjustView];
                                                            }
                                                            
                                                            [self.delegate didChangeShopStatus];
                                                            
                                                            _centerViewType = CenterViewFormView;
                                                            [self performSelector:@selector(adjustView) withObject:nil afterDelay:VIEW_TRANSITION_DELAY];
                                                            [_tutupSekarangSwitch setOn:NO];
                                                        }
                                                        onFailure:^(NSError *error) {
                                                            _centerViewType = CenterViewFailView;
                                                            [self setFailLabelTextWithError:@[@"Kendala koneksi internet"]];
                                                            [self adjustView];
                                                            
                                                            _centerViewType = CenterViewFormView;
                                                            [self performSelector:@selector(adjustView) withObject:nil afterDelay:VIEW_TRANSITION_DELAY];
                                                        }];
        }else{
            if(_scheduleDetail.close_status == CLOSE_STATUS_OPEN){
                [_closeShopRequest requestActionCloseShopFrom:[self stringFromNSDate:_dateMulaiDari]
                                                        until:[self stringFromNSDate:_dateSampaiDengan]
                                                    closeNote:_catatanTextView.text
                                                    onSuccess:^(CloseShopResponse *result) {
                                                        if(result.data.is_success){
                                                            _centerViewType = CenterViewSuccessView;
                                                            _scheduleDetail.close_status = CLOSE_STATUS_CLOSE_SCHEDULED;
                                                            _scheduleDetail.close_start = [self stringFromNSDate:_dateMulaiDari];
                                                            _scheduleDetail.close_end = [self stringFromNSDate:_dateSampaiDengan];
                                                            _isFormEnabled = NO;
                                                            [self adjustView];
                                                        }else{
                                                            _centerViewType = CenterViewFailView;
                                                            [self setFailLabelTextWithError:result.message_error];
                                                            [self adjustView];
                                                        }
                                                        [self.delegate didChangeShopStatus];
                                                        _centerViewType = CenterViewFormView;
                                                        [self performSelector:@selector(adjustView) withObject:nil afterDelay:VIEW_TRANSITION_DELAY];
                                                    }
                                                    onFailure:^(NSError *error) {
                                                        _centerViewType = CenterViewFailView;
                                                        [self setFailLabelTextWithError:@[@"Kendala koneksi internet"]];
                                                        [self adjustView];
                                                        
                                                        _centerViewType = CenterViewFormView;
                                                        [self performSelector:@selector(adjustView) withObject:nil afterDelay:VIEW_TRANSITION_DELAY];
                                                    }];
            }else if(_scheduleDetail.close_status == CLOSE_STATUS_CLOSED){
                [_closeShopRequest requestActionExtendCloseShopUntil:[self stringFromNSDate:_dateSampaiDengan]
                                                           closeNote:_catatanTextView.text
                                                           onSuccess:^(CloseShopResponse *result) {
                                                               if(result.data.is_success){
                                                                   _centerViewType = CenterViewSuccessView;
                                                                   _scheduleDetail.close_status = CLOSE_STATUS_CLOSED;
                                                                   _scheduleDetail.close_start = [self stringFromNSDate:_dateMulaiDari];
                                                                   _scheduleDetail.close_end = [self stringFromNSDate:_dateSampaiDengan];
                                                                   _isFormEnabled = NO;
                                                                   [self adjustView];
                                                               }else{
                                                                   _centerViewType = CenterViewFailView;
                                                                   [self setFailLabelTextWithError:result.message_error];
                                                                   [self adjustView];
                                                               }
                                                               [self.delegate didChangeShopStatus];
                                                               _centerViewType = CenterViewFormView;
                                                               [self performSelector:@selector(adjustView) withObject:nil afterDelay:VIEW_TRANSITION_DELAY];
                                                           } onFailure:^(NSError *error) {
                                                               _centerViewType = CenterViewFailView;
                                                               [self setFailLabelTextWithError:@[@"Kendala koneksi internet"]];
                                                               [self adjustView];
                                                               
                                                               _centerViewType = CenterViewFormView;
                                                               [self performSelector:@selector(adjustView) withObject:nil afterDelay:VIEW_TRANSITION_DELAY];
                                                           }];
            }else if(_scheduleDetail.close_status == CLOSE_STATUS_CLOSE_SCHEDULED){
                [_closeShopRequest requestActionCloseShopFrom:[self stringFromNSDate:_dateMulaiDari]
                                                        until:[self stringFromNSDate:_dateSampaiDengan]
                                                    closeNote:_catatanTextView.text
                                                    onSuccess:^(CloseShopResponse *result) {
                                                        if(result.data.is_success){
                                                            _centerViewType = CenterViewSuccessView;
                                                            _scheduleDetail.close_status = CLOSE_STATUS_CLOSE_SCHEDULED;
                                                            _scheduleDetail.close_start = [self stringFromNSDate:_dateMulaiDari];
                                                            _scheduleDetail.close_end = [self stringFromNSDate:_dateSampaiDengan];
                                                            _isFormEnabled = NO;
                                                            [self adjustView];
                                                        }else{
                                                            _centerViewType = CenterViewFailView;
                                                            [self setFailLabelTextWithError:result.message_error];
                                                            [self adjustView];
                                                        }
                                                        [self.delegate didChangeShopStatus];
                                                        _centerViewType = CenterViewFormView;
                                                        [self performSelector:@selector(adjustView) withObject:nil afterDelay:VIEW_TRANSITION_DELAY];
                                                    } onFailure:^(NSError *error) {
                                                        
                                                    }];
            }
        }
    }
}

- (IBAction)ubahButtonCenterTapped:(id)sender {
    _isFormEnabled = YES;
    [self adjustView];
}

- (IBAction)ubahButtonRightTapped:(id)sender {
    _isFormEnabled = YES;
    [self adjustView];
}

- (IBAction)hapusButtonTapped:(id)sender {
    _centerViewType = CenterViewLoadingView;
    [self adjustView];
    
    [_closeShopRequest requestActionAbortCloseScheduleOnSuccess:^(CloseShopResponse *result) {
        if(result.data.is_success){
            _centerViewType = CenterViewSuccessView;
            _scheduleDetail.close_status = CLOSE_STATUS_OPEN;
            _scheduleDetail.close_start = [self stringFromNSDate:_dateMulaiDari];
            _scheduleDetail.close_end = [self stringFromNSDate:_dateSampaiDengan];
            _isFormEnabled = YES;
            [self adjustView];
        }else{
            _centerViewType = CenterViewFailView;
            [self setFailLabelTextWithError:result.message_error];
            [self adjustView];
        }
        
        _centerViewType = CenterViewFormView;
        [self performSelector:@selector(adjustView) withObject:nil afterDelay:VIEW_TRANSITION_DELAY];

    } onFailure:^(NSError *error) {
        _centerViewType = CenterViewFailView;
        [self setFailLabelTextWithError:@[@"Kendala koneksi internet"]];
        [self adjustView];
        
        _centerViewType = CenterViewFormView;
        [self performSelector:@selector(adjustView) withObject:nil afterDelay:VIEW_TRANSITION_DELAY];
    }];
}

- (IBAction)bukaTokoTapped:(id)sender {
    useAnimation = YES;
    _centerViewType = CenterViewLoadingView;
    [self adjustView];
    [_closeShopRequest requestActionOpenShopOnSuccess:^(CloseShopResponse *result) {
        if(result.data.is_success){
            _scheduleDetail.close_status = CLOSE_STATUS_OPEN;
            _isFormEnabled = YES;
            
            useAnimation = YES;
            _centerViewType = CenterViewSuccessView;
            [self adjustView];
        }else{
            _centerViewType = CenterViewFailView;
            [self setFailLabelTextWithError:result.message_error];
            [self adjustView];
        }
        [self.delegate didChangeShopStatus];
        _centerViewType = CenterViewFormView;
        [self performSelector:@selector(adjustView) withObject:nil afterDelay:VIEW_TRANSITION_DELAY];
    } onFailure:^(NSError *error) {
        _centerViewType = CenterViewFailView;
        [self setFailLabelTextWithError:@[@"Kendala koneksi internet"]];
        [self adjustView];
        
        _centerViewType = CenterViewFormView;
        [self performSelector:@selector(adjustView) withObject:nil afterDelay:VIEW_TRANSITION_DELAY];

    }];
}

- (BOOL)validateForm{
    BOOL isValidationSuccess = YES;
    if(_dateMulaiDari == nil){
        [_mulaiDariView setBackgroundColor:negativeRed];
        isValidationSuccess = NO;
    }else{
        [_mulaiDariView setBackgroundColor:[UIColor whiteColor]];
    }
    
    if(_dateSampaiDengan == nil){
        [_sampaiDenganView setBackgroundColor:negativeRed];
        isValidationSuccess = NO;
    }else{
        [_sampaiDenganView setBackgroundColor:[UIColor whiteColor]];
    }
    
    if(_catatanTextView.text == nil || [_catatanTextView.text isEqualToString:@""]){
        [_catatanView setBackgroundColor:negativeRed];
        [_catatanTextView setBackgroundColor:negativeRed];
        isValidationSuccess = NO;
    }else{
        [_catatanView setBackgroundColor:[UIColor whiteColor]];
        [_catatanTextView setBackgroundColor:[UIColor whiteColor]];
    }
    
    return isValidationSuccess;
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
    }else if(alertView.tag == AlertDatePickerSampaiDengan){
        _dateSampaiDengan = date;
        [self setDateButton];
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

-(void)textViewDidBeginEditing:(UITextView *)textView{
    if(textViewInitialValue){
        [_catatanTextView setText:@""];
        textViewInitialValue = NO;
    }
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, _catatanTextView.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, _catatanTextView.frame.origin.y+kbSize.height);
        [_scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - ScrollView delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
}

# pragma mark - Toggle View
- (void)adjustView{
    if(_centerViewType == CenterViewAturJadwalButton){
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
        
    }else if(_centerViewType == CenterViewFormView){
        if(_isFormEnabled){
            _centerViewHeight.constant = _formView.frame.size.height;
        }else{
            _centerViewHeight.constant = _formView.frame.size.height - _batalView.frame.size.height - 6;
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
    }else if(_centerViewType == CenterViewLoadingView){
        _centerViewHeight.constant = _loadingView.frame.size.height;
        [_aturJadwalTutupView setHidden:YES];
        [_formView setHidden:YES];
        [_loadingView setHidden:NO];
        [_successView setHidden:YES];
        [_failView setHidden:YES];
        [_centerView bringSubviewToFront:_loadingView];
    }else if(_centerViewType == CenterViewSuccessView){
        _centerViewHeight.constant = _successView.frame.size.height;
        [_aturJadwalTutupView setHidden:YES];
        [_formView setHidden:YES];
        [_loadingView setHidden:YES];
        [_successView setHidden:NO];
        [_failView setHidden:YES];
        [_centerView bringSubviewToFront:_successView];
    }else if(_centerViewType == CenterViewFailView){
        _centerViewHeight.constant = _successView.frame.size.height;
        [_aturJadwalTutupView setHidden:YES];
        [_formView setHidden:YES];
        [_loadingView setHidden:YES];
        [_successView setHidden:YES];
        [_failView setHidden:NO];
        [_centerView bringSubviewToFront:_successView];
    }else{
        _centerView = CenterViewAturJadwalButton;
        [self adjustView];
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
            [_mulaiDariView setBackgroundColor:lightGray];
        }else{
            [_mulaiDariButton setEnabled:YES];
            [_mulaiDariView setBackgroundColor:[UIColor whiteColor]];
        }
        [_sampaiDenganButton setEnabled:YES];
        _catatanTextView.editable = YES;
        
        [_sampaiDenganView setBackgroundColor:[UIColor whiteColor]];
        [_catatanView setBackgroundColor:[UIColor whiteColor]];
        [_catatanTextView setBackgroundColor:[UIColor whiteColor]];
        
    }else{
        [_mulaiDariButton setEnabled:NO];
        [_sampaiDenganButton setEnabled:NO];
        _catatanTextView.editable = NO;
        
        [_mulaiDariView setBackgroundColor:lightGray];
        [_sampaiDenganView setBackgroundColor:lightGray];
        [_catatanView setBackgroundColor:lightGray];
        [_catatanTextView setBackgroundColor:lightGray];
    }
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
    UIFont *gothamTwelve = [UIFont fontWithName:@"GothamBook" size:12.0f];
    
    NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc]initWithString:joinedString];
    [attribString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [joinedString length])];
    [attribString addAttribute:NSFontAttributeName value:gothamTwelve range:NSMakeRange(0, [joinedString length])];
    
    _failLabel.attributedText = attribString;
    _failLabel.numberOfLines = 0;
    [_failLabel sizeToFit];
}

@end
