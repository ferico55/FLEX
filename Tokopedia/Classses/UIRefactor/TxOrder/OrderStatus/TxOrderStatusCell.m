//
//  TxOrderStatusCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/17/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderStatusCell.h"
#import "string_tx_order.h"

@implementation TxOrderStatusCell

#pragma mark - Factory methods
+ (id)newCell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"TxOrderStatusCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)awakeFromNib {
    CGRect frame = _oneButtonView.frame;
    frame.origin.y = _statusView.frame.origin.y + _statusView.frame.size.height;
    _oneButtonView.frame = frame;
    [_containerView addSubview:_oneButtonView];
    
    frame = _oneButtonReOrderView.frame;
    frame.origin.y = _statusView.frame.origin.y + _statusView.frame.size.height;
    _oneButtonReOrderView.frame = frame;
    [_containerView addSubview:_oneButtonReOrderView];
    
    frame = _twoButtonsView.frame;
    frame.origin.y = _statusView.frame.origin.y + _statusView.frame.size.height;
    _twoButtonsView.frame = frame;
    [_containerView addSubview:_twoButtonsView];
    
    frame = _threeButtonsView.frame;
    frame.origin.y = _statusView.frame.origin.y + _statusView.frame.size.height;
    _threeButtonsView.frame = frame;
    [_containerView addSubview:_threeButtonsView];
}


- (void)hideAllButton
{
    _oneButtonView.hidden = YES;
    _oneButtonReOrderView.hidden = YES;
    _twoButtonsView.hidden = YES;
    _threeButtonsView.hidden = YES;
}

-(void)setDeadlineProcessDayLeft:(NSInteger)deadlineProcessDayLeft
{
    _deadlineProcessDayLeft = deadlineProcessDayLeft;
    NSString *finishLabelText;
    UIColor *finishLabelColor;
    switch (deadlineProcessDayLeft) {
        case 5:
            finishLabelText = @"5 Hari Lagi";
            finishLabelColor = COLOR_STATUS_CANCEL_3DAYS;
            [_finishLabel setHidden:NO];
            [_cancelAutomaticLabel setHidden:NO];
            break;
        case 4:
            finishLabelText = @"4 Hari Lagi";
            finishLabelColor = COLOR_STATUS_CANCEL_3DAYS;
            [_finishLabel setHidden:NO];
            [_cancelAutomaticLabel setHidden:NO];
            break;
        case 3:
            finishLabelText = @"3 Hari Lagi";
            finishLabelColor = COLOR_STATUS_CANCEL_3DAYS;
            [_finishLabel setHidden:NO];
            [_cancelAutomaticLabel setHidden:NO];
            break;
        case 2:
            finishLabelText = @"2 Hari Lagi";
            finishLabelColor = COLOR_STATUS_CANCEL_3DAYS;
            [_finishLabel setHidden:NO];
            [_cancelAutomaticLabel setHidden:NO];
            break;
        case 1:
            finishLabelText = @"Besok";
            finishLabelColor = COLOR_STATUS_CANCEL_TOMORROW;
            [_finishLabel setHidden:NO];
            [_cancelAutomaticLabel setHidden:NO];
            break;
        case  0:
            finishLabelText = @"Hari Ini";
            finishLabelColor = COLOR_STATUS_CANCEL_TODAY;
            [_finishLabel setHidden:NO];
            [_cancelAutomaticLabel setHidden:NO];
            break;
        default:
            break;
    }
    if (deadlineProcessDayLeft<0) {
        finishLabelText = @"Expired";
        finishLabelColor = COLOR_STATUS_EXPIRED;
        [_finishLabel setHidden:NO];
        [_cancelAutomaticLabel setHidden:NO];
    }
    
    [_finishLabel setText:finishLabelText animated:YES];
    _finishLabel.backgroundColor = finishLabelColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)tap:(id)sender {
    [_delegate statusDetailAtIndexPath:_indexPath];
}
- (IBAction)tapConfirm:(id)sender {
    [_delegate confirmDeliveryAtIndexPath:_indexPath];
}
- (IBAction)tapTrackOrder:(id)sender {
    [_delegate trackOrderAtIndexPath:_indexPath];
}
- (IBAction)tapReOrder:(id)sender {
    [_delegate reOrderAtIndexPath:_indexPath];
}
- (IBAction)tapComplain:(id)sender {
    [_delegate complainAtIndexPath:_indexPath];
}


@end
