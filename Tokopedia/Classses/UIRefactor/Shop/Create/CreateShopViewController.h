//
//  CreateShopViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 4/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TokopediaNetworkManager.h"
@interface CustomHeaderFooterTable : UITableViewHeaderFooterView
{
    UILabel *lblHeader, *lblFooter;
    UIButton *btnCheckDomain;
}

- (void)initLbl:(UIFont *)font andColor:(UIColor *)color andFrame:(CGRect)rect isHeader:(BOOL)isHeader;
- (void)setLblFrame:(CGRect)rect isHeader:(BOOL)isHeader;
- (void)initBtn:(UIFont *)font andColor:(UIColor *)color andFrame:(CGRect)rect;
- (void)setBtnFrame:(CGRect)rect;
@end



@interface CreateShopViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, TokopediaNetworkManagerDelegate>
{
    IBOutlet UITableView *tblCreateShop;
}
@end
