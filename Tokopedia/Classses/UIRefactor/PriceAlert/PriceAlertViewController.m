//
//  PriceAlertViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 5/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "AlertPriceNotificationViewController.h"
#import "CatalogViewController.h"
#import "CatalogInfo.h"
#import "DetailProductViewController.h"
#import "DetailPriceAlertViewController.h"
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
        if(_catalogInfo != nil) {
            [_request requestAddCatalogPriceAlertWithCatalogID:_catalogInfo.catalog_id
                                               priceAlertPrice:[self getPriceAlert]
                                                     onSuccess:^(GeneralActionResult *result) {
                                                         [self setLoadingDoingAction:NO];
                                                         StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[(isEditCatalog? CStringSuccessEditPriceCatalog:CStringSuccessAddPriceCatalog)] delegate:self];
                                                         [stickyAlertView show];
                                                         
                                                         //Update DetailPriceAlert ViewController
                                                         UIViewController *viewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
                                                         if([viewController isMemberOfClass:[CatalogViewController class]]) {
                                                             _catalogInfo.catalog_pricealert_price = [txtPrice.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                                             [((CatalogViewController *) viewController) updatePriceAlert:[self formatRupiah:[txtPrice.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]];
                                                         }
                                                         [self.navigationController popViewControllerAnimated:YES];
                                                     }
                                                     onFailure:^(NSError *error) {
                                                         StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringFailedAddCatalogPriceAlert] delegate:self];                                                         [stickyAlertView show];
                                                         [self setLoadingDoingAction:NO];
                                                     }];
        } else if(_productDetail != nil) {
            [_request requestAddProductPriceAlertWithProductID:_productDetail.product_id
                                               priceAlertPrice:[self getPriceAlert]
                                                     onSuccess:^(GeneralActionResult *result) {
                                                         [self setLoadingDoingAction:NO];
                                                         UIViewController *tempViewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
                                                         if([tempViewController isMemberOfClass:[DetailProductViewController class]]) {
                                                             [((DetailProductViewController *) tempViewController) setBackgroundPriceAlert:YES];
                                                         }
                                                         
                                                         StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[CStringSuccessAddPrice] delegate:self];
                                                         [stickyAlertView show];
                                                         [self.navigationController popViewControllerAnimated:YES];
                                                     }
                                                     onFailure:^(NSError *error) {
                                                         StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringFailedAddPriceAlert] delegate:self];
                                                         [stickyAlertView show];
                                                         [self setLoadingDoingAction:NO];
                                                     }];
        } else if(_detailPriceAlert != nil) {
            [_request requestEditInboxPriceAlertWithPriceAlertID:_detailPriceAlert.pricealert_id
                                                 priceAlertPrice:[self getPriceAlert]
                                                       onSuccess:^(GeneralActionResult *result) {
                                                           [self setLoadingDoingAction:NO];
                                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"TkpdUpdatePriceAlert" object:nil userInfo:@{@"price":[self formatRupiah:[txtPrice.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]}];
                                                           
                                                           StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[CStringSuccessEditPriceAlert] delegate:self];
                                                           [stickyAlertView show];
                                                           [self.navigationController popViewControllerAnimated:YES];
                                                       }
                                                       onFailure:^(NSError *error) {
                                                           StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringFailedEditPriceAlert] delegate:self];
                                                           [stickyAlertView show];
                                                           [self setLoadingDoingAction:NO];
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


#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag {
    if(tag == CTagAddCatalogPriceAlert) {
        return @{CAction:CAddCatalogPriceAlert, CCatalogID:_catalogInfo.catalog_id, CPriceAlertPrice:[self getPriceAlert]};
    }
    else if(tag == CTagEditPriceAlert) {
        return @{CAction:CEditPriceAlert, CPriceAlertID:_detailPriceAlert.pricealert_id, CPriceAlertPrice:[self getPriceAlert]};
    }
    else if(tag == CTagAddPriceAlert) {
        return @{CAction:CAddPriceAlert, CPriceAlertPrice:[self getPriceAlert], CProductID:_productDetail.product_id};
    }
    
    return nil;
}

- (NSString*)getPath:(int)tag {
    return [NSString stringWithFormat:@"%@/%@", CAction, CPriceAlertPL];
}

- (id)getObjectManager:(int)tag {
    rkObjectManager = [RKObjectManager sharedClient];
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[GeneralAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GeneralActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPD_APIISSUCCESSKEY:kTKPD_APIISSUCCESSKEY}];
    
    //relation
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];
    
    //register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:[self getPath:tag] keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [rkObjectManager addResponseDescriptor:responseDescriptorStatus];
    return rkObjectManager;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag {
    GeneralAction *generalAction = [((RKMappingResult *) result).dictionary objectForKey:@""];
    return generalAction.status;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag {
    [self setLoadingDoingAction:NO];
    GeneralAction *generalAction = [((RKMappingResult *) successResult).dictionary objectForKey:@""];
    if(tag == CTagAddCatalogPriceAlert) {
        if([generalAction.result.is_success isEqualToString:@"1"]) {
            StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[(isEditCatalog? CStringSuccessEditPriceCatalog:CStringSuccessAddPriceCatalog)] delegate:self];
            [stickyAlertView show];
            
            
            //Update DetailPriceAlert ViewController
            UIViewController *viewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
            if([viewController isMemberOfClass:[CatalogViewController class]]) {
                 _catalogInfo.catalog_pricealert_price = [txtPrice.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                [((CatalogViewController *) viewController) updatePriceAlert:[self formatRupiah:[txtPrice.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [self actionAfterFailRequestMaxTries:tag];
        }
    }
    else if(tag == CTagAddPriceAlert) {
        if([generalAction.result.is_success isEqualToString:@"1"]) {
            UIViewController *tempViewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
            if([tempViewController isMemberOfClass:[DetailProductViewController class]]) {
                [((DetailProductViewController *) tempViewController) setBackgroundPriceAlert:YES];
            }
            
            
            StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[CStringSuccessAddPrice] delegate:self];
            [stickyAlertView show];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [self actionAfterFailRequestMaxTries:tag];
        }
    }
    else if(tag == CTagEditPriceAlert) {
        if([generalAction.result.is_success isEqualToString:@"1"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TkpdUpdatePriceAlert" object:nil userInfo:@{@"price":[self formatRupiah:[txtPrice.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]}];
            
            
            StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[CStringSuccessEditPriceAlert] delegate:self];
            [stickyAlertView show];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [self actionAfterFailRequestMaxTries:tag];
        }
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {}

- (void)actionBeforeRequest:(int)tag {}

- (void)actionRequestAsync:(int)tag {}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    StickyAlertView *stickyAlertView;
    if(tag == CTagAddCatalogPriceAlert) {
        stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringFailedAddCatalogPriceAlert] delegate:self];
    }
    else if(tag == CTagAddPriceAlert) {
        stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringFailedAddPriceAlert] delegate:self];
    }
    else if(tag == CTagEditPriceAlert) {
        stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringFailedEditPriceAlert] delegate:self];
    }

    [stickyAlertView show];
    [self setLoadingDoingAction:NO];
}
@end
