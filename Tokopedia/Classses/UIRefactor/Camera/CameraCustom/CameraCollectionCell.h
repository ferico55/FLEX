//
//  CameraCollectionCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/13/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface CameraCollectionCell : UICollectionViewCell
+ (id)newcell;
@property (weak, nonatomic) IBOutlet UIImageView *thumb;
@property(nonatomic, strong) ALAsset *asset;
@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImageView;

@end
