//
//  ShipmentStatusCell.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/27/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ShipmentStatusCell.h"

#import "Tokopedia-Swift.h"

@interface ShipmentStatusCell ()

@property (weak, nonatomic) IBOutlet UIView *userView;
@property (weak, nonatomic) IBOutlet OrderButtonView *buttonsView;

@end

@implementation ShipmentStatusCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _oneButtonView.hidden = YES;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    CGRect frame = _containerView.frame;
    frame.size.width = screenWidth-20;
    _containerView.frame = frame;
    
    frame = _oneButtonView.frame;
    frame.origin.y = 201;
    frame.size.width = _containerView.frame.size.width;
    _oneButtonView.frame = frame;
    [_containerView addSubview:_oneButtonView];

    _twoButtonsView.hidden = YES;
    
    frame = _twoButtonsView.frame;
    frame.origin.y = 201;
    frame.size.width = _containerView.frame.size.width;
    _twoButtonsView.frame = frame;
    [_containerView addSubview:_twoButtonsView];
    
    UITapGestureRecognizer *invoiceTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(tap:)];
    _invoiceNumberLabel.tag = 1;
    _invoiceNumberLabel.userInteractionEnabled = YES;
    [_invoiceNumberLabel addGestureRecognizer:invoiceTap];

    UITapGestureRecognizer *userTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(tap:)];
    _userView.tag = 1;
    _userView.userInteractionEnabled = YES;
    [_userView addGestureRecognizer:userTap];
    
    UITapGestureRecognizer *statusViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(tap:)];
    _statusView.tag = 2;
    _statusView.userInteractionEnabled = YES;
    [_statusView addGestureRecognizer:statusViewTap];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)showTrackButtonOnTap:(void (^)(OrderTransaction *))onTap{
    [_buttonsView addTrackButton:^{
        onTap(_order);
    }];
}

- (void)showAskBuyerButtonOnTap:(void (^)(OrderTransaction *))onTap{
    [_buttonsView addAskBuyerButton:^{
        onTap(_order);
    }];
}

-(void)showRetryButtonOnTap:(void (^)(OrderTransaction *))onTap{
    [_buttonsView addRetryButton:^{
        onTap(_order);
    }];
}

-(void)showEditResiButtonOnTap:(void (^)(OrderTransaction *))onTap{
    [_buttonsView addChangeResiButton:^{
        onTap(_order);
    }];
}

- (void)showAllButton
{
    _twoButtonsView.hidden = NO;
    _oneButtonView.hidden = YES;
}

- (void)showTrackButton
{
    _oneButtonView.hidden = NO;
    _twoButtonsView.hidden = YES;
}

- (void)hideDayLeftInformation
{
    _dateFinishLabel.hidden = YES;
    _finishLabel.hidden = YES;
}

- (void)setStatusLabelText:(NSString *)text
{
    text = text ?: @"-";
    NSString *status = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    status = [status stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    _statusLabel.text = status;
}


- (void)hideAllButton{
    [_buttonsView removeAllButtons];
}

- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender; 
        if (button.tag == 1) {
            [self.delegate didTapTrackButton:button indexPath:_indexPath];
        } else if (button.tag == 2) {
            [self.delegate didTapReceiptButton:button indexPath:_indexPath];
        }
    } else if ([[sender view] isKindOfClass:[UILabel class]]) {
        [self.delegate didTapStatusAtIndexPath:_indexPath];
    } else if ([[sender view] isKindOfClass:[UIView class]]) {
        if ([[sender view] tag] == 1) {
            [self.delegate didTapUserAtIndexPath:_indexPath];
        } else if ([[sender view] tag] == 2) {
            [self.delegate didTapStatusAtIndexPath:_indexPath];
        }
    }
}


@end
