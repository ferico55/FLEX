//
//  CategoryViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/27/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryViewCell.h"

#define kTKPDCATEGORYVIEWCELL_IDENTIFIER @"CategoryViewController"

@interface CategoryViewController : UIViewController

@property(strong,nonatomic) NSDictionary* data;

@end
