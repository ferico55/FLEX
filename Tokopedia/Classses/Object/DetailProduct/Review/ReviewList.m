//
//  ReviewList.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/25/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ReviewList.h"

@implementation ReviewList

- (NSString*)review_message {
    return [_review_message kv_decodeHTMLCharacterEntities];
}

- (NSString*)review_product_name {
    return [_review_product_name kv_decodeHTMLCharacterEntities];
}
@end
