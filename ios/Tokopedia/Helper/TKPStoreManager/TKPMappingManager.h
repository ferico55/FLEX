//
//  TKPMappingManager.h
//  Tokopedia
//
//  Created by Renny Runiawati on 11/19/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TKPMappingManager: NSObject

+ (RKObjectManager*)objectManagerGetAddress;
+ (RKObjectManager *)resolutionObjectManagerWithBaseURL:(NSString*)baseURL
                                            pathPattern:(NSString*)pathPattern;
+ (RKObjectManager*)objectManagerEditAddress;
+ (RKObjectManager*)objectManagerUploadImageWithBaseURL:(NSString*)baseURL
                                            pathPattern:(NSString*)pathPattern;

@end
