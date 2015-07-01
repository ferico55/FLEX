//
//  DetailStatisticViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 7/1/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYPieChart.h"

@interface DetailStatisticViewController : UIViewController<XYPieChartDataSource, XYPieChartDelegate>
{
    IBOutlet UISegmentedControl *segmentedHeader, *segmentedFooter;
    IBOutletCollection(UIImageView) NSArray *arrImageHeader;
    IBOutlet UIProgressView *progress5, *progress4, *progress3, *progress2, *progress1;
    IBOutlet UILabel *lblTotalRateHeader, *lblRate5, *lblRate4, *lblRate3, *lblRate2, *lblRate1, *lblPositif1, *lblPositif6, *lblPositif12, *lblNetral1, *lblNetral6, *lblNetral12, *lblNegatif1, *lblNegatif6, *lblNegatif12, *lblPercentageTransaksiCepat, *lblRespon1Hari, *lblRespon2Hari, *lblRespon3Hari, *lblTransaksiSukses, *lblTransaksiGagal;
    IBOutlet UIView *viewPlot, *viewContent, *viewCenterPieChart;
    IBOutlet NSLayoutConstraint *constWidthLblRate1, *constWidthLblRate2, *constWidthLblRate3, *constWidthLblRate4, *constWidthLblRate5;
    IBOutlet UIScrollView *scrollContent;
    IBOutlet XYPieChart *pieChart;
    IBOutlet UIButton *btn1Hari, *btn2Hari, *btn3Hari, *btnPositif, *btnNetral, *btnNegatif;
    IBOutlet UIImageView *imgDescTrSukses, *imgDescTrGagal;
}

- (IBAction)actionSegmented:(id)sender;
@end
