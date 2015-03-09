//
//  CatalogSectionHeaderView.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "CatalogSectionHeaderView.h"

@interface CatalogSectionHeaderView ()

@property (weak, nonatomic) IBOutlet UIView *view;

@end

@implementation CatalogSectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"CatalogSectionHeaderView"
                                      owner:self
                                    options:nil];
        [self addSubview:self.view];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self addSubview:self.view];
}

@end
