//
//  InboxTicketCell.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InboxTicketCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

+ (id)initCell;

@end
