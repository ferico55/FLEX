//
//  RequestResolutionCenter.h
//  Tokopedia
//
//  Created by Renny Runiawati on 10/9/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ResolutionValidation.h"
#import "ResolutionSubmit.h"
#import "ResolutionPicture.h"

@protocol RequestResolutionCenterDelegate <NSObject>



@end

@interface RequestResolutionCenter : NSObject

@property (nonatomic, weak) IBOutlet id<RequestResolutionCenterDelegate> delegate;

-(void)doRequestReplay;

-(void)setParamReplayValidationFromID:(NSString*)resolutionID
                              message:(NSString*)message
                               photos:(NSString*)photos
                              serveID:(NSString*)serverID
                     editSolutionFlag:(NSString*)editSolutionFlag
                             solution:(NSString*)solution
                         refundAmount:(NSString*)refundAmount
                         flagReceived:(NSString*)flagReceived
                          troubleType:(NSString*)troubleType;

@end
