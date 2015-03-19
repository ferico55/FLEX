//
//  ShopDescriptionView.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopDescriptionView : UIView

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
//@property (weak, nonatomic) IBOutlet UIImageView *badgeImageView;

+(id)newView;

@end
