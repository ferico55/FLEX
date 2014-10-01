//
//  DetailProductOtherView.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "DetailProductOtherView.h"

#pragma mark - Detail Product View
@implementation DetailProductOtherView

#pragma mark - Factory Method
+ (id)newview
{
	NSArray* views = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil];
	for (id view in views) {
		if ([view isKindOfClass:[self class]]) {
			return view;
		}
	}
	return nil;
}

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
