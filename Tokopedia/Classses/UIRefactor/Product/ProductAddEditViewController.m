//
//  ProductAddEditViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 12/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "string_product.h"
#import "string_alert.h"
#import "category.h"
#import "camera.h"
#import "GenerateHost.h"
#import "UploadImage.h"
#import "Product.h"
#import "ShopSettings.h"
#import "ManageProduct.h"
#import "AlertPickerView.h"
#import "ProductAddEditViewController.h"
#import "ProductAddEditDetailViewController.h"
#import "ProductEditImageViewController.h"
#import "CameraController.h"
#import "CategoryMenuViewController.h"
#import "URLCacheController.h"

#pragma mark - Setting Add Product View Controller
@interface ProductAddEditViewController ()<UITextFieldDelegate,UIScrollViewDelegate,TKPDAlertViewDelegate,CameraControllerDelegate,CategoryMenuViewDelegate,ProductEditDetailViewControllerDelegate>
{
    NSMutableDictionary *_dataInput;
    NSMutableArray *_productImageURLs;
    NSMutableArray *_productImageIDs;
    NSMutableArray *_productImageDesc;
    
    UITextField *_activeTextField;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;
    
    NSInteger *_requestcountGenerateHost;
    GenerateHost *_generatehost;
    UploadImage *_images;
    Product *_product;
    ShopSettings *_setting;
    
    NSOperationQueue *_operationQueue;
    NSOperationQueue *_operationQueueUploadImage;
    
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    
    __weak RKObjectManager *_objectmanagerGenerateHost;
    __weak RKManagedObjectRequestOperation *_requestGenerateHost;
    
    __weak RKObjectManager *_objectmanagerUploadPhoto;
    __weak NSMutableURLRequest *_requestActionUploadPhoto;
    
    __weak RKObjectManager *_objectmanagerDeleteImage;
    __weak RKManagedObjectRequestOperation *_requestDeleteImage;
    
    NSMutableArray *_errorMessage;
    
    NSInteger _requestCount;
    NSInteger _requestcountDeleteImage;
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
    
    UIBarButtonItem *_nextBarButtonItem;
    BOOL _isFinishedUploadImages;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *productImageScrollView;

@property (weak, nonatomic) IBOutlet UITextField *productNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *minimumOrderTextField;
@property (weak, nonatomic) IBOutlet UITextField *productPriceTextField;
@property (weak, nonatomic) IBOutlet UITextField *productWeightTextField;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *productImagesContentView;

@property (weak, nonatomic) IBOutlet UIButton *categoryButton;
@property (weak, nonatomic) IBOutlet UIButton *priceCurrencyButton;
@property (weak, nonatomic) IBOutlet UIButton *weightUnitButton;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *addImageButtons;
@property (strong, nonatomic) IBOutletCollection(UIActivityIndicatorView) NSArray *productImageActs;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *thumbProductImageViews;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *defaultImageLabels;

-(void)cancel;
-(void)configureRestKit;
-(void)request;
-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestfailure:(id)object;
-(void)requestprocess:(id)object;
-(void)requesttimeout;

-(void)cancelDeleteImage;
-(void)configureRestKitDeleteImage;
-(void)requestDeleteImage:(id)object;
-(void)requestSuccessDeleteImage:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureDeleteImage:(id)object;
-(void)requestProcessDeleteImage:(id)object;
-(void)requestTimeoutDeleteImage;

@end

@implementation ProductAddEditViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isFinishedUploadImages = YES;
    }
    return self;
}

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _productImageActs = [NSArray sortViewsWithTagInArray:_productImageActs];
    _addImageButtons = [NSArray sortViewsWithTagInArray:_addImageButtons];
    _thumbProductImageViews = [NSArray sortViewsWithTagInArray:_thumbProductImageViews];
    _defaultImageLabels = [NSArray sortViewsWithTagInArray:_defaultImageLabels];
    
    _operationQueue = [NSOperationQueue new];
    _operationQueueUploadImage = [NSOperationQueue new];
    _dataInput = [NSMutableDictionary new];
    _errorMessage = [NSMutableArray new];
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];
    
    _productImageURLs = [[NSMutableArray alloc]initWithObjects:@"",@"",@"",@"",@"", nil];
    _productImageIDs = [[NSMutableArray alloc]initWithObjects:@"",@"",@"",@"",@"", nil];
    _productImageDesc = [[NSMutableArray alloc]initWithObjects:@"",@"",@"",@"",@"", nil];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    _nextBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [_nextBarButtonItem setTintColor:[UIColor blackColor]];
    _nextBarButtonItem.tag = 11;
    self.navigationItem.rightBarButtonItem = _nextBarButtonItem;
    
    for (UIButton *buttonAdd in _addImageButtons) {
        buttonAdd.enabled = NO;
    }
    ((UIButton*)_addImageButtons[0]).enabled = YES;
    [_thumbProductImageViews makeObjectsPerformSelector:@selector(setHidden:) withObject:@(YES)];
    for (UIImageView *productImageView in _thumbProductImageViews) {
        productImageView.userInteractionEnabled = NO;
    }
    [self setDefaultData:_data];
    //cache
    //NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:kTKPDDETAILPRODUCT_CACHEFILEPATH];
    //_cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDDETAILPRODUCTFORM_APIRESPONSEFILEFORMAT,[[_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY] integerValue]]];
    //_cachecontroller.filePath = _cachepath;
    //_cachecontroller.URLCacheInterval = 86400.0;
    //[_cachecontroller initCacheWithDocumentPath:path];
    
    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
    if (type == TYPE_ADD_EDIT_PRODUCT_EDIT || type == TYPE_ADD_EDIT_PRODUCT_COPY) {
        [self configureRestKit];
        [self request];
    }
    else{
        [self configureRestkitGenerateHost];
        [self requestGenerateHost];
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // keyboard notification
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _scrollView.contentSize = _contentView.frame.size;
    _productImageScrollView.contentSize = _productImagesContentView.frame.size;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    [_activeTextField resignFirstResponder];
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem *)sender;
        switch (btn.tag) {
            case 10:
                [self.navigationController popViewControllerAnimated:YES];
                break;
            case 11:
            {
                if (!_isFinishedUploadImages) {
                    NSArray *errorMessage = @[@"Belum Selesai Mengupload Image"];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:errorMessage,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                else{
                    if ([self dataInputIsValid]) {
                        NSDictionary *auth = [_data objectForKey:kTKPD_AUTHKEY];
                        NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
                        id productDetail = [_data objectForKey:DATA_PRODUCT_DETAIL_KEY]?:@"";
                        NSString *defaultImagePath = [_dataInput objectForKey:API_PRODUCT_IMAGE_DEFAULT_KEY];
                        if (!defaultImagePath) {
                            defaultImagePath = (type == TYPE_ADD_EDIT_PRODUCT_ADD || type == TYPE_ADD_EDIT_PRODUCT_COPY)? [_productImageURLs firstObject]:[_productImageIDs firstObject];
                            [_dataInput setObject:defaultImagePath forKey:API_PRODUCT_IMAGE_DEFAULT_KEY];
                        }
                        ProductAddEditDetailViewController *vc = [ProductAddEditDetailViewController new];
                        vc.data = @{kTKPD_AUTHKEY : auth?:@{},
                                    DATA_INPUT_KEY : _dataInput,
                                    DATA_TYPE_ADD_EDIT_PRODUCT_KEY : @(type),
                                    DATA_PRODUCT_DETAIL_KEY: productDetail
                                    };
                        vc.delegate = self;
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                    else
                    {
                        NSArray *errorMessage = _errorMessage;
                        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:errorMessage,@"messages", nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                    }
                }
                break;
            }
            default:
                break;
        }
    }
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        switch (btn.tag) {
            case BUTTON_PRODUCT_CATEGORY:
            {
                CategoryMenuViewController *categoryViewController = [CategoryMenuViewController new];
                NSInteger d_id = [[_data objectForKey:kTKPDCATEGORY_DATADEPARTMENTIDKEY] integerValue];
                categoryViewController.data = @{kTKPDCATEGORY_DATADEPARTMENTIDKEY:@(d_id),
                                                DATA_CATEGORY_MENU_PREVIOUS_VIEW_TYPE:@(CATEGORY_MENU_PREVIOUS_VIEW_ADD_PRODUCT)
                                                };
                categoryViewController.delegate = self;
                [self.navigationController pushViewController:categoryViewController animated:YES];
                break;
            }
            case BUTTON_PRODUCT_PRICE_CURRENCY:
            {
                AlertPickerView *v = [AlertPickerView newview];
                v.pickerData = ARRAY_PRICE_CURRENCY;
                v.tag = btn.tag;
                v.delegate = self;
                [v show];
                break;
            }
            case BUTTON_PRODUCT_WEIGHT_UNIT:
            {
                AlertPickerView *v = [AlertPickerView newview];
                v.pickerData = ARRAY_WEIGHT_UNIT;
                v.tag = btn.tag;
                v.delegate = self;
                [v show];
                break;
            }
            case 20: // tag 20-24 add product
            case 21:
            case 22:
            case 23:
            case 24:
            { 
                CameraController* c = [CameraController new];
                [c snap];
                c.delegate = self;
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:c];
                nav.wantsFullScreenLayout = YES;
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self.navigationController presentViewController:nav animated:YES completion:nil];
                [_dataInput setObject:@(btn.tag-20) forKey:kTKPDDETAIL_DATAINDEXKEY];
                break;
            }
            default:
                break;
        }
    }
}
- (IBAction)gesture:(id)sender
{
    [_activeTextField resignFirstResponder];
    
    UITapGestureRecognizer* gesture = (UITapGestureRecognizer*)sender;
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            if (gesture.view.tag > 0) {
                NSInteger indexImage = gesture.view.tag-10;
                NSString *defaultImagePath =[_dataInput objectForKey:API_PRODUCT_IMAGE_DEFAULT_KEY];
                NSString *selectedImagePath =_productImageURLs[indexImage];
                BOOL isDefaultImage;
                if (defaultImagePath)
                    isDefaultImage = [defaultImagePath isEqualToString:selectedImagePath];
                else
                    isDefaultImage = (gesture.view.tag-10 == 0);
                
                ProductEditImageViewController *vc = [ProductEditImageViewController new];
                vc.data = @{kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                            kTKPDSHOPEDIT_APIUPLOADFILEPATHKEY : _productImageURLs[indexImage]?:@"",
                            kTKPDDETAIL_DATAINDEXKEY : @(indexImage),
                            DATA_IS_DEFAULT_IMAGE : @(isDefaultImage),
                            DATA_PRODUCT_IMAGE_NAME_KEY : _productImageDesc[indexImage]?:@""
                            };
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:YES];
            }

            break;
        }
        default:
            break;
    }
}

