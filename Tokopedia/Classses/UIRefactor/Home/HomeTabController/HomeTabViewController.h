//
//  HomeTabViewController.h
//  Tokopedia
//
//  Created by Tonito Acen on 3/30/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeTabViewController : UIViewController

@property(strong, nonatomic) NSString* url;

- (void)setIndexPage:(int)idxPage;
- (void)redirectToProductFeed;
- (void)redirectToWishList;
@end
