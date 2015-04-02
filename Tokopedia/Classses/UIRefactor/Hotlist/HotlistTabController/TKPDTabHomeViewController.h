//
//  TKPDTabHomeViewController.h
//  Tokopedia
//
//  Created by Tokopedia PT on 12/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TKPDTabHomeDelegate <NSObject>

- (void)pushViewController:(id)viewController;

@end

@interface TKPDTabHomeViewController : UIViewController



@end
