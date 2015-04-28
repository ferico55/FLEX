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
#import "Breadcrumb.h"
#import "ProductDetail.h"
#import "MyShopNoteDetailViewController.h"

@interface ProductAddEditDetailViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UITextViewDelegate,
    TKPDAlertViewDelegate,
    MyShopEtalaseFilterViewControllerDelegate,
    ProductEditWholesaleViewControllerDelegate
>
{
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;
    
    NSDictionary *_auth;
    NSMutableDictionary *_dataInput;
    NSMutableArray *_wholesaleList;
    
    UITextView *_activeTextView;
    
    NSInteger _requestCount;
    NSOperationQueue *_operationQueue;
    
    
    __weak RKObjectManager *_objectManagerActionAddProductValidation;
    __weak RKManagedObjectRequestOperation *_requestActionAddProductValidation;
    
    RKObjectManager *_objectManagerActionAddProductPicture;
    __weak RKManagedObjectRequestOperation *_requestActionAddProductPicture;
    
    __weak RKObjectManager *_objectManagerActionAddProductSubmit;
    __weak RKManagedObjectRequestOperation *_requestActionAddProductSubmit;
    
    __weak RKObjectManager *_objectManagerActionEditProduct;
    __weak RKManagedObjectRequestOperation *_requestActionEditProduct;
    
    __weak RKObjectManager *_objectmanagerActionMoveToWarehouse;
    __weak RKManagedObjectRequestOperation *_requestActionMoveToWarehouse;
    
    UIBarButtonItem *_saveBarButtonItem;
    
    BOOL _isNodata;
    BOOL _isBeingPresented;
    EtalaseList *_selectedEtalase;
}
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section0TableViewCell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section1TableViewCell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section2TableViewCell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section3TableViewCell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section4TableViewCell;
@property (strong, nonatomic) IBOutlet UIView *section0FooterView;
@property (strong, nonatomic) IBOutlet UIView *section3FooterView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UISwitch *returnableProductSwitch;
@property (weak, nonatomic) IBOutlet UITextView *productDescriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *pengembalianProductLabel;

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
        _wholesaleList = [NSMutableArray new];
        _dataInput = [NSMutableDictionary new];
        _operationQueue = [NSOperationQueue new];
    }
    return self;
}

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self adjustBarButton];
    [self setDefaultData:_data];
    [self adjustReturnableNotesLabel];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
    
    _isBeingPresented = self.navigationController.isBeingPresented;

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(didEditNote:)
                               name:kTKPD_ADDNOTEPOSTNOTIFICATIONNAMEKEY
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(didUpdateShopHasTerms:)
                               name:DID_UPDATE_SHOP_HAS_TERM_NOTIFICATION_NAME
                             object:nil];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSDictionary *userInfo = @{DATA_INPUT_KEY:_dataInput};
    [_delegate ProductEditDetailViewController:self withUserInfo:userInfo];
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
                } else {
                    [self configureRestkitActionEditProduct];
                    [self requestActionEditProduct:_dataInput];
                }
                break;
            }
            default:
                break;
        }
    }
    if ([sender isKindOfClass:[UIButton class]]) {
        MyShopNoteDetailViewController *vc = [MyShopNoteDetailViewController new];
        vc.data = @{kTKPDDETAIL_DATATYPEKEY : @(NOTES_RETURNABLE_PRODUCT)
                    };

        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        nav.navigationBar.translucent = NO;
        
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
}

- (IBAction)gesture:(id)sender {
    [_activeTextView resignFirstResponder];
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *gesture = (UITapGestureRecognizer*)sender;
        if (gesture.view.tag == GESTURE_PRODUCT_EDIT_WHOLESALE) {
            ProductEditWholesaleViewController *editWholesaleVC = [ProductEditWholesaleViewController new];
            editWholesaleVC.data = @{kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY],
                                     DATA_INPUT_KEY : _dataInput
                                     };
            editWholesaleVC.delegate = self;
            [self.navigationController pushViewController:editWholesaleVC animated:YES];
        }
    }
}

