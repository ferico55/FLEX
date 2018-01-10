//
//  SalesOrderCell.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/14/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "SalesOrderCell.h"
#import "Tokopedia-Swift.h"

@interface SalesOrderCell ()

@property (weak, nonatomic) IBOutlet OrderButtonView *buttonsView;

@end

@implementation SalesOrderCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.invoiceNumberLabel.accessibilityLabel = @"invoiceNumber";
    self.remainingDaysLabel.accessibilityLabel = @"remainingDays";
    self.automaticallyCanceledLabel.accessibilityLabel = @"automaticallyCancel";
    self.userView.accessibilityLabel = @"userView";
    self.userNameLabel.accessibilityLabel = @"userName";
    self.purchaseDateLabel.accessibilityLabel = @"purchaseDate";
    self.paymentAmountLabel.accessibilityLabel = @"paymentAmount";
    self.dueDateLabel.accessibilityLabel = @"dueDate";
    self.statusView.accessibilityLabel = @"statusView";
    self.priceView.accessibilityLabel = @"priceView";
    self.lastStatusLabel.accessibilityLabel = @"lastStatusLabel";
    
    
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

-(void)removeAllButtons{
    [_buttonsView removeAllButtons];
}

-(void)showAcceptButtonOnTap:(void (^)(OrderTransaction *))onTap{
    [_buttonsView addAcceptButton:^{
        onTap(_order);
    }];
}

-(void)showRejectButtonOnTap:(void (^)(OrderTransaction *))onTap{
    [_buttonsView addRejectButton:^{
        onTap(_order);
    }];
}

-(void)showPickUpButtonOnTap:(void (^)(OrderTransaction *))onTap{
    [_buttonsView addPickupButton:^{
        onTap(_order);
    }];
}

-(void)showConfirmButtonOnTap:(void (^)(OrderTransaction *))onTap{
    [_buttonsView addConfirmButton:^{
        onTap(_order);
    }];
}

-(void)showCancelButtonOnTap:(void (^)(OrderTransaction *))onTap{
    [_buttonsView addCancelButton:^{
        onTap(_order);
    }];
}

-(void)showAskBuyerButtonOnTap:(void (^)(OrderTransaction *))onTap{
    [_buttonsView addAskBuyerButton:^{
        onTap(_order);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - Actions

- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {

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
