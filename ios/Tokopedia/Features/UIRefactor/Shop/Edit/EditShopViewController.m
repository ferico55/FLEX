//
//  EditShopViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 3/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "EditShopViewController.h"
#import "GenerateHostRequest.h"
#import "RequestUploadImage.h"

#import "EditShopTypeViewCell.h"
#import "EditShopImageViewCell.h"
#import "EditShopDescriptionViewCell.h"

#import "EditShopDataSource.h"

#import "Shop.h"
#import "ShopSettings.h"
#import "GenerateHost.h"
#import "UploadImage.h"

#import "camera.h"
#import "detail.h"

#import "ShopInfoResponse.h"
#import "CloseShopViewController.h"

#import "WebViewController.h"
#import "Tokopedia-Swift.h"

@interface EditShopViewController ()
<
    EditShopDelegate,
    CloseShopDelegate
>

@property (strong, nonatomic) EditShopDataSource *dataSource;
@property (strong, nonatomic) TokopediaNetworkManager *networkManager;
@property (strong, nonatomic) GeneratedHost *generatedHost;
@property (strong, nonatomic) UploadDataImage *uploadImageObject;
@property (strong, nonatomic) CloseShopViewController *closeShopController;

@end

@implementation EditShopViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Informasi";
        self.navigationItem.backBarButtonItem = self.backButton;
        self.navigationItem.rightBarButtonItem = self.loadingView;
        self.tableView.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1];
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.networkManager = [TokopediaNetworkManager new];
    self.networkManager.isUsingHmac = YES;
    
    self.dataSource = [EditShopDataSource new];
    self.dataSource.delegate = self;
    
    self.tableView.dataSource = _dataSource;
    self.tableView.delegate = _dataSource;
    
    _closeShopController = [[CloseShopViewController alloc]init];
    _closeShopController.delegate = self;
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    
    [self registerNibs];
    
    [self generateHost];
    [self fetchShopInformation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AnalyticsManager trackScreenName:@"Shop Info Setting Page"];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)registerNibs {
    [self.tableView registerNib:[UINib nibWithNibName:@"EditShopTypeViewCell" bundle:nil] forCellReuseIdentifier:@"shopType"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EditShopImageViewCell" bundle:nil] forCellReuseIdentifier:@"shopImage"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EditShopDescriptionViewCell" bundle:nil] forCellReuseIdentifier:@"shopDescription"];
}

- (void)generateHost {
    [GenerateHostRequest fetchGenerateHostOnSuccess:^(GeneratedHost *host) {
        _generatedHost = host;
    } onFailure:^{
        [self.tableView reloadData];
    }];
}

#pragma mark - Navigation items

- (UIBarButtonItem *)backButton {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@""
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:nil];
    return button;
}

- (UIBarButtonItem *)saveButton {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Simpan"
                                                               style:UIBarButtonItemStyleDone
                                                              target:self
                                                              action:@selector(saveShopInformation)];
    return button;
}

- (UIBarButtonItem *)loadingView {
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [indicatorView startAnimating];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
    return button;
}

#pragma mark - Restkit

- (void)uploadShopImage {
    NSString *baseURL = [NSString v4Url];
    NSString *path = @"/v4/action/myshop-info/update_shop_picture.pl";
    
    NSDictionary *parameters = @{
        @"new_add":@(1),
        @"action":@"update_shop_picture",
        @"pic_code":_uploadImageObject.pic_code?:@"",
        @"pic_src": _uploadImageObject.pic_src?:@"",
        @"server_id" : _generatedHost.server_id?:@""
    };
    
    [self.networkManager requestWithBaseUrl:baseURL
                                       path:path
                                     method:RKRequestMethodGET
                                  parameter:parameters
                                    mapping:[ShopSettings mapping]
                                  onSuccess:^(RKMappingResult *successResult,
                                              RKObjectRequestOperation *operation) {
                                      [self didReceiveMappingResultForUploadImage:successResult];
                                  }
                                  onFailure:^(NSError *error) {
                                      StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[[error localizedDescription]] delegate:self];
                                      [alert show];
                                  }];
}

