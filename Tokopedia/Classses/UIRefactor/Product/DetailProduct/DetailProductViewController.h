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
    IBOutlet UIButton *btnWishList, *btnShare, *btnReputasi, *btnKecepatan, *btnPriceAlert, *btnReport;
    IBOutlet UIActivityIndicatorView *headerActivityIndicator, *merchantActivityIndicator;
    IBOutlet UIPageControl *otherProductPageControl;
    IBOutlet UILabel *lblDescTokoTutup, *lblOtherProductTitle, *lblTitleWarehouse, *lblDescWarehouse;

    IBOutlet NSLayoutConstraint *constraintHeightWarehouse, *constraintHeightScrollOtherView;
}

@property (strong,nonatomic) NSDictionary *data;
@property (strong,nonatomic) NSDictionary *loadedData;
@property (strong,nonatomic) NSDictionary *jason;
@property BOOL isSnapSearchProduct;

- (void)setButtonFav;
- (float)calculateHeightLabelDesc:(CGSize)size withText:(NSString *)strText withColor:(UIColor *)color withFont:(UIFont *)font withAlignment:(NSTextAlignment)textAlignment;
- (void)setBackgroundPriceAlert:(BOOL)isActive;
- (IBAction)actionShare:(id)sender;
- (IBAction)actionWishList:(id)sender;
- (IBAction)actionReputasi:(id)sender;
- (IBAction)actionKecepatan:(id)sender;
- (IBAction)actionPriceAlert:(id)sender;
@end
