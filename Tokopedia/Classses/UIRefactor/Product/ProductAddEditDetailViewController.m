//
//  ProductAddEditDetailViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 12/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "ShopSettings.h"
#import "AddProductValidation.h"
#import "AddProductPicture.h"
#import "AddProductSubmit.h"
#import "string_product.h"
#import "string_alert.h"
#import "EtalaseList.h"
#import "WholesalePrice.h"
#import "sortfiltershare.h"
#import "AlertPickerView.h"
#import "ProductAddEditDetailViewController.h"
#import "MyShopEtalaseFilterViewController.h"
#import "ProductEditWholesaleViewController.h"
#import "MyShopEtalaseEditViewController.h"
#import "MyShopNoteViewController.h"

@interface ProductAddEditDetailViewController ()<UITextViewDelegate, TKPDAlertViewDelegate, MyShopEtalaseFilterViewControllerDelegate,ProductEditWholesaleViewControllerDelegate>
{
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;
    
    NSMutableDictionary *_auth;
    NSMutableDictionary *_dataInput;
    NSMutableArray *_wholesaleList;
    
    UITextView *_activeTextView;
    
    NSInteger _requestCount;
    NSOperationQueue *_operationQueue;
    
    __weak RKObjectManager *_objectManagerActionAddProductValidation;
    __weak RKManagedObjectRequestOperation *_requestActionAddProductValidation;
    
    __weak RKObjectManager *_objectManagerActionAddProductPicture;
    __weak RKManagedObjectRequestOperation *_requestActionAddProductPicture;
    
    __weak RKObjectManager *_objectManagerActionAddProductSubmit;
    __weak RKManagedObjectRequestOperation *_requestActionAddProductSubmit;
    
    __weak RKObjectManager *_objectManagerActionEditProduct;
    __weak RKManagedObjectRequestOperation *_requestActionEditProduct;
    
    UIBarButtonItem *_saveBarButtonItem;
}

@property (weak, nonatomic) IBOutlet UIScrollView *containerScrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UISwitch *returnableProductSwitch;
@property (weak, nonatomic) IBOutlet UIButton *insuranceButton;
@property (weak, nonatomic) IBOutlet UIButton *etalaseButton;
@property (weak, nonatomic) IBOutlet UIButton *etalaseDetailButton;
@property (weak, nonatomic) IBOutlet UIButton *productConditionButton;
@property (weak, nonatomic) IBOutlet UITextView *productDescriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *productDescriptionLabel;

-(void)cancelActionAddProductValidation;
-(void)configureRestkitActionAddProductValidation;
-(void)requestActionAddProductValidation:(id)object;
-(void)requestSuccessActionAddProductValidation:(id)object withOperation:(RKObjectRequestOperation *)operation;
-(void)requestFailureActionAddProductValidation:(id)object;
-(void)requestProcessActionAddProductValidation:(id)object;
-(void)requestTimeOutActionAddProductValidation:(NSTimer*)timer;

-(void)cancelActionAddProductPicture;
-(void)configureRestkitActionAddProductPicture;
-(void)requestActionAddProductPicture:(id)object;
-(void)requestSuccessActionAddProductPicture:(id)object withOperation:(RKObjectRequestOperation *)operation;
-(void)requestFailureActionAddProductPicture:(id)object;
-(void)requestProcessActionAddProductPicture:(id)object;
-(void)requestTimeOutActionAddProductPicture:(NSTimer*)timer;

-(void)cancelActionAddProductSubmit;
-(void)configureRestkitActionAddProductSubmit;
-(void)requestActionAddProductSubmit:(id)object;
-(void)requestSuccessActionAddProductSubmit:(id)object withOperation:(RKObjectRequestOperation *)operation;
-(void)requestFailureActionAddProductSubmit:(id)object;
-(void)requestProcessActionAddProductSubmit:(id)object;
-(void)requestTimeOutActionAddProductSubmit:(NSTimer*)timer;

-(void)cancelActionEditProduct;
-(void)configureRestkitActionEditProduct;
-(void)requestActionEditProduct:(id)object;
-(void)requestSuccessActionEditProduct:(id)object withOperation:(RKObjectRequestOperation *)operation;
-(void)requestFailureActionEditProduct:(id)object;
-(void)requestProcessActionEditProduct:(id)object;
-(void)requestTimeOutActionEditProduct:(NSTimer*)timer;

- (IBAction)gesture:(id)sender;
- (IBAction)tap:(id)sender;

@end

@implementation ProductAddEditDetailViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _wholesaleList = [NSMutableArray new];
    _dataInput = [NSMutableDictionary new];
    _auth = [NSMutableDictionary new];
    
    _operationQueue = [NSOperationQueue new];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = BARBUTTON_PRODUCT_BACK;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    _saveBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [_saveBarButtonItem setTintColor:[UIColor blackColor]];
    _saveBarButtonItem.tag = BARBUTTON_PRODUCT_SAVE;
    self.navigationItem.rightBarButtonItem = _saveBarButtonItem;
    
    [self setDefaultData:_data];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
    
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary* auth = [secureStorage keychainDictionary];
    _auth = [auth mutableCopy];
}

