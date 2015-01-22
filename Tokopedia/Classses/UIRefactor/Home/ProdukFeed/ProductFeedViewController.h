//
//  ProdukFeedViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/27/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductFeedViewController : UIViewController

@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) UINavigationController *navcon;

- (id)initWithPosition:(NSInteger)position withNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

@end
