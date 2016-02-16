//
//  CategoryResponse.h
//  Tokopedia
//
//  Created by Tokopedia on 2/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoryData.h"
#import "CategoryDetail.h"

@interface CategoryResponse : NSObject

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) CategoryData *result;

@end
