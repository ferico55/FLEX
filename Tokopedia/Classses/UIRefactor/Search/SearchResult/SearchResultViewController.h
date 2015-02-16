//
//  SearchResultViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Search Result View Controller

@interface SearchResultViewController : UIViewController

@property (strong,nonatomic) NSDictionary *data;
@property (weak, nonatomic) IBOutlet UILabel *pricelabel;
@property (weak, nonatomic, setter = setImageUrl:) NSString *urlstring;
@property (weak, nonatomic) IBOutlet UIImageView *productimageview;

@end
