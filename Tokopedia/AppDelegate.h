//
//  AppDelegate.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tkpd.h"
#import "TAGContainer.h"
#import "TAGContainerOpener.h"
#import "TAGManager.h"

@protocol SmileyDelegate <NSObject>
- (void)actionVote:(id)sender;
@end



@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *viewController;
@property (strong, nonatomic) UIViewController *navigationController;

@property (nonatomic, strong) TAGManager *tagManager;
@property (nonatomic, strong) TAGContainer *container;
+ (void)setIconResponseSpeed:(NSString *)strResponse withImage:(id)imgSpeed largeImage:(BOOL)isLarge;
+ (void)generateMedal:(NSString *)value withImage:(id)image isLarge:(BOOL)isLarge;
+ (UIImage *)generateImage:(UIImage *)image withCount:(int)count;
- (void)showPopUpSmiley:(UIView *)viewContentPopUp andPadding:(int)paddingRightLeftContent withReputationNetral:(NSString *)strNetral withRepSmile:(NSString *)strGood withRepSad:(NSString *)strSad withDelegate:(id<SmileyDelegate>)delegate;
@end
