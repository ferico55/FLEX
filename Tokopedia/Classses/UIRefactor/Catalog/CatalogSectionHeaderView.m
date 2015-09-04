//
//  CatalogSectionHeaderView.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "CatalogSectionHeaderView.h"

@implementation CatalogSectionHeaderView

- (id)init {
    self = [super init];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"CatalogSectionHeaderView"
                                      owner:self
                                    options:nil];
        CGFloat width = [[UIScreen mainScreen] bounds].size.width;
        CGRect frame = CGRectMake(0, 0, width, self.view.frame.size.height);
        self.view.frame = frame;
        [self addSubview:self.view];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    _view.layer.borderColor = [UIColor colorWithRed:158/255.0f green:158/255.0f blue:158/255.0f alpha:1.0f].CGColor;
    _view.layer.borderWidth = 1.0f;
    _view.layer.masksToBounds = YES;
}

@end