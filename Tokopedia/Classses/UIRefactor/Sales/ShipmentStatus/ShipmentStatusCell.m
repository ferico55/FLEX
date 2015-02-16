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
    
    UITapGestureRecognizer *statusViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(tap:)];
    statusViewTap.numberOfTapsRequired = 1;
    _statusView.userInteractionEnabled = YES;
    [_statusView addGestureRecognizer:statusViewTap];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)showAllButton
{
    _oneButtonView.hidden = NO;
}

- (void)showTrackButton
{
    _twoButtonsView.hidden = NO;
}

- (void)hideDayLeftInformation
{
    _dateFinishLabel.hidden = YES;
    _finishLabel.hidden = YES;
}

- (void)setStatusLabelText:(NSString *)text
{
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
    } else {
        [self.delegate didTapStatusAtIndexPath:_indexPath];
    }
}


@end
