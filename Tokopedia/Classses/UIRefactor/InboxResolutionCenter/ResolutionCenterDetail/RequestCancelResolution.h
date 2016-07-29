//
//  RequestCancelResolution.h
//  Tokopedia
//
//  Created by IT Tkpd on 5/18/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "InboxResolutionCenterList.h"

@protocol CancelComplainDelegate <NSObject>
@required
- (void)successCancelComplain:(InboxResolutionCenterList*)resolution successStatus:(NSArray*)successStatus;
- (void)failedCancelComplain:(InboxResolutionCenterList*)resolution errors:(NSArray*)errors;

@end

@interface RequestCancelResolution : NSObject


@property (nonatomic, weak) IBOutlet id<CancelComplainDelegate> delegate;

@property InboxResolutionCenterList *resolution;
@property NSInteger resolutionID;
@property UIViewController *viewController;


-(void)doRequest;

+(void)fetchCancelComplainID:(NSString*)complainID
                      detail:(InboxResolutionCenterList*)resolution
                     success:(void (^)(InboxResolutionCenterList *resolution))success
                     failure:(void (^)(NSError *error))failure;

@end
