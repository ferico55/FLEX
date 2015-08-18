//
//  SmileyAndMedal.h
//  Tokopedia
//
//  Created by Tokopedia on 8/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SmileyDelegate.h"

@interface SmileyAndMedal : NSObject
+ (void)setIconResponseSpeed:(NSString *)strResponse withImage:(id)imgSpeed largeImage:(BOOL)isLarge;
+ (void)generateMedalWithLevel:(NSString *)level withSet:(NSString *)set withImage:(id)image isLarge:(BOOL)isLarge;
+ (UIImage *)generateImage:(UIImage *)image withCount:(int)count;
- (void)showPopUpSmiley:(UIView *)viewContentPopUp andPadding:(int)paddingRightLeftContent withReputationNetral:(NSString *)strNetral withRepSmile:(NSString *)strGood withRepSad:(NSString *)strSad withDelegate:(id<SmileyDelegate>)delegate;
@end
