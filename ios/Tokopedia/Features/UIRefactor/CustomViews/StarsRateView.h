//
//  StarsRateView.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/24/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Stars Rate View
@interface StarsRateView : UIView

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *starimages;
@property (nonatomic) NSInteger starscount;

@end
