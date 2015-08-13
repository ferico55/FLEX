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
    
    
    [self resizeButtonContent:btnPositif];
    [self resizeButtonContent:btnNegatif];
    [self resizeButtonContent:btnNetral];
    [self resizeButtonContent:btn1Hari];
    [self resizeButtonContent:btn2Hari];
    [self resizeButtonContent:btn3Hari];
    
    self.title = @"Statistik";
    [self setProgressHeader:0 withAnimate:NO];
//    [self initSpeedData]; being comment, cause now speed data is not display
    
    UISegmentedControl *tempView = [UISegmentedControl new];
    tempView.tag = 12;//12 is tag for transaction segment
    tempView.selectedSegmentIndex = 1;
    [self actionSegmented:tempView];
    [self initKepuasanToko];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Init Data
- (void)initSpeedData {
    lblTransaksiCepat.text = _detailShopResult.respond_speed.speed_level;
    [SmileyAndMedal setIconResponseSpeed:_detailShopResult.respond_speed.badge withImage:imgSpeed largeImage:YES];
    
    progressFooter1.progress = _detailShopResult.respond_speed.one_day==nil||_detailShopResult.respond_speed.one_day.count==0? 0:([[_detailShopResult.respond_speed.one_day objectForKey:CCount] intValue]/[_detailShopResult.respond_speed.count_total floatValue]);
    progressFooter2.progress = _detailShopResult.respond_speed.two_days==nil||_detailShopResult.respond_speed.two_days.count==0? 0:([[_detailShopResult.respond_speed.two_days objectForKey:CCount] intValue]/[_detailShopResult.respond_speed.count_total floatValue]);
    progressFooter3.progress = _detailShopResult.respond_speed.three_days==nil||_detailShopResult.respond_speed.three_days.count==0? 0:([[_detailShopResult.respond_speed.three_days objectForKey:CCount] intValue]/[_detailShopResult.respond_speed.count_total floatValue]);
    
    lblRespon1Hari.text = [NSString stringWithFormat:@"(%d)", _detailShopResult.respond_speed.one_day==nil||_detailShopResult.respond_speed.one_day.count==0?0:[[_detailShopResult.respond_speed.one_day objectForKey:CCount] intValue]];
    lblRespon2Hari.text = [NSString stringWithFormat:@"(%d)", _detailShopResult.respond_speed.two_days==nil||_detailShopResult.respond_speed.two_days.count==0?0:[[_detailShopResult.respond_speed.two_days objectForKey:CCount] intValue]];
    lblRespon3Hari.text = [NSString stringWithFormat:@"(%d)", _detailShopResult.respond_speed.three_days==nil||_detailShopResult.respond_speed.three_days.count==0?0:[[_detailShopResult.respond_speed.three_days objectForKey:CCount] intValue]];
    
    
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
    [progress1 setProgress:((int)[[tempQuality.one_star_rank stringByReplacingOccurrencesOfString:@"." withString:@""] intValue]/totalCount) animated:isAnimate];
    [progress2 setProgress:((int)[[tempQuality.two_star_rank stringByReplacingOccurrencesOfString:@"." withString:@""] intValue]/totalCount) animated:isAnimate];
    [progress3 setProgress:((int)[[tempQuality.three_star_rank stringByReplacingOccurrencesOfString:@"." withString:@""] intValue]/totalCount) animated:isAnimate];
    [progress4 setProgress:((int)[[tempQuality.four_star_rank stringByReplacingOccurrencesOfString:@"." withString:@""] intValue]/totalCount) animated:isAnimate];
    [progress5 setProgress:((int)[[tempQuality.five_star_rank stringByReplacingOccurrencesOfString:@"." withString:@""] intValue]/totalCount) animated:isAnimate];
    
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
        tempImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(i<(int)ceilf([tempQuality.average floatValue])? @"icon_star_active":@"icon_star") ofType:@"png"]];
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
            if((int)((UISegmentedControl *) sender).selectedSegmentIndex == 0) {
                viewPlot.hidden = YES;
            }
            else {
                viewPlot.hidden = NO;
                if(_detailShopResult.stats.hide_rate!=nil && [_detailShopResult.stats.hide_rate isEqualToString:@"1"]) { //if hide_rate == 1 not using percentage
                    lblPercentageFooter.text = [NSString stringWithFormat:@"%@", _detailShopResult.stats.tx_count_success==nil||[_detailShopResult.stats.tx_count_success isEqualToString:@""]? @"0":_detailShopResult.stats.tx_count_success];
                }
                else
                    lblPercentageFooter.text = [NSString stringWithFormat:@"%.1f%%", _detailShopResult.stats.rate_success==nil||[_detailShopResult.stats.rate_success isEqualToString:@""]? 0:[_detailShopResult.stats.rate_success floatValue]];

                NSString *strDari = @"Dari ";
                NSString *strTransaksi = @" Transaksi";
                lblDescPercentageFooter.text = [NSString stringWithFormat:@"%@%@%@", strDari, _detailShopResult.stats.shop_total_transaction, strTransaksi];
                
                NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys: lblDescPercentageFooter.font, NSFontAttributeName, lblDescPercentageFooter.textColor, NSForegroundColorAttributeName, nil];
                UIFont *boldFont = [UIFont fontWithName:@"Gotham Medium" size:lblDescPercentageFooter.font.pointSize];
                NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:boldFont, NSFontAttributeName, nil];
                NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:lblDescPercentageFooter.text attributes:attrs];
                [attributedText setAttributes:subAttrs range:NSMakeRange(strDari.length, lblDescPercentageFooter.text.length-strDari.length-strTransaksi.length)];
                [lblDescPercentageFooter setAttributedText:attributedText];
            }
        }
            break;
    }
}
@end