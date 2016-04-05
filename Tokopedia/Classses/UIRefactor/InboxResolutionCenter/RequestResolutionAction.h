//
//  RequestResolutionAction.h
//  Tokopedia
//
//  Created by Renny Runiawati on 4/5/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResolutionAction.h"

@interface RequestResolutionAction : NSObject

+(void)fetchCancelResolutionID:(NSString*)resolutionID
                       success:(void(^) (ResolutionActionResult* data))success
                       failure:(void(^)(NSError* error))failure;

@end
