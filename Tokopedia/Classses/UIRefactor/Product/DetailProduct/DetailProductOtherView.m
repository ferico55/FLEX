//
//  DetailProductOtherView.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "DetailProductOtherView.h"

@interface DetailProductOtherView ()


@end

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

#pragma mark - View Action
-(IBAction)gesture:(id)sender
{
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *gesture = (UITapGestureRecognizer*)sender;
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan: {
                break;
            }
            case UIGestureRecognizerStateChanged: {
                break;
            }
            case UIGestureRecognizerStateEnded: {
                
                [_delegate DetailProductOtherView:self withindex:_index];
                break;
            }
            default:
                break;
        }
    }
}


#pragma mark - Setter Getter
- (UIView *)getViewContent
{
    return viewContent;
}
@end
