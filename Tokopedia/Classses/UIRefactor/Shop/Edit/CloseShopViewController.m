//
//  CloseShopViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 5/9/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "CloseShopViewController.h"
#import "AlertDatePickerView.h"

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

@interface CloseShopViewController ()<TKPDAlertViewDelegate, UIScrollViewDelegate>
@property CenterViewType centerViewType;
@end

@implementation CloseShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [_scrollView setScrollEnabled:YES];
    _scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1000);
    _scrollViewHeight.constant = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat borderWidth = 2.0f;
    
    CALayer * externalBorder = [CALayer layer];
    externalBorder.frame = CGRectMake(-1, -1, _formView.frame.size.width+2, _formView.frame.size.height+2);
    externalBorder.borderColor = [UIColor blackColor].CGColor;
    externalBorder.borderWidth = 1.0;
    
    [_formView.layer addSublayer:externalBorder];
    _formView.layer.masksToBounds = NO;
    [_tutupSekarangSwitch setOn:NO];
    
    _centerViewType = CenterViewAturJadwalButton;
    
    [_centerView addSubview:_aturJadwalTutupView];
    [_centerView addSubview:_formView];
    [_centerView addSubview:_loadingView];
    [_centerView addSubview:_successView];
    [self adjustView];
    [self setMulaiDariButtonToToday];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Button Action
- (IBAction)aturJadwalTutupButtonTapped:(id)sender {
    _centerViewType = CenterViewFormView;
    [self adjustView];
}
- (IBAction)batalButtonTapped:(id)sender {
    _centerViewType = CenterViewAturJadwalButton;
    [self adjustView];
}
- (IBAction)tutupSekarangSwitchValueChanged:(id)sender {
    if([_tutupSekarangSwitch isOn]){
        //_mulaiDariView.backgroundColor = [UIColor grayColor];
        [_mulaiDariButton setEnabled:NO];
        [self setMulaiDariButtonToToday];
    }else{
        //_mulaiDariView.backgroundColor = [UIColor whiteColor];
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
    [datePicker show];
}




#pragma mark - Date Picker Delegate
-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {    
    NSDate *date = [alertView.data objectForKey:@"datepicker"];
    NSCalendarUnit calendarUnit = NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:calendarUnit fromDate:date];
    NSString *dateString = [NSString stringWithFormat:@"%zd/%zd/%zd", [components day], [components month], [components year]];
    
    if(alertView.tag == AlertDatePickerMulaiDari){
        [_mulaiDariButton setTitle:dateString forState:UIControlStateNormal];
    }else if(alertView.tag == AlertDatePickerSampaiDengan){
        [_sampaiDenganButton setTitle:dateString forState:UIControlStateNormal];
    }
}

#pragma mark - ScrollView delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

# pragma mark - Toggle View

-(void)setMulaiDariButtonToToday{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    [_mulaiDariButton setTitle:[formatter stringFromDate:[NSDate date]]
                      forState:UIControlStateNormal];
}

- (void)adjustView{
    if(_centerViewType == CenterViewAturJadwalButton){
        [_aturJadwalTutupView setHidden:NO];
        [_formView setHidden:YES];
        [_loadingView setHidden:YES];
        [_successView setHidden:YES];
        [_centerView bringSubviewToFront:_aturJadwalTutupView];
        _centerViewHeight.constant = 0;
        [UIView animateWithDuration:10
                              delay:0
             usingSpringWithDamping:3
              initialSpringVelocity:0.2
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^
         {
             _centerViewHeight.constant = _aturJadwalTutupView.frame.size.height;
         }completion:nil];
    }else if(_centerViewType == CenterViewFormView){
        [_aturJadwalTutupView setHidden:YES];
        [_formView setHidden:NO];
        [_loadingView setHidden:YES];
        [_successView setHidden:YES];
        [_centerView bringSubviewToFront:_formView];
        _centerViewHeight.constant = 0;
        [UIView animateWithDuration:10
                              delay:0
             usingSpringWithDamping:3
              initialSpringVelocity:0.2
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^
         {
             _centerViewHeight.constant = _formView.frame.size.height;
         }completion:nil];
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
}
@end
