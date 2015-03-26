//
//  TransactionATCViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionAction.h"
#import "TransactionATCForm.h"
#import "TransactionCalculatePrice.h"

#import "TransactionObjectMapping.h"

#import "string_alert.h"

#import "AlertPickerView.h"
#import "StickyAlertView.h"
#import "string_settings.h"
#import "SettingAddressViewController.h"
#import "TransactionATCViewController.h"
#import "AddressFormList.h"
#import "DetailProductResult.h"
#import "TransactionShipmentViewController.h"
#import "TransactionCartRootViewController.h"

#pragma mark - Transaction Add To Cart View Controller

@interface TransactionATCViewController ()
<
    TKPDAlertViewDelegate,
    SettingAddressViewControllerDelegate,
    TransactionShipmentViewControllerDelegate,
    SettingAddressViewControllerDelegate,
    UITabBarControllerDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    UITextViewDelegate,
    UIAlertViewDelegate
>
{
    NSMutableDictionary *_dataInput;
    
    BOOL _isnodata;
    BOOL _isRefreshRequest;
    
    UITextField *_activeTextField;
    UITextView *_activeTextView;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestcount;
    
    NSDictionary *_auth;
    
    __weak RKObjectManager *_objectManagerFormATC;
    __weak RKManagedObjectRequestOperation *_requestFormATC;
    
    __weak RKObjectManager *_objectManagerActionATC;
    __weak RKManagedObjectRequestOperation *_requestActionATC;
    
    __weak RKObjectManager *_objectManagerActionCalculate;
    __weak RKManagedObjectRequestOperation *_requestActionCalculate;
    
    NSOperationQueue *_operationQueue;
    
    UIBarButtonItem *_doneBarButtonItem;
    
    BOOL _isRequestFrom;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;

    BOOL _productQuantityChanged;
}
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *headerTableView;

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *tableViewProductCell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *tableViewShipmentCell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *tableViewPaymentDetailCell;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIImageView *productThumbImageView;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productDescriptionLabel;
@property (weak, nonatomic) IBOutlet UITextView *remarkTextView;
@property (weak, nonatomic) IBOutlet UILabel *recieverNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@property (weak, nonatomic) IBOutlet UILabel *productQuantityLabel;
@property (weak, nonatomic) IBOutlet UIStepper *productQuantityStepper;

-(void)cancelFormATC;
-(void)configureRestKitFormATC;
-(void)requestFormATC;
-(void)requestSuccessFormATC:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureFormATC:(id)object;
-(void)requestProcessFormATC:(id)object;
-(void)requestTimeoutFormATC;

-(void)cancelActionATC;
-(void)configureRestKitActionATC;
-(void)requestActionATC:(id)object;
-(void)requestSuccessActionATC:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureActionATC:(id)object;
-(void)requestProcessActionATC:(id)object;
-(void)requestTimeoutActionATC;

-(void)cancelActionCalculate;
-(void)configureRestKitActionCalculate;
-(void)requestActionCalculate:(id)object;
-(void)requestSuccessActionCalculate:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureActionCalculate:(id)object;
-(void)requestProcessActionCalculate:(id)object;
-(void)requestTimeoutActionCalculate;

@end

