//
//  ProductAddEditViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DKAsset;

@interface SelectedImage : NSObject
    @property (nonatomic, strong) UIImage *image;
    @property (nonatomic, strong) NSString *desc;
    @property (nonatomic, strong) NSString *imageID;
    @property (nonatomic, strong) NSString *filePath;
    @property (nonatomic, strong) NSString *imagePrimary;
    @property (nonatomic, strong) NSString *URLString;
    @property BOOL isFromAsset;
@end

@interface ProductAddEditViewController : UIViewController

@property (nonatomic, strong) NSDictionary *data;

@end
