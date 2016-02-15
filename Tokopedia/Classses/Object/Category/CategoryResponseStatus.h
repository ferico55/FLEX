//
//  CategoryResponseStatus.h
//  Tokopedia
//
//  Created by Tokopedia on 2/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CategoryResponseStatus : NSObject

@property (strong, nonatomic) NSString *error_code;
@property (strong, nonatomic) NSString *message;

@end