@implementation TransactionATCViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
        _isRefreshRequest = NO;
    }
    return self;
}

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
   
    _dataInput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    
    _tableViewPaymentDetailCell = [NSArray sortViewsWithTagInArray:_tableViewPaymentDetailCell];
    _tableViewProductCell = [NSArray sortViewsWithTagInArray:_tableViewProductCell];
    _tableViewShipmentCell = [NSArray sortViewsWithTagInArray:_tableViewShipmentCell];
    _isnodata = YES;
    
    [_remarkTextView setPlaceholder:PLACEHOLDER_NOTE_ATC];
    
    [self setDefaultData:_data];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    barButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_BACK;
    [self.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView)forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self configureRestKitFormATC];
    [self requestFormATC];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.title = @"Beli";
    
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);

    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(tap:)];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    [_activeTextView resignFirstResponder];
    [_activeTextField resignFirstResponder];
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton*)sender;
        switch (button.tag) {
            case TAG_BUTTON_TRANSACTION_BUY:
            {
                if ([self isValidInput]) {
                    [self configureRestKitActionATC];
                    [self requestActionATC:_dataInput];
                }
            }
            default:
                break;
        }
    }
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *barButtonItem = (UIBarButtonItem *)sender;
        switch (barButtonItem.tag) {
            case TAG_BAR_BUTTON_TRANSACTION_BACK:
                [self.navigationController popViewControllerAnimated:YES];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Table View Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _isnodata?0:3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return _isnodata?0:_tableViewProductCell.count;
            break;
        case 1:
            return _isnodata?0:_tableViewShipmentCell.count;
            break;
        case 2:
            return _isnodata?0:_tableViewPaymentDetailCell.count;
        default:
            return 0;
            break;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    if (!_isnodata) {
        ShippingInfoShipments *shipment = [_dataInput objectForKey:DATA_SELECTED_SHIPMENT_KEY];
        ShippingInfoShipmentPackage *shipmentPackage = [_dataInput objectForKey:DATA_SELECTED_SHIPMENT_PACKAGE_KEY];
        AddressFormList *address = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY];
        [self setAddress:address];
        ProductDetail *product = [_dataInput objectForKey:DATA_DETAIL_PRODUCT_KEY];
        switch (indexPath.section) {
            case 0:
            {
                cell = _tableViewProductCell[indexPath.row];
                UILabel *label = (UILabel *)[cell viewWithTag:1];
                switch (indexPath.row) {
                    case TAG_BUTTON_TRANSACTION_INSURANCE:
                    {
                        if ([product.product_must_insurance integerValue]==1) {
                            label.text = @"Wajib Asuransi";
                        }
                        else{
                            NSInteger insuranceID = [product.product_insurance integerValue];
                            label.text = (insuranceID==1)?@"Ya":@"Tidak";
                        }
                        break;
                    }
                }
                break;
            }
            case 1:
            {
                cell = _tableViewShipmentCell[indexPath.row];
                UILabel *label = (UILabel *)[cell viewWithTag:1];
                switch (indexPath.row) {
                    case TAG_BUTTON_TRANSACTION_ADDRESS:
                    {
                        label.text = address.address_name;
                        break;
                    }
                    case TAG_BUTTON_TRANSACTION_SHIPPING_AGENT:
                    {
                        label.text = shipment.shipment_name;
                        break;
                    }
                    case TAG_BUTTON_TRANSACTION_SERVICE_TYPE:
                    {
                        label.text = shipmentPackage.name;
                        break;
                    }
                }
                break;
            }
            case 2:
                cell = _tableViewPaymentDetailCell[indexPath.row];
                UILabel *label = (UILabel *)[cell viewWithTag:1];
                switch (indexPath.row) {
                    case TAG_BUTTON_TRANSACTION_PRODUCT_PRICE:
                    {
                        label.text = product.product_price;
                        break;
                    }
                    case TAG_BUTTON_TRANSACTION_SHIPMENT_COST:
                    {
                        label.text = shipmentPackage.price;
                        break;
                    }
                    case TAG_BUTTON_TRANSACTION_TOTAL:
                    {
                        NSString *productPrice = [product.product_price stringByReplacingOccurrencesOfString:@"Rp " withString:@""];
                        productPrice = [productPrice stringByReplacingOccurrencesOfString:@"." withString:@""];
                        productPrice = [productPrice stringByReplacingOccurrencesOfString:@"," withString:@""];
                        productPrice = [productPrice stringByReplacingOccurrencesOfString:@"-" withString:@""];

                        NSString *shipmentPackagePrice = [shipmentPackage.price stringByReplacingOccurrencesOfString:@"Rp " withString:@""];
                        shipmentPackagePrice = [shipmentPackagePrice stringByReplacingOccurrencesOfString:@"." withString:@""];
                        shipmentPackagePrice = [shipmentPackagePrice stringByReplacingOccurrencesOfString:@"," withString:@""];
                        shipmentPackagePrice = [shipmentPackagePrice stringByReplacingOccurrencesOfString:@"-" withString:@""];

                        NSNumber *total = [NSNumber numberWithInteger:([productPrice integerValue] + [shipmentPackagePrice integerValue])];
                        
                        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                        formatter.numberStyle = NSNumberFormatterCurrencyStyle;
                        formatter.currencyCode = @"Rp ";
                        formatter.currencyGroupingSeparator = @".";
                        formatter.currencyDecimalSeparator = @",";
                        formatter.maximumFractionDigits = 0;
                        formatter.minimumFractionDigits = 0;
                        
                        NSString *totalPrice = [[formatter stringFromNumber:total] stringByAppendingString:@",-"];
                        
                        label.text = totalPrice;
                    }
                }
                if (!_productQuantityChanged) {
                    UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView *)[cell viewWithTag:2];
                    [indicatorView stopAnimating];
                    [indicatorView setHidden:YES];
                }
        }
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (indexPath.section == 2 && _productQuantityChanged) {
        [_dataInput setObject:@(_productQuantityStepper.value) forKey:API_QUANTITY_KEY];
        [self calculatePriceWithAction:@""];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    switch (indexPath.section) {
        case 0:
            cell = _tableViewProductCell[indexPath.row];
            break;
        case 1:
            cell = _tableViewShipmentCell[indexPath.row];
            break;
        case 2:
            cell = _tableViewPaymentDetailCell[indexPath.row];
        default:
            break;
    }
    return cell.frame.size.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_activeTextField resignFirstResponder];
    [_activeTextView resignFirstResponder];
    if (_isRequestFrom) {
        return;
    }
    if (indexPath.section == 0)
    {
        switch (indexPath.row) {
            case TAG_BUTTON_TRANSACTION_INSURANCE:
            {
                ProductDetail *product = [_dataInput objectForKey:DATA_DETAIL_PRODUCT_KEY];
                if ([product.product_must_insurance integerValue]!=1) {
                    AlertPickerView *alert = [AlertPickerView newview];
                    alert.tag = indexPath.row;
                    alert.delegate = self;
                    alert.pickerData = ARRAY_INSURACE;
                    [alert show];
                }
                break;
            }
            case TAG_BUTTON_TRANSACTION_NOTE:
            {
                [_remarkTextView becomeFirstResponder];
                break;
            }
        }
    }
    else if (indexPath.section == 1){
        switch (indexPath.row) {
            case TAG_BUTTON_TRANSACTION_ADDRESS:
            {
                AddressFormList *address = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY];
                SettingAddressViewController *addressViewController = [SettingAddressViewController new];
                addressViewController.delegate = self;
                NSIndexPath *selectedIndexPath = [_dataInput objectForKey:DATA_ADDRESS_INDEXPATH_KEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                addressViewController.data = @{DATA_TYPE_KEY:@(TYPE_ADD_EDIT_PROFILE_ATC),
                                               DATA_INDEXPATH_KEY: selectedIndexPath,
                                               DATA_ADDRESS_DETAIL_KEY:address?:[AddressFormList new]};
                [self.navigationController pushViewController:addressViewController animated:YES];
                break;
            }
            case TAG_BUTTON_TRANSACTION_SERVICE_TYPE:
            {
                NSArray *shipments = [_dataInput objectForKey:DATA_SHIPMENT_KEY];
                NSIndexPath *selectedShipment = [_dataInput objectForKey:DATA_SELECTED_INDEXPATH_SHIPMENT_KEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                NSInteger indexShipment = selectedShipment.row;
                NSIndexPath *selectedShipmentPackage = [_dataInput objectForKey:DATA_SELECTED_INDEXPATH_SHIPMENT_PACKAGE_KEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                
                ShippingInfoShipments *shipment = shipments[indexShipment];
                
                NSMutableArray *shipmentPackages = [NSMutableArray new];
                [shipmentPackages addObjectsFromArray:shipment.shipment_package];
                for (ShippingInfoShipmentPackage *package in shipment.shipment_package) {
                    if ([package.price isEqualToString:@"0"]) {
                        [shipmentPackages removeObject:package];
                    }
                }
                TransactionShipmentViewController *shipmentViewController = [TransactionShipmentViewController new];
                shipmentViewController.data = @{DATA_TYPE_KEY:@(TYPE_TRANSACTION_SHIPMENT_SERVICE_TYPE),
                                                DATA_SHIPMENT_KEY :shipmentPackages,
                                                DATA_INDEXPATH_KEY : selectedShipmentPackage
                                                };
                shipmentViewController.delegate = self;
                [self.navigationController pushViewController:shipmentViewController animated:YES];
                break;
            }
            case TAG_BUTTON_TRANSACTION_SHIPPING_AGENT:
            {
                NSIndexPath *selectedShipment = [_dataInput objectForKey:DATA_SELECTED_INDEXPATH_SHIPMENT_KEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                
                ShippingInfoShipments *shipments = [_dataInput objectForKey:DATA_SHIPMENT_KEY];
                TransactionShipmentViewController *shipmentViewController = [TransactionShipmentViewController new];
                shipmentViewController.data = @{DATA_TYPE_KEY:@(TYPE_TRANSACTION_SHIPMENT_SHIPPING_AGENCY),
                                                DATA_SHIPMENT_KEY :shipments,
                                                DATA_INDEXPATH_KEY : selectedShipment
                                                };
                shipmentViewController.delegate = self;
                [self.navigationController pushViewController:shipmentViewController animated:YES];
                break;
            }
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [(_headerTableView[section]) frame].size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _headerTableView[section];
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    [_activeTextField resignFirstResponder];
    [_activeTextView resignFirstResponder];
    [_remarkTextView resignFirstResponder];
    [_dataInput setObject:_remarkTextView.text forKey:API_NOTES_KEY];
}

#pragma mark - Request Form
-(void)cancelFormATC
{
    [_requestFormATC cancel];
    _requestFormATC = nil;
    [_objectManagerFormATC.operationQueue cancelAllOperations];
    _objectManagerFormATC = nil;
}

-(void)configureRestKitFormATC
{
    _objectManagerFormATC = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionATCForm class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionATCFormResult class]];
    
    RKObjectMapping *formMapping = [RKObjectMapping mappingForClass:[TransactionATCFormDetail class]];
    [formMapping addAttributeMappingsFromDictionary:@{API_AVAILABLE_COUNT_KEY:API_AVAILABLE_COUNT_KEY}];
    
    TransactionObjectMapping *mapping = [TransactionObjectMapping new];
    RKObjectMapping *productMapping = [mapping productMapping];
    RKObjectMapping *AddressMapping = [mapping addressMapping];
    RKObjectMapping *shipmentsMapping = [mapping shipmentsMapping];
    RKObjectMapping *shipmentspackageMapping = [mapping shipmentPackageMapping];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_FORM_KEY toKeyPath:API_FORM_KEY withMapping:formMapping]];
    
    [formMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_PRODUCT_DETAIL_KEY toKeyPath:API_PRODUCT_DETAIL_KEY withMapping:productMapping]];
    
    [formMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_DESTINATION_KEY toKeyPath:API_DESTINATION_KEY withMapping:AddressMapping]];
    
    RKRelationshipMapping *shipmentRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APISHIPMENTKEY toKeyPath:kTKPDDETAILSHOP_APISHIPMENTKEY withMapping:shipmentsMapping];
    [formMapping addPropertyMapping:shipmentRel];
    
    RKRelationshipMapping *shipmentpackageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APISHIPMENTPACKAGEKEY toKeyPath:kTKPDDETAILSHOP_APISHIPMENTPACKAGEKEY withMapping:shipmentspackageMapping];
    [shipmentsMapping addPropertyMapping:shipmentpackageRel];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:API_TRANSACTION_CART_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerFormATC addResponseDescriptor:responseDescriptor];
    
}

