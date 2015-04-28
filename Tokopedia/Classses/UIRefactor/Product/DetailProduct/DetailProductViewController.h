//
//  DetailProductViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Detail Product View Controller
@interface DetailProductViewController : UIViewController
{
    IBOutlet UIView *viewTableContentHeader;
    IBOutlet UIButton *btnWishList, *btnShare;
    IBOutlet UIActivityIndicatorView *headerActivityIndicator, *merchantActivityIndicator;
    IBOutlet UIPageControl *otherProductPageControl;
    IBOutlet UILabel *lblDescTokoTutup;
}
@property (strong,nonatomic) NSDictionary *data;

- (IBAction)actionShare:(id)sender;
- (IBAction)actionWishList:(id)sender;
@end
