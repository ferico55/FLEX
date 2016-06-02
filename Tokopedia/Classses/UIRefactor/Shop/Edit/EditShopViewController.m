//
//  EditShopViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 3/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "EditShopViewController.h"
#import "EditShopStatusViewController.h"
#import "TKPDPhotoPicker.h"
#import "RequestGenerateHost.h"
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

@interface EditShopViewController ()
<
    EditShopStatusDelegate,
    EditShopDelegate,
    TKPDPhotoPickerDelegate,
    GenerateHostDelegate,
    CloseShopDelegate
>

@property (strong, nonatomic) TKPDPhotoPicker *photoPicker;
@property (strong, nonatomic) EditShopDataSource *dataSource;
@property (strong, nonatomic) TokopediaNetworkManager *networkManager;
@property (strong, nonatomic) GeneratedHost *generatedHost;
@property (strong, nonatomic) UploadImageResult *uploadImageObject;
@property (strong, nonatomic) CloseShopViewController *closeShopController;

@end

@implementation EditShopViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Atur Toko";
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
    
    [self registerNibs];
    
    [self generateHost];
    [self fetchShopInformation];
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
    RequestGenerateHost *requestHost = [RequestGenerateHost new];
    [requestHost configureRestkitGenerateHost];
    [requestHost requestGenerateHost];
    requestHost.delegate = self;
}

#pragma mark - Navigation items

- (UIBarButtonItem *)backButton {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@""
                                                               style:UIBarButtonItemStyleBordered
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
        @"pic_code":_uploadImageObject.image.pic_code?:@"",
        @"pic_src": _uploadImageObject.image.pic_src?:@"",
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
        StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[@"Anda telah berhasil mengubah gambar toko"] delegate:self];
        [alert show];
        NSDictionary *userinfo = @{
            kTKPDSHOPEDIT_APIUPLOADFILETHUMBKEY :_uploadImageObject.image.pic_src?:@"",
            kTKPDSHOPEDIT_APIUPLOADFILEPATHKEY:_uploadImageObject.file_path?:@""
        };
        [[NSNotificationCenter defaultCenter] postNotificationName:EDIT_SHOP_AVATAR_NOTIFICATION_NAME
                                                            object:nil
                                                          userInfo:userinfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_EDITSHOPPOSTNOTIFICATIONNAMEKEY
                                                            object:nil
                                                          userInfo:userinfo];
        self.dataSource.shop.image.logo = _uploadImageObject.image.pic_src;
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

#pragma mark - Photo picker delegate

- (void)photoPicker:(TKPDPhotoPicker *)picker didDismissCameraControllerWithUserInfo:(NSDictionary *)userInfo {
    NSIndexPath *shopImageIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    EditShopImageViewCell *imageViewCell = [self.tableView cellForRowAtIndexPath:shopImageIndexPath];
    
    NSDictionary *object = @{
        DATA_SELECTED_PHOTO_KEY : userInfo,
        DATA_SELECTED_IMAGE_VIEW_KEY : imageViewCell.shopImageView,
    };
    
    imageViewCell.shopImageView.image = [[userInfo objectForKey:@"photo"] objectForKey:@"photo"];
    
    RequestUploadImage *uploadImage = [RequestUploadImage new];
    [uploadImage requestActionUploadObject:object
                             generatedHost:_generatedHost
                                    action:kTKPDDETAIL_APIUPLOADSHOPIMAGEKEY
                                    newAdd:1
                                 productID:@""
                                 paymentID:@""
                                 fieldName:API_UPLOAD_SHOP_IMAGE_FORM_FIELD_NAME
                                   success:^(id imageObject, UploadImage *image) {
                                       self.uploadImageObject = image.result;
                                       [self uploadShopImage];
                                   } failure:^(id imageObject, NSError *error) {
                                       StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[[error localizedDescription]] delegate:self];
                                       [alert show];
                                   }];
}

#pragma mark - Edit shop delegate

- (void)didTapShopPhoto {
    _photoPicker = [[TKPDPhotoPicker alloc] initWithParentViewController:self pickerTransistionStyle:UIModalTransitionStyleCoverVertical];
    [_photoPicker setDelegate:self];
}

- (void)didTapShopStatus {
    _closeShopController.scheduleDetail = _dataSource.shop.closed_schedule_detail;
    _closeShopController.closedNote = _dataSource.shop.closed_detail.note;
    
    [self.navigationController pushViewController:_closeShopController animated:YES];
}

-(void)didChangeShopStatus{
    [self fetchShopInformation];
}

- (void)didTapMerchantInfo{
    WebViewController *webViewController = [WebViewController new];
    NSString *webViewStrUrl =@"https://gold.tokopedia.com";
    webViewController.isLPWebView = NO;
    webViewController.strURL = webViewStrUrl;
    webViewController.strTitle = @"Gold Merchant";
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - Generate Host

-(void)successGenerateHost:(GenerateHost *)generateHost {
    _generatedHost = generateHost.result.generated_host;
}

- (void)failedGenerateHost:(NSArray *)errorMessages {
    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
    [alert show];
    [self.tableView reloadData];
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