-(void)viewDidLayoutSubviews
{
    _containerScrollView.contentSize = _contentView.frame.size;
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    NSDictionary *userInfo = @{DATA_INPUT_KEY:_dataInput};
    [_delegate ProductEditDetailViewController:self withUserInfo:userInfo];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    [_activeTextView resignFirstResponder];
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton*)sender;
        switch (button.tag) {
            case BUTTON_PRODUCT_INSURANCE:
            {
                AlertPickerView *alertView = [AlertPickerView newview];
                alertView.tag = BUTTON_PRODUCT_INSURANCE;
                alertView.delegate = self;
                alertView.pickerData = ARRAY_PRODUCT_INSURACE;
                [alertView show];
                break;
            }
            case BUTTON_PRODUCT_CONDITION:
            {
                AlertPickerView *alertView = [AlertPickerView newview];
                alertView.tag = BUTTON_PRODUCT_CONDITION;
                alertView.delegate = self;
                alertView.pickerData = ARRAY_PRODUCT_CONDITION;
                [alertView show];
                break;
            }
            case BUTTON_PRODUCT_ETALASE:
            {
                AlertPickerView *alertView = [AlertPickerView newview];
                alertView.tag = BUTTON_PRODUCT_ETALASE;
                alertView.delegate = self;
                alertView.pickerData = ARRAY_PRODUCT_MOVETO_ETALASE;
                [alertView show];
                break;
            }
            case BUTTON_PRODUCT_ETALASE_DETAIL:
            {
                NSIndexPath *indexpath = [_dataInput objectForKey:kTKPDDETAILETALASE_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                MyShopEtalaseFilterViewController *etalaseViewController = [MyShopEtalaseFilterViewController new];
                NSDictionary *auth = [_data objectForKey:kTKPD_AUTHKEY];
                etalaseViewController.data = @{kTKPDDETAIL_APISHOPIDKEY:@([[auth objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue]?:0),
                            kTKPDFILTER_DATAINDEXPATHKEY: indexpath,
                            DATA_PRESENTED_ETALASE_TYPE_KEY : @(PRESENTED_ETALASE_ADD_PRODUCT),
                            
                            };
                etalaseViewController.delegate = self;
                [self.navigationController pushViewController:etalaseViewController animated:YES];
            }
            default:
                break;
        }
    }
    if ([sender isKindOfClass:[UISwitch class]]) {
        UISwitch *returnableSwitch =(UISwitch*)sender;
        BOOL isReturnable = returnableSwitch.on;
        [_dataInput setObject:@(isReturnable) forKey:API_PRODUCT_IS_RETURNABLE_KEY];
    }
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        switch (button.tag) {
            case BARBUTTON_PRODUCT_BACK:
            {
                NSDictionary *userInfo = @{DATA_INPUT_KEY:_dataInput};
                [_delegate ProductEditDetailViewController:self withUserInfo:userInfo];
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            case BARBUTTON_PRODUCT_SAVE:
            {
                NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
                if (type == TYPE_ADD_EDIT_PRODUCT_ADD|| type == TYPE_ADD_EDIT_PRODUCT_COPY) {
                    [self configureRestkitActionAddProductValidation];
                    [self requestActionAddProductValidation:_dataInput];
                }
                else
                {
                    [self configureRestkitActionEditProduct];
                    [self requestActionEditProduct:_dataInput];
                }
                break;
            }
            default:
                break;
        }
    }
}

- (IBAction)gesture:(id)sender {
    [_activeTextView resignFirstResponder];
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *gesture = (UITapGestureRecognizer*)sender;
            //switch (gesture.state) {
            //case UIGestureRecognizerStateBegan: {
            //    break;
            //}
            //case UIGestureRecognizerStateChanged: {
            //    break;
            //}
            //case UIGestureRecognizerStateEnded: {
                if (gesture.view.tag == GESTURE_PRODUCT_EDIT_WHOLESALE) {
                    ProductEditWholesaleViewController *editWholesaleVC = [ProductEditWholesaleViewController new];
                    editWholesaleVC.data = @{kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY],
                                  DATA_INPUT_KEY : _dataInput
                                  };
                    editWholesaleVC.delegate = self;
                    [self.navigationController pushViewController:editWholesaleVC animated:YES];
                }
                    //break;
                //}
            //}
    }
}

#pragma mark - -Request Add Product Validation
-(void)cancelActionAddProductValidation
{
    [_requestActionAddProductValidation cancel];
    _requestActionAddProductValidation = nil;
    [_objectManagerActionAddProductValidation.operationQueue cancelAllOperations];
    _objectManagerActionAddProductValidation = nil;
}

-(void)configureRestkitActionAddProductValidation
{
    _objectManagerActionAddProductValidation = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[AddProductValidation class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[AddProductValidationResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIISSUCCESSKEY:kTKPDDETAIL_APIISSUCCESSKEY,
                                                        API_POSTKEY_KEY : API_POSTKEY_KEY
                                                        }];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAILACTIONPRODUCT_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerActionAddProductValidation addResponseDescriptor:responseDescriptor];
    
}
/**
 # add product new langkah ke-1
 # sub add_product_validation example URL
 # www.tkpdevel-pg.ekarisky/ws/action/product.pl?action=add_product_validation&
 # server_id=2&
 # duplicate=0&
 # product_name=Produk%20dari%20WS%20IOS&
 # product_description=Coba%20Tambah%20Produk%20dari%20WS%20IOS&
 # product_department_id=582&
 # product_catalog_id=5312&
 # product_min_order=1&
 # product_price_currency=1&
 # product_price=1000000&
 # product_weight_unit=1&
 # product_weight=1&
 # product_photo=& (delimiternya '~')
 # product_photo_desc=& (delimiternya '~')
 # product_photo_default=&
 # product_must_insurance=0&
 # product_upload_to=1&
 # product_etalase_id=1509&
 # product_etalase_name=sdfdsfds113&
 # product_condition=1&
 # product_returnable=1&
 # qty_min_1=&
 # qty_max_1=&
 # prd_prc_1=&
 # click_name=& 
 **/
