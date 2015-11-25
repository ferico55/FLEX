//
//  ProductReputationCell.h
//  Tokopedia
//
//  Created by Tokopedia on 6/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductReputationSimpleCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UIView *reputationMessageView;
@property(nonatomic, weak) IBOutlet UIView *reputationBuyerView;
@property(nonatomic, weak) IBOutlet UIView *listReputationView;
@property(nonatomic, weak) IBOutlet UIView *reputationStarView;

@property(nonatomic, weak) IBOutlet UILabel *reputationMessageLabel;
@property(nonatomic, weak) IBOutlet UILabel *reputationBuyerLabel;
@property(nonatomic, weak) IBOutlet UILabel *reputationDateLabel;
@property(nonatomic, weak) IBOutlet UILabel *reputationScoreLabel;

@property(nonatomic, weak) IBOutlet UIImageView *reputationBuyerImage;

@end