#pragma mark - Table View Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rowCount = 0;
    switch (section) {
        case 0:
            rowCount = _section0TableViewCell.count;
            break;
        case 1:
            rowCount = _section1TableViewCell.count;
            break;
        case 2:
            rowCount = _section2TableViewCell.count;
            break;
        case 3:
            rowCount = _section3TableViewCell.count;
            break;
        case 4:
            rowCount = _section4TableViewCell.count;
            break;
        default:
            break;
    }

    return rowCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];

    UITableViewCell *cell = nil;
    switch (indexPath.section) {
        case 0:
            cell = _section0TableViewCell[indexPath.row];
            if (indexPath.row == BUTTON_PRODUCT_INSURANCE) {
                NSString *productMustInsurance =[ARRAY_PRODUCT_INSURACE[([product.product_must_insurance integerValue]-1>0)?[product.product_must_insurance integerValue]-1:0]objectForKey:DATA_NAME_KEY];
                cell.detailTextLabel.text = productMustInsurance;
            }
            break;
        case 1:
            cell = _section1TableViewCell[indexPath.row];
            BOOL isProductWarehouse = ([product.product_move_to integerValue] == PRODUCT_WAREHOUSE_YES_ID);
            if (indexPath.row == BUTTON_PRODUCT_ETALASE) {
                NSString *moveTo = (isProductWarehouse)?[ARRAY_PRODUCT_MOVETO_ETALASE[0]objectForKey:DATA_NAME_KEY]:[ARRAY_PRODUCT_MOVETO_ETALASE[1]objectForKey:DATA_NAME_KEY];
                cell.detailTextLabel.text = moveTo;
            }
            else if (indexPath.row == BUTTON_PRODUCT_ETALASE_DETAIL)
            {
                cell.detailTextLabel.textColor = (isProductWarehouse)?[UIColor grayColor]:[UIColor colorWithRed:(0.f/255.f) green:122.f/255.f blue:255.f/255.f alpha:1];
                if (isProductWarehouse)
                    cell.detailTextLabel.text = @"-";
                else
                    cell.detailTextLabel.text = ([product.product_etalase isEqualToString:@"0"]||!product.product_etalase)?@"Pilih Etalase":product.product_etalase;
            }
            break;
        case 2:
            cell = _section2TableViewCell[indexPath.row];
            if (indexPath.row==BUTTON_PRODUCT_CONDITION) {
                NSInteger productCondition = [product.product_condition integerValue];
                BOOL isNewProduct = (productCondition == PRODUCT_CONDITION_NEW_ID || productCondition == PRODUCT_CONDITION_NOTSET_ID)?YES:NO;
                NSString *productConditionName = isNewProduct?[ARRAY_PRODUCT_CONDITION[0] objectForKey:DATA_NAME_KEY]:[ARRAY_PRODUCT_CONDITION[1] objectForKey:DATA_NAME_KEY];
                cell.detailTextLabel.text = productConditionName;
            }
            break;
        case 3:
            cell = _section3TableViewCell[indexPath.row];
            break;
        case 4:
            cell = _section4TableViewCell[indexPath.row];
            break;
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


#pragma mark - Table View Delegate
-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0)
        return _section0FooterView;
    else if (section == 3)
        return _section3FooterView;
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
        return _section0FooterView.frame.size.height;
    else if(section == 3)
        return _section3FooterView.frame.size.height;
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float cellHeight;
    switch (indexPath.section) {
        case 0:
            cellHeight = ((UITableViewCell*)_section0TableViewCell[indexPath.row]).frame.size.height;
            break;
        case 1:
            cellHeight = ((UITableViewCell*)_section1TableViewCell[indexPath.row]).frame.size.height;
            break;
        case 2:
            cellHeight = ((UITableViewCell*)_section2TableViewCell[indexPath.row]).frame.size.height;
            break;
        case 3:
            cellHeight = ((UITableViewCell*)_section3TableViewCell[indexPath.row]).frame.size.height;
            break;
        case 4:
            cellHeight = ((UITableViewCell*)_section4TableViewCell[indexPath.row]).frame.size.height;
            break;
        default:
            break;
    }
    return cellHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_productDescriptionTextView resignFirstResponder];
    [_dataInput setObject:_productDescriptionTextView.text?:@"" forKey:API_PRODUCT_DESCRIPTION_KEY];
    ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
    BOOL isProductWarehouse = ([product.product_move_to integerValue] == PRODUCT_WAREHOUSE_YES_ID);
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case BUTTON_PRODUCT_INSURANCE:
                {
                    AlertPickerView *alertView = [AlertPickerView newview];
                    alertView.tag = 10;
                    alertView.delegate = self;
                    alertView.pickerData = ARRAY_PRODUCT_INSURACE;
                    [alertView show];
                    break;
                }
            }
            break;
        case 1:
            switch (indexPath.row) {
                case BUTTON_PRODUCT_ETALASE:
                {
                    AlertPickerView *alertView = [AlertPickerView newview];
                    alertView.tag = 11;
                    alertView.delegate = self;
                    alertView.pickerData = ARRAY_PRODUCT_MOVETO_ETALASE;
                    [alertView show];
                    break;
                }
                case BUTTON_PRODUCT_ETALASE_DETAIL:
                {
                    if (!isProductWarehouse) {
                        ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
                        EtalaseList *newEtalase = [EtalaseList new];
                        newEtalase.etalase_name = product.product_etalase;
                        newEtalase.etalase_id = [product.product_etalase_id stringValue];
                        NSIndexPath *indexpath = [_dataInput objectForKey:kTKPDDETAILETALASE_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                        MyShopEtalaseFilterViewController *etalaseViewController = [MyShopEtalaseFilterViewController new];
                        NSDictionary *auth = [_data objectForKey:kTKPD_AUTHKEY];
                        etalaseViewController.data = @{kTKPDDETAIL_APISHOPIDKEY:@([[auth objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue]?:0),
                                                       kTKPDFILTER_DATAINDEXPATHKEY: indexpath,
                                                       DATA_PRESENTED_ETALASE_TYPE_KEY : @(PRESENTED_ETALASE_ADD_PRODUCT),
                                                       ETALASE_OBJECT_SELECTED_KEY : newEtalase
                                                       };
                        etalaseViewController.delegate = self;
                        [self.navigationController pushViewController:etalaseViewController animated:YES];
                    }
                    break;
                }
            }
            break;
        case 2:
            switch (indexPath.row) {
                case BUTTON_PRODUCT_CONDITION:
                {
                    AlertPickerView *alertView = [AlertPickerView newview];
                    alertView.tag = 12;
                    alertView.delegate = self;
                    alertView.pickerData = ARRAY_PRODUCT_CONDITION;
                    [alertView show];
                    break;
                }
                default:
                    break;
            }
            break;
        case 4:
            switch (indexPath.row) {
                case BUTTON_PRODUCT_EDIT_WHOLESALE:
                {
                    ProductEditWholesaleViewController *editWholesaleVC = [ProductEditWholesaleViewController new];
                    editWholesaleVC.data = @{kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY],
                                             DATA_INPUT_KEY : _dataInput
                                             };
                    editWholesaleVC.delegate = self;
                    [self.navigationController pushViewController:editWholesaleVC animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [_productDescriptionTextView resignFirstResponder];
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
#define PRODUCT_MOVETO_WAREHOUSE_ID @"2"
    
    Breadcrumb *breadcrumb = [_dataInput objectForKey:DATA_CATEGORY_KEY];
    ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];

    NSString *action = ACTION_ADD_PRODUCT_VALIDATION;
    NSInteger serverID = [_generateHost.result.generated_host.server_id integerValue]?:0;
    NSString *productName = product.product_name?:@"";
    NSString *productDescription = product.product_description?:@"";
    NSString *departmentID = breadcrumb.department_id?:@"";
    NSString *minimumOrder = product.product_min_order?:@"1";
    NSString *productPriceCurrencyID = product.product_currency_id?:@"";
    NSString *productPrice = product.product_price?:@"";
    NSString *productWeightUnitID = product.product_weight_unit?:@"";
    NSString *productWeight = product.product_weight?:@"";
    NSString *productImage = [userInfo objectForKey:API_PRODUCT_IMAGE_TOUPLOAD_KEY]?:@"";
    NSString *photoDefault = [userInfo objectForKey:API_PRODUCT_IMAGE_DEFAULT_KEY]?:@"";
    NSString *productInsurance = product.product_must_insurance?:@"";
    NSString *moveToWarehouse = product.product_move_to?:@"";
    
    NSNumber *etalaseUserInfoID = product.product_etalase_id?:@(0);
    BOOL isNewEtalase = ([etalaseUserInfoID integerValue]==DATA_ADD_NEW_ETALASE_ID);
    NSString *etalaseID = isNewEtalase?API_ADD_PRODUCT_NEW_ETALASE_TAG:[etalaseUserInfoID stringValue];
    
    NSString *etalaseName = product.product_etalase?:@"";
    NSString *productConditionID = product.product_condition?:@"";
    NSArray *wholesaleList = [userInfo objectForKey:DATA_WHOLESALE_LIST_KEY]?:@[];
    
    NSString *productID = product.product_id?:@"";
    NSInteger returnableProduct = [[_dataInput objectForKey:API_PRODUCT_IS_RETURNABLE_KEY]integerValue];
    if (returnableProduct == -1) {
        returnableProduct = 0; // Not Set
    }
    else if(returnableProduct == 1)
    {
        returnableProduct = 1; //returnable
    }
    else
    {
        returnableProduct = 2; // not returnable
    }
    
    NSString *userID = [_auth objectForKey:kTKPD_USERIDKEY]?:@"";
    
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterShortStyle];
    //NSString *uniqueID = [NSString stringWithFormat:@"%zd2365364365645644564564",userID];
    NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *uniqueID = [NSString stringWithFormat:@"%zd%@%@",userID,udid,dateString];
    
    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
    NSInteger duplicate = (type == TYPE_ADD_EDIT_PRODUCT_COPY)?1:0;

    
    [_dataInput setObject:uniqueID forKey:API_UNIQUE_ID_KEY];
    
    NSDictionary* paramDictionary = @{kTKPDDETAIL_APIACTIONKEY:action,
                                      API_PRODUCT_ID_KEY: productID,
                                      API_SERVER_ID_KEY : @(serverID)?:@(0),
                                      API_PRODUCT_NAME_KEY: productName,
                                      API_PRODUCT_PRICE_KEY: productPrice,
                                      API_PRODUCT_PRICE_CURRENCY_ID_KEY: productPriceCurrencyID,
                                      API_PRODUCT_WEIGHT_KEY: productWeight,
                                      API_PRODUCT_WEIGHT_UNIT_KEY: productWeightUnitID,
                                      API_PRODUCT_DEPARTMENT_ID_KEY: departmentID,
                                      API_PRODUCT_MINIMUM_ORDER_KEY : minimumOrder,
                                      API_PRODUCT_DESCRIPTION_KEY : productDescription,
                                      API_PRODUCT_MUST_INSURANCE_KEY : productInsurance,
                                      API_PRODUCT_MOVETO_WAREHOUSE_KEY : moveToWarehouse,
                                      API_PRODUCT_ETALASE_ID_KEY : etalaseID,
                                      API_PRODUCT_ETALASE_NAME_KEY : etalaseName,
                                      API_PRODUCT_CONDITION_KEY : productConditionID,
                                      API_PRODUCT_IMAGE_TOUPLOAD_KEY : productImage?:@(0),
                                      API_PRODUCT_IMAGE_DEFAULT_KEY: photoDefault?:@"",
                                      API_PRODUCT_IS_RETURNABLE_KEY : @(returnableProduct),
                                      API_PRODUCT_IS_CHANGE_WHOLESALE_KEY:@(1),
                                      API_UNIQUE_ID_KEY:uniqueID,
                                      API_IS_DUPLICATE_KEY : @(duplicate),
                                      };
    NSMutableDictionary *paramMutableDict = [NSMutableDictionary new];
    [paramMutableDict addEntriesFromDictionary:paramDictionary];
    
    for (NSDictionary *wholesale in wholesaleList) {
        [paramMutableDict addEntriesFromDictionary:wholesale];
    }
    NSString *productImageDesc = [userInfo objectForKey:API_PRODUCT_IMAGE_DESCRIPTION_KEY]?:@"";
    [paramMutableDict setObject:productImageDesc forKey:API_PRODUCT_IMAGE_DESCRIPTION_KEY];
    
    NSDictionary *param = [paramMutableDict copy];
    
    
    _saveBarButtonItem.enabled = NO;
    _requestActionAddProductValidation = [_objectManagerActionAddProductValidation appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAILACTIONPRODUCT_APIPATH parameters:[param encrypt]];
    
    [_requestActionAddProductValidation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionAddProductValidation:mappingResult
                                         withOperation:operation];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionAddProductValidation:error];
        [timer invalidate];
        _saveBarButtonItem.enabled = YES;
    }];
    
    [_operationQueue addOperation:_requestActionAddProductValidation];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                            target:self
                                          selector:@selector(requestTimeOutActionAddProductValidation:)
                                          userInfo:nil
                                           repeats:NO];

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
                if ([setting.result.post_key isEqualToString:@"1"] || setting.result.post_key == nil) {
                    NSArray *array = setting.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                    _saveBarButtonItem.enabled = YES;
                } else {
                    [_dataInput setObject:setting.result.post_key?:@"" forKey:API_POSTKEY_KEY];
                    [self configureRestkitActionAddProductPicture];
                    [self requestActionAddProductPicture:_dataInput];
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
    //_objectManagerActionAddProductPicture = [RKObjectManager sharedClient];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/ws",_generateHost.result.generated_host.upload_host];
    _objectManagerActionAddProductPicture = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:urlString]];
    
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