- (void)didReceiveMappingResultForUploadImage:(RKMappingResult *)mappingResult {
    ShopSettings *settings = [mappingResult.dictionary objectForKey:@""];
    if (settings.result.is_success == 1) {
        [AnalyticsManager trackEventName:@"clickShopInfo"
                                category:GA_EVENT_CATEGORY_SHOP_INFO
                                  action:GA_EVENT_ACTION_EDIT
                                   label:@"Picture"];
        StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[@"Anda telah berhasil mengubah gambar toko"] delegate:self];
        [alert show];
        NSDictionary *userinfo = @{
            kTKPDSHOPEDIT_APIUPLOADFILETHUMBKEY :_uploadImageObject.pic_src?:@"",
            kTKPDSHOPEDIT_APIUPLOADFILEPATHKEY:_uploadImageObject.pic_src?:@""
        };
        [[NSNotificationCenter defaultCenter] postNotificationName:EDIT_SHOP_AVATAR_NOTIFICATION_NAME
                                                            object:nil
                                                          userInfo:userinfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_EDITSHOPPOSTNOTIFICATIONNAMEKEY
                                                            object:nil
                                                          userInfo:userinfo];
        self.dataSource.shop.image.logo = _uploadImageObject.pic_src;
        [self.tableView reloadData];
    } else {
        NSArray *errorMessages = settings.message_error?:@[@"Anda gagal mengubah gambar toko. Mohon coba kembali"];
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
        [alert show];
    }
}

- (void)fetchShopInformation {
    NSString *baseURL = [NSString v4Url];
    NSString *path = @"/v4/myshop-info/get_shop_info.pl";
    [self.networkManager requestWithBaseUrl:baseURL
                                       path:path
                                     method:RKRequestMethodGET
                                  parameter:@{}
                                    mapping:[ShopInfoResponse mapping]
                                  onSuccess:^(RKMappingResult *successResult,
                                              RKObjectRequestOperation *operation) {
                                      ShopInfoResponse *response = [successResult.dictionary objectForKey:@""];
                                      if (response.data) {
                                          self.dataSource.shop = response.data;
                                          [self.tableView reloadData];
                                          self.navigationItem.rightBarButtonItem = self.saveButton;
                                      }
                                  }
                                  onFailure:^(NSError *error) {
                                      StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[[error localizedDescription]] delegate:self];
                                      [alert show];
                                  }];
}

- (void)saveShopInformation {
    self.navigationItem.rightBarButtonItem = self.loadingView;
    NSString *baseURL = [NSString v4Url];
    NSString *path = @"/v4/action/myshop-info/update_shop_info.pl";
    ShopInfoResult *shop = _dataSource.shop;
    NSDictionary *parameters = @{
        @"closed_note":shop.closed_detail.note,
        @"closed_until":shop.closed_detail.until,
        @"short_desc":shop.info.shop_description,
        @"tag_line":shop.info.shop_tagline,
        @"status":shop.isOpen?@"1":@"2",
    };
    [AnalyticsManager trackEventName:@"clickShopInfo" category:GA_EVENT_CATEGORY_SHOP_INFO action:GA_EVENT_ACTION_EDIT label:@"Form"];
    [self.networkManager requestWithBaseUrl:baseURL
                                       path:path
                                     method:RKRequestMethodGET
                                  parameter:parameters
                                    mapping:[ShopSettings mapping]
                                  onSuccess:^(RKMappingResult *mappingResult,
                                              RKObjectRequestOperation *operation) {
                                      ShopSettings *settings = [mappingResult.dictionary objectForKey:@""];
                                      if (settings.result.is_success == 1) {
                                          [self didReceiveActionMappingResult:mappingResult];
                                      } else if (settings.message_error.count > 0) {
                                          StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:settings.message_error delegate:self];
                                          [alert show];
                                      }
                                      self.navigationItem.rightBarButtonItem = self.saveButton;
                                  }
                                  onFailure:^(NSError *error) {
                                      StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[[error localizedDescription]] delegate:self];
                                      [alert show];
                                      self.navigationItem.rightBarButtonItem = self.saveButton;
                                  }];
}

