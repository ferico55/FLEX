//
//  DetailStatisticViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 7/1/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYPieChart.h"
#import <QuartzCore/QuartzCore.h>

@class DetailShopResult;

@interface DetailStatisticViewController : UIViewController <XYPieChartDelegate, XYPieChartDataSource>
{
    IBOutlet UISegmentedControl *segmentedHeader, *segmentedFooter;
    IBOutletCollection(UIImageView) NSArray *arrImageHeader;
    IBOutlet UIProgressView *progress5, *progress4, *progress3, *progress2, *progress1, *progressFooter1, *progressFooter2, *progressFooter3;
    IBOutlet UILabel *lblTotalRateHeader, *lblRate5, *lblRate4, *lblRate3, *lblRate2, *lblRate1, *lblPositif1, *lblPositif6, *lblPositif12, *lblNetral1, *lblNetral6, *lblNetral12, *lblNegatif1, *lblNegatif6, *lblNegatif12, *lblPercentageTransaksiCepat, *lblRespon1Hari, *lblRespon2Hari, *lblRespon3Hari, *lblTransaksiCepat, *lblAverage, *lblPercentageFooter, *lblDescPercentageFooter;
    IBOutlet UIView *viewPlot, *viewContent;
    IBOutlet NSLayoutConstraint *constWidthLblRate1, *constWidthLblRate2, *constWidthLblRate3, *constWidthLblRate4, *constWidthLblRate5, *constWidthFooterLbl1, *constWidthFooterLbl2, *constWidthFooterLbl3;
    IBOutlet UIScrollView *scrollContent;
    IBOutlet UIButton *btn1Hari, *btn2Hari, *btn3Hari, *_buttonPositive, *_buttonNetral, *_buttonNegative;
    IBOutlet UIImageView *imgSpeed;
    UILabel *_successRateLabel;

}

@property (nonatomic, weak) DetailShopResult *detailShopResult;


@property (strong, nonatomic) IBOutlet XYPieChart *reputationChart;
@property (strong, nonatomic) NSMutableArray *slices;
@property (strong, nonatomic) NSArray *sliceColors;
@property (weak, nonatomic) IBOutlet UILabel *totalSuccessLabel;

- (IBAction)actionSegmented:(id)sender;
@end
