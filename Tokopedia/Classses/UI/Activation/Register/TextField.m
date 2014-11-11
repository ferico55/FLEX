//
//  TextField.m
//  Tokopedia
//
//  Created by Tokopedia PT on 11/11/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "TextField.h"

@implementation TextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (self.isTopRoundCorner || self.isBottomRoundCorner) {

        CGFloat radius = 2.0;
        CGRect maskFrame = self.bounds;
        
        if (self.isTopRoundCorner) {
            maskFrame.size.height += radius;
        } else if (self.isBottomRoundCorner) {
            maskFrame.size.height = self.frame.size.height;
        }

        CALayer *maskLayer = [CALayer layer];
        maskLayer.cornerRadius = radius;
        maskLayer.backgroundColor = [UIColor colorWithRed:158.0/255.0 green:158.0/255.0 blue:158.0/255.0 alpha:1].CGColor;
        maskLayer.frame = maskFrame;
        
        self.layer.mask = maskLayer;
    }
    
    self.layer.borderColor = [UIColor colorWithRed:158.0/255.0 green:158.0/255.0 blue:158.0/255.0 alpha:1].CGColor;
    self.layer.borderWidth = 1;
    
    //Add padding to left side
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, self.frame.size.height)];
    self.leftView = paddingView;
    self.leftViewMode = UITextFieldViewModeAlways;
}

@end