-(void)requestActionAddProductValidation:(id)object
{
    if (_requestActionAddProductValidation.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userInfo = (NSDictionary*)object;
#define PRODUCT_MOVETO_WAREHOUSE_ID 2
    
    //TODO:: catalogid
    NSString *action = ACTION_ADD_PRODUCT_VALIDATION;
    NSInteger serverID = [[userInfo objectForKey:API_SERVER_ID_KEY] integerValue]?:0;
    NSString *productName = [userInfo objectForKey:API_PRODUCT_NAME_KEY]?:@"";
    NSString *productDescription = [userInfo objectForKey:API_PRODUCT_DESCRIPTION_KEY]?:@"";
    NSInteger departmentID = [[userInfo objectForKey:API_DEPARTMENT_ID_KEY]integerValue]?:0;
    NSInteger minimumOrder = [[userInfo objectForKey:API_PRODUCT_MINIMUM_ORDER_KEY]integerValue]?:1;
    NSInteger productPriceCurrencyID = [[userInfo objectForKey:API_PRODUCT_PRICE_CURRENCY_ID_KEY]integerValue]?:1;
    NSInteger productPrice = [[userInfo objectForKey:API_PRODUCT_PRICE_KEY]integerValue]?:0;
    NSInteger productWeightUnitID = [[userInfo objectForKey:API_PRODUCT_WEIGHT_UNIT_KEY]integerValue]?:1;
    NSInteger productWeight = [[userInfo objectForKey:API_PRODUCT_WEIGHT_KEY]integerValue]?:0;
    NSString *productImage = [userInfo objectForKey:API_PRODUCT_IMAGE_TOUPLOAD_KEY]?:@"";
    NSString *photoDefault = [userInfo objectForKey:API_PRODUCT_IMAGE_DEFAULT_KEY]?:@"";
    NSInteger productInsurance = [[userInfo objectForKey:API_PRODUCT_MUST_INSURANCE_KEY] integerValue];
    NSInteger moveToWarehouse = [[userInfo objectForKey:API_PRODUCT_MOVETO_WAREHOUSE_KEY]integerValue]?:PRODUCT_MOVETO_WAREHOUSE_ID;
    
    NSInteger etalaseUserInfoID = [[userInfo objectForKey:API_PRODUCT_ETALASE_ID_KEY]integerValue];
    BOOL isNewEtalase = (etalaseUserInfoID==DATA_ADD_NEW_ETALASE_ID);
    NSString *etalaseID = isNewEtalase?API_ADD_PRODUCT_NEW_ETALASE_TAG:[NSString stringWithFormat:@"%zd",etalaseUserInfoID];
    
    NSString *etalaseName = [userInfo objectForKey:API_PRODUCT_ETALASE_NAME_KEY]?:@"";
    NSInteger productConditionID = [[userInfo objectForKey: API_PRODUCT_CONDITION_KEY] integerValue]?:1;
    NSArray *wholesaleList = [userInfo objectForKey:DATA_WHOLESALE_LIST_KEY]?:@[];
    
    NSNumber *productID = [userInfo objectForKey:API_PRODUCT_ID_KEY];
    BOOL isReturnableProduct = [[userInfo objectForKey:API_PRODUCT_IS_RETURNABLE_KEY]integerValue];
    
    NSInteger userID = [[_auth objectForKey:kTKPD_USERIDKEY]integerValue];
    
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterShortStyle];
    //NSString *uniqueID = [NSString stringWithFormat:@"%zd2365364365645644564564",userID];
    NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *uniqueID = [NSString stringWithFormat:@"%zd%@%@",userID,udid,dateString];
    
    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
    NSInteger duplicate = (type == TYPE_ADD_EDIT_PRODUCT_COPY)?1:0;
    
    [_dataInput setObject:uniqueID forKey:API_UNIQUE_ID_KEY];
    
    NSDictionary* paramDictionary = @{kTKPDDETAIL_APIACTIONKEY:action?:@"",
                                      API_PRODUCT_ID_KEY: productID?:@(0),
                                      API_SERVER_ID_KEY : @(serverID)?:@(0),
                                      API_PRODUCT_NAME_KEY: productName?:@"",
                                      API_PRODUCT_PRICE_KEY: @(productPrice)?:@(0),
                                      API_PRODUCT_PRICE_CURRENCY_ID_KEY: @(productPriceCurrencyID)?:@(0),
                                      API_PRODUCT_WEIGHT_KEY: @(productWeight)?:@(0),
                                      API_PRODUCT_WEIGHT_UNIT_KEY: @(productWeightUnitID)?:@(0),
                                      API_PRODUCT_DEPARTMENT_ID_KEY: @(departmentID)?:@(0),
                                      API_PRODUCT_MINIMUM_ORDER_KEY : @(minimumOrder)?:@(0),
                                      API_PRODUCT_DESCRIPTION_KEY : productDescription?:@"",
                                      API_PRODUCT_MUST_INSURANCE_KEY : @(productInsurance)?:@(0),
                                      API_PRODUCT_MOVETO_WAREHOUSE_KEY : @(moveToWarehouse)?:@(0),
                                      API_PRODUCT_ETALASE_ID_KEY : etalaseID?:@(0),
                                      API_PRODUCT_ETALASE_NAME_KEY : etalaseName?:@"",
                                      API_PRODUCT_CONDITION_KEY : @(productConditionID)?:@(0),
                                      API_PRODUCT_IMAGE_TOUPLOAD_KEY : productImage?:@(0),
                                      API_PRODUCT_IMAGE_DEFAULT_KEY: photoDefault?:@"",
                                      API_PRODUCT_IS_RETURNABLE_KEY : @(isReturnableProduct)?:@(0),
                                      API_PRODUCT_IS_CHANGE_WHOLESALE_KEY:@(1),
                                      API_UNIQUE_ID_KEY:uniqueID,
                                      API_IS_DUPLICATE_KEY : @(duplicate)
                                      };
    NSMutableDictionary *param = [NSMutableDictionary new];
    [param addEntriesFromDictionary:paramDictionary];
    
    for (NSDictionary *wholesale in wholesaleList) {
        [param addEntriesFromDictionary:wholesale];
    }
    NSString *productImageDesc = [userInfo objectForKey:API_PRODUCT_IMAGE_DESCRIPTION_KEY]?:@"";
    [param setObject:productImageDesc forKey:API_PRODUCT_IMAGE_DESCRIPTION_KEY];
    
    _requestCount ++;
    
    _saveBarButtonItem.enabled = NO;
    _requestActionAddProductValidation = [_objectManagerActionAddProductValidation appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAILACTIONPRODUCT_APIPATH parameters:[param encrypt]];
    
    [_requestActionAddProductValidation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionAddProductValidation:mappingResult
                                         withOperation:operation];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionAddProductValidation:error];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestActionAddProductValidation];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeOutActionAddProductValidation:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionAddProductValidation:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    AddProductValidation *setting = stat;
    BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionAddProductValidation:object];
    }
}