#pragma mark - Request Product Detail
-(void)cancel
{
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}

- (void)configureRestKit
{
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *productMapping = [RKObjectMapping mappingForClass:[Product class]];
    [productMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[DetailProductResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{API_SERVER_ID_KEY:API_SERVER_ID_KEY,
                                                        API_IS_GOLD_SHOP_KEY:API_IS_GOLD_SHOP_KEY
                                                        }];
    
    RKObjectMapping *infoMapping = [RKObjectMapping mappingForClass:[ProductDetail class]];
    [infoMapping addAttributeMappingsFromDictionary:@{API_PRODUCT_NAME_KEY:API_PRODUCT_NAME_KEY,
                                                      API_PRODUCT_WEIGHT_UNIT_KEY:API_PRODUCT_WEIGHT_UNIT_KEY,
                                                      API_PRODUCT_DESCRIPTION_KEY:API_PRODUCT_DESCRIPTION_KEY,
                                                      API_PRODUCT_PRICE_KEY:API_PRODUCT_PRICE_KEY,
                                                      API_PRODUCT_INSURANCE_KEY:API_PRODUCT_INSURANCE_KEY,
                                                      API_PRODUCT_CONDITION_KEY:API_PRODUCT_CONDITION_KEY,
                                                      API_PRODUCT_MINIMUM_ORDER_KEY:API_PRODUCT_MINIMUM_ORDER_KEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTSTATUSKEY:kTKPDDETAILPRODUCT_APIPRODUCTSTATUSKEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTLASTUPDATEKEY:kTKPDDETAILPRODUCT_APIPRODUCTLASTUPDATEKEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTIDKEY:kTKPDDETAILPRODUCT_APIPRODUCTIDKEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTPRICEALERTKEY:kTKPDDETAILPRODUCT_APIPRODUCTPRICEALERTKEY,
                                                      API_PRODUCT_WEIGHT_KEY:API_PRODUCT_WEIGHT_KEY,
                                                      API_PRODUCT_FORM_PRICE_CURRENCY_ID_KEY:API_PRODUCT_FORM_PRICE_CURRENCY_ID_KEY,
                                                      kTKPDDETAILPRODUCT_APICURRENCYKEY:kTKPDDETAILPRODUCT_APICURRENCYKEY,
                                                      API_PRODUCT_ETALASE_ID_KEY:API_PRODUCT_ETALASE_ID_KEY,
                                                      API_PRODUCT_DEPARTMENT_ID_KEY:API_PRODUCT_DEPARTMENT_ID_KEY,
                                                      API_PRODUCT_FORM_DESCRIPTION_KEY:API_PRODUCT_FORM_DESCRIPTION_KEY,
                                                      API_PRODUCT_FORM_DEPARTMENT_TREE_KEY:API_PRODUCT_FORM_DEPARTMENT_TREE_KEY,
                                                      API_PRODUCT_FORM_RETURNABLE_KEY:API_PRODUCT_FORM_RETURNABLE_KEY,
                                                      API_PRODUCT_MUST_INSURANCE_KEY:API_PRODUCT_MUST_INSURANCE_KEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTURKKEY:kTKPDDETAILPRODUCT_APIPRODUCTURKKEY,
                                                      API_PRODUCT_FORM_ETALASE_NAME_KEY:API_PRODUCT_FORM_ETALASE_NAME_KEY
                                                      }];
    
    RKObjectMapping *statisticMapping = [RKObjectMapping mappingForClass:[Statistic class]];
    [statisticMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISTATISTICKEY:kTKPDDETAILPRODUCT_APISTATISTICKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTSOLDKEY:kTKPDDETAILPRODUCT_APIPRODUCTSOLDKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTTRANSACTIONKEY:kTKPDDETAILPRODUCT_APIPRODUCTTRANSACTIONKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTSUCCESSRATEKEY:kTKPDDETAILPRODUCT_APIPRODUCTSUCCESSRATEKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTVIEWKEY:kTKPDDETAILPRODUCT_APIPRODUCTVIEWKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTCANCELRATEKEY:kTKPDDETAILPRODUCT_APIPRODUCTCANCELRATEKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY:kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY:kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTREVIEWKEY:kTKPDDETAILPRODUCT_APIPRODUCTREVIEWKEY,
                                                           KTKPDDETAILPRODUCT_APIPRODUCTQUALITYRATEKEY:KTKPDDETAILPRODUCT_APIPRODUCTQUALITYRATEKEY,
                                                           KTKPDDETAILPRODUCT_APIPRODUCTACCURACYRATEKEY:KTKPDDETAILPRODUCT_APIPRODUCTACCURACYRATEKEY,
                                                           KTKPDDETAILPRODUCT_APIPRODUCTQUALITYPOINTKEY:KTKPDDETAILPRODUCT_APIPRODUCTQUALITYPOINTKEY,
                                                           KTKPDDETAILPRODUCT_APIPRODUCTACCURACYPOINTKEY:KTKPDDETAILPRODUCT_APIPRODUCTACCURACYPOINTKEY
                                                           
                                                           }];
    
    RKObjectMapping *shopinfoMapping = [RKObjectMapping mappingForClass:[ShopInfo class]];
    [shopinfoMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISHOPINFOKEY:kTKPDDETAILPRODUCT_APISHOPINFOKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPOPENSINCEKEY:kTKPDDETAILPRODUCT_APISHOPOPENSINCEKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY:kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY:kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY,
                                                          kTKPDDETAIL_APISHOPIDKEY:kTKPDDETAIL_APISHOPIDKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPLASTLOGINKEY:kTKPDDETAILPRODUCT_APISHOPLASTLOGINKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPTAGLINEKEY:kTKPDDETAILPRODUCT_APISHOPTAGLINEKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPNAMEKEY:kTKPDDETAILPRODUCT_APISHOPNAMEKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPISFAVKEY:kTKPDDETAILPRODUCT_APISHOPISFAVKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPDESCRIPTIONKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPAVATARKEY:kTKPDDETAILPRODUCT_APISHOPAVATARKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPDOMAINKEY:kTKPDDETAILPRODUCT_APISHOPDOMAINKEY
                                                          }];
    
    RKObjectMapping *shopstatsMapping = [RKObjectMapping mappingForClass:[ShopStats class]];
    [shopstatsMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISHOPSERVICERATEKEY:kTKPDDETAILPRODUCT_APISHOPSERVICERATEKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPSERVICEDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPSERVICEDESCRIPTIONKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPSPEEDRATEKEY:kTKPDDETAILPRODUCT_APISHOPSPEEDRATEKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPACURACYRATEKEY:kTKPDDETAILPRODUCT_APISHOPACURACYRATEKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPACURACYDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPACURACYDESCRIPTIONKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPSPEEDDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPSPEEDDESCRIPTIONKEY
                                                           }];
    
    RKObjectMapping *wholesaleMapping = [RKObjectMapping mappingForClass:[WholesalePrice class]];
    [wholesaleMapping addAttributeMappingsFromArray:@[kTKPDDETAILPRODUCT_APIWHOLESALEMINKEY,kTKPDDETAILPRODUCT_APIWHOLESALEPRICEKEY,kTKPDDETAILPRODUCT_APIWHOLESALEMAXKEY]];
    
    RKObjectMapping *breadcrumbMapping = [RKObjectMapping mappingForClass:[Breadcrumb class]];
    [breadcrumbMapping addAttributeMappingsFromArray:@[kTKPDDETAILPRODUCT_APIDEPARTMENTNAMEKEY,API_DEPARTMENT_ID_KEY]];
    
    RKObjectMapping *otherproductMapping = [RKObjectMapping mappingForClass:[OtherProduct class]];
    [otherproductMapping addAttributeMappingsFromArray:@[API_PRODUCT_PRICE_KEY,
                                                         API_PRODUCT_NAME_KEY,
                                                         kTKPDDETAILPRODUCT_APIPRODUCTIDKEY,
                                                         kTKPDDETAILPRODUCT_APIPRODUCTIMAGEKEY]];
    
    RKObjectMapping *imagesMapping = [RKObjectMapping mappingForClass:[ProductImages class]];
    [imagesMapping addAttributeMappingsFromArray:@[kTKPDDETAILPRODUCT_APIIMAGEIDKEY,kTKPDDETAILPRODUCT_APIIMAGESTATUSKEY,kTKPDDETAILPRODUCT_APIIMAGEDESCRIPTIONKEY,kTKPDDETAILPRODUCT_APIIMAGEPRIMARYKEY,kTKPDDETAILPRODUCT_APIIMAGESRCKEY]];
    
    // Relationship Mapping
    [productMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIRESULTKEY toKeyPath:kTKPDDETAIL_APIRESULTKEY withMapping:resultMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_PRODUCT_INFO_KEY toKeyPath:API_PRODUCT_INFO_KEY withMapping:infoMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISTATISTICKEY toKeyPath:kTKPDDETAILPRODUCT_APISTATISTICKEY withMapping:statisticMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISHOPINFOKEY toKeyPath:kTKPDDETAILPRODUCT_APISHOPINFOKEY withMapping:shopinfoMapping]];
    [shopinfoMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISHOPSTATKEY toKeyPath:kTKPDDETAILPRODUCT_APISHOPSTATKEY withMapping:shopstatsMapping]];
    
    RKRelationshipMapping *breadcrumbRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIBREADCRUMBPATHKEY toKeyPath:kTKPDDETAIL_APIBREADCRUMBPATHKEY withMapping:breadcrumbMapping];
    [resultMapping addPropertyMapping:breadcrumbRel];
    RKRelationshipMapping *otherproductRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIOTHERPRODUCTPATHKEY toKeyPath:kTKPDDETAIL_APIOTHERPRODUCTPATHKEY withMapping:otherproductMapping];
    [resultMapping addPropertyMapping:otherproductRel];
    RKRelationshipMapping *productimageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIPRODUCTIMAGEPATHKEY toKeyPath:kTKPDDETAIL_APIPRODUCTIMAGEPATHKEY withMapping:imagesMapping];
    [resultMapping addPropertyMapping:productimageRel];
    RKRelationshipMapping *wholesaleRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIWHOLESALEPRICEPATHKEY toKeyPath:kTKPDDETAIL_APIWHOLESALEPRICEPATHKEY withMapping:wholesaleMapping];
    [resultMapping addPropertyMapping:wholesaleRel];
    
    // Response Descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:productMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILPRODUCT_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptor];
}

