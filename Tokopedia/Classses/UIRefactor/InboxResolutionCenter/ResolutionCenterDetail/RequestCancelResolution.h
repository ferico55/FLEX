//
//  RequestCancelResolution.h
//  Tokopedia
//
//  Created by IT Tkpd on 5/18/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "InboxResolutionCenterList.h"

@interface RequestCancelResolution : NSObject

@property InboxResolutionCenterList *resolution;
@property NSInteger resolutionID;
@property UIViewController *viewController;

+(void)fetchCancelComplainID:(NSString*)complainID
                      detail:(InboxResolutionCenterList*)resolution
                     success:(void (^)(InboxResolutionCenterList *resolution, NSString* uriNext))success
                     failure:(void (^)(NSError *error))failure;

@end