-(void)requestFailureActionAddProductValidation:(id)object
{
    [self requestProcessActionAddProductValidation:object];
}

-(void)requestProcessActionAddProductValidation:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            AddProductValidation *setting = stat;
            BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if (![setting.result.post_key isEqualToString:@"1"])
                {
                    [_dataInput setObject:setting.result.post_key?:@"" forKey:API_POSTKEY_KEY];
                    [self configureRestkitActionAddProductPicture];
                    [self requestActionAddProductPicture:_dataInput];
                }
                else
                {
                    NSArray *array = setting.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
            }
        }
        else{
            [self cancelActionAddProductValidation];
            NSError *error = object;
            if (!([error code] == NSURLErrorCancelled)){
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeOutActionAddProductValidation:(NSTimer *)timer
{
    [self cancelActionAddProductValidation];
}


#pragma mark -Request Action Add Product Picture
-(void)cancelActionAddProductPicture
{
    [_requestActionAddProductPicture cancel];
    _requestActionAddProductPicture = nil;
    [_objectManagerActionAddProductPicture.operationQueue cancelAllOperations];
    _objectManagerActionAddProductPicture = nil;
}

-(void)configureRestkitActionAddProductPicture
{
    _objectManagerActionAddProductPicture = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[AddProductPicture class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[AddProductPictureResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{API_FILE_UPLOADED_KEY:API_FILE_UPLOADED_KEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAILACTIONPRODUCT_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerActionAddProductPicture addResponseDescriptor:responseDescriptor];
    
}

/**
 # add product new langkah ke-2
 # sub add_product_picture example URL
 # www.tkpdevel-pg.ekarisky/ws/action/product.pl?action=add_product_picture&
 # product_photo=&
 # product_photo_desc=&
 # product_photo_default=&
 # duplicate=&
 # user_id=&
 # token=&
 # server_id=&
 # web_service=
 **/
-(void)requestActionAddProductPicture:(id)object
{
    if (_requestActionAddProductPicture.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userInfo = (NSDictionary*)object;
    
    
    //TODO:: catalogid,duplicate,token,webservice
    NSString *action = ACTION_ADD_PRODUCT_PICTURE;
    NSString *productPhoto = [userInfo objectForKey:API_PRODUCT_IMAGE_TOUPLOAD_KEY]?:@"";
    NSString *productPhotoDesc = [userInfo objectForKey:API_PRODUCT_IMAGE_DESCRIPTION_KEY]?:@"";
    NSString *photoDefault = [userInfo objectForKey:API_PRODUCT_IMAGE_DEFAULT_KEY]?:@"";
    NSInteger userID = [[_auth objectForKey:kTKPD_USERIDKEY]integerValue];
    NSInteger serverID = [[userInfo objectForKey:API_SERVER_ID_KEY] integerValue]?:0;

    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
    NSInteger duplicate = (type == TYPE_ADD_EDIT_PRODUCT_COPY)?1:0;
    
    NSDictionary* paramDictionary = @{kTKPDDETAIL_APIACTIONKEY:action?:@"",
                                      API_SERVER_ID_KEY : @(serverID)?:@(0),
                                      API_PRODUCT_IMAGE_TOUPLOAD_KEY : productPhoto?:@(0),
                                      API_PRODUCT_IMAGE_DESCRIPTION_KEY: productPhotoDesc,
                                      API_PRODUCT_IMAGE_DEFAULT_KEY: photoDefault?:@"",
                                      kTKPD_USERIDKEY : @(userID),
                                      API_IS_DUPLICATE_KEY :@(duplicate)
                                      };
    NSMutableDictionary *param = [NSMutableDictionary new];
    [param addEntriesFromDictionary:paramDictionary];
    
    _requestCount ++;
    
    _requestActionAddProductPicture = [_objectManagerActionAddProductPicture appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAILACTIONPRODUCT_APIPATH parameters:[param encrypt]];
    
    [_requestActionAddProductPicture setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionAddProductPicture:mappingResult withOperation:operation];
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionAddProductPicture:error];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestActionAddProductPicture];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeOutActionAddProductPicture:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionAddProductPicture:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    AddProductPicture *setting = stat;
    BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionAddProductPicture:object];
    }
}

-(void)requestFailureActionAddProductPicture:(id)object
{
    [self requestProcessActionAddProductPicture:object];
}

-(void)requestProcessActionAddProductPicture:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            AddProductPicture *setting = stat;
            BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(setting.message_error)
                {
                    NSArray *array = setting.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                //TODO:: add else after web service done
                //else
                //{
                    [_dataInput setObject:setting.result.file_uploaded forKey:API_FILE_UPLOADED_KEY];
                    [self configureRestkitActionAddProductSubmit];
                    [self requestActionAddProductSubmit:_dataInput];
                //}
            }
        }
        else{
            [self cancelActionAddProductPicture];
            NSError *error = object;
            if (!([error code] == NSURLErrorCancelled)){
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeOutActionAddProductPicture:(NSTimer *)timer
{
    [self cancelActionAddProductPicture];
}

#pragma mark -Request Add Product Submit

-(void)cancelActionAddProductSubmit
{
    [_requestActionAddProductSubmit cancel];
    _requestActionAddProductSubmit = nil;
    [_objectManagerActionAddProductSubmit.operationQueue cancelAllOperations];
    _objectManagerActionAddProductSubmit = nil;
}

-(void)configureRestkitActionAddProductSubmit
{
    _objectManagerActionAddProductSubmit = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[AddProductSubmit class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[AddProductSubmitResult class]];

    [resultMapping addAttributeMappingsFromDictionary:@{kTKPD_APIISSUCCESSKEY:kTKPD_APIISSUCCESSKEY,
                                                        API_PRODUCT_ID_KEY:API_PRODUCT_ID_KEY,
                                                        API_PRODUCT_PRIMARY_PHOTO_KEY:API_PRODUCT_PRIMARY_PHOTO_KEY,
                                                        API_PRODUCT_DESC_KEY:API_PRODUCT_DESC_KEY,
                                                        API_PRODUCT_ETALASE_KEY:API_PRODUCT_ETALASE_KEY,
                                                        API_PRODUCT_DESTINATION_KEY:API_PRODUCT_DESTINATION_KEY,
                                                        API_PRODUCT_URL_KEY:API_PRODUCT_URL_KEY,
                                                        API_PRODUCT_NAME_KEY:API_PRODUCT_NAME_KEY
                                                        }];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAILACTIONPRODUCT_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerActionAddProductSubmit addResponseDescriptor:responseDescriptor];
    
}
/**
 # add product new langkah ke-3
 # sub add_product_submit example URL
 # www.tkpdevel-pg.ekarisky/ws/action/product.pl?action=add_product_submit&
 # server_id=2&
 # product_name=Produk%20dari%20WS%20IOS&
 # product_description=Coba%20Tambah%20Produk%20dari%20WS%20IOS&
 # product_department_id=582&
 # product_catalog_id=5312&
 # product_min_order=1&
 # product_price_currency=1&
 # product_price=1000000&
 # product_weight_unit=1&
 # product_weight=1&
 # product_photo=& (delimiternya '~')
 # product_photo_desc=& (delimiternya '~')
 # product_photo_default=&
 # product_must_insurance=0&
 # product_upload_to=1&
 # product_etalase_id=1509&
 # product_etalase_name=sdfdsfds113&
 # product_condition=1&
 # product_returnable=1&
 # qty_min_1=&
 # qty_max_1=&
 # prd_prc_1=&
 # click_name=&
 # post_key=&
 # file_uploaded=
 */
-(void)requestActionAddProductSubmit:(id)object
{
    if (_requestActionAddProductSubmit.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userInfo = (NSDictionary*)object;
    
    //TODO:: catalogid
    NSString *action = ACTION_ADD_PRODUCT_SUBMIT;
    
    NSString *postKey = [userInfo objectForKey:API_POSTKEY_KEY];
    NSString *uploadedFile = [userInfo objectForKey:API_FILE_UPLOADED_KEY];
    
    NSInteger randomNumber = arc4random() % 16;
    NSString *uniqueID = [NSString stringWithFormat:@"%@%zd",[_dataInput objectForKey:API_UNIQUE_ID_KEY],randomNumber];
    
    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
    NSInteger duplicate = (type == TYPE_ADD_EDIT_PRODUCT_COPY)?1:0;
    
    NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY:action,
                            API_POSTKEY_KEY:postKey,
                            API_FILE_UPLOADED_KEY:uploadedFile,
                            API_UNIQUE_ID_KEY : uniqueID,
                            API_IS_DUPLICATE_KEY:@(duplicate)
                            };
    _requestCount ++;
    
    _requestActionAddProductSubmit = [_objectManagerActionAddProductSubmit appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAILACTIONPRODUCT_APIPATH parameters:[param encrypt]];
    
    [_requestActionAddProductSubmit setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionAddProductSubmit:mappingResult withOperation:operation];
        [timer invalidate];
        _saveBarButtonItem.enabled = YES;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFailureActionAddProductSubmit:error];
        [timer invalidate];
        _saveBarButtonItem.enabled = YES;
    }];
    
    [_operationQueue addOperation:_requestActionAddProductSubmit];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeOutActionAddProductSubmit:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionAddProductSubmit:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    AddProductSubmit *setting = stat;
    BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionAddProductSubmit:object];
    }
}

