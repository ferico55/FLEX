//
//  TrackOrderHistoryCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/24/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TRACK_ORDER_HISTORY_CELL_IDENTIFIER @"TrackOrderHistoryCellIdentifier"

@interface TrackOrderHistoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateHistoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;

+(id)newCell;

@end
