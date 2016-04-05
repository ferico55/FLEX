//
//  EtalaseCell.h
//  Tokopedia
//
//  Created by Johanes Effendi on 4/5/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EtalaseCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;
@property (strong, nonatomic) IBOutlet UIImageView *checkImageView;

@property (nonatomic) BOOL showDetail;
@property (nonatomic) BOOL showChevron;
@property (nonatomic) BOOL showCheckImage;

@end
