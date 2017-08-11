//
//  ProdukFeedViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/27/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductFeedViewController : GAITrackedViewController

@property (assign, nonatomic) BOOL isOpened;
@property NSInteger index;
- (void) scrollToTop;
@end
