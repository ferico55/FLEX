//
//  SearchAutoCompleteHeaderView.m
//  Tokopedia
//
//  Created by Tonito Acen on 8/31/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "SearchAutoCompleteHeaderView.h"
#import "UIView+HVDLayout.h"

@implementation SearchAutoCompleteHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self != nil) {
        [self setBackgroundColor:[UIColor colorWithWhite:0.85 alpha:1.0f]];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:label];
        [label setFont:[UIFont fontWithName:@"Gotham Medium" size:12.0f]];
        
        UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self addSubview:deleteButton];
        [deleteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [deleteButton.titleLabel setFont:[UIFont fontWithName:@"Gotham Medium" size:11.0f]];
        
        _deleteButton = deleteButton;
        _titleLabel = label;
        
        [_titleLabel HVD_fillInSuperViewWithInsets:UIEdgeInsetsMake(5, 10, 5, 50)];        
        [_deleteButton HVD_pinToRightOfView:_titleLabel withMargin:10];
        [_deleteButton HVD_setHeight:self.frame.size.height];
    }
    
    return self;
}



@end
