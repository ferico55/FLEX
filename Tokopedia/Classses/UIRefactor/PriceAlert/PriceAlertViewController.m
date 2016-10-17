//
//  PriceAlertViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 5/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "CatalogViewController.h"
#import "CatalogInfo.h"
#import "DetailProductViewController.h"
#import "DetailPriceAlert.h"
#import "GeneralAction.h"
#import "PriceAlertViewController.h"
#import "ProductDetail.h"
#import "RKObjectManager.h"
#import "string_price_alert.h"
#import "TokopediaNetworkManager.h"
#import "PriceAlertRequest.h"

#define CTagEditPriceAlert 1
#define CTagAddPriceAlert 2
#define CTagAddCatalogPriceAlert 3


@interface PriceAlertViewController ()<TokopediaNetworkManagerDelegate> {
    TokopediaNetworkManager *tokopediaNetworkManager;
    RKObjectManager *rkObjectManager;
    
    UIBarButtonItem *rightBarButtonItem;
    BOOL isEditCatalog;
    
    PriceAlertRequest *_request;
}
@end

@implementation PriceAlertViewController

- (NSString *)formatRupiah:(NSString *)strRupiah {
    if([strRupiah isEqualToString:@""]) {
        strRupiah = @"0";
    }
    
    NSMutableString *result = [NSMutableString stringWithString:strRupiah];
    int n = (int)strRupiah.length;
    
    while (n-3 > 0) {
        [result insertString:@"." atIndex:n-3];
        n -= 3;
    }
    
    return [NSString stringWithFormat:@"Rp %@", result];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _request = [PriceAlertRequest new];
    
    if(_detailPriceAlert!=nil && ![_detailPriceAlert.pricealert_price isEqualToString:@"Rp 0"]) {
        NSString *tempStr = [_detailPriceAlert.pricealert_price stringByReplacingOccurrencesOfString:@"Rp " withString:@""];
        tempStr = [tempStr stringByReplacingOccurrencesOfString:@"." withString:@""];
        if([tempStr isEqualToString:@"Semua Harga"]){
            txtPrice.text = @"";
        }else{
            txtPrice.text = tempStr;
        }
        
        [self initNavigation:NO];
    }
    else if(_catalogInfo!=nil && ![_catalogInfo.catalog_pricealert_price isEqualToString:@"Rp 0"] && ![_catalogInfo.catalog_pricealert_price isEqualToString:@"0"]) {
        isEditCatalog = YES;
        NSString *tempStr = [_catalogInfo.catalog_pricealert_price stringByReplacingOccurrencesOfString:@"Rp " withString:@""];
        tempStr = [tempStr stringByReplacingOccurrencesOfString:@"." withString:@""];
        if([tempStr isEqualToString:@"Semua Harga"]){
            txtPrice.text = @"";
        }else{
            txtPrice.text = tempStr;
        }
        [self initNavigation:NO];
    }
    else
        [self initNavigation:YES];
    
    //Set line space
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    [attributes setObject:style forKey:NSParagraphStyleAttributeName];
    [attributes setObject:lblDesc.font forKey:NSFontAttributeName];
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:lblDesc.text attributes:attributes];
    lblDesc.attributedText = attributedString;
    
    
    //Add padding left
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, txtPrice.bounds.size.height)];
    paddingView.backgroundColor = [UIColor clearColor];
    [txtPrice setLeftViewMode:UITextFieldViewModeAlways];
    [txtPrice setLeftView:paddingView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [AnalyticsManager trackScreenName:@"Insert Price Alert Page"];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Setup View
- (void)initNavigation:(BOOL)isNew {
    self.navigationItem.title = CStringNotificationHarga;
    rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:(isNew?CStringSave:CStringUbah) style:UIBarButtonItemStylePlain target:self action:@selector(actionTambah:)];;
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
}


