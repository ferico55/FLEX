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
        [self setBackgroundColor:[UIColor whiteColor]];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:label];
        [label setFont:[UIFont microThemeMedium]];
        [label setTextColor:[UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1.0]];
        
        UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self addSubview:deleteButton];
        [deleteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [deleteButton.titleLabel setFont:[UIFont title2Theme]];
        [deleteButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [deleteButton setTitleColor:[UIColor colorWithRed:255.0/255 green:87.0/255 blue:34.0/255 alpha:1.0] forState:UIControlStateNormal];
        
        _deleteButton = deleteButton;
        _titleLabel = label;
        CGFloat clearAllLeftInset = [self getClearAllLeftInset];
        
        
        [_titleLabel HVD_fillInSuperViewWithInsets:UIEdgeInsetsMake(7.5, 20, 5, 50)];
        [_deleteButton HVD_fillInSuperViewWithInsets:UIEdgeInsetsMake(7.5, clearAllLeftInset, 5, 15)];
    }
    
    return self;
}

- (CGFloat) getClearAllLeftInset {
    CGFloat clearAllWidth = 60;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size
    .width;
    CGFloat clearAllRightInset = 15;
    return screenWidth -  clearAllWidth - clearAllRightInset;
}



@end