- (void)request
{
    if (_request.isExecuting) return;
    
    _requestCount++;
    
    NSDictionary *auth = [_data objectForKey:kTKPD_AUTHKEY];
    NSInteger productID = [[_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY]integerValue];
    NSInteger myshopID = [[auth objectForKey:kTKPD_SHOPIDKEY]integerValue];
	NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY : ACTION_GET_PRODUCT_FORM,
                            kTKPDDETAIL_APIPRODUCTIDKEY : @(productID),
                            kTKPDDETAIL_APISHOPIDKEY : @(myshopID)
                            };
    [self enableButtonBeforeSuccessRequest:NO];
    
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAILPRODUCT_APIPATH parameters:[param encrypt]];
	//[_cachecontroller getFileModificationDate];
	//_timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
	//if (_timeinterval > _cachecontroller.URLCacheInterval) {
        NSTimer *timer;
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [timer invalidate];
            [self requestsuccess:mappingResult withOperation:operation];
            [self enableButtonBeforeSuccessRequest:YES];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [timer invalidate];
            [self requestfailure:error];
            [self enableButtonBeforeSuccessRequest:YES];
        }];
        
        [_operationQueue addOperation:_request];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
    //}
    //else {
    //  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //  [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    //  [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    //  NSLog(@"Updated: %@",[dateFormatter stringFromDate:_cachecontroller.fileDate]);
    //  NSLog(@"cache and updated in last 24 hours.");
    //  [self requestfailure:nil];
    //}
}

-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stats = [result objectForKey:@""];
    _product = stats;
    BOOL status = [_product.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        //[_cacheconnection connection:operation.HTTPRequestOperation.request didReceiveResponse:operation.HTTPRequestOperation.response];
        //[_cachecontroller connectionDidFinish:_cacheconnection];
        //save response data to plist
        //[operation.HTTPRequestOperation.responseData writeToFile:_cachepath atomically:YES];
        
        [self requestprocess:object];
    }
}

-(void)requestfailure:(id)object
{
    //if (_timeinterval > _cachecontroller.URLCacheInterval) {
        [self requestprocess:object];
    //}
    //else{
    //NSError* error;
    //NSData *data = [NSData dataWithContentsOfFile:_cachepath];
    //id parsedData = [RKMIMETypeSerialization objectFromData:data MIMEType:RKMIMETypeJSON error:&error];
    //if (parsedData == nil && error) {
    //    NSLog(@"parser error");
    //}
    //
    //NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
    //for (RKResponseDescriptor *descriptor in _objectmanager.responseDescriptors) {
    //    [mappingsDictionary setObject:descriptor.mapping forKey:descriptor.keyPath];
    //}
    //
    //RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData mappingsDictionary:mappingsDictionary];
    //NSError *mappingError = nil;
    //BOOL isMapped = [mapper execute:&mappingError];
    //if (isMapped && !mappingError) {
    //    RKMappingResult *mappingresult = [mapper mappingResult];
    //    NSDictionary *result = mappingresult.dictionary;
    //    id stats = [result objectForKey:@""];
    //    _product = stats;
    //    BOOL status = [_product.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    //    
    //    if (status) {
    //        [self requestprocess:mappingresult];
    //    }
    //}
    //}
}

