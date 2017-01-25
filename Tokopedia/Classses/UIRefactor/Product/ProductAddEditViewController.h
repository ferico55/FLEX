//
//  ProductAddEditViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TYPE_ADD_EDIT_PRODUCT)
{
    TYPE_ADD_EDIT_PRODUCT_DEFAULT = 0,
    TYPE_ADD_EDIT_PRODUCT_ADD,
    TYPE_ADD_EDIT_PRODUCT_EDIT,
    TYPE_ADD_EDIT_PRODUCT_COPY
};

@interface ProductAddEditViewController : UIViewController

@property (nonatomic, strong) NSString *productID;
@property (nonatomic) TYPE_ADD_EDIT_PRODUCT type;

@end
