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
        [label setFont:[UIFont title2ThemeMedium]];
        
        UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self addSubview:deleteButton];
        [deleteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [deleteButton.titleLabel setFont:[UIFont microThemeMedium]];
        [deleteButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        
        _deleteButton = deleteButton;
        _titleLabel = label;
        
        [_titleLabel HVD_fillInSuperViewWithInsets:UIEdgeInsetsMake(5, 10, 5, 50)];
        [_deleteButton HVD_fillInSuperViewWithInsets:UIEdgeInsetsMake(5, 50, 5, 10)];
    }
    
    return self;
}



@end