-(void)requestActionAddProductPicture:(id)object
{
    if (_requestActionAddProductPicture.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userInfo = (NSDictionary*)object;
    
    NSString *action = ACTION_ADD_PRODUCT_PICTURE;
    NSString *productPhoto = [userInfo objectForKey:API_PRODUCT_IMAGE_TOUPLOAD_KEY]?:@"";
    NSString *productPhotoDesc = [userInfo objectForKey:API_PRODUCT_IMAGE_DESCRIPTION_KEY]?:@"";
    NSString *photoDefault = [userInfo objectForKey:API_PRODUCT_IMAGE_DEFAULT_KEY]?:@"";
    NSString *serverID = _generateHost.result.generated_host.server_id?:@"";

    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
    NSInteger duplicate = (type == TYPE_ADD_EDIT_PRODUCT_COPY)?1:0;
    
    NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY:action?:@"",
                            API_SERVER_ID_KEY : serverID,
                            API_PRODUCT_IMAGE_TOUPLOAD_KEY : productPhoto?:@(0),
                            API_PRODUCT_IMAGE_DESCRIPTION_KEY: productPhotoDesc,
                            API_PRODUCT_IMAGE_DEFAULT_KEY: photoDefault?:@"",
                            API_IS_DUPLICATE_KEY :@(duplicate),
                            };
    
    _requestActionAddProductPicture = [_objectManagerActionAddProductPicture appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAILACTIONPRODUCT_APIPATH parameters:[param encrypt]];
    
    [_requestActionAddProductPicture setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionAddProductPicture:mappingResult withOperation:operation];
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionAddProductPicture:error];
        [timer invalidate];
        _saveBarButtonItem.enabled = YES;
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
    else
    {
        _saveBarButtonItem.enabled = YES;
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
                if ([setting.result.file_uploaded isEqualToString:@"1"] || setting.result.file_uploaded == nil) {
                    NSArray *array = setting.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:array delegate:self];
                    [alert show];
                    
                    _saveBarButtonItem.enabled = YES;
                }
                else
                {
                    [_dataInput setObject:setting.result.file_uploaded?:@"" forKey:API_FILE_UPLOADED_KEY];
                    [self configureRestkitActionAddProductSubmit];
                    [self requestActionAddProductSubmit:_dataInput];
                }
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
                            API_IS_DUPLICATE_KEY:@(duplicate),
                            };
    _requestCount ++;
    
    _requestActionAddProductSubmit = [_objectManagerActionAddProductSubmit appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAILACTIONPRODUCT_APIPATH parameters:[param encrypt]];
    
    [_requestActionAddProductSubmit setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionAddProductSubmit:mappingResult withOperation:operation];
        [timer invalidate];
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
                    _saveBarButtonItem.enabled = YES;
                }
                if (setting.result.is_success == 1 || setting.result.product_id!=0) {
                    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
                    NSString *defaultSuccessMessage = (type == TYPE_ADD_EDIT_PRODUCT_ADD)?SUCCESSMESSAGE_ADD_PRODUCT:SUCCESSMESSAGE_EDIT_PRODUCT;SUCCESSMESSAGE_ADD_PRODUCT;
                    NSArray *array = setting.message_status?:[[NSArray alloc] initWithObjects:defaultSuccessMessage, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
    
    NSString *action = ACTION_EDIT_PRODUCT_KEY;
    ProductDetail *product = [userInfo objectForKey:DATA_PRODUCT_DETAIL_KEY];
    Breadcrumb *breadcrumb = [userInfo objectForKey:DATA_CATEGORY_KEY];
    
    NSInteger serverID = [_generateHost.result.generated_host.server_id integerValue]?:0;
    NSString *productName = product.product_name?:@"";
    NSString *productDescription = product.product_description?:@"";
    NSString *productPrice = product.product_price?:0;
    NSString *productPriceCurrencyID = product.product_currency_id?:@"";
    NSString *productWeight = product.product_weight?:@"";
    NSString *productWeightUnitID = product.product_weight_unit?:@"";
    NSString *departmentID = breadcrumb.department_id?:@"";
    NSString *minimumOrder = product.product_min_order?:@"";
    NSString *productInsurance = product.product_must_insurance?:@"";
    
    NSString *moveToWarehouse = [product.product_etalase_id isEqual:@(0)]?PRODUCT_MOVETO_WAREHOUSE_ID:@"1";
    
    NSNumber *etalaseUserInfoID = product.product_etalase_id;
    if ([etalaseUserInfoID isEqual:@(0)]) {
        
        [self configureRestKitActionMoveToWarehouse];
        [self requestActionMoveToWarehouse:_dataInput];
        return;
    }
    BOOL isNewEtalase = ([etalaseUserInfoID integerValue]==DATA_ADD_NEW_ETALASE_ID);
    NSString *etalaseID = isNewEtalase?API_ADD_PRODUCT_NEW_ETALASE_TAG:[etalaseUserInfoID stringValue];
    
    NSString *etalaseName = product.product_etalase;
    NSString *productConditionID = product.product_condition;
    NSString *productImage = [userInfo objectForKey:API_PRODUCT_IMAGE_TOUPLOAD_KEY]?:@"";
    NSArray *wholesaleList = [userInfo objectForKey:DATA_WHOLESALE_LIST_KEY]?:@[];
    NSString *photoDefault = [userInfo objectForKey:API_PRODUCT_IMAGE_DEFAULT_KEY]?:@"";
    
    NSString *productID = product.product_id?:@"";
    NSString *returnableProduct = [_dataInput objectForKey:API_PRODUCT_IS_RETURNABLE_KEY]?:product.product_returnable?:@"";
    if ([returnableProduct integerValue] == -1) {
        returnableProduct = @"0"; // Not Set
    }
    else if([returnableProduct integerValue] == 1)
    {
        returnableProduct = @"1"; //returnable
    }
    else
    {
        returnableProduct = @"2"; // not returnable
    }
    
    NSDictionary* paramDictionary = @{kTKPDDETAIL_APIACTIONKEY:action?:@"",
                                      API_PRODUCT_ID_KEY: productID,
                                      API_SERVER_ID_KEY : @(serverID)?:@(0),
                                      API_PRODUCT_NAME_KEY: productName,
                                      API_PRODUCT_PRICE_KEY: productPrice,
                                      API_PRODUCT_PRICE_CURRENCY_ID_KEY: productPriceCurrencyID,
                                      API_PRODUCT_WEIGHT_KEY: productWeight,
                                      API_PRODUCT_WEIGHT_UNIT_KEY: productWeightUnitID,
                                      API_PRODUCT_DEPARTMENT_ID_KEY: departmentID,
                                      API_PRODUCT_MINIMUM_ORDER_KEY : minimumOrder,
                                      API_PRODUCT_DESCRIPTION_KEY : productDescription,
                                      API_PRODUCT_MUST_INSURANCE_KEY : productInsurance,
                                      API_PRODUCT_MOVETO_WAREHOUSE_KEY : moveToWarehouse,
                                      API_PRODUCT_ETALASE_ID_KEY : etalaseID,
                                      API_PRODUCT_ETALASE_NAME_KEY : etalaseName,
                                      API_PRODUCT_CONDITION_KEY : productConditionID,
                                      API_PRODUCT_IMAGE_TOUPLOAD_KEY : productImage?:@(0),
                                      API_PRODUCT_IMAGE_DEFAULT_KEY: photoDefault?:@"",
                                      API_PRODUCT_IS_RETURNABLE_KEY : returnableProduct?:@"",
                                      API_PRODUCT_IS_CHANGE_WHOLESALE_KEY:@(1),
                                      };
    NSMutableDictionary *paramMutableDict = [NSMutableDictionary new];
    [paramMutableDict addEntriesFromDictionary:paramDictionary];
    
    for (NSDictionary *wholesale in wholesaleList) {
        [paramMutableDict addEntriesFromDictionary:wholesale];
    }

    NSDictionary *imageDescriptions = [userInfo objectForKey:API_PRODUCT_IMAGE_DESCRIPTION_KEY];
    [paramMutableDict addEntriesFromDictionary:imageDescriptions];
    
    NSDictionary *param = [paramMutableDict copy];
    
    _saveBarButtonItem.enabled = NO;
    _requestActionEditProduct = [_objectManagerActionEditProduct appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAILACTIONPRODUCT_APIPATH parameters:[param encrypt]];
    
    [_requestActionEditProduct setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionEditProduct:mappingResult withOperation:operation];
        [timer invalidate];
        _saveBarButtonItem.enabled = YES;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
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
                if(setting.message_error) {
                    NSArray *errorMessages = setting.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
                    [alert show];
                }
                if (setting.result.is_success == 1) {
                    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
                    NSString *defaultSuccessMessage;
                    if (type == TYPE_ADD_EDIT_PRODUCT_ADD)defaultSuccessMessage=SUCCESSMESSAGE_ADD_PRODUCT;
                    if (type == TYPE_ADD_EDIT_PRODUCT_EDIT)defaultSuccessMessage=SUCCESSMESSAGE_EDIT_PRODUCT;
                    if (type == TYPE_ADD_EDIT_PRODUCT_COPY)defaultSuccessMessage=SUCCESSMESSAGE_COPY_PRODUCT;

                    NSArray *successMessages = setting.message_status?:@[defaultSuccessMessage];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:successMessages delegate:self];
                    [alert show];

                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                    
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

#pragma mark Request Action MoveToWarehouse
-(void)cancelActionMoveToWarehouse
{
    [_requestActionMoveToWarehouse cancel];
    _requestActionMoveToWarehouse = nil;
    [_objectmanagerActionMoveToWarehouse.operationQueue cancelAllOperations];
    _objectmanagerActionMoveToWarehouse = nil;
}

-(void)configureRestKitActionMoveToWarehouse
{
    _objectmanagerActionMoveToWarehouse = [RKObjectManager sharedClient];
    
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
    
    [_objectmanagerActionMoveToWarehouse addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionMoveToWarehouse:(id)object
{
    if (_requestActionMoveToWarehouse.isExecuting) return;
    
    NSTimer *timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionMoveToWarehouse) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
    
    NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY:ACTION_MOVE_TO_WAREHOUSE,
                            kTKPDDETAILPRODUCT_APIPRODUCTIDKEY : product.product_id?:@"",
                            };
    _requestActionMoveToWarehouse = [_objectmanagerActionMoveToWarehouse appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAILACTIONPRODUCT_APIPATH parameters:[param encrypt]];
    
    [_requestActionMoveToWarehouse setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionMoveToWarehouse:mappingResult withOperation:operation];
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionMoveToWarehouse:error];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestActionMoveToWarehouse];

}