-(void)requestprocess:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stats = [result objectForKey:@""];
            _product = stats;
            BOOL status = [_product.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                NSMutableDictionary *data = [NSMutableDictionary new];
                [data addEntriesFromDictionary:_data];
                [self setDefaultData:data];
            }
        }else{
            [self cancel];
            NSError *error = object;
            if (!([error code] == NSURLErrorCancelled)){
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requesttimeout
{
    [self cancel];
}

#pragma mark Request Generate Host
-(void)configureRestkitGenerateHost
{
    _objectmanagerGenerateHost =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[GenerateHost class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GenerateHostResult class]];
    
    RKObjectMapping *generatedhostMapping = [RKObjectMapping mappingForClass:[GeneratedHost class]];
    [generatedhostMapping addAttributeMappingsFromDictionary:@{
                                                               kTKPDGENERATEDHOST_APISERVERIDKEY:kTKPDGENERATEDHOST_APISERVERIDKEY,
                                                               kTKPDGENERATEDHOST_APIUPLOADHOSTKEY:kTKPDGENERATEDHOST_APIUPLOADHOSTKEY,
                                                               kTKPDGENERATEDHOST_APIUSERIDKEY:kTKPDGENERATEDHOST_APIUSERIDKEY
                                                               }];
    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDGENERATEDHOST_APIGENERATEDHOSTKEY toKeyPath:kTKPDGENERATEDHOST_APIGENERATEDHOSTKEY withMapping:generatedhostMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAIL_UPLOADIMAGEAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerGenerateHost addResponseDescriptor:responseDescriptor];
}

-(void)cancelGenerateHost
{
    [_requestGenerateHost cancel];
    _requestGenerateHost = nil;
    
    [_objectmanagerGenerateHost.operationQueue cancelAllOperations];
    _objectmanagerGenerateHost = nil;
}

- (void)requestGenerateHost
{
    if(_requestGenerateHost.isExecuting) return;
    
    _requestcountGenerateHost ++;
    
    
    NSTimer *timer;
    
	NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIUPLOADGENERATEHOSTKEY
                            };
    
    _requestGenerateHost = [_objectmanagerGenerateHost appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAIL_UPLOADIMAGEAPIPATH parameters:[param encrypt]];
    
    [_requestGenerateHost setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessGenerateHost:mappingResult withOperation:operation];
        [timer invalidate];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFailureGenerateHost:error];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestGenerateHost];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutGenerateHost) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}


-(void)requestSuccessGenerateHost:(id)object withOperation:(RKObjectRequestOperation*)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    _generatehost = info;
    NSString *statusstring = _generatehost.status;
    BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessGenerateHost:object];
    }
}

-(void)requestFailureGenerateHost:(id)object
{
    
}

-(void)requestProcessGenerateHost:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id info = [result objectForKey:@""];
            _generatehost = info;
            NSString *statusstring = _generatehost.status;
            BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                [_addImageButtons makeObjectsPerformSelector:@selector(setEnabled:) withObject:@(YES)];
                [_dataInput setObject:@(_generatehost.result.generated_host.server_id) forKey:API_SERVER_ID_KEY];
            }
        }
        else
        {
            NSError *error = object;
            if (!([error code] == NSURLErrorCancelled)){
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeoutGenerateHost
{
    [self cancelGenerateHost];
}

#pragma mark Request Action Upload Photo
-(void)configureRestkitUploadPhoto
{
    _objectmanagerUploadPhoto =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[UploadImage class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[UploadImageResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDSHOPEDIT_APIUPLOADFILEPATHKEY:kTKPDSHOPEDIT_APIUPLOADFILEPATHKEY,
                                                        kTKPDSHOPEDIT_APIUPLOADFILETHUMBKEY:kTKPDSHOPEDIT_APIUPLOADFILETHUMBKEY,
                                                        API_UPLOAD_PHOTO_ID_KEY:API_UPLOAD_PHOTO_ID_KEY
                                                        }];
    
    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAIL_UPLOADIMAGEAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerUploadPhoto addResponseDescriptor:responseDescriptor];
    
    [_objectmanagerUploadPhoto setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    [_objectmanagerUploadPhoto setRequestSerializationMIMEType:RKMIMETypeJSON];
}


- (void)cancelActionUploadPhoto
{
	_requestActionUploadPhoto = nil;
	
    [_operationQueueUploadImage cancelAllOperations];
    _objectmanagerUploadPhoto = nil;
}

- (void)requestActionUploadPhoto:(id)object
{
    
	NSDictionary* userInfo = object;
    
    NSDictionary *auth = [_data objectForKey:kTKPD_AUTHKEY];
    
    NSDictionary* photo = [userInfo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    NSData* imageData = [photo objectForKey:DATA_CAMERA_IMAGEDATA];
    NSString* imageName = [photo objectForKey:DATA_CAMERA_IMAGENAME];
    NSInteger serverID = [[_dataInput objectForKey:API_SERVER_ID_KEY]integerValue]?:_generatehost.result.generated_host.server_id;
    NSInteger userID = [[auth objectForKey:kTKPD_USERIDKEY]integerValue];

    ManageProductList *product = [_data objectForKey:DATA_PRODUCT_DETAIL_KEY];
    NSInteger productID = product.product_id;
    
    NSDictionary *param = @{ kTKPDDETAIL_APIACTIONKEY:kTKPDDETAIL_APIUPLOADPRODUCTIMAGEKEY,
                             kTKPDSHOPEDIT_APIUSERIDKEY:@(userID),
                             kTKPDGENERATEDHOST_APISERVERIDKEY:@(serverID),
                             API_PRODUCT_ID_KEY : @(productID)
                             };
    
    _requestActionUploadPhoto = [NSMutableURLRequest requestUploadImageData:imageData
                                                                  withName:API_UPLOAD_PRODUCT_IMAGE_DATA_NAME
                                                               andFileName:imageName
                                                     withRequestParameters:param
                                                             ];
    
    NSUInteger index = [[_dataInput objectForKey:kTKPDDETAIL_DATAINDEXKEY] integerValue];
    NSLog(@"Index image %zd", index);
    UIImageView *thumbProductImage = (UIImageView*)_thumbProductImageViews[index];
    thumbProductImage.alpha = 0.5f;
    thumbProductImage.userInteractionEnabled = NO;
    
    NSTimer *timer;
    NSDictionary *userInfoTimer = @{DATA_INDEX_KEY:@(index)};
    timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeoutUploadPhoto:) userInfo:userInfoTimer repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    _isFinishedUploadImages = NO;
    
    [NSURLConnection sendAsynchronousRequest:_requestActionUploadPhoto
                                       queue:_operationQueueUploadImage
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                               NSString *responsestring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               if ([httpResponse statusCode] == 200) {
                                   
                                   id parsedData = [RKMIMETypeSerialization objectFromData:data MIMEType:RKMIMETypeJSON error:&error];
                                   if (parsedData == nil && error) {
                                       NSLog(@"parser error");
                                       return;
                                   }
                                   
                                   _isFinishedUploadImages = YES;
                                   NSLog(@"Index image %zd", index);
                                   [timer invalidate];
                                   
                                   NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
                                   for (RKResponseDescriptor *descriptor in _objectmanagerUploadPhoto.responseDescriptors) {
                                       [mappingsDictionary setObject:descriptor.mapping forKey:descriptor.keyPath];
                                   }
                                   
                                   RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData mappingsDictionary:mappingsDictionary];
                                   NSError *mappingError = nil;
                                   BOOL isMapped = [mapper execute:&mappingError];
                                   if (isMapped && !mappingError) {
                                       NSLog(@"result %@",[mapper mappingResult]);
                                       RKMappingResult *mappingresult = [mapper mappingResult];
                                       NSDictionary *result = mappingresult.dictionary;
                                       id stat = [result objectForKey:@""];
                                       _images = stat;
                                       BOOL status = [_images.status isEqualToString:kTKPDREQUEST_OKSTATUS];
                                       
                                       if (status) {
                                           if (!_images.message_error) {
                                               [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION animations:^{
                                                   thumbProductImage.alpha = 1.0;
                                               }];
                                               thumbProductImage.userInteractionEnabled = YES;
                                               NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
                                               [_productImageURLs replaceObjectAtIndex:index withObject:_images.result.file_path];
                                               [_productImageIDs replaceObjectAtIndex:index withObject:@(_images.result.pic_id)];
                                               
                                               NSArray *objectProductPhoto = (type == TYPE_ADD_EDIT_PRODUCT_ADD || type == TYPE_ADD_EDIT_PRODUCT_COPY)?_productImageURLs:_productImageIDs;
                                               NSString *stringImageURLs = [[objectProductPhoto valueForKey:@"description"] componentsJoinedByString:@"~"];
                                               [_dataInput setObject:stringImageURLs forKey:API_PRODUCT_IMAGE_TOUPLOAD_KEY];
                                               NSLog(@" Product image URL %@ with string %@ ", objectProductPhoto, stringImageURLs);
                                           }
                                           else
                                           {
                                               [self failedAddImageAtIndex:index];
                                           }
                                           [self requestProcessUploadPhoto:mappingresult];
                                       }
                                   }
                                   
                               }
                               NSLog(@"%@",responsestring);
                           }];
}

