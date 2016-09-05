//
//  ShopPaymentViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 4/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ShopPaymentViewController.h"
#import "MyShopPaymentCell.h"
#import "LoadingView.h"

#import "SettingPayment.h"
#import "ShipmentCourierData.h"
#import "AddShop.h"
#import "RequestUploadImage.h"
#import "ImageResult.h"

#import "UITableView+LoadingView.h"
#import "NSURL+Dictionary.h"

#import "Tokopedia-Swift.h"

@interface ShopPaymentViewController () <LoadingViewDelegate>

@property (strong, nonnull) NSString *titleForFooter;
@property (strong, nonatomic) TokopediaNetworkManager *networkManager;

@property (strong, nonatomic) LoadingView *loadingView;

@end

@implementation ShopPaymentViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.tableView.allowsSelection = NO;
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
        self.tableView.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Pembayaran";
    
    UINib *nib = [UINib nibWithNibName:@"MyShopPaymentCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"MyShopPaymentCellIdentifier"];
    
    self.loadingView = [LoadingView new];
    self.loadingView.delegate = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    self.networkManager = [TokopediaNetworkManager new];
    self.networkManager.isUsingHmac = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.openShop) {
        self.navigationItem.rightBarButtonItem = self.saveButton;
        for (Payment *payment in self.paymentOptions) {
            if ([self.loc objectForKey:payment.payment_id]) {
                payment.payment_info = [self.loc objectForKey:payment.payment_id];
            }
        }
    } else if (self.paymentOptions == nil) {
        [self fetchPaymentData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Bar button items

- (UIBarButtonItem *)loadingBarButton {
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [indicatorView startAnimating];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
    return button;
}

- (UIBarButtonItem *)saveButton {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Selesai" style:UIBarButtonItemStyleDone target:self action:@selector(validateShop)];
    return button;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.paymentOptions.count;
}

- (MyShopPaymentCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyShopPaymentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyShopPaymentCellIdentifier" forIndexPath:indexPath];

    Payment *payment = self.paymentOptions[indexPath.row];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    style.lineSpacing = 6.0;
    
    NSDictionary *titleAttributes = @{
        NSFontAttributeName            : [UIFont title2ThemeMedium],
        NSParagraphStyleAttributeName  : style,
    };
    
    NSDictionary *textAttributes = @{
        NSFontAttributeName            : [UIFont title2Theme],
        NSParagraphStyleAttributeName  : style,
    };
    
    cell.nameLabel.attributedText = [[NSAttributedString alloc] initWithString:payment.payment_name attributes:titleAttributes];
    
    NSString *description = [NSString convertHTML:payment.payment_info];
    cell.descriptionLabel.attributedText = [[NSAttributedString alloc] initWithString:description attributes:textAttributes];
    [cell.descriptionLabel sizeToFit];
    
    cell.indexPath = indexPath;
    
    [cell.thumbnailImageView setImageWithURL:[NSURL URLWithString:payment.payment_image]];

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return self.titleForFooter;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0f) {
        return UITableViewAutomaticDimension;
    } else {
        return 220;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0f) {
        return UITableViewAutomaticDimension;
    } else {
        return 220;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Restkit 

- (void)fetchPaymentData {
    [self.tableView startIndicatorView];
    [self.networkManager requestWithBaseUrl:[NSString v4Url]
                                       path:@"/v4/myshop-payment/get_payment_info.pl"
                                     method:RKRequestMethodGET
                                  parameter:@{}
                                    mapping:[SettingPayment mapping]
                                  onSuccess:^(RKMappingResult *successResult,
                                              RKObjectRequestOperation *operation) {
                                      [self didReceivePaymentData:[successResult.dictionary objectForKey:@""]];
                                  } onFailure:^(NSError *errorResult) {
                                      self.tableView.tableFooterView = _loadingView;
                                      [self.tableView startIndicatorView];
                                      [self.refreshControl endRefreshing];
                                  }];
}

- (void)didReceivePaymentData:(SettingPayment *)data {
    if (data.message_error.count > 0) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:data.message_error delegate:self];
        [alert show];
    } else if ([data.status isEqualToString:@"OK"]) {
        for (Payment *payment in data.result.payment_options) {
            if ([data.result.loc objectForKey:payment.payment_id]) {
                payment.payment_info = [data.result.loc objectForKey:payment.payment_id];
            }
        }

        self.paymentOptions = data.result.payment_options;

        self.titleForFooter = [NSString stringWithFormat:@"Pilihan Pembayaran yang ingin Anda berikan kepada pengunjung Toko Online Anda.\n\n%@\n\n", [data.result.note componentsJoinedByString:@"\n\n"]];
        
        [self.tableView reloadData];
        [self.tableView stopIndicatorView];
        [self.refreshControl endRefreshing];
    }
}

- (void)validateShop {
    self.navigationItem.rightBarButtonItem = self.loadingBarButton;
    // WS asked if longitude and latitude is 0.000000 then change it to empty string
    if ([[_parameters objectForKey:@"longitude"]  isEqual: @"0.000000"] && [[_parameters objectForKey:@"latitude"]  isEqual: @"0.000000"]) {
        [_parameters setValue:@"" forKey:@"longitude"];
        [_parameters setValue:@"" forKey:@"latitude"];
    }
    NSString *path = @"/v4/action/myshop/open_shop_validation.pl";
    [self.networkManager requestWithBaseUrl:[NSString v4Url]
                                       path:path
                                     method:RKRequestMethodPOST
                                  parameter:_parameters
                                    mapping:[AddShop mapping]
                                  onSuccess:^(RKMappingResult *mappingResult, RKObjectRequestOperation *operation) {
                                      self.navigationItem.rightBarButtonItem = self.saveButton;
                                      AddShop *response = mappingResult.dictionary[@""];
                                      if (response.message_status) {
                                          [self didReceiveSuccessMessages:response.message_status];
                                      }
                                      if(response.message_error) {
                                          [self didReceiveErrorMessages:response.message_error];
                                      } else {
                                          self.postKey = response.result.post_key;
                                          if (self.shopLogo && self.postKey) {
                                              [self openShopPicture];
                                          } else {
                                              TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
                                              [secureStorage setKeychainWithValue:response.result.shop_id withKey:kTKPD_SHOPIDKEY];
                                              [secureStorage setKeychainWithValue:[_parameters objectForKey:@"shop_name"] withKey:kTKPD_SHOPNAMEKEY];
                                              [secureStorage setKeychainWithValue:@(0) withKey:kTKPD_SHOPISGOLD];
 
                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"shopCreated" object:self];
                                              OpenShopSuccessViewController *controller = [[OpenShopSuccessViewController alloc] initWithNibName:@"OpenShopSuccessViewController" bundle:nil];                                              
                                              controller.shopName = [_parameters objectForKey:@"shop_name"];
                                              controller.shopDomain = [_parameters objectForKey:@"shop_domain"];
                                              controller.shopUrl = response.result.shop_url;
                                              [self.navigationController pushViewController:controller animated:YES];
                                          }
                                      }
                                  }
                                  onFailure:^(NSError *errorResult) {
                                      if (errorResult) {
                                          [self didReceiveErrorMessages:@[errorResult.localizedDescription]];
                                      } else {
                                          [self didReceiveErrorMessages:@[@"Mohon maaf sedang terjadi gangguan."]];
                                      }
                                      self.navigationItem.rightBarButtonItem = self.saveButton;
                                  }];
}