-(void)requestFormATC
{
    if (_requestFormATC.isExecuting) return;
    NSTimer *timer;
    
    ProductDetail *product = [_dataInput objectForKey:DATA_DETAIL_PRODUCT_KEY];
    NSInteger productID = [product.product_id integerValue];
    
    NSDictionary* param = @{API_ACTION_KEY :ACTION_ADD_TO_CART_FORM,
                            API_PRODUCT_ID_KEY:@(productID)
                            };
    _requestcount ++;
    _tableView.tableFooterView = _footer;
    [_act startAnimating];
    _isRequestFrom = YES;
    [self buyButtonIsLoading:YES];
    
    _requestFormATC = [_objectManagerFormATC appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_TRANSACTION_CART_PATH parameters:[param encrypt]];
    
    [_requestFormATC setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessFormATC:mappingResult withOperation:operation];
        _isRefreshRequest = NO;
        [_refreshControl endRefreshing];
        [timer invalidate];
        _isRequestFrom = NO;
        _tableView.tableFooterView = nil;
        [_act stopAnimating];
        [self buyButtonIsLoading:NO];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureFormATC:error];
        _isRefreshRequest = NO;
        [_refreshControl endRefreshing];
        [timer invalidate];
        _isRequestFrom = NO;
        _tableView.tableFooterView = nil;
        [_act stopAnimating];
        [self buyButtonIsLoading:NO];
    }];
    
    [_operationQueue addOperation:_requestFormATC];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutFormATC) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessFormATC:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionATCForm *ATCForm = stat;
    BOOL status = [ATCForm.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessFormATC:object];
    }
}

