//
//  TextMenu.m
//  Tokopedia
//
//  Created by Tokopedia on 6/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TextMenu.h"

@implementation TextMenu

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return action==@selector(copy:);
}
@end
