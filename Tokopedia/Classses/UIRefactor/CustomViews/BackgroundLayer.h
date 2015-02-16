//
//  BackgroundLayer.h
//  Tokopedia
//
//  Created by Tokopedia on 10/13/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface BackgroundLayer : NSObject
+(CAGradientLayer*) greyGradient;
+(CAGradientLayer*) blueGradient;
+(CAGradientLayer*) blackGradient;
+(CAGradientLayer *)blackGradientFromTop;
@end
