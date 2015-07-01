//
//  DetailStatisticViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 7/1/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "DetailStatisticViewController.h"

@interface DetailStatisticViewController ()

@end

@implementation DetailStatisticViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [pieChart setStartPieAngle:M_PI_2];
    [pieChart setAnimationSpeed:1.0];
    [pieChart setLabelRadius:160];
    [pieChart setPieBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];
    [pieChart setUserInteractionEnabled:NO];

    
    
    [self resizeButtonContent:btnPositif];
    [self resizeButtonContent:btnNegatif];
    [self resizeButtonContent:btnNetral];
    [self resizeButtonContent:btn1Hari];
    [self resizeButtonContent:btn2Hari];
    [self resizeButtonContent:btn3Hari];
    
    CGRect rect = CGRectMake(0.0f, 0.0f, imgDescTrGagal.bounds.size.width, imgDescTrGagal.bounds.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    imgDescTrGagal.image = image;
    [imgDescTrGagal.layer setCornerRadius:imgDescTrGagal.bounds.size.width/2.0f];
    imgDescTrGagal.layer.masksToBounds = YES;
    
    rect = CGRectMake(0.0f, 0.0f, imgDescTrGagal.bounds.size.width, imgDescTrGagal.bounds.size.height);
    UIGraphicsBeginImageContext(rect.size);
    context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor greenColor] CGColor]);
    CGContextFillRect(context, rect);
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    imgDescTrSukses.image = image;
    [imgDescTrSukses.layer setCornerRadius:imgDescTrSukses.bounds.size.width/2.0f];
    imgDescTrSukses.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [scrollContent setContentSize:CGSizeMake(self.view.bounds.size.width, viewContent.bounds.size.height)];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
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
    switch (tag) {
        case 0:
        {
            //Set Progress
            float totalCount = 100000.0f;
            [progress1 setProgress:80000/totalCount animated:isAnimate];
            [progress2 setProgress:20000/totalCount animated:isAnimate];
            [progress3 setProgress:0/totalCount animated:isAnimate];
            [progress4 setProgress:0/totalCount animated:isAnimate];
            [progress5 setProgress:0/totalCount animated:isAnimate];
            
            
            lblRate1.text = [NSString stringWithFormat:@"(%d)", 80000];
            lblRate2.text = [NSString stringWithFormat:@"(%d)", 20000];
            lblRate3.text = [NSString stringWithFormat:@"(%d)", 0];
            lblRate4.text = [NSString stringWithFormat:@"(%d)", 0];
            lblRate5.text = [NSString stringWithFormat:@"(%d)", 0];
            
            //Calculate widht total rate
            UILabel *tempLabel = [UILabel new];
            tempLabel.text = lblRate1.text;
            tempLabel.font = lblRate1.font;
            tempLabel.textColor = lblRate1.textColor;
            tempLabel.numberOfLines = 0;
            CGSize tempSize = [tempLabel sizeThatFits:CGSizeMake(self.view.bounds.size.width/5.3f, 9999)];
            constWidthLblRate1.constant = constWidthLblRate2.constant = constWidthLblRate3.constant = constWidthLblRate4.constant = constWidthLblRate5.constant = tempSize.width;
            
            
            
            //Set header rate
            for(int i=0;i<arrImageHeader.count;i++) {
                UIImageView *tempImageView = arrImageHeader[i];
                tempImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(i<3)?@"icon_star_active":@"icon_star" ofType:@"png"]];
            }
            
            lblTotalRateHeader.text = [NSString stringWithFormat:@"%d Out of %d", 3, 6];
        }
            break;
        case 1:
        {
            //Set Progress
            float totalCount = 200000.0f;
            [progress1 setProgress:80000/totalCount animated:isAnimate];
            [progress2 setProgress:20000/totalCount animated:isAnimate];
            [progress3 setProgress:60000/totalCount animated:isAnimate];
            [progress4 setProgress:40000/totalCount animated:isAnimate];
            [progress5 setProgress:0/totalCount animated:isAnimate];
            
            
            lblRate1.text = [NSString stringWithFormat:@"(%d)", 80000];
            lblRate2.text = [NSString stringWithFormat:@"(%d)", 20000];
            lblRate3.text = [NSString stringWithFormat:@"(%d)", 60000];
            lblRate4.text = [NSString stringWithFormat:@"(%d)", 40000];
            lblRate5.text = [NSString stringWithFormat:@"(%d)", 0];
            
            //Calculate widht total rate
            UILabel *tempLabel = [UILabel new];
            tempLabel.text = lblRate1.text;
            tempLabel.font = lblRate1.font;
            tempLabel.textColor = lblRate1.textColor;
            tempLabel.numberOfLines = 0;
            CGSize tempSize = [tempLabel sizeThatFits:CGSizeMake(self.view.bounds.size.width/5.3f, 9999)];
            constWidthLblRate1.constant = constWidthLblRate2.constant = constWidthLblRate3.constant = constWidthLblRate4.constant = constWidthLblRate5.constant = tempSize.width;
            
            
            
            //Set header rate
            for(int i=0;i<4;i++) {
                UIImageView *tempImageView = arrImageHeader[i];
                tempImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(i<4)?@"icon_star_active":@"icon_star" ofType:@"png"]];
            }
            
            lblTotalRateHeader.text = [NSString stringWithFormat:@"%d Out of %d", 4, 6];
        }
            break;
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
                pieChart.delegate = self;
                pieChart.dataSource = self;
                [viewCenterPieChart.layer setCornerRadius:viewCenterPieChart.bounds.size.width/2.0f];
                viewPlot.hidden = NO;
                [pieChart reloadData];
            }
        }
            break;
    }
}


#pragma mark - PieChart Delegate
- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart {
    return 2;
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index {
    if(index == 0)
        return 70;
    else
        return 30;
}

//Optional
- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index {
    if(index == 0)
        return [UIColor greenColor];
    else
        return [UIColor lightGrayColor];
}

- (NSString *)pieChart:(XYPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index {
    return @"";
}
@end