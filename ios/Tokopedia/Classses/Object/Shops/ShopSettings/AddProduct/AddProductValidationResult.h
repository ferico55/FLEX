//
//  AddProductValidationResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddProductValidationResult : NSObject <TKPObjectMapping>

@property (nonatomic) NSString *is_success;
@property (nonatomic) NSString *post_key;

@end
