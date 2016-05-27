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

typedef NS_ENUM(NSInteger, CenterViewType){
    CenterViewAturJadwalButton,
    CenterViewFormView,
    CenterViewLoadingView,
    CenterViewSuccessView
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

@property (strong, nonatomic) IBOutlet UIView *successView;
@property CenterViewType centerViewType;
@property BOOL isFormEnabled;
@end

@implementation CloseShopViewController{
    CloseShopRequest *_closeShopRequest;
    NSDate* _dateMulaiDari;
    NSDate* _dateSampaiDengan;
    BOOL textViewInitialValue;
    BOOL useAnimation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _closeShopRequest = [CloseShopRequest new];
    
    
    //self.scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [_scrollView setScrollEnabled:YES];
    _scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1000);
    _scrollViewHeight.constant = [UIScreen mainScreen].bounds.size.height;
    
    CALayer * externalBorder = [CALayer layer];
    externalBorder.frame = CGRectMake(-1, -1, _formView.frame.size.width+2, _formView.frame.size.height+2);
    externalBorder.borderColor = [UIColor colorWithRed:0.914 green:0.914 blue:0.914 alpha:1].CGColor;
    externalBorder.borderWidth = 1.0;
    
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
    useAnimation = YES;
    [self adjustView];
    
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
    datePicker.data = @{kTKPDALERTVIEW_DATATYPEKEY:@(kTKPDALERT_DATAALERTTYPESHOPEDITKEY)};
    datePicker.tag = AlertDatePickerMulaiDari;
    datePicker.delegate = self;
    datePicker.isSetMinimumDate = YES;
    [datePicker show];
}
- (IBAction)sampaiDenganButtonTapped:(id)sender {
    AlertDatePickerView *datePicker = [AlertDatePickerView newview];
    datePicker.data = @{kTKPDALERTVIEW_DATATYPEKEY:@(kTKPDALERT_DATAALERTTYPESHOPEDITKEY)};
    datePicker.tag = AlertDatePickerSampaiDengan;
    datePicker.delegate = self;
    datePicker.isSetMinimumDate = YES;
    
    datePicker.startDate = [self addDays:1 toNSDate:_dateMulaiDari];
    [datePicker show];
}
- (IBAction)submitButtonTapped:(id)sender {
    _centerViewType = CenterViewLoadingView;
    if([_tutupSekarangSwitch isOn]){
        [_closeShopRequest requestActionCloseShopFromNowUntil:[self stringFromNSDate:_dateSampaiDengan]
                                                    closeNote:_catatanTextView.text
                                                    onSuccess:^(CloseShopResponse *result) {
                                                        _centerViewType = CenterViewSuccessView;
                                                    }
                                                    onFailure:^(NSError *error) {
                                                        
                                                    }];
    }else{
        [_closeShopRequest requestActionCloseShopFrom:[self stringFromNSDate:_dateMulaiDari]
                                                until:[self stringFromNSDate:_dateSampaiDengan]
                                            closeNote:_catatanTextView.text
                                            onSuccess:^(CloseShopResponse *result) {
            
        }
                                            onFailure:^(NSError *error) {
            
                                            }];
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
    
}

- (IBAction)bukaTokoTapped:(id)sender {
    [_closeShopRequest requestActionOpenShopOnSuccess:^(CloseShopResponse *result) {
        
    } onFailure:^(NSError *error) {
        
    }];
}

#pragma mark - Date Picker Delegate
-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {    
    NSDate *date = [alertView.data objectForKey:@"datepicker"];
    if(alertView.tag == AlertDatePickerMulaiDari){
        _dateMulaiDari = date;
        if(_dateSampaiDengan && _dateSampaiDengan < _dateMulaiDari){
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

#pragma mark - ScrollView delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

# pragma mark - Toggle View
- (void)adjustView{
    if(_centerViewType == CenterViewAturJadwalButton){
        [_aturJadwalTutupView setHidden:NO];
        [_formView setHidden:YES];
        [_loadingView setHidden:YES];
        [_successView setHidden:YES];
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
        [_aturJadwalTutupView setHidden:YES];
        [_formView setHidden:NO];
        [_loadingView setHidden:YES];
        [_successView setHidden:YES];
        _centerViewHeight.constant = _formView.frame.size.height;
        [_centerView bringSubviewToFront:_formView];
        
        if(useAnimation){
            [_centerView setAlpha:0];
            [UIView animateWithDuration:0.6f animations:^{
                [_centerView setAlpha:1];
            }];
            useAnimation = NO;
        }
    }else if(_centerViewType == CenterViewLoadingView){
        [_aturJadwalTutupView setHidden:YES];
        [_formView setHidden:YES];
        [_loadingView setHidden:NO];
        [_successView setHidden:YES];
        [_centerView bringSubviewToFront:_loadingView];
    }else if(_centerViewType == CenterViewSuccessView){
        [_aturJadwalTutupView setHidden:YES];
        [_formView setHidden:YES];
        [_loadingView setHidden:YES];
        [_successView setHidden:NO];
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
        
    }else if(_scheduleDetail.close_status == CLOSE_STATUS_CLOSED){
        _tutupTokoSekarangLabel.text = @"JADWAL TUTUP";
        [_tutupSekarangSwitch setHidden:YES];
        [_scheduleIcon setHidden:NO];
        
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
        
        [_mulaiDariButton setTitle:_scheduleDetail.close_start forState:UIControlStateNormal];
        [_sampaiDenganButton setTitle:_scheduleDetail.close_end forState:UIControlStateNormal];
    }else{
        //OPEN WITH CLOSE SCHEDULE
        _tutupTokoSekarangLabel.text = @"JADWAL TUTUP";
        [_tutupSekarangSwitch setHidden:YES];
        [_scheduleIcon setHidden:NO];
        
        //button in form footer
        if(_isFormEnabled){
            [_submitButton setHidden:YES];
            [_hapusButton setHidden:NO];
            [_ubahButtonRight setHidden:NO];
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
        
        [_mulaiDariButton setTitle:_scheduleDetail.close_start forState:UIControlStateNormal];
        [_sampaiDenganButton setTitle:_scheduleDetail.close_end forState:UIControlStateNormal];
    }
    
    //SETTING BUTTON BATAL
    if(_isFormEnabled){
        _centerViewHeight.constant = CENTER_VIEW_NORMAL_HEIGHT;
        
        [_mulaiDariButton setEnabled:YES];
        [_sampaiDenganButton setEnabled:YES];
        _catatanTextView.editable = YES;
        
        [_mulaiDariView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
        [_sampaiDenganView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
        [_catatanView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
        [_catatanTextView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
        
    }else{
        _centerViewHeight.constant = CENTER_VIEW_NORMAL_HEIGHT - 44;
        
        [_mulaiDariButton setEnabled:NO];
        [_sampaiDenganButton setEnabled:NO];
        _catatanTextView.editable = NO;
        
        [_mulaiDariView setBackgroundColor:[UIColor colorWithRed:0.968 green:0.968 blue:0.968 alpha:1]];
        [_sampaiDenganView setBackgroundColor:[UIColor colorWithRed:0.968 green:0.968 blue:0.968 alpha:1]];
        [_catatanView setBackgroundColor:[UIColor colorWithRed:0.968 green:0.968 blue:0.968 alpha:1]];
        [_catatanTextView setBackgroundColor:[UIColor colorWithRed:0.968 green:0.968 blue:0.968 alpha:1]];
    }
}
@end
