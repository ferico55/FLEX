//
//  SearchResultShopCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchShopModelView;

@interface SearchResultShopCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *shopImage;
@property (weak, nonatomic) IBOutlet UILabel *shopName;
@property (weak, nonatomic) IBOutlet UILabel *shopLocation;
@property (weak, nonatomic) IBOutlet UIImageView *goldBadgeView;

@property (weak, nonatomic) SearchShopModelView* modelView;


@end
