//
//  UITextField+WithInset.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "UITextField+WithInset.h"

@implementation UITextField (WithInset)

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 0, 10);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 0, 10);
}

@end
