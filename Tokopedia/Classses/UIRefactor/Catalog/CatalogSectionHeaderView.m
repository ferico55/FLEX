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
        self.view.frame = frame;        
        [self addSubview:self.view];
        [self layoutIfNeeded];
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
