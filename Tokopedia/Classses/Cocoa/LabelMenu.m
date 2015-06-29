//
//  LabelMenu.m
//  Tokopedia
//
//  Created by Tokopedia on 6/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "LabelMenu.h"

@implementation LabelMenu

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canResignFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(copy:));
}

- (void)copy:(id)sender
{
    [_delegate duplicate:(int)self.tag];
}
@end
