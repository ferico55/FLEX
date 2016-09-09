//
//  SalesOrderCell.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/14/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "SalesOrderCell.h"

@interface SalesOrderCell ()

@property (weak, nonatomic) IBOutlet UIView *priceView;

@end

@implementation SalesOrderCell

- (void)awakeFromNib {
    
    self.remainingDaysLabel.layer.cornerRadius = 1;

    [self.acceptButton.titleLabel setFont:[UIFont microTheme]];
    [self.acceptButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];

    [self.rejectButton.titleLabel setFont:[UIFont microTheme]];
    [self.rejectButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    
    UITapGestureRecognizer *invoiceTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    self.invoiceNumberLabel.userInteractionEnabled = YES;
    [self.invoiceNumberLabel addGestureRecognizer:invoiceTap];
    
    UITapGestureRecognizer *buyerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    self.userView.tag = 1;
    self.userView.userInteractionEnabled = YES;
    [self.userView addGestureRecognizer:buyerTap];


    UITapGestureRecognizer *priceViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    _priceView.tag = 2;
    _priceView.userInteractionEnabled = YES;
    [_priceView addGestureRecognizer:priceViewTap];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - Actions

- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        if (button.tag == 1) {
            [self.delegate tableViewCell:self rejectOrderAtIndexPath:self.indexPath];
        } else if (button.tag == 2) {
            [self.delegate tableViewCell:self acceptOrderAtIndexPath:self.indexPath];        
        } else if (button.tag == 3) {
            [self.delegate tableViewCell:self changeCourierAtIndexPath:self.indexPath];
        }
    } else if ([[sender view] isKindOfClass:[UILabel class]]) {
        [self.delegate tableViewCell:self didSelectPriceAtIndexPath:self.indexPath];
    } else {
        if ([[sender view] tag] == 1) {
            [self.delegate tableViewCell:self didSelectUserAtIndexPath:self.indexPath];
        } else if ([[sender view] tag] == 2) {
            [self.delegate tableViewCell:self didSelectPriceAtIndexPath:self.indexPath];
        }
    }
}

@end
