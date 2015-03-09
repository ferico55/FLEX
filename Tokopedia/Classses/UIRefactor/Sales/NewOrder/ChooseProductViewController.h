//
//  ChooseProductViewController.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChooseProductDelegate <NSObject>

- (void)didSelectProducts:(NSArray *)products;

@end

@interface ChooseProductViewController : UIViewController

@property (strong, nonatomic) NSArray *products;
@property (weak, nonatomic) id<ChooseProductDelegate> delegate;

@end
