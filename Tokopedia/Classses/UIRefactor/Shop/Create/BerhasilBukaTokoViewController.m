//
//  BerhasilBukaTokoViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 4/17/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "BerhasilBukaTokoViewController.h"
#import "ProductAddEditViewController.h"
#import "MoreViewController.h"
#import "string_more.h"
#import "string_product.h"
#import "ShopContainerViewController.h"

@interface BerhasilBukaTokoViewController ()

@end

@implementation BerhasilBukaTokoViewController
@synthesize dictData, isAnyImage;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = CStringBukaToko;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:CStringSelesai style:UIBarButtonItemStylePlain target:self action:@selector(actionBack:)];
    self.navigationItem.hidesBackButton = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shopCreated" object:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initAttributeText:lblCongratulation withStrText:[NSString stringWithFormat:CStringCongratulation, [dictData objectForKey:kTKPD_SHOPNAMEKEY]] withFont:[UIFont fontWithName:CFont_Gotham_Book size:15.0f] withColor:lblCongratulation.textColor withTextAlignment:NSTextAlignmentCenter];
    txtURL.text = [dictData objectForKey:kTKPD_SHOPURL];
    [self initAttributeText:lblSubCongratulation withStrText:lblSubCongratulation.text withFont:[UIFont fontWithName:CFont_Gotham_Book size:13.0f] withColor:lblSubCongratulation.textColor withTextAlignment:NSTextAlignmentCenter];
    lblTambahProduct.font = lblUrl.font = [UIFont fontWithName:CFont_Gotham_Book size:16.0f];
    [self initAttributeText:lblDescTambahProduct withStrText:CStringContentTambahProduct withFont:[UIFont fontWithName:CFont_Gotham_Book size:14.0f] withColor:lblTambahProduct.textColor withTextAlignment:NSTextAlignmentLeft];
    
    
    
    CGRect rect = CGRectMake(0, 0, btnTambahProduct.bounds.size.height/2.0f, btnTambahProduct.bounds.size.height/2.0f);
    UIGraphicsBeginImageContext(rect.size);
    [[UIImage imageNamed:@"icon_plus_blue.png"] drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [btnTambahProduct setImage:image forState:UIControlStateNormal];
    CGFloat spacing = 8;
    btnTambahProduct.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, spacing);
    btnTambahProduct.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
    [self settingFrame];
}


#pragma mark - Action View
- (void)actionBack:(id)sender
{
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *_auth = [secureStorage keychainDictionary];
    ShopContainerViewController *container = [[ShopContainerViewController alloc] init];
    container.data = @{MORE_SHOP_ID : [_auth objectForKey:MORE_SHOP_ID],
                       MORE_AUTH : _auth,
                       MORE_SHOP_NAME : [_auth objectForKey:MORE_SHOP_NAME]
                       };
    NSMutableArray *tempController = [self.navigationController.viewControllers mutableCopy];
    int n = (int)tempController.count;
    for(int i=0;i<n-1;i++) {
        [tempController removeLastObject];
    }
    [tempController insertObject:container atIndex:tempController.count];
    
    self.navigationController.viewControllers = tempController;
}


#pragma mark - Method
- (void)initAttributeText:(UILabel *)lblDesc withStrText:(NSString *)strText withFont:(UIFont *)fontDesc withColor:(UIColor *)color withTextAlignment:(NSTextAlignment)textAlignment
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 8.0;
    style.alignment = textAlignment;
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName:color,
                                 NSFontAttributeName: fontDesc,
                                 NSParagraphStyleAttributeName: style,
                                 };
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:strText attributes:attributes];
    lblDesc.attributedText = attributedText;
}


#pragma mark - UIView
- (void)settingFrame
{
    int padding = 10;
    CGSize tempSize = [lblCongratulation sizeThatFits:CGSizeMake(self.view.bounds.size.width-(padding *2), 9999)];
    lblCongratulation.frame = CGRectMake(padding, padding, self.view.bounds.size.width-20, tempSize.height);
    
    lblSubCongratulation.frame = CGRectMake(padding, lblCongratulation.frame.origin.y+lblCongratulation.bounds.size.height+padding, lblCongratulation.bounds.size.width, lblSubCongratulation.bounds.size.height);
    lblUrl.frame = CGRectMake(padding, lblSubCongratulation.frame.origin.y+lblSubCongratulation.bounds.size.height+padding, lblSubCongratulation.bounds.size.width, lblUrl.bounds.size.height);
    txtURL.contentInset = UIEdgeInsetsMake(0, padding*4, 0, padding*2);
    txtURL.frame = CGRectMake(0, lblUrl.frame.origin.y+lblUrl.bounds.size.height, self.view.bounds.size.width, txtURL.bounds.size.height);
    lblTambahProduct.frame = CGRectMake(padding, txtURL.frame.origin.y+txtURL.bounds.size.height+padding, txtURL.bounds.size.width, lblTambahProduct.bounds.size.height);
    viewContentDesc.frame = CGRectMake(0, lblTambahProduct.frame.origin.y+lblTambahProduct.bounds.size.height+padding, [UIScreen mainScreen].bounds.size.width, viewContentDesc.bounds.size.height);
    btnTambahProduct.frame = CGRectMake(padding, padding+viewContentDesc.frame.origin.y+viewContentDesc.bounds.size.height, self.view.bounds.size.width-(padding*2), btnTambahProduct.bounds.size.height);
    [contentScrollView setContentSize:CGSizeMake(self.view.bounds.size.width, btnTambahProduct.frame.origin.y+btnTambahProduct.bounds.size.height+padding)];
}


#pragma mark - Action Method
- (IBAction)actionTambahProduct:(id)sender
{
    ProductAddEditViewController *productViewController = [ProductAddEditViewController new];
    productViewController.type = TYPE_ADD_EDIT_PRODUCT_ADD;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:productViewController];
    nav.navigationBar.translucent = NO;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}
@end
