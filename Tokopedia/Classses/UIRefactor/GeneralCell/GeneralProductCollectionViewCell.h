//
//  GeneralProductCollectionViewCell.h
//  Tokopedia
//
//  Created by Tonito Acen on 5/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GeneralProductCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *thumb;
@property (strong, nonatomic) IBOutlet UILabel *labelprice;
@property (strong, nonatomic) IBOutlet UILabel *labeldescription;
@property (strong, nonatomic) IBOutlet UILabel *labelalbum;
@property (strong, nonatomic) IBOutlet UIImageView *isGoldShop;

@end
