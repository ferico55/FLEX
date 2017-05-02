//
//  ShopStatView.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopStatView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *imgStatistic;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *statLabel;
@property (weak, nonatomic) IBOutlet UILabel *openStatusLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintWidthMedal;

+(id)newView;

@end
