//
//  CategoryDetail.m
//  Tokopedia
//
//  Created by Tokopedia on 2/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "CategoryDetail.h"

@implementation CategoryDetail

@synthesize hasChildCategories = _hasChildCategories;

- (void)setHasChildCategories:(BOOL)hasChildCategories {
    _hasChildCategories = hasChildCategories;
}

- (BOOL)hasChildCategories {
    if (self.child.count > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isEqual:(CategoryDetail *)object {
    if ([self.categoryId isEqualToString:object.categoryId]) {
        return YES;
    }
    return NO;
}

@end
