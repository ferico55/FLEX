//
//  InboxResolutionCenterComplainCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxResolutionCenterComplainCell.h"
#import "string_inbox_resolution_center.h"


@implementation InboxResolutionCenterComplainCell

#pragma mark - Factory methods
+ (id)newCell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"InboxResolutionCenterComplainCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}


- (void)awakeFromNib {
    
    [_warningLabel setCustomAttributedText:@"Komplain lebih dari 30 hari"];
}

- (IBAction)actionReputation:(id)sender {
    [_delegate actionReputation:sender];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setDisputeStatus:(NSString *)disputeStatus
{
    _disputeStatus = disputeStatus;
    
    NSInteger disputeStatusInteger = [_disputeStatus integerValue];
    
    if (disputeStatusInteger == RESOLUTION_OPEN)
    {
        _statusLabel.text = @"Diskusi";
        _statusLabel.backgroundColor = COLOR_STATUS_PROCESSING;
    }
    else if (disputeStatusInteger == RESOLUTION_DO_ACTION)
    {
        _statusLabel.text = @"Retur";
        _statusLabel.backgroundColor = COLOR_STATUS_PROCESSING;
    }
    else if(disputeStatusInteger == RESOLUTION_CS_ANSWERED)
    {
        _statusLabel.text = @"Solusi";
        _statusLabel.backgroundColor = COLOR_STATUS_PROCESSING;
    }
    else if (disputeStatusInteger == RESOLUTION_CANCELED || disputeStatusInteger == RESOLUTION_FINISHED)
    {
        _statusLabel.text = @"Selesai";
        _statusLabel.backgroundColor = COLOR_STATUS_DONE;
    }

}
- (IBAction)gesture:(id)sender {
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer*)sender;
    if (gesture.view.tag == 10)
        [_delegate goToInvoiceAtIndexPath:_indexPath];
    else if(gesture.view.tag == 11)
        [_delegate goToShopOrProfileAtIndexPath:_indexPath];
    else if (gesture.view.tag == 12)
        [_delegate goToResolutionDetailAtIndexPath:_indexPath];
    else if (gesture.view.tag == 13)
        [_delegate showImageAtIndexPath:_indexPath];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView layoutIfNeeded];
    self.statusLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.statusLabel.frame);
}

@end