- (void)didReceiveActionMappingResult:(RKMappingResult *)mappingResult {
    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[KTKPDSHOP_SUCCESSEDIT] delegate:self];
    [alert show];
    
    NSInteger index = self.navigationController.viewControllers.count - 3;
    UIViewController *previousController = [self.navigationController.viewControllers objectAtIndex:index];
    [self.navigationController popToViewController:previousController animated:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_EDITSHOPPOSTNOTIFICATIONNAMEKEY object:nil userInfo:nil];
}


#pragma mark - Edit shop delegate

- (void)didTapShopPhoto {
    __weak typeof(self) wself = self;
    [TKPImagePickerController showImagePicker:self
                                    assetType:DKImagePickerControllerAssetTypeAllPhotos
                          allowMultipleSelect:NO
                                   showCancel:YES
                                   showCamera:NO
                                  maxSelected:(1)
                               selectedAssets:nil
                                   completion:^(NSArray<DKAsset *> *assets) {
                                       if (assets.count < 1) {
                                           return;
                                       }
                                       DKAsset* asset = assets[0];
                                       [asset fetchFullScreenImageWithCompleteBlock:^(UIImage * image, NSDictionary * dict) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               NSString* imageNameFull = dict[@"PHImageFileSandboxExtensionTokenKey"];
                                               NSString* imageNameOnly = imageNameFull.lastPathComponent.lowercaseString;
                                               
                                               UserAuthentificationManager *auth = [UserAuthentificationManager new];
                                               RequestObjectUploadImage *requestObject = [RequestObjectUploadImage new];
                                               requestObject.server_id = wself.generatedHost.server_id;
                                               requestObject.user_id = [auth getUserId];
                                               
                                               NSString *uploadImageBaseURL = [NSString stringWithFormat:@"https://%@",wself.generatedHost.upload_host];
                                               [RequestUploadImage requestUploadImage:image
                                                                       withUploadHost:uploadImageBaseURL
                                                                                 path:@"/web-service/v4/action/upload-image/upload_shop_image.pl"
                                                                                 name:@"logo"
                                                                             fileName:imageNameOnly
                                                                        requestObject:requestObject
                                                                            onSuccess:^(ImageResult *imageResult) {
                                                                                
                                                                                wself.uploadImageObject = imageResult.image;
                                                                                [wself uploadShopImage];
                                                                                
                                                                            } onFailure:^(NSError *error) {
                                                                                
                                                                            }];
                                           });
                                       }];
                                   }];
}

- (void)didTapShopStatus {
    _closeShopController.scheduleDetail = _dataSource.shop.closed_schedule_detail;
    if(_dataSource.shop.closed_detail.note && ![_dataSource.shop.closed_detail.note isEqualToString:@""]){
        _closeShopController.closedNote = _dataSource.shop.closed_detail.note;
    }else{
        _closeShopController.closedNote = _dataSource.shop.closed_schedule_detail.close_later_note;
    }    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_closeShopController];
    nav.navigationBar.translucent = NO;
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

-(void)didChangeShopStatus{
    [self fetchShopInformation];
}

- (void)didTapMerchantInfo{
    WebViewController *webViewController = [WebViewController new];
    NSString *webViewStrUrl = [self goldMerchantURL];
    webViewController.isLPWebView = NO;
    webViewController.strURL = webViewStrUrl;
    webViewController.strTitle = @"Gold Merchant";
    [self.navigationController pushViewController:webViewController animated:YES];
}

-(NSString*)goldMerchantURL{
    return @"https://gold.tokopedia.com";
}

#pragma mark - Edit status delegate

- (void)didFinishEditShopClosedNote:(NSString *)note
                        closedUntil:(NSString *)until {
    ShopCloseDetail *detail = self.dataSource.shop.closed_detail;
    detail.note = note;
    detail.until = until;
    self.dataSource.shop.closed_detail = detail;
    [self.tableView reloadData];
}

@end
