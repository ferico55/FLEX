//
//  ContactUsFormCategoryCell.m
//  Tokopedia
//
//  Created by Tokopedia on 9/11/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ContactUsFormCategoryCell.h"

@implementation ContactUsFormCategoryCell

- (id)init {
    self = [super init];
    if (self) {
        NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"ContactUsFormCategoryCell"
                                                   owner:nil
                                                 options:0];
        for (id o in a) {
            if ([o isKindOfClass:[self class]]) {
                return o;
            }
        }
    }
    return self;
}

@end
