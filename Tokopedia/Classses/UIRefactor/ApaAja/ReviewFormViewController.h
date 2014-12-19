//
//  ReviewFormViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 12/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewFormViewController : UIViewController

@property (strong, nonatomic) NSDictionary* data;
@property (nonatomic) BOOL isEditForm;
@property (nonatomic) BOOL isViewForm;

@end
