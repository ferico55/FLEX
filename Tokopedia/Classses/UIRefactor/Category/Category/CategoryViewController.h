//
//  CategoryViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/27/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKPDTabHomeViewController.h"
#import "BannerCollectionReusableView.h"

@interface CategoryViewController : GAITrackedViewController

@property(strong,nonatomic) NSDictionary* data;
@property (weak, nonatomic) id<TKPDTabHomeDelegate> delegate;

@end
