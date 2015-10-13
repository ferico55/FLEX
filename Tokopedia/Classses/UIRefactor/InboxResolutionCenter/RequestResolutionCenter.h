//
//  RequestResolutionCenter.h
//  Tokopedia
//
//  Created by Renny Runiawati on 10/9/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GeneratedHost.h"

@protocol RequestResolutionCenterDelegate <NSObject>

-(void)didSuccessReplay;
-(void)didSuccessCreate;

@end

@interface RequestResolutionCenter : NSObject

@property (nonatomic, weak) IBOutlet id<RequestResolutionCenterDelegate> delegate;

@property GeneratedHost *generatedHost;

-(void)doRequestReplay;
-(void)doRequestCreate;

-(void)setParamReplayValidationFromID:(NSString*)resolutionID
                              message:(NSString*)message
                               photos:(NSString*)photos
                             serverID:(NSString*)serverID
                     editSolutionFlag:(NSString*)editSolutionFlag
                             solution:(NSString*)solution
                         refundAmount:(NSString*)refundAmount
                         flagReceived:(NSString*)flagReceived
                          troubleType:(NSString*)troubleType
                               action:(NSString*)action;

-(void)setParamCreateValidationFromID:(NSString*)orderID
                         flagReceived:(NSString*)flagReceived
                          troubleType:(NSString*)troubleType
                             solution:(NSString*)solution
                         refundAmount:(NSString*)refundAmount
                               remark:(NSString*)remark
                               photos:(NSString*)photos
                            serverID:(NSString*)serverID;

@end
