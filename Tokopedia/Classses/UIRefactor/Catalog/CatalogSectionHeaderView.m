//
//  CatalogSectionHeaderView.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "CatalogSectionHeaderView.h"

@interface CatalogSectionHeaderView ()

//@property (weak, nonatomic) IBOutlet UIView *view;

@end

@implementation CatalogSectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *tempArr = [[NSBundle mainBundle] loadNibNamed:@"CatalogSectionHeaderView" owner:nil options:0];
        self = [tempArr objectAtIndex:0];
//        viewContent.layer.borderColor = [UIColor colorWithRed:158/255.0f green:158/255.0f blue:158/255.0f alpha:1.0f].CGColor;
//        viewContent.layer.borderWidth = 1.0f;
//        viewContent.layer.masksToBounds = YES;
    }

    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
//    [self addSubview:self.view];
    viewContent.layer.borderColor = [UIColor colorWithRed:158/255.0f green:158/255.0f blue:158/255.0f alpha:1.0f].CGColor;
    viewContent.layer.borderWidth = 1.0f;
    viewContent.layer.masksToBounds = YES;
}

@end