#pragma mark - Method
- (NSString *)getPriceAlert {
    NSString *tempPrice = [txtPrice.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([tempPrice isEqualToString:@""])
        return @"";
    else
        return tempPrice;
}

- (TokopediaNetworkManager *)getNetworkManager:(int)tag {
    if(tokopediaNetworkManager == nil) {
        tokopediaNetworkManager = [TokopediaNetworkManager new];
        tokopediaNetworkManager.delegate = self;
    }
    
    tokopediaNetworkManager.tagRequest = tag;
    return tokopediaNetworkManager;
}

- (void)actionTambah:(id)sender {
    __weak typeof(self) weakSelf = self;
    if(_catalogInfo != nil) {
        [_request requestAddCatalogPriceAlertWithCatalogID:_catalogInfo.catalog_id
                                           priceAlertPrice:[self getPriceAlert]
                                                 onSuccess:^(GeneralActionResult *result) {
                                                     [weakSelf setLoadingDoingAction:NO];
                                                     StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[(isEditCatalog? CStringSuccessEditPriceCatalog:CStringSuccessAddPriceCatalog)] delegate:self];
                                                     [stickyAlertView show];
                                                     
                                                     //Update DetailPriceAlert ViewController
                                                     UIViewController *viewController = [weakSelf.navigationController.viewControllers objectAtIndex:weakSelf.navigationController.viewControllers.count-2];
                                                     if([viewController isMemberOfClass:[CatalogViewController class]]) {
                                                         _catalogInfo.catalog_pricealert_price = [txtPrice.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                                         [((CatalogViewController *) viewController) updatePriceAlert:[weakSelf formatRupiah:[txtPrice.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]];
                                                     }
                                                     [weakSelf.navigationController popViewControllerAnimated:YES];
                                                 }
                                                 onFailure:^(NSError *error) {
                                                     StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringFailedAddCatalogPriceAlert] delegate:self];                                                         [stickyAlertView show];
                                                     [weakSelf setLoadingDoingAction:NO];
                                                 }];
    } else if(_productDetail != nil) {
        [_request requestAddProductPriceAlertWithProductID:_productDetail.product_id
                                           priceAlertPrice:[self getPriceAlert]
                                                 onSuccess:^(GeneralActionResult *result) {
                                                     [weakSelf setLoadingDoingAction:NO];
                                                     UIViewController *tempViewController = [weakSelf.navigationController.viewControllers objectAtIndex:weakSelf.navigationController.viewControllers.count-2];
                                                     if([tempViewController isMemberOfClass:[DetailProductViewController class]]) {
                                                         [((DetailProductViewController *) tempViewController) setBackgroundPriceAlert:YES];
                                                     }
                                                     
                                                     StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[CStringSuccessAddPrice] delegate:self];
                                                     [stickyAlertView show];
                                                     [weakSelf.navigationController popViewControllerAnimated:YES];
                                                 }
                                                 onFailure:^(NSError *error) {
                                                     StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringFailedAddPriceAlert] delegate:self];
                                                     [stickyAlertView show];
                                                     [weakSelf setLoadingDoingAction:NO];
                                                 }];
    } else if(_detailPriceAlert != nil) {
        [_request requestEditInboxPriceAlertWithPriceAlertID:_detailPriceAlert.pricealert_id
                                             priceAlertPrice:[self getPriceAlert]
                                                   onSuccess:^(GeneralActionResult *result) {
                                                       [weakSelf setLoadingDoingAction:NO];
                                                       [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdatePriceAlert" object:nil userInfo:@{@"price":[weakSelf formatRupiah:[txtPrice.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]}];
                                                       
                                                       StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[CStringSuccessEditPriceAlert] delegate:self];
                                                       [stickyAlertView show];
                                                       [weakSelf.navigationController popViewControllerAnimated:YES];
                                                   }
                                                   onFailure:^(NSError *error) {
                                                       StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringFailedEditPriceAlert] delegate:self];
                                                       [stickyAlertView show];
                                                       [weakSelf setLoadingDoingAction:NO];
                                                   }];
    }
}

- (void)setLoadingDoingAction:(BOOL)isDoingAction {
    if(isDoingAction) {
        txtPrice.enabled = NO;
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicator.frame = CGRectMake(0, 0, 30, 30);
        [activityIndicator startAnimating];
        self.navigationItem.rightBarButtonItem.customView = activityIndicator;
    }
    else {
        txtPrice.enabled = YES;
        self.navigationItem.rightBarButtonItem.customView = nil;
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    }
}

@end
