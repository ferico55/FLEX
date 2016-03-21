//
//  EditShopTypeViewCell.h
//  Tokopedia
//
//  Created by Tokopedia on 3/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditShopTypeViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *goldMerchantBadgeView;
@property (weak, nonatomic) IBOutlet UILabel *regularMerchantLabel;

- (void)showsGoldMerchantBadge;

@end