-(void)requestSuccessActionMoveToWarehouse:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    ShopSettings *setting = stat;
    BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionMoveToWarehouse:object];
    }
}

-(void)requestFailureActionMoveToWarehouse:(id)object
{
    [self requestProcessActionMoveToWarehouse:object];
}

-(void)requestProcessActionMoveToWarehouse:(id)object
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
                    NSArray *array = setting.message_status?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
                    
                    //if (_isBeingPresented) {
                        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                    //} else {
                    //    NSInteger indexPopViewController = self.navigationController.viewControllers.count-3;
                    //    UIViewController *popViewController = self.navigationController.viewControllers [indexPopViewController];
                    //    [self.navigationController popToViewController:popViewController animated:NO];
                    //}
                }
            }
        }
        else{
            //[self cancelActionMoveToWarehouse];
            NSError *error = object;
            if (!([error code] == NSURLErrorCancelled)){
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeoutActionMoveToWarehouse
{
    [self cancelActionMoveToWarehouse];
}


#pragma mark - TextView Delegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    _activeTextView = textView;

    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView == _productDescriptionTextView) {
        if(textView.text.length != 0 && ![textView.text isEqualToString:@""]){
            ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
            product.product_description = textView.text;
            [_dataInput setObject:product forKey:DATA_PRODUCT_DETAIL_KEY];
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
- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _tableView.contentInset = contentInsets;
    _tableView.scrollIndicatorInsets = contentInsets;
    
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)info {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _tableView.contentInset = contentInsets;
                         _tableView.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished){
                     }];
}