-(void)requestFailureFormATC:(id)object
{
    [self requestProcessFormATC:object];
}

-(void)requestProcessFormATC:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            TransactionATCForm *ATCForm = stat;
            BOOL status = [ATCForm.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(ATCForm.message_error)
                {
                    NSArray *messages = ATCForm.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:messages delegate:self];
                    [alert show];
                }
                else{
                    AddressFormList *address = ATCForm.result.form.destination;
                    [_dataInput setObject:address forKey:DATA_ADDRESS_DETAIL_KEY];
                    
                    NSIndexPath* selectedIndexPathShipment =[_dataInput objectForKey:DATA_SELECTED_INDEXPATH_SHIPMENT_KEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                    
                    NSIndexPath* selectedIndexPathShipmentPackage =[_dataInput objectForKey:DATA_SELECTED_INDEXPATH_SHIPMENT_PACKAGE_KEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                    
                    NSArray *shipments = ATCForm.result.form.shipment;
                    [_dataInput setObject:shipments forKey:DATA_SHIPMENT_KEY];
                    
                    NSInteger indexShipment = selectedIndexPathShipment.row;
                    ShippingInfoShipments *shipment = shipments[indexShipment];
                    
                    NSInteger indexShipmentPackage = selectedIndexPathShipmentPackage.row;
                    NSMutableArray *shipmentPackages = [NSMutableArray new];
                    [shipmentPackages addObjectsFromArray:shipment.shipment_package];
                    for (ShippingInfoShipmentPackage *package in shipment.shipment_package) {
                        if ([package.price isEqualToString:@"0"]) {
                            [shipmentPackages removeObject:package];
                        }
                    }
                    
                    if (shipmentPackages.count > 0) {
                        ShippingInfoShipmentPackage *shipmentPackage = shipmentPackages[indexShipmentPackage];
                        [_dataInput setObject:shipment forKey:DATA_SELECTED_SHIPMENT_KEY];
                        [_dataInput setObject:shipmentPackage forKey:DATA_SELECTED_SHIPMENT_PACKAGE_KEY];                        
                    }

                    [self setAddress:address];
                    _isnodata = NO;
                    [_tableView reloadData];
                }
            }
        }
        else{
            
            [self cancelFormATC];
            NSError *error = object;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeoutFormATC
{
    [self cancelFormATC];
}

//# sub add_to_cart example URL
//# www.tkpdevel-pg.ekarisky/ws/action/tx.pl?action=add_to_cart&
//# product_id=10724&
//# address_id=2358&
//# address_name=Alamat Rumah&
//# address_street=Bikini Bottom No.1&
//# address_province=DKI Jakarta&
//# address_city=Kota Administrasi Jakarta Barat&
//# address_district=Kembangan&
//# address_postal_code=12345&
//# quantity=1&
//# insurance=1&
//# shipping_id=1&
//# shipping_product=1&
//# notes=Ngetes Aja&
//# receiver_name=Smithy Werben Jeger Man Jensen&
//# receiver_phone=082122987745

#pragma mark Request Action Add To Cart
-(void)cancelActionATC
{
    [_requestActionATC cancel];
    _requestActionATC = nil;
    [_objectManagerActionATC.operationQueue cancelAllOperations];
    _objectManagerActionATC = nil;
}

-(void)configureRestKitActionATC
{
    _objectManagerActionATC = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{API_IS_SUCCESS_KEY:API_IS_SUCCESS_KEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:API_ACTION_TRANSACTION_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerActionATC addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionATC:(id)object
{
    if (_requestActionATC.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userinfo = (NSDictionary*)object;
    ShippingInfoShipments *shipment = [userinfo objectForKey:DATA_SELECTED_SHIPMENT_KEY];
    ShippingInfoShipmentPackage *shipmentPackage = [userinfo objectForKey:DATA_SELECTED_SHIPMENT_PACKAGE_KEY];
    AddressFormList *address = [userinfo objectForKey:DATA_ADDRESS_DETAIL_KEY];
    ProductDetail *product = [userinfo objectForKey:DATA_DETAIL_PRODUCT_KEY];
    
    NSInteger productID = [ product.product_id integerValue];
    NSInteger quantity = [[userinfo objectForKey:API_QUANTITY_KEY]integerValue];
    NSInteger insuranceID = [product.product_insurance integerValue];
    NSInteger shippingID = [shipment.shipment_id integerValue];
    NSInteger shippingProduct = [shipmentPackage.sp_id integerValue];
    NSString *remark = [userinfo objectForKey:API_NOTES_KEY];
    
    NSInteger addressID = (address.address_id==0)?-1:address.address_id;
    NSNumber *districtID = address.district_id?:@(0);
    NSString *addressName = address.address_name?:@"";
    NSString *addressStreet = address.address_street?:@"";
    NSNumber *provinceID = address.province_id?:@(0);
    NSNumber *cityID = address.city_id?:@(0);
    NSInteger postalCode = address.postal_code;
    NSString *recieverName = address.receiver_name?:@"";
    NSString *recieverPhone = address.receiver_phone?:@"";
    
    NSDictionary* param = @{API_ACTION_KEY:ACTION_ADD_TO_CART,
                            API_PRODUCT_ID_KEY:@(productID),
                            API_ADDRESS_ID_KEY : @(addressID),
                            API_QUANTITY_KEY:@(quantity),
                            API_INSURANCE_KEY:@(insuranceID),
                            API_SHIPPING_ID_KEY:@(shippingID),
                            API_SHIPPING_PRODUCT_KEY:@(shippingProduct),
                            API_NOTES_KEY:remark?:@"",
                            API_ADDRESS_ID_KEY : @(addressID),
                            API_ADDRESS_NAME_KEY: addressName,
                            API_ADDRESS_STREET_KEY : addressStreet,
                            API_ADDRESS_PROVINCE_KEY:provinceID,
                            API_ADDRESS_CITY_KEY:cityID,
                            API_ADDRESS_DISTRICT_KEY:districtID,
                            API_ADDRESS_POSTAL_CODE_KEY:@(postalCode),
                            API_RECIEVER_NAME_KEY:recieverName,
                            API_RECIEVER_PHONE_KEY:recieverPhone,
                            API_DISTRICT_ID_KEY : districtID
                            };
    _requestcount ++;
    
    [self buyButtonIsLoading:YES];
    
    _requestActionATC = [_objectManagerActionATC appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_ACTION_TRANSACTION_PATH parameters:[param encrypt]];
    
    [_requestActionATC setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionATC:mappingResult withOperation:operation];
        _isRefreshRequest = NO;
        [_refreshControl endRefreshing];
        [timer invalidate];
        [self buyButtonIsLoading:NO];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFailureActionATC:error];
        _isRefreshRequest = NO;
        [_refreshControl endRefreshing];
        [timer invalidate];
        [self buyButtonIsLoading:NO];
    }];
    
    [_operationQueue addOperation:_requestActionATC];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionATC) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionATC:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionAction *setting = stat;
    BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionATC:object];
    }
}

