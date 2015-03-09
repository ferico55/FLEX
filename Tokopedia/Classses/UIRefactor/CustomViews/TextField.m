//
//  TextField.m
//  Tokopedia
//
//  Created by Tokopedia PT on 11/11/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "TextField.h"
#import <QuartzCore/QuartzCore.h>

@implementation TextField

- (void)drawRect:(CGRect)rect
{
    if (self.isTopRoundCorner || self.isBottomRoundCorner) {

        CGFloat radius = 3.0;
        CGRect maskFrame = self.bounds;
        
        if (self.isTopRoundCorner) {
            maskFrame.size.height += radius;
        } else if (self.isBottomRoundCorner) {
            maskFrame.size.height = self.frame.size.height;
        }

        CALayer *maskLayer = [CALayer layer];
        maskLayer.cornerRadius = radius;
        maskLayer.backgroundColor = [UIColor colorWithRed:189.0/255.0 green:189.0/255.0 blue:189.0/255.0 alpha:1].CGColor;
        maskLayer.frame = maskFrame;
        
        self.layer.mask = maskLayer;
    }
    
    self.layer.borderColor = [UIColor colorWithRed:189.0/255.0 green:189.0/255.0 blue:189.0/255.0 alpha:1].CGColor;
    self.layer.borderWidth = 1;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 10, bounds.origin.y + 8,
                      bounds.size.width - 20, bounds.size.height - 16);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

@end
