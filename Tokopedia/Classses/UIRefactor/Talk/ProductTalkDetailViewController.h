//
//  ProductTalkDetailViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 10/16/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Detail Product Talk Detail View Controller
@interface ProductTalkDetailViewController : UIViewController
{
    IBOutlet UIButton *btnReputation;
}

@property (strong,nonatomic) NSDictionary *data;

@end