#pragma mark - Alertview Delegate
-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
#define DEFAULT_ETALASE_DETAIL_TITLE_BUTTON @"Pilih Etalase"
    ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY]?:[ProductDetail new];
    switch (alertView.tag) {
        case 10:
        {
            NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];
            NSString *value = [ARRAY_PRODUCT_INSURACE[index] objectForKey:DATA_VALUE_KEY];
            product.product_must_insurance = value;
            [_dataInput setObject:product forKey:DATA_PRODUCT_DETAIL_KEY];
            [_tableView reloadData];
            break;
        }
        case 12:
        {
            NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];
            NSString *value = [ARRAY_PRODUCT_CONDITION[index] objectForKey:DATA_VALUE_KEY];
            product.product_condition = value;
            [_dataInput setObject:product forKey:DATA_PRODUCT_DETAIL_KEY];
            [_tableView reloadData];
            break;
        }
        case 11:
        {
            NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];
            NSString *value = [ARRAY_PRODUCT_MOVETO_ETALASE[index] objectForKey:DATA_VALUE_KEY];
            product.product_move_to = value;//([value integerValue]==1)?@"0":value;
            if (index == 0) {
                product.product_etalase_id = @(0);
            }
            [_dataInput setObject:product forKey:DATA_PRODUCT_DETAIL_KEY];
            [_tableView reloadData];
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
    ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
    product.product_etalase_id = @([etalase.etalase_id integerValue]);
    product.product_etalase = etalase.etalase_name;
    [_dataInput setObject:product forKey:DATA_PRODUCT_DETAIL_KEY];
    NSIndexPath *indexpath = [userInfo objectForKey:kTKPDDETAILETALASE_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    [_dataInput setObject:indexpath forKey:kTKPDDETAILETALASE_DATAINDEXPATHKEY];
    
    [_tableView reloadData];
}

