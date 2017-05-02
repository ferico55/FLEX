//
//  ReviewImageAttachment.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReviewImageAttachment : NSObject

@property (nonatomic, strong) NSString *uri_large;
@property (nonatomic, strong) NSString *attachment_id;
@property (nonatomic, strong) NSString *uri_thumbnail;
@property (nonatomic, strong) NSString *desc;

+ (RKObjectMapping*)mapping;

@end
