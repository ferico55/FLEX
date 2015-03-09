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
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setDisputeStatus:(NSString *)disputeStatus
{
    _disputeStatus = disputeStatus;
    if ([_disputeStatus isEqualToString:@"100"]) {
        _statusLabel.text = @"Diskusi";
        _statusLabel.backgroundColor = COLOR_STATUS_PROCESSING;
    }
    else if ([_disputeStatus isEqualToString:@"300"]) {
        _statusLabel.text = @"Solusi";
        _statusLabel.backgroundColor = COLOR_STATUS_PROCESSING;
    }
    else if ([_disputeStatus isEqualToString:@"0"])
    {
        _statusLabel.text = @"Selesai";
        _statusLabel.backgroundColor = COLOR_STATUS_DONE;
    }
}

@end
