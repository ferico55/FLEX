//
//  ReputationDetailFormViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 3/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReputationDetailFormViewController : UIViewController

@property (strong, nonatomic) NSDictionary* data;
@property (nonatomic) int reviewIndex;
@property (nonatomic) BOOL isEditForm;
@property (nonatomic) BOOL isViewForm;

@end
