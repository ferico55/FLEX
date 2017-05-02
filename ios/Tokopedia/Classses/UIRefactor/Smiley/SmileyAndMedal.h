//
//  SmileyAndMedal.h
//  Tokopedia
//
//  Created by Tokopedia on 8/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SmileyDelegate.h"

#define CBadgeSpeedGood @"badge-speed-good"
#define CBadgeSpeedBad @"badge-speed-bad"
#define CBadgeSpeedNeutral @"badge-speed-neutral"
#define CStringPoin @"Poin"
#define CWidthItemPopUp 50
#define CHeightItemPopUp 30

@interface SmileyAndMedal : NSObject
+ (void)setIconResponseSpeed:(NSString *)strResponse withImage:(id)imgSpeed largeImage:(BOOL)isLarge;
+ (void)generateMedalWithLevel:(NSString *)level withSet:(NSString *)set withImage:(id)image isLarge:(BOOL)isLarge;
+ (UIImage *)generateImage:(UIImage *)image withCount:(int)count;
- (void)showPopUpSmiley:(UIView *)viewContentPopUp andPadding:(int)paddingRightLeftContent withReputationNetral:(NSString *)strNetral withRepSmile:(NSString *)strGood withRepSad:(NSString *)strSad withDelegate:(id<SmileyDelegate>)delegate;
@end
