//
//  DetailStatisticViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 7/1/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "DetailShopResult.h"
#import "DetailStatisticViewController.h"
#import "SmileyAndMedal.h"
#define CStringTransaksiSuccess @"Transaksi Sukses"
#define CStringTransaksiGagal @"Transaksi gagal / Ditolak"

@interface DetailStatisticViewController ()

@end

@implementation DetailStatisticViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    
    [self resizeButtonContent:_buttonPositive];
    [self resizeButtonContent:_buttonNegative];
    [self resizeButtonContent:_buttonNetral];
    [self resizeButtonContent:btn1Hari];
    [self resizeButtonContent:btn2Hari];
    [self resizeButtonContent:btn3Hari];
    
    [self animateButtonPositive];
    
    self.title = @"Statistik";
    [self setProgressHeader:0 withAnimate:NO];
//    [self initSpeedData]; being comment, cause now speed data is not display
    
    UISegmentedControl *tempView = [UISegmentedControl new];
    tempView.tag = 12;//12 is tag for transaction segment
    tempView.selectedSegmentIndex = 1;
    [self actionSegmented:tempView];
    [self initKepuasanToko];
    
    
    //init chart pie
    _slices = [NSMutableArray arrayWithCapacity:2];
    [_slices addObject:[NSNumber numberWithFloat:[_detailShopResult.shop_tx_stats.shop_tx_success_rate_1_month floatValue]]];
    [_slices addObject:[NSNumber numberWithFloat:(100-[_detailShopResult.shop_tx_stats.shop_tx_success_rate_1_month floatValue])]];

    _sliceColors = [NSArray arrayWithObjects: [UIColor colorWithRed:(66/255.0) green:(189/255.0) blue:(65/255.0) alpha:1], [UIColor clearColor], nil];
    
    [_reputationChart setDataSource:self];
    [_reputationChart setDelegate:self];
    [_reputationChart setStartPieAngle:M_PI];
    [_reputationChart setLabelRadius:160];
    [_reputationChart setAnimationSpeed:1.0];
    [_reputationChart setShowLabel:NO];
//    [_reputationChart setShowPercentage:YES];
    [_reputationChart reloadData];
    
    UIView *centerRadiusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
    [centerRadiusView setCenter:CGPointMake(_reputationChart.frame.size.width/2, _reputationChart.frame.size.height/2)];
    [centerRadiusView setBackgroundColor:[UIColor whiteColor]];
    [centerRadiusView.layer setCornerRadius:centerRadiusView.frame.size.width / 2];
    
    _successRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
    [_successRateLabel setText:[NSString stringWithFormat:@"%@%%", _detailShopResult.shop_tx_stats.shop_tx_success_rate_1_month]];
    [_successRateLabel setFont:[UIFont systemFontOfSize:25]];
    [_successRateLabel setTextAlignment:NSTextAlignmentCenter];
    [_successRateLabel setCenter:CGPointMake(_reputationChart.frame.size.width/2, _reputationChart.frame.size.height/2)];
    [_totalSuccessLabel setText:[NSString stringWithFormat:@"Dari %@ transaksi", _detailShopResult.shop_tx_stats.shop_tx_success_1_month_fmt]];
    
    [_reputationChart addSubview:centerRadiusView];
    [_reputationChart addSubview:_successRateLabel];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init Data
- (void)initSpeedData {
    lblTransaksiCepat.text = _detailShopResult.respond_speed.speed_level;
    [SmileyAndMedal setIconResponseSpeed:_detailShopResult.respond_speed.badge withImage:imgSpeed largeImage:YES];
    
    progressFooter1.progress = _detailShopResult.respond_speed.one_day==nil||_detailShopResult.respond_speed.one_day.count==0? 0:([[_detailShopResult.respond_speed.one_day objectForKey:CCount] floatValue]/[_detailShopResult.respond_speed.count_total floatValue]);
    progressFooter2.progress = _detailShopResult.respond_speed.two_days==nil||_detailShopResult.respond_speed.two_days.count==0? 0:([[_detailShopResult.respond_speed.two_days objectForKey:CCount] floatValue]/[_detailShopResult.respond_speed.count_total floatValue]);
    progressFooter3.progress = _detailShopResult.respond_speed.three_days==nil||_detailShopResult.respond_speed.three_days.count==0? 0:([[_detailShopResult.respond_speed.three_days objectForKey:CCount] floatValue]/[_detailShopResult.respond_speed.count_total floatValue]);
    
    lblRespon1Hari.text = [NSString stringWithFormat:@"(%d)", _detailShopResult.respond_speed.one_day==nil||_detailShopResult.respond_speed.one_day.count==0?0:[[_detailShopResult.respond_speed.one_day objectForKey:CCount] floatValue]];
    lblRespon2Hari.text = [NSString stringWithFormat:@"(%d)", _detailShopResult.respond_speed.two_days==nil||_detailShopResult.respond_speed.two_days.count==0?0:[[_detailShopResult.respond_speed.two_days objectForKey:CCount] floatValue]];
    lblRespon3Hari.text = [NSString stringWithFormat:@"(%d)", _detailShopResult.respond_speed.three_days==nil||_detailShopResult.respond_speed.three_days.count==0?0:[[_detailShopResult.respond_speed.three_days objectForKey:CCount] floatValue]];
    
    
    float width1 = [lblRespon1Hari sizeThatFits:CGSizeMake(self.view.bounds.size.width/5.3f, 9999)].width;
    float width2 = [lblRespon2Hari sizeThatFits:CGSizeMake(self.view.bounds.size.width/5.3f, 9999)].width;
    float width3 = [lblRespon3Hari sizeThatFits:CGSizeMake(self.view.bounds.size.width/5.3f, 9999)].width;
    
    width1 = width1>width2? width1: width2;
    width1 = width1>width3? width1: width3;
    constWidthFooterLbl1.constant = constWidthFooterLbl2.constant = constWidthFooterLbl3.constant = width1;
}