-(void)requestFailureActionATC:(id)object
{
    [self requestProcessActionATC:object];
}

-(void)requestProcessActionATC:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            TransactionAction *setting = stat;
            BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(setting.message_error)
                {
                    NSArray *messages = setting.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:messages delegate:self];
                    [alert show];
                }
                if (setting.result.is_success == 1) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[setting.message_status firstObject] delegate:self cancelButtonTitle:@"Kembali Belanja" otherButtonTitles:@"Ke Keranjang Belanja",nil];
                    alertView.tag=TAG_BUTTON_TRANSACTION_BUY;
                    [alertView show];
                }
            }
        }
        else{
            
            //[self cancelActionATC];
            NSError *error = object;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeoutActionATC
{
    //[self cancelActionATC];
}

#pragma mark Request Action Calculate Price
-(void)cancelActionCalculate
{
    [_requestActionCalculate cancel];
    _requestActionCalculate = nil;
    [_objectManagerActionCalculate.operationQueue cancelAllOperations];
    _objectManagerActionCalculate = nil;
}

-(void)configureRestKitActionCalculate
{
    _objectManagerActionCalculate = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionCalculatePrice class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionCalculatePriceResult class]];
    
    TransactionObjectMapping *mapping = [TransactionObjectMapping new];
    RKObjectMapping *productMapping = [mapping productMapping];
    RKObjectMapping *shipmentsMapping = [mapping shipmentsMapping];
    RKObjectMapping *shipmentspackageMapping = [mapping shipmentPackageMapping];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_PRODUCT_KEY toKeyPath:API_PRODUCT_KEY withMapping:productMapping]];
    
    RKRelationshipMapping *shipmentRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APISHIPMENTKEY toKeyPath:kTKPDDETAILSHOP_APISHIPMENTKEY withMapping:shipmentsMapping];
    [resultMapping addPropertyMapping:shipmentRel];
    
    RKRelationshipMapping *shipmentpackageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APISHIPMENTPACKAGEKEY toKeyPath:kTKPDDETAILSHOP_APISHIPMENTPACKAGEKEY withMapping:shipmentspackageMapping];
    [shipmentsMapping addPropertyMapping:shipmentpackageRel];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:API_TRANSACTION_CART_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerActionCalculate addResponseDescriptor:responseDescriptor];
}

