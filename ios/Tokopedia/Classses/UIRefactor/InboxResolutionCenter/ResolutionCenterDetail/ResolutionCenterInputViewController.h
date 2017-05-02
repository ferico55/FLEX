//
//  ResolutionCenterInputViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 3/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResolutionDetailConversation.h"
@class GeneratedHost;

@protocol ResolutionCenterInputViewControllerDelegate <NSObject>
@optional
-(void)solutionType:(NSString *)solutionType troubleType:(NSString *)troubleType refundAmount:(NSString *)refundAmout message:(NSString *)message photo:(NSString *)photo serverID:(NSString*)serverID isGotTheOrder:(BOOL)isGotTheOrder;
-(void)message:(NSString *)message photo:(NSString *)photo serverID:(NSString*)serverID;
-(void)setGenerateHost:(GeneratedHost*)generateHost;
-(void)reportResolution;
- (void)addResolutionLast:(ResolutionLast*)resolutionLast conversationLast:(ResolutionConversation*)conversationLast replyEnable:(BOOL)isReplyEnable;
-(void)hideReportButton:(BOOL)isHideReportButton;
@end

@interface ResolutionCenterInputViewController : UIViewController


@property (nonatomic, weak) IBOutlet id<ResolutionCenterInputViewControllerDelegate> delegate;

@property (nonatomic) ResolutionDetailConversation *resolution;
@property NSString *lastSolution;
@property NSString *resolutionID;

@end