- (void)initKepuasanToko {
    lblPositif1.text = _detailShopResult.stats.shop_last_one_month.count_score_good;
    lblPositif6.text = _detailShopResult.stats.shop_last_six_months.count_score_good;
    lblPositif12.text = _detailShopResult.stats.shop_last_twelve_months.count_score_good;
    
    lblNetral1.text = _detailShopResult.stats.shop_last_one_month.count_score_neutral;
    lblNetral6.text = _detailShopResult.stats.shop_last_six_months.count_score_neutral;
    lblNetral12.text = _detailShopResult.stats.shop_last_twelve_months.count_score_neutral;
    
    lblNegatif1.text = _detailShopResult.stats.shop_last_one_month.count_score_bad;
    lblNegatif6.text = _detailShopResult.stats.shop_last_six_months.count_score_bad;
    lblNegatif12.text = _detailShopResult.stats.shop_last_twelve_months.count_score_bad;
}


#pragma mark - Method View
- (void)resizeButtonContent:(UIButton *)tempBtn {
    int spacing = 3;
    CGSize imageSize = tempBtn.imageView.bounds.size;
    CGSize titleSize = tempBtn.titleLabel.bounds.size;
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    
    [tempBtn.imageView setBackgroundColor:[UIColor whiteColor]];
    
    tempBtn.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    tempBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (totalHeight - titleSize.height),0.0);
}