- (void)requestSuccessUploadPhoto:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    _images = info;
    NSString *statusstring = _images.status;
    BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessUploadPhoto:object];
    }
}

- (void)requestFailureUploadPhoto:(id)object
{
    [self requestProcessUploadPhoto:object];
}

- (void)requestProcessUploadPhoto:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id info = [result objectForKey:@""];
            _images = info;
            NSString *statusstring = _images.status;
            BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if (!_images.message_error) {
                    //NSUInteger index = [[_dataInput objectForKey:kTKPDDETAIL_DATAINDEXKEY] integerValue];
                    //NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
                    //[_productImageURLs replaceObjectAtIndex:index withObject:_images.result.file_path];
                    //[_productImageIDs replaceObjectAtIndex:index withObject:@(_images.result.pic_id)];
                    //
                    //NSArray *objectProductPhoto = (type == TYPE_ADD_EDIT_PRODUCT_ADD)?_productImageURLs:_productImageIDs;
                    //NSString *stringImageURLs = [[objectProductPhoto valueForKey:@"description"] componentsJoinedByString:@"~"];
                    //[_dataInput setObject:stringImageURLs forKey:API_PRODUCT_IMAGE_TOUPLOAD_KEY];
                    //NSLog(@" Product image URL %@ with string %@ ", objectProductPhoto, stringImageURLs);
                }
                else
                {
                    NSArray *array = _images.message_error?:[[NSArray alloc] initWithObjects:@"failed", nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
            }
        }
        else
        {
            NSError *error = object;
            if (!([error code] == NSURLErrorCancelled)){
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}
-(void)requesttimeoutUploadPhoto:(NSTimer*)timer
{
    NSInteger index = [[[timer userInfo] objectForKey:DATA_INDEX_KEY] integerValue];
    [self cancelActionUploadPhoto];
    [self failedAddImageAtIndex:index];
}

#pragma mark Request Delete Image
-(void)configureRestKitDeleteImage
{
    _objectmanagerDeleteImage =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ShopSettings class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ShopSettingsResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIISSUCCESSKEY:kTKPDDETAIL_APIISSUCCESSKEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAILACTIONPRODUCT_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerDeleteImage addResponseDescriptor:responseDescriptor];
}

-(void)cancelDeleteImage
{
    [_requestDeleteImage cancel];
    _requestDeleteImage = nil;
    
    [_objectmanagerDeleteImage.operationQueue cancelAllOperations];
    _objectmanagerDeleteImage = nil;
}

- (void)requestDeleteImage:(id)object
{
    if(_requestDeleteImage.isExecuting) return;
    
    _requestcountDeleteImage ++;
    NSDictionary *userInfo = (NSDictionary*)object;
    
    NSInteger productID = [[userInfo objectForKey:API_PRODUCT_ID_KEY]integerValue];
    NSInteger myshopID = [[userInfo objectForKey:kTKPD_SHOPIDKEY]integerValue];
    NSInteger pictureID = [[userInfo objectForKey:API_PRODUCT_PICTURE_ID_KEY]integerValue];
    NSDictionary *param = @{kTKPDDETAIL_APIACTIONKEY : ACTION_DELETE_IMAGE,
                            API_PRODUCT_ID_KEY: @(productID),
                            kTKPD_SHOPIDKEY : @(myshopID),
                            API_PRODUCT_PICTURE_ID_KEY:@(pictureID)
                            };
    
    NSTimer *timer;
    
    _requestDeleteImage = [_objectmanagerDeleteImage appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAILACTIONPRODUCT_APIPATH parameters:[param encrypt]];
    [_requestDeleteImage setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessDeleteImage:mappingResult withOperation:operation];
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureDeleteImage:error];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestDeleteImage];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutDeleteImage) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}


-(void)requestSuccessDeleteImage:(id)object withOperation:(RKObjectRequestOperation*)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    _setting = info;
    NSString *statusstring = _setting.status;
    BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessDeleteImage:object];
    }
}

-(void)requestFailureDeleteImage:(id)object
{
    [self requestProcessDeleteImage:object];
}

-(void)requestProcessDeleteImage:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            ShopSettings *setting = stat;
            BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(setting.message_error)
                {
                    NSArray *array = setting.message_error?:[[NSArray alloc] initWithObjects:ERRORMESSAGE_DELETE_PRODUCT_IMAGE, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                    [self cancelDeletedImage];
                }
                if (setting.result.is_success == 1) {
                    NSArray *array = setting.message_status?:[[NSArray alloc] initWithObjects:SUCCESSMESSAGE_DELETE_PRODUCT_IMAGE, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
                }
            }
        }
        else{
            [self cancelDeleteImage];
            [self cancelDeletedImage];
            NSError *error = object;
            if (!([error code] == NSURLErrorCancelled)){
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
                [self cancelDeletedImage];
            }
        }
    }
}

-(void)requestTimeoutDeleteImage
{
    [self cancelDeleteImage];
}


