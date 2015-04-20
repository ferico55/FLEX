//
//  BerhasilBukaTokoViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 4/17/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BerhasilBukaTokoViewController : UIViewController
{
    IBOutlet UILabel *lblCongratulation, *lblUrl, *lblSubCongratulation, *lblTambahProduct, *lblDescTambahProduct;
    IBOutlet UITextView *txtURL;
    IBOutlet UIScrollView *contentScrollView;
    IBOutlet UIButton *btnTambahProduct;
    IBOutlet UIView *viewContentDesc;
}

- (IBAction)actionTambahProduct:(id)sender;
@end
