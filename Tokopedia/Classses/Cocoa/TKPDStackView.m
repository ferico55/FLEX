//
//  TKPDStackView.m
//  Tokopedia
//
//  Created by Johanes Effendi on 7/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "TKPDStackView.h"

@implementation TKPDStackView{
    CGFloat counter;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)pushView:(UIView *)view{
    if(_orientation == TKPDStackViewOrientationLeftToRight){
        [view setFrame:CGRectMake(counter, 0, view.frame.size.width, view.frame.size.height)];
        [self addSubview:view];
        counter = counter + view.frame.size.width;
    }else if(_orientation == TKPDStackViewOrientationRightToLeft){
        [view setFrame:CGRectMake(self.frame.size.width-view.frame.size.width-counter, 0, view.frame.size.width, view.frame.size.height)];
        [self addSubview:view];
        counter = counter + view.frame.size.width;
    }else if(_orientation == TKPDStackViewOrientationTopToBottom){
        [view setFrame:CGRectMake(0, counter, view.frame.size.width, view.frame.size.height)];
        [self addSubview:view];
        counter = counter + view.frame.size.height;
    }else if(_orientation == TKPDStackViewOrientationBottomToTop){
        [view setFrame:CGRectMake(0, self.frame.size.height-view.frame.size.height-counter, view.frame.size.width, view.frame.size.height)];
        [self addSubview:view];
        counter = counter + view.frame.size.height;
    }else{
        _orientation = TKPDStackViewOrientationLeftToRight;
        [self pushView:view];
    }
}

-(void)removeAllPushedView{
    NSArray *viewsToRemove = [self subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    counter = 0;
}

@end
