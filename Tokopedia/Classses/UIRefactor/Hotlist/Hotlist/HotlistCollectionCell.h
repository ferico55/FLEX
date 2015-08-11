//
//  HotlistCollectionCell.h
//  Tokopedia
//
//  Created by Renny Runiawati on 6/18/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HotlistViewModel.h"

@interface HotlistCollectionCell : UICollectionViewCell

- (void)setViewModel:(HotlistViewModel*)viewModel;
@property (weak, nonatomic) IBOutlet UIImageView *productimageview;

@end