- (void)submitShop {
    NSString *path = @"/v4/action/myshop/open_shop_submit.pl";
    NSDictionary *parameters = @{@"post_key": _postKey?:@"", @"file_uploaded": _fileUploaded?:@""};
    [self.networkManager requestWithBaseUrl:[NSString v4Url]
                                       path:path
                                     method:RKRequestMethodPOST
                                  parameter:parameters
                                    mapping:[AddShop mapping]
                                  onSuccess:^(RKMappingResult *mappingResult,
                                              RKObjectRequestOperation *operation) {
                                      AddShop *response = [mappingResult.dictionary objectForKey:@""];
                                      if ([response.result.is_success boolValue]) {
                                          TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
                                          [secureStorage setKeychainWithValue:response.result.shop_id withKey:kTKPD_SHOPIDKEY];
                                          [secureStorage setKeychainWithValue:[_parameters objectForKey:@"shop_name"] withKey:kTKPD_SHOPNAMEKEY];
                                          [secureStorage setKeychainWithValue:self.shopLogo withKey:kTKPD_SHOPIMAGEKEY];
                                          [secureStorage setKeychainWithValue:@(0) withKey:kTKPD_SHOPISGOLD];
                                          [[NSNotificationCenter defaultCenter] postNotificationName:@"shopCreated" object:self];
                                          OpenShopSuccessViewController *controller = [[OpenShopSuccessViewController alloc] initWithNibName:@"OpenShopSuccessViewController" bundle:nil];
                                          controller.shopName = [_parameters objectForKey:@"shop_name"];
                                          controller.shopDomain = [_parameters objectForKey:@"shop_domain"];
                                          controller.shopUrl = response.result.shop_url;
                                          [self.navigationController pushViewController:controller animated:YES];
                                            }
                                  } onFailure:^(NSError *errorResult) {
                                      [self didReceiveErrorMessages:@[errorResult.localizedDescription]];
                                  }];
}

- (void)didReceiveErrorMessages:(NSArray *)errorMessages {
    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
    [alert show];
}

- (void)didReceiveSuccessMessages:(NSArray *)successMessages {
    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:successMessages delegate:self];
    [alert show];
}

- (void)openShopPicture {
    NSString *baseURL = [NSString stringWithFormat:@"https://%@", self.generatedHost.upload_host];
    NSString *path = @"/web-service/v4/action/upload-image-helper/open_shop_picture.pl";
    NSString *serverId = self.generatedHost.server_id;
    NSDictionary *parameters = @{@"shop_logo": _shopLogo?:@"", @"server_id": serverId?:@""};
    [self.networkManager requestWithBaseUrl:baseURL
                                       path:path
                                     method:RKRequestMethodPOST
                                  parameter:parameters
                                    mapping:[ImageResult mapping]
                                  onSuccess:^(RKMappingResult *mappingResult,
                                              RKObjectRequestOperation *operation) {
                                      ImageResult *response = [mappingResult.dictionary objectForKey:@""];
                                      if ([response.data.is_success boolValue]) {
                                          self.fileUploaded = response.data.file_uploaded;
                                          [self submitShop];
                                      }
                                  } onFailure:^(NSError *errorResult) {
                                      [self didReceiveErrorMessages:@[errorResult.localizedDescription]];
                                  }];
}

#pragma mark - Loading view delegate

- (void)pressRetryButton {
    [self fetchPaymentData];
}

#pragma mark - Refresh control

- (void)refresh:(UIRefreshControl *)refreshControl {
    if (self.openShop) {
        [refreshControl endRefreshing];
    } else {
        [self fetchPaymentData];
    }
}

@end
