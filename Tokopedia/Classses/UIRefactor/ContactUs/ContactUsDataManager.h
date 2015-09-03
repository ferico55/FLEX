//
//  ContactUsDataManager.h
//  Tokopedia
//
//  Created by Tokopedia on 9/1/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactUsResponse.h"

@interface ContactUsDataManager : NSObject

- (void)requestTicketCategoriesResponse:(void (^)(ContactUsResponse *))response
                                  error:(void (^)(NSError *))error;

@end
