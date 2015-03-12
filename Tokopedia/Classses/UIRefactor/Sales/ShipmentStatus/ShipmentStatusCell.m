//
//  ShipmentStatusCell.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/27/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ShipmentStatusCell.h"

@interface ShipmentStatusCell () {
    NSDictionary *_statusLabelAttributes;
}

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UIView *userView;

@end

@implementation ShipmentStatusCell

- (void)awakeFromNib {    
    CGRect frame = _oneButtonView.frame;
    frame.origin.y = 201;
    _oneButtonView.frame = frame;
    [_containerView addSubview:_oneButtonView];

    frame = _twoButtonsView.frame;
    frame.origin.y = 201;
    _twoButtonsView.frame = frame;
    [_containerView addSubview:_twoButtonsView];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    
    _statusLabelAttributes = @{
                                NSForegroundColorAttributeName  : [UIColor blackColor],
                                NSFontAttributeName             : _statusLabel.font,
                                NSParagraphStyleAttributeName   : style,
                              };
    
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

- (void)showAllButton
{
    _twoButtonsView.hidden = NO;
}

- (void)showTrackButton
{
    _oneButtonView.hidden = NO;
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
    _statusLabel.attributedText = [[NSAttributedString alloc] initWithString:status
                                                                  attributes:_statusLabelAttributes];
}


- (void)hideAllButton
{
    _oneButtonView.hidden = YES;
    _twoButtonsView.hidden = YES;
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