#pragma mark - Camera Controller Delegate
-(void)didDismissCameraController:(UIViewController *)controller withUserInfo:(NSDictionary *)userinfo
{
    [self configureRestkitUploadPhoto];
    [self requestActionUploadPhoto:userinfo];

    NSDictionary* photo = [userinfo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];

    UIImage* image = [photo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    UIGraphicsBeginImageContextWithOptions(kTKPDCAMERA_UPLOADEDIMAGESIZE, NO, image.scale);
    [image drawInRect:kTKPDCAMERA_UPLOADEDIMAGERECT];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSUInteger index = [[_dataInput objectForKey:kTKPDDETAIL_DATAINDEXKEY] integerValue];
    NSUInteger indexEnableButton = (index<_addImageButtons.count-1)?index+1:index;
    //[(UIButton*)_buttonaddproduct[index] setBackgroundImage:image forState:UIControlStateNormal];
    ((UIButton*)_addImageButtons[indexEnableButton]).enabled = YES;
    ((UIButton*)_addImageButtons[index]).hidden = YES;
    ((UIImageView*)_thumbProductImageViews[index]).image = image;
    ((UIImageView*)_thumbProductImageViews[index]).hidden = NO;
    ((UIImageView*)_thumbProductImageViews[index]).alpha = 0.5f;
}

-(void)failedAddImageAtIndex:(NSInteger)index
{
    NSUInteger indexDisableButton = (index<_addImageButtons.count-1)?index+1:index;
    ((UIButton*)_addImageButtons[indexDisableButton]).enabled = NO;
    ((UIButton*)_addImageButtons[index]).hidden = NO;
    ((UIImageView*)_thumbProductImageViews[index]).hidden = YES;
    
    NSArray *array = _images.message_error?:[[NSArray alloc] initWithObjects:ERRORMESSAGE_FAILED_IMAGE_UPLOAD, nil];
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
}

#pragma mark - Category Delegate
-(void)CategoryMenuViewController:(CategoryMenuViewController *)viewController userInfo:(NSDictionary *)userInfo
{
    NSString *departmentTitle = [userInfo objectForKey:kTKPDCATEGORY_DATATITLEKEY];
    NSInteger departmentID = [[userInfo objectForKey:API_DEPARTMENT_ID_KEY] integerValue];
    [_categoryButton setTitle:departmentTitle forState:UIControlStateNormal];
    [_dataInput setObject:@(departmentID) forKey:API_DEPARTMENT_ID_KEY];
}

#pragma mark - Product Edit Image Delegate

-(void)deleteProductImageAtIndex:(NSInteger)index
{
    [_dataInput setObject:_productImageIDs[index] forKey:DATA_LAST_DELETED_IMAGE_ID];
    [_dataInput setObject:_productImageURLs forKey:DATA_LAST_DELETED_IMAGE_PATH];
    [_dataInput setObject:@(index) forKey:DATA_LAST_DELETED_INDEX];
    [_dataInput setObject:((UIImageView*)_thumbProductImageViews[index]).image forKey:DATA_LAST_DELETED_IMAGE];
    
    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
    if (type == TYPE_ADD_EDIT_PRODUCT_EDIT || type == TYPE_ADD_EDIT_PRODUCT_COPY) {
        [self configureRestKitDeleteImage];
        TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
        NSDictionary* auth = [secureStorage keychainDictionary];
        
        DetailProductResult *detailProduct = _product.result;
        NSInteger productID = [detailProduct.product.product_id integerValue];
        NSInteger myshopID = [[auth objectForKey:kTKPD_SHOPIDKEY]integerValue];
        NSInteger pictureID = [_productImageIDs[index] integerValue];
        NSDictionary *userInfo = @{API_PRODUCT_ID_KEY: @(productID),
                                   kTKPD_SHOPIDKEY : @(myshopID),
                                   API_PRODUCT_PICTURE_ID_KEY:@(pictureID)
                                   };
        [self requestDeleteImage:userInfo];
    }

    ((UIButton*)_addImageButtons[index]).hidden = NO;
    ((UIButton*)_addImageButtons[index]).enabled = YES;
    [_productImageIDs replaceObjectAtIndex:index withObject:@""];
    [_productImageURLs replaceObjectAtIndex:index withObject:@""];
    ((UIImageView*)_thumbProductImageViews[index]).image = nil;
    ((UIImageView*)_thumbProductImageViews[index]).hidden = YES;
}

-(void)updateProductImage:(UIImage *)image AtIndex:(NSInteger)index withUserInfo:(NSDictionary *)userInfo
{
    [self configureRestkitUploadPhoto];
    [self requestActionUploadPhoto:userInfo];
    
    UIGraphicsBeginImageContextWithOptions(kTKPDCAMERA_UPLOADEDIMAGESIZE, NO, image.scale);
    [image drawInRect:kTKPDCAMERA_UPLOADEDIMAGERECT];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    ((UIButton*)_addImageButtons[index]).hidden = YES;
    ((UIImageView*)_thumbProductImageViews[index]).image = image;
    ((UIImageView*)_thumbProductImageViews[index]).hidden = NO;
}

-(void)setDefaultImageAtIndex:(NSInteger)index
{
    for (UILabel *defaultImageLabel in _defaultImageLabels) {
        defaultImageLabel.hidden = YES;
    }
    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
    ((UILabel*)_defaultImageLabels[index]).hidden = NO;
    NSString *imagePath = _productImageURLs[index];
    NSString *imageID = _productImageIDs[index];
    NSString *defaultImage = (type == TYPE_ADD_EDIT_PRODUCT_ADD)?imagePath:imageID;
    [_dataInput setObject:defaultImage forKey:API_PRODUCT_IMAGE_DEFAULT_KEY];
}

-(void)setProductImageName:(NSString *)name atIndex:(NSInteger)index
{
    [_productImageDesc replaceObjectAtIndex:index withObject:name];
    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
    if (type == TYPE_ADD_EDIT_PRODUCT_ADD) {
        NSString *stringImageName = [[_productImageDesc valueForKey:@"description"] componentsJoinedByString:@"~"];
        [_dataInput setObject:stringImageName forKey:API_PRODUCT_IMAGE_DESCRIPTION_KEY];
    }
    else
    {
        NSInteger imageID =[_productImageIDs[index] integerValue];
        NSString *imageDescriptionKey = [NSString stringWithFormat:API_PRODUCT_IMAGE_DESCRIPTION_KEY@"%zd",imageID];
        NSDictionary *imageNames = [_dataInput objectForKey:API_PRODUCT_IMAGE_DESCRIPTION_KEY];
        NSMutableDictionary *ImageNameDictionary = [NSMutableDictionary new];
        [ImageNameDictionary addEntriesFromDictionary:imageNames];
        [ImageNameDictionary setObject:name forKey:imageDescriptionKey];
        [_dataInput setObject:ImageNameDictionary forKey:API_PRODUCT_IMAGE_DESCRIPTION_KEY];
    }
}

#pragma mark - Alert View Delegate
-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    
    switch (alertView.tag) {
        case 11:
        {
            
            //price curency
            TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
            NSDictionary* auth = [secureStorage keychainDictionary];
            BOOL isGoldShop = [[auth objectForKey:kTKPD_SHOPISGOLD]boolValue];
            
            NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];

            NSInteger previousValue = [[_dataInput objectForKey:API_PRODUCT_PRICE_CURRENCY_ID_KEY]integerValue];
            
            NSInteger value = [[ARRAY_PRICE_CURRENCY[index] objectForKey:DATA_VALUE_KEY] integerValue];

            if ( value == PRICE_CURRENCY_ID_USD && !isGoldShop) {
            
                NSArray *errorMessage = @[ERRORMESSAGE_INVALID_PRICE_CURRENCY_USD];
                
                NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:errorMessage,@"messages", nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];

            }
            else{
            
                NSString *name = [ARRAY_PRICE_CURRENCY[index] objectForKey:DATA_NAME_KEY];
               
                if (value != previousValue) {
                    _productPriceTextField.text = @"";
                }
                
                [_dataInput setObject:@(value) forKey:API_PRODUCT_PRICE_CURRENCY_ID_KEY];
                
                [_priceCurrencyButton setTitle:name forState:UIControlStateNormal];
            }
            break;
        }
        case 12:
        {
            //weight curency
            NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];
            NSInteger value = [[ARRAY_WEIGHT_UNIT[index] objectForKey:DATA_VALUE_KEY] integerValue];
            [_dataInput setObject:@(value) forKey:API_PRODUCT_WEIGHT_UNIT_KEY];
            NSString *name = [ARRAY_WEIGHT_UNIT[index] objectForKey:DATA_NAME_KEY];
            [_weightUnitButton setTitle:name forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
}


#pragma mark - Text Field Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    _activeTextField = textField;
    [textField resignFirstResponder];
    if (textField == _productNameTextField) {
        NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
        if (type == TYPE_ADD_EDIT_PRODUCT_EDIT) {
            UIAlertView *editableNameProduct = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:ERRRORMESSAGE_CANNOT_EDIT_PRODUCT_NAME delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
            [editableNameProduct show];
        }
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == _productNameTextField) {
        NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
        if (type == TYPE_ADD_EDIT_PRODUCT_ADD || type == TYPE_ADD_EDIT_PRODUCT_COPY) {
            [_dataInput setObject:textField.text forKey:API_PRODUCT_NAME_KEY];
        }
    }
    if (textField == _productPriceTextField) {
        
        NSString *productPrice = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
        [_dataInput setObject:productPrice forKey:API_PRODUCT_PRICE_KEY];
    }
    if (textField == _productWeightTextField) {
        [_dataInput setObject:textField.text forKey:API_PRODUCT_WEIGHT_KEY];
    }
    if (textField == _minimumOrderTextField) {
        [_dataInput setObject:textField.text forKey:API_PRODUCT_MINIMUM_ORDER_KEY];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSInteger currency = [[_dataInput objectForKey:API_PRODUCT_PRICE_CURRENCY_ID_KEY]integerValue];
    BOOL isIDRCurrency = (currency == PRICE_CURRENCY_ID_RUPIAH);
    if (textField == _productPriceTextField) {
        if (isIDRCurrency) {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            if([string length]==0)
            {
                [formatter setGroupingSeparator:@","];
                [formatter setGroupingSize:4];
                [formatter setUsesGroupingSeparator:YES];
                [formatter setSecondaryGroupingSize:3];
                NSString *num = textField.text ;
                num = [num stringByReplacingOccurrencesOfString:@"," withString:@""];
                NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:[num doubleValue]]];
                textField.text = str;
                return YES;
            }
            else {
                [formatter setGroupingSeparator:@","];
                [formatter setGroupingSize:2];
                [formatter setUsesGroupingSeparator:YES];
                [formatter setSecondaryGroupingSize:3];
                NSString *num = textField.text ;
                if(![num isEqualToString:@""])
                {
                    num = [num stringByReplacingOccurrencesOfString:@"," withString:@""];
                    NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:[num doubleValue]]];
                    textField.text = str;
                }
                return YES;
            }
        }
    }
    return YES;
}