#pragma mark - Method
- (void)setProgressHeader:(int)tag withAnimate:(BOOL)isAnimate {
    Quality *tempQuality;
    switch (tag) {
        case 0:
        {
            tempQuality = _detailShopResult.ratings.quality;
        }
            break;
        default:
        {
            tempQuality = _detailShopResult.ratings.accuracy;
        }
            break;
    }
    
    
    //Set Progress
    float totalCount = [[tempQuality.count_total stringByReplacingOccurrencesOfString:@"." withString:@""] floatValue];
    [progress1 setProgress:((int)[[tempQuality.one_star_rank stringByReplacingOccurrencesOfString:@"." withString:@""] floatValue]/totalCount) animated:isAnimate];
    [progress2 setProgress:((int)[[tempQuality.two_star_rank stringByReplacingOccurrencesOfString:@"." withString:@""] floatValue]/totalCount) animated:isAnimate];
    [progress3 setProgress:((int)[[tempQuality.three_star_rank stringByReplacingOccurrencesOfString:@"." withString:@""] floatValue]/totalCount) animated:isAnimate];
    [progress4 setProgress:((int)[[tempQuality.four_star_rank stringByReplacingOccurrencesOfString:@"." withString:@""] floatValue]/totalCount) animated:isAnimate];
    [progress5 setProgress:((int)[[tempQuality.five_star_rank stringByReplacingOccurrencesOfString:@"." withString:@""] floatValue]/totalCount) animated:isAnimate];
    
    lblRate1.text = [NSString stringWithFormat:@"(%@)", tempQuality.one_star_rank];
    lblRate2.text = [NSString stringWithFormat:@"(%@)", tempQuality.two_star_rank];
    lblRate3.text = [NSString stringWithFormat:@"(%@)", tempQuality.three_star_rank];
    lblRate4.text = [NSString stringWithFormat:@"(%@)", tempQuality.four_star_rank];
    lblRate5.text = [NSString stringWithFormat:@"(%@)", tempQuality.five_star_rank];
    
    //Calculate widht total rate
    float width1 = [lblRate1 sizeThatFits:CGSizeMake(self.view.bounds.size.width/5.3f, 9999)].width;
    float width2 = [lblRate2 sizeThatFits:CGSizeMake(self.view.bounds.size.width/5.3f, 9999)].width;
    float width3 = [lblRate3 sizeThatFits:CGSizeMake(self.view.bounds.size.width/5.3f, 9999)].width;
    float width4 = [lblRate4 sizeThatFits:CGSizeMake(self.view.bounds.size.width/5.3f, 9999)].width;
    float width5 = [lblRate5 sizeThatFits:CGSizeMake(self.view.bounds.size.width/5.3f, 9999)].width;
    
    width1 = width1>width2? width1: width2;
    width1 = width1>width3? width1: width3;
    width1 = width1>width4? width1: width4;
    width1 = width1>width5? width1: width5;
    constWidthLblRate1.constant = constWidthLblRate2.constant = constWidthLblRate3.constant = constWidthLblRate4.constant = constWidthLblRate5.constant = width1;
    
    lblAverage.text = tempQuality.average;
    NSString *strReview = @"Review";
    lblTotalRateHeader.text = [NSString stringWithFormat:@"%@ %@", tempQuality.count_total, strReview];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:lblTotalRateHeader.font.pointSize];
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys: boldFont, NSFontAttributeName, lblTotalRateHeader.textColor, NSForegroundColorAttributeName, nil];
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:lblTotalRateHeader.font, NSFontAttributeName, lblTotalRateHeader.textColor, NSForegroundColorAttributeName, nil];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:lblTotalRateHeader.text attributes:attrs];
    [attributedText setAttributes:subAttrs range:NSMakeRange(lblTotalRateHeader.text.length-strReview.length, strReview.length)];
    [lblTotalRateHeader setAttributedText:attributedText];
    
    //Set star
    for(int i=0;i<arrImageHeader.count;i++) {
        UIImageView *tempImage = arrImageHeader[i];
        NSString *iconName = i < (int)ceilf([tempQuality.average floatValue]) ? @"icon_star_active" : @"icon_star";
        tempImage.image = [UIImage imageNamed:iconName];
    }
}


#pragma mark - Action
- (IBAction)actionSegmented:(id)sender {
    switch (((UIView *) sender).tag) {
        case 11: //Header
        {
            [self setProgressHeader:(int)((UISegmentedControl *) sender).selectedSegmentIndex withAnimate:YES];
        }
            break;
        case 12:
        {
            NSString *successRateValue;
            NSString *totalSuccessValue;
            if((int)((UISegmentedControl *) sender).selectedSegmentIndex == 0) {
                successRateValue = _detailShopResult.shop_tx_stats.shop_tx_success_rate_1_month;
                totalSuccessValue = _detailShopResult.shop_tx_stats.shop_tx_success_1_month_fmt;
            } else if((int)((UISegmentedControl *) sender).selectedSegmentIndex == 1) {
                successRateValue = _detailShopResult.shop_tx_stats.shop_tx_success_rate_3_month;
                totalSuccessValue = _detailShopResult.shop_tx_stats.shop_tx_success_3_month_fmt;
            } else {
                successRateValue = _detailShopResult.shop_tx_stats.shop_tx_success_rate_1_year;
                totalSuccessValue = _detailShopResult.shop_tx_stats.shop_tx_success_1_year_fmt;
            }
            CATransition *animation = [CATransition animation];
            animation.duration = 1.0;
            animation.type = kCATransitionFade;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [_successRateLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
            [_totalSuccessLabel setText:[NSString stringWithFormat:@"Dari %@ transaksi", totalSuccessValue]];
            
            [_slices removeAllObjects];
            [_slices addObject:[NSNumber numberWithFloat:[successRateValue floatValue]]];
            [_slices addObject:[NSNumber numberWithFloat:(100-[successRateValue floatValue])]];
            [_successRateLabel setText:[NSString stringWithFormat:@"%@%%", successRateValue]];
            [_reputationChart reloadData];
        }
            break;
    }
}


#pragma mark - PieChart Delegate
- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart {
    return 2;
}


- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index {
    CGFloat f = (CGFloat)[[_slices objectAtIndex:index] integerValue];
    return f;
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index {
    return [_sliceColors objectAtIndex:index];
}

- (void)animateButtonPositive {
    CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [anim setToValue:[NSNumber numberWithFloat:0]];
    [anim setFromValue:[NSNumber numberWithDouble:30]];
    [anim setDuration:1];
    [anim setAutoreverses:NO];
    [anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [_buttonPositive.layer addAnimation:anim forKey:@"SwingingRotation"];
}



@end
