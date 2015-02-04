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

    UITapGestureRecognizer *priceViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    priceViewTap.numberOfTapsRequired = 1;
    
    _priceView.userInteractionEnabled = YES;
    [_priceView addGestureRecognizer:priceViewTap];

    [self.acceptButton.titleLabel setFont:[UIFont fontWithName:@"GothamBook" size:12]];
    [self.acceptButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];

    [self.rejectButton.titleLabel setFont:[UIFont fontWithName:@"GothamBook" size:12]];
    [self.rejectButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


#pragma mark - Actions

- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        if (button.tag == 1) {

            [self.rejectButton.titleLabel setFont:[UIFont fontWithName:@"GothamMedium" size:12]];
            
            [self.delegate tableViewCell:self rejectOrderAtIndexPath:self.indexPath];
        
        } else {

            [self.acceptButton.titleLabel setFont:[UIFont fontWithName:@"GothamMedium" size:12]];
            
            [self.delegate tableViewCell:self acceptOrderAtIndexPath:self.indexPath];
        
        }
    } else {
        [self.delegate tableViewCell:self didSelectPriceAtIndexPath:self.indexPath];
    }
}


@end
