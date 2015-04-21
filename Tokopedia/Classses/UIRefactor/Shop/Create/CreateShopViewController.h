//
//  CreateShopViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 4/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TokopediaNetworkManager.h"
#import "MoreViewController.h"

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




@protocol CustomTxtViewProtocol <NSObject>
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;
@end

@interface CustomTxtView : UITextView<CustomTxtViewProtocol>
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, strong) UILabel *placeHolderLabel;
@property (nonatomic, unsafe_unretained) id<CustomTxtViewProtocol> createShopViewController;
- (void)textChanged:(NSNotification*)notification;
@end





@interface CreateShopViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, TokopediaNetworkManagerDelegate, CustomTxtViewProtocol>
{
    IBOutlet UITableView *tblCreateShop;
}

@property (nonatomic, unsafe_unretained) MoreViewController *moreViewController;
- (NSDictionary *)getDictContentPhoto;
- (NSString *)getSlogan;
- (NSString *)getDesc;
- (NSString *)getNamaToko;
- (NSString *)getNamaDomain;
@end