#pragma mark - Product Edit Detail Delegate 
-(void)ProductEditDetailViewController:(ProductAddEditDetailViewController *)cell withUserInfo:(NSDictionary *)userInfo
{
    NSDictionary *updatedDataInput = [userInfo objectForKey:DATA_INPUT_KEY];
    
    [_dataInput removeAllObjects];
    [_dataInput addEntriesFromDictionary:updatedDataInput];
}

#pragma mark - Methods

- (void) setDefaultData:(NSDictionary*)data
{
    _data = data;
    if (data) {
        
        NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
        self.title = (type ==TYPE_ADD_EDIT_PRODUCT_ADD)?TITLE_ADD_PRODUCT:TITLE_EDIT_PRODUCT;
        
        DetailProductResult *detailProduct = _product.result;
        NSArray *images = detailProduct.product_images;
        NSInteger imageCount = images.count;
        NSInteger addProductImageCount = (imageCount<_addImageButtons.count)?imageCount:imageCount-1;
        ((UIButton*)_addImageButtons[addProductImageCount]).enabled = YES;
        
        NSMutableDictionary *productImageDescription = [NSMutableDictionary new];
        for (int i = 0 ; i<imageCount;i++) {
            ProductImages *image = images[i];
            ((UIButton*)_addImageButtons[i]).hidden = YES;
            [_productImageURLs replaceObjectAtIndex:i withObject:image.image_src];
            [_productImageIDs replaceObjectAtIndex:i withObject:@(image.image_id)];
            [_productImageDesc replaceObjectAtIndex:i withObject:image.image_description];

            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:image.image_src] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            UIImageView *thumb = (UIImageView*)_thumbProductImageViews[i];
            thumb.userInteractionEnabled = NO;
            thumb.hidden = NO;
            thumb.image = nil;
            //thumb.hidden = YES;	//@prepareforreuse then @reset
            [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                [thumb setImage:image animated:YES];
#pragma clang diagnostic pop
                thumb.userInteractionEnabled = YES;
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            }];
            
            NSString *productImageDescriptionKey = [NSString stringWithFormat:API_PRODUCT_IMAGE_DESCRIPTION_KEY@"%zd",image.image_id];
            [productImageDescription setObject:image.image_description forKey:productImageDescriptionKey];
        }
        
        [_dataInput setObject:productImageDescription forKey:API_PRODUCT_IMAGE_DESCRIPTION_KEY];

        NSArray *objectProductPhoto = (type == TYPE_ADD_EDIT_PRODUCT_ADD||type == TYPE_ADD_EDIT_PRODUCT_COPY)?_productImageURLs:_productImageIDs;
        NSString *stringImageURLs = [[objectProductPhoto valueForKey:@"description"] componentsJoinedByString:@"~"];
        [_dataInput setObject:stringImageURLs forKey:API_PRODUCT_IMAGE_TOUPLOAD_KEY];
        NSLog(@" Product image URL %@ with string %@ ", objectProductPhoto, stringImageURLs);
        
        NSInteger serverID = detailProduct.server_id;
        NSNumber *productID = detailProduct.product.product_id?:@(0);
        NSString *productName = detailProduct.product.product_name?:@"";
        NSArray *breadcrumbs = detailProduct.breadcrumb?:@[];
        Breadcrumb *breadcrumb = [breadcrumbs lastObject];
        NSString *categoryName = breadcrumb.department_name;
        NSInteger categoryID = [breadcrumb.department_id integerValue];
        NSInteger minimumOrder = detailProduct.product.product_min_order?:1;
        NSString *priceCurencyID = detailProduct.product.product_currency_id?:@"1";
        
        NSInteger indexPriceCurrency = [priceCurencyID integerValue]?[priceCurencyID integerValue]-1:[priceCurencyID integerValue];
        NSString *priceCurrency = [ARRAY_PRICE_CURRENCY[indexPriceCurrency] objectForKey:DATA_NAME_KEY];
        NSString *price = detailProduct.product.product_price?:@"";
        NSInteger weightUnitID = [detailProduct.product.product_weight_unit integerValue];
        NSInteger indexWeightUnit = weightUnitID?weightUnitID-1:weightUnitID;
        NSString *weightUnit = [ARRAY_WEIGHT_UNIT[indexWeightUnit] objectForKey:DATA_NAME_KEY];
        NSString *weight = detailProduct.product.product_weight?:@"";
        NSInteger mustInsurance = [detailProduct.product.product_must_insurance integerValue];
        NSInteger productConditionID = [detailProduct.product.product_condition integerValue];
        NSString *productDescription = detailProduct.product.product_short_desc?:@"";
        NSArray *wholesale = detailProduct.wholesale_price?:@[];
        BOOL isWarehouse = ([detailProduct.product.product_etalase_id integerValue]>0)?NO:YES;
        NSInteger uploadToWarehouse = isWarehouse?UPLOAD_TO_VALUE_IF_IS_WAREHOUSE:UPLOAD_TO_VALUE_IF_ISNOT_WAREHOUSE;
        NSInteger etalaseID = [detailProduct.product.product_etalase_id integerValue];
        BOOL isGoldShop = detailProduct.shop_is_gold;
        NSInteger returnable = detailProduct.product.product_returnable;
        NSString *etalaseName = detailProduct.product.product_etalase?:@"";
        
        _productNameTextField.text = productName;
        //_productNameTextField.enabled = (type ==TYPE_ADD_EDIT_PRODUCT_ADD || type == TYPE_ADD_EDIT_PRODUCT_COPY)?YES:NO;

        [_categoryButton setTitle:categoryName?:@"Pilih Kategori" forState:UIControlStateNormal];
        _minimumOrderTextField.text = [NSString stringWithFormat:@"%zd",minimumOrder];
        [_priceCurrencyButton setTitle:priceCurrency forState:UIControlStateNormal];
        [_dataInput setObject:price forKey:API_PRODUCT_PRICE_KEY];
        
        NSInteger priceInteger = [price integerValue];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        if ([priceCurencyID integerValue] == PRICE_CURRENCY_ID_RUPIAH) {
            [formatter setGroupingSeparator:@","];
            [formatter setGroupingSize:3];
            [formatter setUsesGroupingSeparator:YES];
            [formatter setSecondaryGroupingSize:3];
            price = (priceInteger>0)?[formatter stringFromNumber:@(priceInteger)]:@"";
        }
        else
        {
            price = (price>0)?[NSString localizedStringWithFormat:@"%.2f",(float)priceInteger]:@"";

            //[formatter setNumberStyle: NSNumberFormatterDecimalStyle];
            //price = [formatter stringFromNumber:[NSNumber numberWithDouble:[price doubleValue]]];
        }
        
        _productPriceTextField.text = price;
        [_weightUnitButton setTitle:weightUnit forState:UIControlStateNormal];
        _productWeightTextField.text = weight;
        
        [_dataInput setObject:@(serverID) forKey:API_SERVER_ID_KEY];
        [_dataInput setObject:productID forKey:API_PRODUCT_ID_KEY];
        [_dataInput setObject:productName forKey:API_PRODUCT_NAME_KEY];
        [_dataInput setObject:@(categoryID) forKey:API_DEPARTMENT_ID_KEY];
        [_dataInput setObject:@(minimumOrder) forKey:API_PRODUCT_MINIMUM_ORDER_KEY];
        [_dataInput setObject:priceCurencyID forKey:API_PRODUCT_PRICE_CURRENCY_ID_KEY];
        [_dataInput setObject:@(weightUnitID) forKey:API_PRODUCT_WEIGHT_UNIT_KEY];
        [_dataInput setObject:weight forKey:API_PRODUCT_WEIGHT_KEY];
        [_dataInput setObject:@(mustInsurance) forKey:API_PRODUCT_MUST_INSURANCE_KEY];
        [_dataInput setObject:@(productConditionID) forKey:API_PRODUCT_CONDITION_KEY];
        [_dataInput setObject:productDescription forKey:API_PRODUCT_DESCRIPTION_KEY];
        [_dataInput setObject:wholesale forKey:DATA_WHOLESALE_LIST_KEY];
        [_dataInput setObject:@(uploadToWarehouse) forKey:API_PRODUCT_MOVETO_WAREHOUSE_KEY];
        [_dataInput setObject:@(etalaseID) forKey:API_PRODUCT_ETALASE_ID_KEY];
        [_dataInput setObject:@(isGoldShop) forKey:API_IS_GOLD_SHOP_KEY];
        [_dataInput setObject:@(returnable) forKey:API_PRODUCT_IS_RETURNABLE_KEY];
        [_dataInput setObject:etalaseName forKey:API_PRODUCT_ETALASE_NAME_KEY];
    }
}