-(void)requestActionCalculate:(id)object
{
    if (_requestActionCalculate.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userinfo = (NSDictionary*)object;
    
    NSString *action = ACTION_CALCULATE_PRICE;
    NSString *toDoCalculate = [userinfo objectForKey:DATA_TODO_CALCULATE]?:@"";
    ProductDetail *product = [userinfo objectForKey:DATA_DETAIL_PRODUCT_KEY];
    NSInteger productID = [product.product_id integerValue];
    NSInteger quantity = [[userinfo objectForKey:API_QUANTITY_KEY]integerValue];
    NSInteger insuranceID = [[userinfo objectForKey:API_INSURANCE_KEY]integerValue];
    ShippingInfoShipments *shipment = [userinfo objectForKey:DATA_SELECTED_SHIPMENT_KEY];
    NSInteger shippingID = [shipment.shipment_id integerValue];
    ShippingInfoShipmentPackage *shipmentPackage = [userinfo objectForKey:DATA_SELECTED_SHIPMENT_PACKAGE_KEY];
    NSInteger shippingProduct = [shipmentPackage.sp_id integerValue];
    NSString *weight = product.product_weight?:@"0";
    
    AddressFormList *address = [userinfo objectForKey:DATA_ADDRESS_DETAIL_KEY];
    NSInteger addressID = (address.address_id==0)?-1:address.address_id;
    NSNumber *districtID = address.district_id?:@(0);
    NSString *addressName = address.address_name?:@"";
    NSString *addressStreet = address.address_street?:@"";
    NSString *provinceName = address.province_name?:@"";
    NSString *cityName = address.city_name?:@"";
    NSString *disctrictName = address.district_name?:@"";
    NSInteger postalCode = address.postal_code;
    NSString *recieverName = address.receiver_name?:@"";
    NSString *recieverPhone = address.receiver_phone?:@"";

    NSDictionary* param = @{API_ACTION_KEY:action,
                            API_DO_KEY : toDoCalculate,
                            API_PRODUCT_ID_KEY:@(productID),
                            API_DISTRICT_ID_KEY: districtID,
                            API_ADDRESS_ID_KEY : @(addressID),
                            API_ADDRESS_NAME_KEY: addressName,
                            API_ADDRESS_STREET_KEY : addressStreet,
                            API_ADDRESS_PROVINCE_KEY:provinceName,
                            API_ADDRESS_CITY_KEY:cityName,
                            API_ADDRESS_DISTRICT_KEY:disctrictName,
                            API_POSTAL_CODE_KEY:@(postalCode),
                            API_RECIEVER_NAME_KEY:recieverName,
                            API_RECIEVER_PHONE_KEY:recieverPhone,
                            API_CALCULATE_QUANTTITY_KEY:@(quantity),
                            API_INSURANCE_KEY:@(insuranceID),
                            API_SHIPPING_ID_KEY:@(shippingID),
                            API_SHIPPING_PRODUCT_KEY:@(shippingProduct),
                            API_CALCULATE_WEIGHT_KEY: weight
                            };
    _requestcount ++;
    
    [self buyButtonIsLoading:YES];
    _requestActionCalculate = [_objectManagerActionCalculate appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_TRANSACTION_CART_PATH parameters:[param encrypt]];
    
    [_requestActionCalculate setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionCalculate:mappingResult withOperation:operation];
        _productQuantityChanged = NO;
        _isRefreshRequest = NO;
        [_refreshControl endRefreshing];
        [timer invalidate];
        [self buyButtonIsLoading:NO];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionCalculate:error];
        _isRefreshRequest = NO;
        [_refreshControl endRefreshing];
        [timer invalidate];
        [self buyButtonIsLoading:NO];
    }];
    
    [_operationQueue addOperation:_requestActionCalculate];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionCalculate) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];

    for (UITableViewCell *cell in _tableViewPaymentDetailCell) {
        UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView *)[cell viewWithTag:2];
        [indicatorView startAnimating];
        [indicatorView setHidden:NO];
        
        UILabel *label = (UILabel *)[cell viewWithTag:1];
        label.hidden = YES;
    }
}

-(void)requestSuccessActionCalculate:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionCalculatePrice *calculate = stat;
    BOOL status = [calculate.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionCalculate:object];
    }
}

-(void)requestFailureActionCalculate:(id)object
{
    [self requestProcessActionCalculate:object];
}