-(void)requestFailureActionAddProductSubmit:(id)object
{
    [self requestProcessActionAddProductSubmit:object];
}

-(void)requestProcessActionAddProductSubmit:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            AddProductSubmit *setting = stat;
            BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(setting.message_error)
                {
                    NSArray *array = setting.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                if (setting.result.is_success == 1 || setting.result.product_id!=0) {
                    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
                    NSString *defaultSuccessMessage = (type == TYPE_ADD_EDIT_PRODUCT_ADD)?SUCCESSMESSAGE_ADD_PRODUCT:SUCCESSMESSAGE_EDIT_PRODUCT;SUCCESSMESSAGE_ADD_PRODUCT;
                    NSArray *array = setting.message_status?:[[NSArray alloc] initWithObjects:defaultSuccessMessage, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
                    
                    NSInteger indexPopViewController = self.navigationController.viewControllers.count-3;
                    UIViewController *popViewController = self.navigationController.viewControllers [indexPopViewController];
                    [self.navigationController popToViewController:popViewController animated:NO];
                    [[NSNotificationCenter defaultCenter] postNotificationName:ADD_PRODUCT_POST_NOTIFICATION_NAME object:nil userInfo:nil];
                }
            }
        }
        else{
            [self cancelActionAddProductSubmit];
            NSError *error = object;
            if (!([error code] == NSURLErrorCancelled)){
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeOutActionAddProductSubmit:(NSTimer *)timer
{
    [self cancelActionAddProductSubmit];
}

#pragma mark -Request Edit Product

-(void)cancelActionEditProduct
{
    [_requestActionEditProduct cancel];
    _requestActionEditProduct = nil;
    [_objectManagerActionEditProduct.operationQueue cancelAllOperations];
    _objectManagerActionEditProduct = nil;
}

-(void)configureRestkitActionEditProduct
{
    _objectManagerActionEditProduct = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ShopSettings class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ShopSettingsResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPD_APIISSUCCESSKEY:kTKPD_APIISSUCCESSKEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAILACTIONPRODUCT_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerActionEditProduct addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionEditProduct:(id)object
{
    if (_requestActionEditProduct.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userInfo = (NSDictionary*)object;
#define PRODUCT_MOVETO_WAREHOUSE_ID 2
    
    NSString *action = ACTION_EDIT_PRODUCT_KEY;
    
    NSInteger serverID = [[userInfo objectForKey:API_SERVER_ID_KEY] integerValue]?:0;
    NSString *productName = [userInfo objectForKey:API_PRODUCT_NAME_KEY]?:@"";
    NSString *productDescription = [userInfo objectForKey:API_PRODUCT_DESCRIPTION_KEY]?:@"";
    NSInteger productPrice = [[userInfo objectForKey:API_PRODUCT_PRICE_KEY]integerValue]?:0;
    NSInteger productPriceCurrencyID = [[userInfo objectForKey:API_PRODUCT_PRICE_CURRENCY_ID_KEY]integerValue]?:1;
    NSInteger productWeight = [[userInfo objectForKey:API_PRODUCT_WEIGHT_KEY]integerValue]?:0;
    NSInteger productWeightUnitID = [[userInfo objectForKey:API_PRODUCT_WEIGHT_UNIT_KEY]integerValue]?:1;
    NSInteger departmentID = [[userInfo objectForKey:API_DEPARTMENT_ID_KEY]integerValue]?:0;
    NSInteger minimumOrder = [[userInfo objectForKey:API_PRODUCT_MINIMUM_ORDER_KEY]integerValue]?:1;
    NSInteger productInsurance = [[userInfo objectForKey:API_PRODUCT_MUST_INSURANCE_KEY] integerValue];
    
    NSInteger moveToWarehouse = [[userInfo objectForKey:API_PRODUCT_MOVETO_WAREHOUSE_KEY]integerValue]?:PRODUCT_MOVETO_WAREHOUSE_ID;
    
    NSInteger etalaseUserInfoID = [[userInfo objectForKey:API_PRODUCT_ETALASE_ID_KEY]integerValue];
    BOOL isNewEtalase = (etalaseUserInfoID==DATA_ADD_NEW_ETALASE_ID);
    NSString *etalaseID = isNewEtalase?API_ADD_PRODUCT_NEW_ETALASE_TAG:[NSString stringWithFormat:@"%zd",etalaseUserInfoID];
    
    NSString *etalaseName = [userInfo objectForKey:API_PRODUCT_ETALASE_NAME_KEY]?:@"";
    NSInteger productConditionID = [[userInfo objectForKey: API_PRODUCT_CONDITION_KEY] integerValue]?:1;
    NSString *productImage = [userInfo objectForKey:API_PRODUCT_IMAGE_TOUPLOAD_KEY]?:@"";
    NSArray *wholesaleList = [userInfo objectForKey:DATA_WHOLESALE_LIST_KEY]?:@[];
    NSString *photoDefault = [userInfo objectForKey:API_PRODUCT_IMAGE_DEFAULT_KEY]?:@"";
    
    NSNumber *productID = [userInfo objectForKey:API_PRODUCT_ID_KEY];
    BOOL isReturnableProduct = [[userInfo objectForKey:API_PRODUCT_IS_RETURNABLE_KEY]integerValue];
    
    
    
    NSDictionary* paramDictionary = @{kTKPDDETAIL_APIACTIONKEY:action?:@"",
                                      API_PRODUCT_ID_KEY: productID?:@(0),
                                      API_SERVER_ID_KEY : @(serverID)?:@(0),
                                      API_PRODUCT_NAME_KEY: productName?:@"",
                                      API_PRODUCT_PRICE_KEY: @(productPrice)?:@(0),
                                      API_PRODUCT_PRICE_CURRENCY_ID_KEY: @(productPriceCurrencyID)?:@(0),
                                      API_PRODUCT_WEIGHT_KEY: @(productWeight)?:@(0),
                                      API_PRODUCT_WEIGHT_UNIT_KEY: @(productWeightUnitID)?:@(0),
                                      API_PRODUCT_DEPARTMENT_ID_KEY: @(departmentID)?:@(0),
                                      API_PRODUCT_MINIMUM_ORDER_KEY : @(minimumOrder)?:@(0),
                                      API_PRODUCT_DESCRIPTION_KEY : productDescription?:@"",
                                      API_PRODUCT_MUST_INSURANCE_KEY : @(productInsurance)?:@(0),
                                      API_PRODUCT_MOVETO_WAREHOUSE_KEY : @(moveToWarehouse)?:@(0),
                                      API_PRODUCT_ETALASE_ID_KEY : etalaseID?:@(0),
                                      API_PRODUCT_ETALASE_NAME_KEY : etalaseName?:@"",
                                      API_PRODUCT_CONDITION_KEY : @(productConditionID)?:@(0),
                                      API_PRODUCT_IMAGE_TOUPLOAD_KEY : productImage?:@(0),
                                      API_PRODUCT_IMAGE_DEFAULT_KEY: photoDefault?:@"",
                                      API_PRODUCT_IS_RETURNABLE_KEY : @(isReturnableProduct)?:@(0),
                                      API_PRODUCT_IS_CHANGE_WHOLESALE_KEY:@(1)
                                      };
    NSMutableDictionary *param = [NSMutableDictionary new];
    [param addEntriesFromDictionary:paramDictionary];
    
    for (NSDictionary *wholesale in wholesaleList) {
        [param addEntriesFromDictionary:wholesale];
    }

    NSDictionary *imageDescriptions = [userInfo objectForKey:API_PRODUCT_IMAGE_DESCRIPTION_KEY];
    [param addEntriesFromDictionary:imageDescriptions];
    
    _requestCount ++;
    
    _saveBarButtonItem.enabled = NO;
    _requestActionEditProduct = [_objectManagerActionEditProduct appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAILACTIONPRODUCT_APIPATH parameters:[param encrypt]];
    
    [_requestActionEditProduct setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionEditProduct:mappingResult withOperation:operation];
        [timer invalidate];
        _saveBarButtonItem.enabled = YES;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFailureActionEditProduct:error];
        [timer invalidate];
        _saveBarButtonItem.enabled = YES;
    }];
    
    [_operationQueue addOperation:_requestActionEditProduct];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeOutActionEditProduct:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionEditProduct:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    ShopSettings *setting = stat;
    BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionEditProduct:object];
    }
}

