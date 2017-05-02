//
//  ProductTalkCommentActionResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#define CFieldCommentID @"comment_id"



@interface ProductTalkCommentActionResult : NSObject

@property (nonatomic, strong) NSString *is_success;
@property(nonatomic, strong) NSString *comment_id;

+ (RKObjectMapping *)mapping;
@end
