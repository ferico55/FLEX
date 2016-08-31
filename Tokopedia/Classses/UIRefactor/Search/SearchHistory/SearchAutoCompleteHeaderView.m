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
        [label setFont:[UIFont title2ThemeMedium]];
        
        UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self addSubview:deleteButton];
        [deleteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [deleteButton.titleLabel setFont:[UIFont title2Theme]];
        [deleteButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [deleteButton setTitleColor:[UIColor colorWithRed:255.0/255 green:87.0/255 blue:34.0/255 alpha:1.0] forState:UIControlStateNormal];
        
        _deleteButton = deleteButton;
        _titleLabel = label;
        
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 20.0)];
        [separatorView setBackgroundColor:[UIColor colorWithRed:247.0/255 green:247.0/255 blue:247.0/255 alpha:1.0]];
        [self addSubview:separatorView];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(21, self.frame.size.height, [[UIScreen mainScreen] bounds].size.width, 1.0)];
        [lineView setBackgroundColor:[UIColor colorWithRed:200.0/255 green:199.0/255 blue:204.0/255 alpha:1.0]];
        [self addSubview:lineView];
        
        [_titleLabel HVD_fillInSuperViewWithInsets:UIEdgeInsetsMake(25, 20, 5, 50)];
        [_deleteButton HVD_fillInSuperViewWithInsets:UIEdgeInsetsMake(25, 50, 5, 15)];
    }
    
    return self;
}



@end