-(void)requestFailureActionEditProduct:(id)object
{
    [self requestProcessActionEditProduct:object];
}

-(void)requestProcessActionEditProduct:(id)object
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
                    NSArray *array = setting.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                if (setting.result.is_success == 1) {
                    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
                    NSString *defaultSuccessMessage;
                    if (type == TYPE_ADD_EDIT_PRODUCT_ADD)defaultSuccessMessage=SUCCESSMESSAGE_ADD_PRODUCT;
                    if (type == TYPE_ADD_EDIT_PRODUCT_EDIT)defaultSuccessMessage=SUCCESSMESSAGE_EDIT_PRODUCT;
                    if (type == TYPE_ADD_EDIT_PRODUCT_COPY)defaultSuccessMessage=SUCCESSMESSAGE_COPY_PRODUCT;
                    NSArray *array = setting.message_status?:[[NSArray alloc] initWithObjects:defaultSuccessMessage, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
                    
                    NSInteger indexPopViewController = self.navigationController.viewControllers.count-3;
                    UIViewController *popViewController = self.navigationController.viewControllers [indexPopViewController];
                    [self.navigationController popToViewController:popViewController animated:NO];
                    [[NSNotificationCenter defaultCenter] postNotificationName:ADD_PRODUCT_POST_NOTIFICATION_NAME object:nil userInfo:nil];
                }
            }
        }
        else{
            [self cancelActionEditProduct];
            NSError *error = object;
            if (!([error code] == NSURLErrorCancelled)){
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeOutActionEditProduct:(NSTimer *)timer
{
    [self cancelActionEditProduct];
}

#pragma mark - TextView Delegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    _activeTextView = textView;
    
    _productDescriptionLabel.hidden = YES;
    
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    if (textView == _productDescriptionTextView) {
        if(_productDescriptionTextView.text.length == 0){
            _productDescriptionLabel.hidden = YES;
        }
    }
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView == _productDescriptionTextView) {
        if(textView.text.length != 0 && ![textView.text isEqualToString:@""]){
            [_dataInput setObject:textView.text forKey:API_PRODUCT_DESCRIPTION_KEY];
        }
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
#define PRODUCT_DESCRIPTION_CHARACTER_LIMIT 200
    return textView.text.length + (text.length - range.length) <= PRODUCT_DESCRIPTION_CHARACTER_LIMIT;
}



#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification *)info {
    if(_keyboardSize.height < 0){
        _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
        _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;

        _scrollviewContentSize = [_containerScrollView contentSize];
        _scrollviewContentSize.height += _keyboardSize.height;
        [_containerScrollView setContentSize:_scrollviewContentSize];
    }else{
        [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                              delay:0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _scrollviewContentSize = [_containerScrollView contentSize];
                             _scrollviewContentSize.height -= _keyboardSize.height;

                             _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
                             _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
                             _scrollviewContentSize.height += _keyboardSize.height;
                             if ((self.view.frame.origin.y + _activeTextView.frame.origin.y+_activeTextView.frame.size.height)> _keyboardPosition.y) {
                                 UIEdgeInsets inset = _containerScrollView.contentInset;
                                 inset.top = (_keyboardPosition.y-(self.view.frame.origin.y + _activeTextView.frame.origin.y+_activeTextView.frame.size.height + 10));
                                 [_containerScrollView setContentInset:inset];
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
                         _containerScrollView.contentInset = contentInsets;
                         _containerScrollView.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished){
                     }];
}

#pragma mark - Alertview Delegate
-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
#define DEFAULT_ETALASE_DETAIL_TITLE_BUTTON @"Pilih Etalase"
    switch (alertView.tag) {
        case BUTTON_PRODUCT_INSURANCE:
        {
            NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];
            NSInteger value = [[ARRAY_PRODUCT_INSURACE[index] objectForKey:DATA_VALUE_KEY] integerValue];
            NSString *name = [ARRAY_PRODUCT_INSURACE[index] objectForKey:DATA_NAME_KEY];
            [_dataInput setObject:@(value) forKey:API_PRODUCT_MUST_INSURANCE_KEY];
            [_insuranceButton setTitle:name forState:UIControlStateNormal];
            break;
        }
        case BUTTON_PRODUCT_CONDITION:
        {
            NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];
            NSInteger value = [[ARRAY_PRODUCT_CONDITION[index] objectForKey:DATA_VALUE_KEY] integerValue];
            NSString *name = [ARRAY_PRODUCT_CONDITION[index] objectForKey:DATA_NAME_KEY];
            [_dataInput setObject:@(value) forKey:API_PRODUCT_CONDITION_KEY];
            [_productConditionButton setTitle:name forState:UIControlStateNormal];
            break;
        }
        case BUTTON_PRODUCT_ETALASE:
        {
            NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];
            NSInteger value = [[ARRAY_PRODUCT_MOVETO_ETALASE[index] objectForKey:DATA_VALUE_KEY] integerValue];
            NSString *name = [ARRAY_PRODUCT_MOVETO_ETALASE[index] objectForKey:DATA_NAME_KEY];
            [_dataInput setObject:@(value) forKey:API_PRODUCT_MOVETO_WAREHOUSE_KEY];
            [_etalaseButton setTitle:name forState:UIControlStateNormal];
            
            BOOL isWarehouse = (value == PRODUCT_WAREHOUSE_YES_ID);
            if (isWarehouse) {
                _etalaseDetailButton.enabled = NO;
                [_etalaseDetailButton setTitle:DEFAULT_ETALASE_DETAIL_TITLE_BUTTON forState:UIControlStateNormal];
                [_dataInput removeObjectForKey:API_PRODUCT_ETALASE_ID_KEY];
                [_dataInput removeObjectForKey:API_PRODUCT_ETALASE_NAME_KEY];
            }
            else{
                _etalaseDetailButton.enabled = YES;
            }
            break;
        }
        case BUTTON_PRODUCT_RETURNABLE_NOTE:
        {

            break;
        }
        default:
            break;
    }
}

