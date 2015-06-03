//
//  DetailProductViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#pragma mark - Detail Product View Controller
@interface DetailProductViewController : GAITrackedViewController
{
    IBOutlet UIView *viewTableContentHeader, *viewContentWishList, *viewContentUlasanAndDiskusi, *viewContentWarehouse;
    IBOutlet UIButton *btnWishList, *btnShare;
    IBOutlet UIActivityIndicatorView *headerActivityIndicator, *merchantActivityIndicator;
    IBOutlet UIPageControl *otherProductPageControl;
    IBOutlet UILabel *lblDescTokoTutup, *lblOtherProductTitle, *lblTitleWarehouse, *lblDescWarehouse;
    IBOutlet NSLayoutConstraint *constraintHeightWarehouse;
}
@property (strong,nonatomic) NSDictionary *data;

- (float)calculateHeightLabelDesc:(CGSize)size withText:(NSString *)strText;
- (void)setBackgroundPriceAlert:(BOOL)isActive;
- (IBAction)actionShare:(id)sender;
- (IBAction)actionWishList:(id)sender;
@end