-(void)requestProcessActionCalculate:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            TransactionCalculatePrice *calculate = stat;
            BOOL status = [calculate.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(calculate.message_error)
                {
                    NSArray *messages = calculate.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:messages delegate:self];
                    [alert show];
                }
                else
                {
                    NSString *toDoCalculate = [_dataInput objectForKey:DATA_TODO_CALCULATE]?:@"";
                    NSIndexPath *selectedIndexPathShipment;
                    NSIndexPath *selectedIndexPathShipmentPackage;
                    
                    if ([toDoCalculate isEqualToString:CALCULATE_PRODUCT]) {
                        NSString *productPrice = calculate.result.product.price;
                        ProductDetail *product = [_dataInput objectForKey:DATA_DETAIL_PRODUCT_KEY];
                        product.product_price = productPrice;
                        [_dataInput setObject:product forKey:DATA_DETAIL_PRODUCT_KEY];
                        
                        selectedIndexPathShipment =[_dataInput objectForKey:DATA_SELECTED_INDEXPATH_SHIPMENT_KEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                        
                        selectedIndexPathShipmentPackage =[_dataInput objectForKey:DATA_SELECTED_INDEXPATH_SHIPMENT_PACKAGE_KEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                    }
                    else
                    {
                        [_dataInput removeObjectForKey:DATA_SELECTED_INDEXPATH_SHIPMENT_KEY];
                        [_dataInput removeObjectForKey:DATA_SELECTED_INDEXPATH_SHIPMENT_PACKAGE_KEY];
                        
                        selectedIndexPathShipment =[NSIndexPath indexPathForRow:0 inSection:0];
                        selectedIndexPathShipmentPackage =[NSIndexPath indexPathForRow:0 inSection:0];
                    }
                    
                    NSArray *shipments = calculate.result.shipment;
                    [_dataInput setObject:shipments forKey:DATA_SHIPMENT_KEY];

                    NSInteger indexShipment = selectedIndexPathShipment.row;
                    ShippingInfoShipments *shipment = shipments[indexShipment];
                    
                    NSInteger indexShipmentPackage = selectedIndexPathShipmentPackage.row;
                    NSMutableArray *shipmentPackages = [NSMutableArray new];
                    [shipmentPackages addObjectsFromArray:shipment.shipment_package];
                    for (ShippingInfoShipmentPackage *package in shipment.shipment_package) {
                        if ([package.price isEqualToString:@"0"]) {
                            [shipmentPackages removeObject:package];
                        }
                    }
                    ShippingInfoShipmentPackage *shipmentPackage = shipmentPackages[indexShipmentPackage];
                    [_dataInput setObject:shipment forKey:DATA_SELECTED_SHIPMENT_KEY];
                    [_dataInput setObject:shipmentPackage forKey:DATA_SELECTED_SHIPMENT_PACKAGE_KEY];
                    [_tableView reloadData];
                    
                    for (UITableViewCell *cell in _tableViewPaymentDetailCell) {
                        UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView *)[cell viewWithTag:2];
                        [indicatorView stopAnimating];
                        [indicatorView setHidden:YES];
                        
                        UILabel *label = (UILabel *)[cell viewWithTag:1];
                        label.hidden = NO;
                    }
                }
            }
        }
        else{
            
            //[self cancelActionCalculate];
            NSError *error = object;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeoutActionCalculate
{
    //[self cancelActionCalculate];
}

#pragma mark - Transaction Shipment Delegate
-(void)TransactionShipmentViewController:(TransactionShipmentViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    NSIndexPath *selectedIndexPath = [userInfo objectForKey:DATA_INDEXPATH_KEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    NSInteger type = [[userInfo objectForKey:DATA_TYPE_KEY]integerValue];
    
    NSArray *shipments = [_dataInput objectForKey:DATA_SHIPMENT_KEY];

    NSIndexPath *selectedIndexPathShipment =
    (type == TYPE_TRANSACTION_SHIPMENT_SHIPPING_AGENCY)
    ?selectedIndexPath
    :[_dataInput objectForKey:DATA_SELECTED_INDEXPATH_SHIPMENT_KEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    
    NSIndexPath *selectedIndexPathShipmentPackage =
    (type == TYPE_TRANSACTION_SHIPMENT_SHIPPING_AGENCY)
    ?[NSIndexPath indexPathForRow:0 inSection:0]
    :selectedIndexPath?:[NSIndexPath indexPathForRow:0 inSection:0];
    
    NSInteger indexShipment = selectedIndexPathShipment.row;
    ShippingInfoShipments *shipment = shipments[indexShipment];
    
    NSInteger indexShipmentPackage = selectedIndexPathShipmentPackage.row;
    NSMutableArray *shipmentPackages = [NSMutableArray new];
    [shipmentPackages addObjectsFromArray:shipment.shipment_package];

    for (ShippingInfoShipmentPackage *package in shipment.shipment_package) {
        if ([package.price isEqualToString:@"0"]) {
            [shipmentPackages removeObject:package];
        }
    }
    if (shipmentPackages.count==0) {
        NSArray *messages = @[[NSString stringWithFormat:@"Tidak dapat menggunakan layanan %@",shipment.shipment_name],];
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:messages delegate:self];
        [alert show];
        return;
    }
    ShippingInfoShipmentPackage *shipmentPackage = shipmentPackages[indexShipmentPackage];
    [_dataInput setObject:shipmentPackage forKey:DATA_SELECTED_SHIPMENT_PACKAGE_KEY];
    
    [_dataInput setObject:selectedIndexPathShipment forKey:DATA_SELECTED_INDEXPATH_SHIPMENT_KEY];
    [_dataInput setObject:selectedIndexPathShipmentPackage forKey:DATA_SELECTED_INDEXPATH_SHIPMENT_PACKAGE_KEY];
    [_dataInput setObject:shipment forKey:DATA_SELECTED_SHIPMENT_KEY];
    
    if (type == TYPE_TRANSACTION_SHIPMENT_SHIPPING_AGENCY) {
        [_dataInput removeObjectForKey:DATA_SELECTED_INDEXPATH_SHIPMENT_PACKAGE_KEY];
    }
    
    [_tableView reloadData];
}

#pragma mark - Alert View Delegate
-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case TAG_BUTTON_TRANSACTION_INSURANCE:
        {
            ProductDetail *product = [_dataInput objectForKey:DATA_DETAIL_PRODUCT_KEY];
            NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];
            NSString *value = [ARRAY_INSURACE[index] objectForKey:DATA_VALUE_KEY];
            NSString *name = [ARRAY_INSURACE[index] objectForKey:DATA_NAME_KEY];
            product.product_insurance = value;
            [_dataInput setObject:name forKey:DATA_INSURANCE_NAME_KEY];
            [_dataInput setObject:product forKey:DATA_DETAIL_PRODUCT_KEY];
            [_tableView reloadData];
            break;
        }
        case TAG_BUTTON_TRANSACTION_BUY:
        {
            if (buttonIndex==0) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                TransactionCartRootViewController *cartViewController = [TransactionCartRootViewController new];
                [self.navigationController pushViewController:cartViewController animated:YES];
            }
            break;
        }
        default:
            break;
    }
}