#pragma mark - Product Wholesale View Controller Delegate
-(void)ProductEditWholesaleViewController:(ProductEditWholesaleViewController *)viewController withWholesaleList:(NSArray *)list
{
    [_dataInput setObject:list forKey:DATA_WHOLESALE_LIST_KEY];
}

#pragma mark - Methods
-(void)setShopHasTerm:(NSString *)shopHasTerm
{
    _shopHasTerm = shopHasTerm;
    if (shopHasTerm) {
        if ([shopHasTerm isEqualToString:@""]||[shopHasTerm isEqualToString:@"0"] || shopHasTerm == nil) {
            _returnableProductSwitch.enabled = NO;
        }
        else
        {
            _returnableProductSwitch.enabled = YES;
        }
    }

}

-(void)setDefaultData:(NSDictionary*)data
{
    _data = data;
    if (data) {
                
        [_dataInput addEntriesFromDictionary:[_data objectForKey:DATA_INPUT_KEY]];
        
        ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
        NSString *productReturnable = product.product_returnable;
        if ([productReturnable isEqualToString:@""] || [productReturnable isEqualToString:@"0"] || productReturnable == nil) {
            [_dataInput setObject:@(-1) forKey:API_PRODUCT_IS_RETURNABLE_KEY];
        }
        BOOL isProductReturnable = ([productReturnable integerValue] == RETURNABLE_YES_ID)?YES:NO;
        _returnableProductSwitch.on = isProductReturnable;
        
        NSString *productDescription = [NSString convertHTML:product.product_short_desc]?:@"";
        productDescription = ([productDescription isEqualToString:@"0"])?@"":productDescription;
        _productDescriptionTextView.text = productDescription;
        
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
        
        UserAuthentificationManager *auth = [UserAuthentificationManager new];
        NSString *shopHasTerm = [auth getShopHasTerm];

        if ([shopHasTerm isEqualToString:@""]||[shopHasTerm isEqualToString:@"0"] || shopHasTerm == nil) {
            _returnableProductSwitch.enabled = NO;
        }
        else
        {
            _returnableProductSwitch.enabled = YES;
        }
        
        [_tableView reloadData];
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

-(void)adjustBarButton
{
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(tap:)];
    barButtonItem.tag = BARBUTTON_PRODUCT_BACK;
    self.navigationItem.backBarButtonItem = barButtonItem;
    
    _saveBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Simpan"
                                                          style:UIBarButtonItemStyleDone
                                                         target:(self)
                                                         action:@selector(tap:)];
    _saveBarButtonItem.tag = BARBUTTON_PRODUCT_SAVE;
    self.navigationItem.rightBarButtonItem = _saveBarButtonItem;
}

-(void)adjustReturnableNotesLabel
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]  initWithString:_pengembalianProductLabel.text];
    [attributedString addAttribute:NSFontAttributeName value:FONT_GOTHAM_BOOK_10 range:[_pengembalianProductLabel.text rangeOfString:@"Klik Disini"]];
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1]
                             range:[_pengembalianProductLabel.text rangeOfString:@"Klik Disini"]];
    
    [attributedString addAttribute:NSParagraphStyleAttributeName
                             value:style
                             range:[_pengembalianProductLabel.text rangeOfString:_pengembalianProductLabel.text]];
    
    _pengembalianProductLabel.attributedText = attributedString;
}

-(void)didEditNote:(NSNotification*)notification
{
    [_delegate DidEditReturnableNote];
}

-(void)didUpdateShopHasTerms:(NSNotification*)notification
{
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    NSString *shopHasTerm = [auth getShopHasTerm];
    
    if ([shopHasTerm isEqualToString:@""]||[shopHasTerm isEqualToString:@"0"] || shopHasTerm == nil) {
        _returnableProductSwitch.enabled = NO;
    }
    else
    {
        _returnableProductSwitch.enabled = YES;
    }
    
    [_tableView reloadData];
}

@end