#pragma mark - Product Etalase Delegate
-(void)MyShopEtalaseFilterViewController:(MyShopEtalaseFilterViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    EtalaseList *etalase = [userInfo objectForKey:DATA_ETALASE_KEY];

    [_dataInput setObject:@(etalase.etalase_id) forKey:API_PRODUCT_ETALASE_ID_KEY];
    [_dataInput setObject:etalase.etalase_name forKey:API_PRODUCT_ETALASE_NAME_KEY];
    [_etalaseDetailButton setTitle:etalase.etalase_name forState:UIControlStateNormal];
    
    NSIndexPath *indexpath = [userInfo objectForKey:kTKPDDETAILETALASE_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    [_dataInput setObject:indexpath forKey:kTKPDDETAILETALASE_DATAINDEXPATHKEY];
}

#pragma mark - Product Wholesale View Controller Delegate
-(void)ProductEditWholesaleViewController:(ProductEditWholesaleViewController *)viewController withWholesaleList:(NSArray *)list
{
    [_dataInput setObject:list forKey:DATA_WHOLESALE_LIST_KEY];
}

#pragma mark - Methods
-(void)setDefaultData:(NSDictionary*)data
{
    _data = data;
    if (data) {
                
        [_dataInput addEntriesFromDictionary:[_data objectForKey:DATA_INPUT_KEY]];
        
        NSInteger productReturnable = [[_dataInput objectForKey:API_PRODUCT_IS_RETURNABLE_KEY]integerValue];
        BOOL isProductReturnable = (productReturnable == RETURNABLE_YES_ID)?YES:NO;
        _returnableProductSwitch.on = isProductReturnable;
        
        NSInteger productInsurance = [[_dataInput objectForKey:API_PRODUCT_MUST_INSURANCE_KEY]integerValue];
        NSInteger indexInsurance = productInsurance?productInsurance-1:productInsurance;
        NSString *productInsuranceName = [ARRAY_PRODUCT_INSURACE[indexInsurance]objectForKey:DATA_NAME_KEY];
        [_insuranceButton setTitle:productInsuranceName forState:UIControlStateNormal];
        
        NSInteger productWarehouse = [[_dataInput objectForKey:API_PRODUCT_MOVETO_WAREHOUSE_KEY]integerValue];
        BOOL isProductWarehouse = (productWarehouse == PRODUCT_WAREHOUSE_YES_ID || productWarehouse == PRODUCT_WAREHOUSE_NOTSET_ID)?YES:NO;
        NSString *etalaseName = [_dataInput objectForKey:API_PRODUCT_ETALASE_NAME_KEY];
        NSString *etalaseButtonTitle = isProductWarehouse?[ARRAY_PRODUCT_MOVETO_ETALASE[0]objectForKey:DATA_NAME_KEY]:[ARRAY_PRODUCT_MOVETO_ETALASE[1]objectForKey:DATA_NAME_KEY];
        
        if (isProductWarehouse) {
            _etalaseDetailButton.enabled = NO;
            [_etalaseDetailButton setTitle:DEFAULT_ETALASE_DETAIL_TITLE_BUTTON forState:UIControlStateNormal];
            [_etalaseButton setTitle:etalaseButtonTitle forState:UIControlStateNormal];
            [_dataInput removeObjectForKey:API_PRODUCT_ETALASE_ID_KEY];
        }
        else{
            _etalaseDetailButton.enabled = YES;
            [_etalaseDetailButton setTitle:etalaseName forState:UIControlStateNormal];
            [_etalaseButton setTitle:etalaseButtonTitle forState:UIControlStateNormal];
        }
        
        NSInteger productCondition = [[_dataInput objectForKey:API_PRODUCT_CONDITION_KEY]integerValue];
        BOOL isNewProduct = (productCondition == PRODUCT_CONDITION_NEW_ID || productCondition == PRODUCT_CONDITION_NOTSET_ID)?YES:NO;
        NSString *productConditionButtonTitle = isNewProduct?[ARRAY_PRODUCT_CONDITION[0] objectForKey:DATA_NAME_KEY]:[ARRAY_PRODUCT_CONDITION[1] objectForKey:DATA_NAME_KEY];
        
        [_productConditionButton setTitle:productConditionButtonTitle forState:UIControlStateNormal];
        
        NSString *productDescription = [_dataInput objectForKey:API_PRODUCT_DESCRIPTION_KEY];
        _productDescriptionTextView.text = productDescription;
        _productDescriptionLabel.hidden = YES;
        
        NSArray *wholesaleList = [_dataInput objectForKey:DATA_WHOLESALE_LIST_KEY]?:@[];
        
        NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
        if ((type == TYPE_ADD_EDIT_PRODUCT_EDIT || type == TYPE_ADD_EDIT_PRODUCT_COPY) && [[wholesaleList firstObject] isKindOfClass:[WholesalePrice class]]) {
            for (WholesalePrice *wholesale in wholesaleList) {
                NSInteger price = [wholesale.wholesale_price integerValue];
                NSInteger minimumQuantity = [wholesale.wholesale_min integerValue];
                NSInteger maximumQuantity = [wholesale.wholesale_max integerValue];
                [self addWholesaleListPrice:price withQuantityMinimum:minimumQuantity andQuantityMaximum:maximumQuantity];
            }
            [_dataInput setObject:_wholesaleList forKey:DATA_WHOLESALE_LIST_KEY];
        }
    }
}

-(void)addWholesaleListPrice:(NSInteger)price withQuantityMinimum:(NSInteger)minimum andQuantityMaximum:(NSInteger)maximum
{
    NSInteger wholesaleListIndex = _wholesaleList.count+1;
    NSString *wholesalePriceKey = [NSString stringWithFormat:@"%@%zd",API_WHOLESALE_PRICE,wholesaleListIndex];
    NSString *wholesaleQuantityMaximum = [NSString stringWithFormat:@"%@%zd",API_WHOLESALE_QUANTITY_MAXIMUM_KEY,wholesaleListIndex];
    NSString *wholesaleQuantityMinimum = [NSString stringWithFormat:@"%@%zd",API_WHOLESALE_QUANTITY_MINIMUM_KEY,wholesaleListIndex];
    
    
    NSDictionary *wholesale = @{wholesalePriceKey:@(price),
                                wholesaleQuantityMaximum:@(maximum),
                                wholesaleQuantityMinimum:@(minimum)
                                };
    [_wholesaleList addObject:wholesale];
}

@end
