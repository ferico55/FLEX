//
//  ResolutionCenterCreateStepOneCell.h
//  Tokopedia
//
//  Created by Johanes Effendi on 8/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResolutionCenterCreateStepOneCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (strong, nonatomic) IBOutlet UILabel *productName;
@property (strong, nonatomic) IBOutlet UIImageView *badgeProsecure;
@property (strong, nonatomic) IBOutlet UILabel *labelProsecure;
@property (strong, nonatomic) IBOutlet UIImageView *iconChecklist;

+ (id)newcell;
@end
