//
//  EditShopImageViewCell.h
//  Tokopedia
//
//  Created by Tokopedia on 3/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditShopImageViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *shopImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIButton *changeImageButton;

@end
