//
//  ContactUsActionResultError.h
//  Tokopedia
//
//  Created by Tokopedia on 9/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactUsActionResultError : NSObject

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *message_body_error;

@end
