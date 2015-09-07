//
//  ContactUsFormDataManager.h
//  Tokopedia
//
//  Created by Tokopedia on 9/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactUsActionResponse.h"

@interface ContactUsFormDataManager : NSObject

- (void)requestFormModelContactUs:(void (^)(ContactUsActionResponse *))response
                            error:(void (^)(NSError *))error;

@end