#pragma mark - Setting Address Delegate
-(void)SettingAddressViewController:(SettingAddressViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    AddressFormList *address = [userInfo objectForKey:DATA_ADDRESS_DETAIL_KEY];
    [_dataInput setObject:address forKey:DATA_ADDRESS_DETAIL_KEY];
    [self setAddress:address];
    
    NSIndexPath *selectedIndexPath = [userInfo objectForKey:DATA_INDEXPATH_KEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    [_dataInput setObject:selectedIndexPath forKey:DATA_ADDRESS_INDEXPATH_KEY];
    [self calculatePriceWithAction:CALCULATE_SHIPMENT];
    [_tableView reloadData];
}

#pragma mark - Textfield Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [_activeTextView resignFirstResponder];
    _activeTextView = nil;
    _activeTextField = textField;
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [_activeTextField resignFirstResponder];
    return YES;
}

#pragma mark - Text View Delegate

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    _activeTextField= nil;
    [_activeTextView resignFirstResponder];
    _activeTextView = textView;

    return YES;
}

-(BOOL)textViewShouldReturn:(UITextView *)textView{
    
    [_activeTextView resignFirstResponder];
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView == _remarkTextView) {
        [_dataInput setObject:textView.text forKey:API_NOTES_KEY];
    }
    return YES;
}

#pragma mark - UIStepper method

- (IBAction)changeStepperValue:(UIStepper *)sender {
    _productQuantityChanged = YES;
    _productQuantityLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification *)anotification {
     NSDictionary* info = [anotification userInfo];
     CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
     
     UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
     _tableView.contentInset = contentInsets;
     _tableView.scrollIndicatorInsets = contentInsets;
     
     [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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


#pragma mark - Methods

-(void)refreshView
{
    [self configureRestKitFormATC];
    [self requestFormATC];
}

-(void)setDefaultData:(NSDictionary*)data
{
    _data = data;
    if (data) {
        _productQuantityStepper.value = 1;
        _productQuantityLabel.text = @"1";
        [_dataInput setObject:@(1) forKey:API_QUANTITY_KEY];
        DetailProductResult *result = [_data objectForKey:DATA_DETAIL_PRODUCT_KEY];
        NSString *shopName = result.shop_info.shop_name;
        [_shopNameLabel setText:shopName animated:YES];
        [_productDescriptionLabel setText:result.product.product_name animated:YES];
        NSArray *productImages = result.product_images;
        ProductImages *productImage = productImages[0];
        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:productImage.image_src] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        
        UIImageView *thumb = _productThumbImageView;
        thumb.image = nil;
        //thumb.hidden = YES;	//@prepareforreuse then @reset
        
        [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            [thumb setImage:image animated:YES];
#pragma clang diagnostic pop
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        }];
        
        [_dataInput setObject:result.product forKey:DATA_DETAIL_PRODUCT_KEY];
        NSDictionary *insuranceDefault = [ARRAY_INSURACE lastObject];
        NSInteger insuranceID = [[insuranceDefault objectForKey:DATA_VALUE_KEY]integerValue];
        [_dataInput setObject:@(insuranceID) forKey:API_INSURANCE_KEY];
    }
}

-(void)setAddress:(AddressFormList*)address
{
    NSString *addressStreet = [NSString stringWithFormat:@"%@\n%@\n%@\n%@, %@ %zd",address.address_street?:@"", address.district_name?:@"", address.city_name?:@"-",address.province_name?:@"", address.country_name?:@"", address.postal_code];
    UIFont *font = [UIFont fontWithName:@"GothamBook" size:14];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: style,
                                 };
    
    NSAttributedString *addressAttributedText = [[NSAttributedString alloc] initWithString:addressStreet
                                                                                attributes:attributes];
    _addressLabel.attributedText = addressAttributedText;
    [_phoneLabel setText:address.receiver_phone animated:YES];
    [_recieverNameLabel setText:address.receiver_name animated:YES];
}

-(BOOL)isValidInput
{
    BOOL isValid = YES;
    NSMutableArray *errorMessage = [NSMutableArray new];
    
    ShippingInfoShipments *shipment = [_dataInput objectForKey:DATA_SELECTED_SHIPMENT_KEY];
    NSInteger shippingID = [shipment.shipment_id integerValue];
    
    if (shippingID == 0)
    {
        isValid = NO;
        [errorMessage addObject:ERRORMESSAGE_NULL_CART_SHIPPING_AGENT];
    }
    
    if (!isValid) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessage delegate:self];
        [alert show];
        return NO;
    }
    else
        return YES;
}

-(void)buyButtonIsLoading:(BOOL)isLoading
{
    _buyButton.enabled = !isLoading;
    if (isLoading) {
        _buyButton.layer.opacity = 0.8;
    } else {
        _buyButton.layer.opacity = 1;
    }
}

-(void)calculatePriceWithAction:(NSString*)action
{
    [_dataInput setObject:action forKey:DATA_TODO_CALCULATE];
    [self configureRestKitActionCalculate];
    [self requestActionCalculate:_dataInput];
}

@end
