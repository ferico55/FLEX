//
//  ProductGalleryViewController.h
//  Tokopedia
//
//  Created by Tonito Acen on 3/24/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductGalleryViewController : UIViewController <UIScrollViewDelegate> {
    UIImageView *_productGallery;
}

@property (strong,nonatomic) NSDictionary *data;


@end
