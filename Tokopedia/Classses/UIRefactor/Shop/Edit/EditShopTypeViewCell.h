//
//  EditShopTypeViewCell.h
//  Tokopedia
//
//  Created by Tokopedia on 3/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol EditShopTypeViewCellDelegate <NSObject>
-(void)merchantInfoButtonTapped;

@end
@interface EditShopTypeViewCell : UITableViewCell

@property (nonatomic, weak) id<EditShopTypeViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *goldMerchantBadgeView;
@property (weak, nonatomic) IBOutlet UILabel *merchantStatusLabel;
@property (strong, nonatomic) IBOutlet UILabel *merchantDescriptionLabel;
@property (strong, nonatomic) IBOutlet UIButton *merchantInfoButton;

- (void)initializeInterfaceWithGoldMerchantStatus:(BOOL)isGoldMerchant;
- (void)initializeInterfaceWithGoldMerchantStatus:(BOOL)isGoldMerchant expiryDate:(NSString*)expiryDate;

@end