- (BOOL)dataInputIsValid
{
    [_errorMessage removeAllObjects];
    BOOL isValid = YES;
    BOOL isValidPrice = YES;
    BOOL isValidWeight = YES;
    BOOL isValidImage = (_productImageURLs.count>0);
    NSString *productName = [_dataInput objectForKey:API_PRODUCT_NAME_KEY]?:@"";
    NSInteger productPrice = [[_dataInput objectForKey:API_PRODUCT_PRICE_KEY]integerValue]?:0;
    NSInteger productPriceCurrencyID = [[_dataInput objectForKey:API_PRODUCT_PRICE_CURRENCY_ID_KEY]integerValue]?:1;
    NSInteger productWeight = [[_dataInput objectForKey:API_PRODUCT_WEIGHT_KEY]integerValue]?:0;
    NSInteger productWeightUnitID = [[_dataInput objectForKey:API_PRODUCT_WEIGHT_UNIT_KEY]integerValue]?:1;
    NSInteger departmentID = [[_dataInput objectForKey:API_DEPARTMENT_ID_KEY]integerValue]?:0;
    
    BOOL isPriceCurrencyRupiah = (productPriceCurrencyID == 1);
    BOOL isPriceCurrencyUSD = (productPriceCurrencyID == 2);
    
    BOOL isWeightUnitGram = (productWeightUnitID == 1);
    BOOL isWeightUnitKilogram = (productWeightUnitID == 2);
    
    if (productName && ![productName isEqualToString:@""] &&
        productPrice>0 &&
        productWeight>0 &&
        departmentID>0) {
       
        if (isPriceCurrencyRupiah && productPrice>=MINIMUM_PRICE_RUPIAH && productPrice<=MAXIMUM_PRICE_RUPIAH)
            isValidPrice = YES;
        else if (isPriceCurrencyUSD && productPrice>=MINIMUM_PRICE_USD && productPrice<=MAXIMUM_PRICE_USD)
            isValidPrice = YES;
        else
            isValidPrice = NO;
        
        if (isWeightUnitGram && productWeight >=MINIMUM_WEIGHT_GRAM && productWeight<=MAXIMUM_WEIGHT_GRAM)
            isValidWeight = YES;
        else if (isWeightUnitKilogram && productWeight>=MINIMUM_WEIGHT_KILOGRAM && productWeight<=MAXIMUM_WEIGHT_KILOGRAM)
            isValidWeight = YES;
        else
            isValidWeight = NO;
    }

    if ( !productName || [productName isEqualToString:@""]) {
        [_errorMessage addObject:ERRORMESSAGE_NULL_PRODUCT_NAME];
        isValid = NO;
    }
    if (!(productPrice > 0)) {
        [_errorMessage addObject:ERRORMESSAGE_NULL_PRICE];
        isValid = NO;
    }
    else
    {
        if (productPriceCurrencyID == PRICE_CURRENCY_ID_RUPIAH && (productPrice<MINIMUM_PRICE_RUPIAH || productPrice>MAXIMUM_PRICE_RUPIAH)) {
            [_errorMessage addObject:ERRORMESSAGE_INVALID_PRICE_RUPIAH];
            isValid = NO;
        }
        else if (productPriceCurrencyID == PRICE_CURRENCY_ID_USD && (productPrice<MINIMUM_PRICE_USD || productPrice>MAXIMUM_PRICE_USD)) {
            [_errorMessage addObject:ERRORMESSAGE_INVALID_PRICE_USD];
            isValid = NO;
        }
    }
    if (!(departmentID>0)) {
        [_errorMessage addObject:ERRORMESSAGE_NULL_CATEGORY];
        isValid = NO;
    }
    if (productWeightUnitID == WEIGHT_UNIT_ID_GRAM && (productWeight<MINIMUM_WEIGHT_GRAM || productWeight>MAXIMUM_WEIGHT_GRAM)) {
        [_errorMessage addObject:ERRORMESSAGE_INVALID_WEIGHT_GRAM];
        isValid = NO;
    }
    else if (productWeightUnitID == WEIGHT_UNIT_ID_KILOGRAM && (productWeight<MINIMUM_WEIGHT_KILOGRAM || productWeight>MAXIMUM_WEIGHT_KILOGRAM)) {
        [_errorMessage addObject:ERRORMESSAGE_INVALID_WEIGHT_KILOGRAM];
        isValid = NO;
    }
    if (!isValidImage) {
        [_errorMessage addObject:ERRORMESSAGE_NULL_IMAGE];
    }

    return (isValidWeight && isValidPrice && isValid && isValidImage);
}

-(void)enableButtonBeforeSuccessRequest:(BOOL)isEnable
{
    _nextBarButtonItem.enabled = isEnable;
    ((UIButton*)_addImageButtons[0]).enabled = NO;
    _categoryButton.enabled = isEnable;
    _priceCurrencyButton.enabled = isEnable;
    _categoryButton.enabled = isEnable;
    _productNameTextField.userInteractionEnabled = isEnable;
    _minimumOrderTextField.userInteractionEnabled = isEnable;
    _productPriceTextField.userInteractionEnabled = isEnable;
    _weightUnitButton.enabled = isEnable;
    _productWeightTextField.userInteractionEnabled = isEnable;
}

-(void)cancelDeletedImage
{
    NSString *deletedImagePath = [_dataInput objectForKey:DATA_LAST_DELETED_IMAGE_PATH];
    NSInteger deletedImageID = [[_dataInput objectForKey:DATA_LAST_DELETED_IMAGE_ID]integerValue];
    NSInteger index = [[_dataInput objectForKey:DATA_LAST_DELETED_INDEX]integerValue];
    UIImage *image = [_dataInput objectForKey:DATA_LAST_DELETED_IMAGE];
    
    UIGraphicsBeginImageContextWithOptions(kTKPDCAMERA_UPLOADEDIMAGESIZE, NO, image.scale);
    [image drawInRect:kTKPDCAMERA_UPLOADEDIMAGERECT];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    ((UIButton*)_addImageButtons[index]).hidden = YES;
    ((UIImageView*)_thumbProductImageViews[index]).image = image;
    ((UIImageView*)_thumbProductImageViews[index]).hidden = NO;
    [_productImageURLs replaceObjectAtIndex:index withObject:deletedImagePath];
    [_productImageIDs replaceObjectAtIndex:index withObject:@(deletedImageID)];
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification *)info {
    if(_keyboardSize.height < 0){
        _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
        _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
        
        
        _scrollviewContentSize = [_scrollView contentSize];
        _scrollviewContentSize.height += _keyboardSize.height;
        [_scrollView setContentSize:_scrollviewContentSize];
    }else{
        [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                              delay:0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _scrollviewContentSize = [_scrollView contentSize];
                             _scrollviewContentSize.height -= _keyboardSize.height;
                             
                             _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
                             _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
                             _scrollviewContentSize.height += _keyboardSize.height;
                             if ((_activeTextField.frame.origin.y+_activeTextField.frame.size.height)> _keyboardPosition.y) {
                                 UIEdgeInsets inset = _scrollView.contentInset;
                                 inset.top = (_keyboardPosition.y-(self.view.frame.origin.y + _activeTextField.frame.origin.y+_activeTextField.frame.size.height + 10));
                                 [_scrollView setContentInset:inset];
                             }
                         }
                         completion:^(BOOL finished){
                         }];
        
    }
}

- (void)keyboardWillHide:(NSNotification *)info {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _scrollView.contentInset = contentInsets;
                         _scrollView.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished){
                     }];
}


@end
