//
//  ChangeCourierViewController.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 12/3/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "BarCodeViewController.h"
#import "ChangeCourierViewController.h"
#import "GeneralTableViewController.h"
#import "StickyAlertView.h"
#import "ActionOrder.h"
#import "Order.h"
#import "OrderTransaction.h"
#import "string_order.h"

@interface ChangeCourierViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
GeneralTableViewControllerDelegate,
BarCodeDelegate
>
{
    BOOL _changeCourier;
    NSString *_receiptNumber;
    ShipmentCourier *_selectedCourier;
    ShipmentCourierPackage *_selectedCourierPackage;
    
    NSString *strNoResi;
    BOOL _shouldReloadData;
    
    RKObjectManager *_actionObjectManager;
    RKManagedObjectRequestOperation *_actionRequest;
    RKResponseDescriptor *_responseActionDescriptorStatus;
    
    NSOperationQueue *_operationQueue;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UILabel *footerLabel;

@end

@implementation ChangeCourierViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"Ubah Kurir";
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:nil];
    self.navigationItem.backBarButtonItem = backBarButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(tap:)];
    cancelButton.tag = 1;
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Selesai"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(tap:)];
    doneButton.tag = 2;
    self.navigationItem.rightBarButtonItem = doneButton;
    
    _changeCourier = YES;
    
    for (ShipmentCourier *courier in _shipmentCouriers) {
        if ([courier.shipment_name isEqualToString:_order.order_shipment.shipment_name]) {
            _selectedCourier = courier;
        }
    }
    
    for (ShipmentCourierPackage *package in _selectedCourier.shipment_package) {
        _selectedCourierPackage = package;
    }
    
    _shouldReloadData = NO;
    
    _operationQueue = [NSOperationQueue new];
    
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if (section == 0) {
        rows = 2;
    } else if (section == 1) {
        rows = 1;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    } else {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Agen kurir";
            cell.detailTextLabel.text = _selectedCourier.shipment_name;
            cell.detailTextLabel.font = [UIFont largeTheme];
            cell.detailTextLabel.textColor = [UIColor grayColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Paket pengiriman";
            cell.detailTextLabel.text = _selectedCourierPackage.name;
            cell.detailTextLabel.font = [UIFont largeTheme];
            cell.detailTextLabel.textColor = [UIColor grayColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.font = [UIFont largeTheme];
    } else if (indexPath.section == 1) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width-15, 44)];
        textField.placeholder = @"Nomor resi";
        textField.tag = 1;
        textField.font = [UIFont largeTheme];
        textField.text = strNoResi;
        [cell addSubview:textField];
        
        
        UIView *tempView = [cell viewWithTag:111];
        if(tempView != nil)
        {
            [tempView removeFromSuperview];
            tempView = nil;
        }
        
        UIButton *btnScanCode = [UIButton buttonWithType:UIButtonTypeCustom];
        btnScanCode.tag = 111;
        
        int diameterFrame = 40;
        btnScanCode.frame = CGRectMake(textField.bounds.size.width-30, (textField.bounds.size.height-diameterFrame)/2.0f, diameterFrame, diameterFrame);
        [btnScanCode setImage:[UIImage imageNamed:@"icon_camera_grey_active.png"] forState:UIControlStateNormal];
        [btnScanCode addTarget:self action:@selector(showCameraCode:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btnScanCode];
    }
    
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return _footerView;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return _footerView.frame.size.height;
    } else {
        return 0;
    }
}

#pragma mark - Table delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        GeneralTableViewController *controller = [GeneralTableViewController new];
        if (indexPath.row == 0) {
            controller.title = @"Agen Kurir";
            controller.objects = _shipmentCouriers;
            controller.selectedObject = _selectedCourier ?: [_shipmentCouriers objectAtIndex:0];
            controller.delegate = self;
            controller.senderIndexPath = indexPath;
        } else if (indexPath.row == 1) {
            controller.title = @"Paket Pengiriman";
            controller.objects = [_selectedCourier shipment_package];
            controller.selectedObject = _selectedCourierPackage ?: [[_selectedCourier shipment_package] objectAtIndex:0];
            controller.delegate = self;
            controller.senderIndexPath = indexPath;
        }
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - General table delegate

- (void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && _selectedCourier != object) {
        
        _selectedCourier = object;
        _selectedCourierPackage = [[object shipment_package] objectAtIndex:0];
        
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
        cell.detailTextLabel.text = [object description];
        
        cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        cell.detailTextLabel.text = _selectedCourierPackage.name;
        
    } else if (indexPath.row == 1) {
        
        _selectedCourierPackage = object;
        
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
        cell.detailTextLabel.text = [object description];
        
    }
    
}

- (void)addOverlayCamera:(UIView *)parentView withFrame:(CGRect)rectFrame cancelDelegate:(UIViewController *)delegate
{
    UIView *overLayView = [[UIView alloc] initWithFrame:rectFrame];
    overLayView.backgroundColor = [UIColor lightGrayColor];
    
    int diameterCancel = 10;
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCancel.frame = CGRectMake(diameterCancel, diameterCancel, overLayView.bounds.size.height-(diameterCancel*2), overLayView.bounds.size.height-(diameterCancel*2));
    btnCancel.layer.borderColor = [btnCancel.titleLabel.textColor CGColor];
    btnCancel.layer.borderWidth = 1.0f;
    btnCancel.layer.cornerRadius = (btnCancel.bounds.size.height-diameterCancel)/2.0f;
    btnCancel.layer.masksToBounds = YES;
    [btnCancel addTarget:delegate action:@selector(cancelCamera:) forControlEvents:UIControlEventTouchUpInside];
    [btnCancel setImage:[UIImage imageNamed:@"icon_close_white.png"] forState:UIControlStateNormal];
    [overLayView addSubview:btnCancel];
    [parentView addSubview:overLayView];
}

- (void)showCameraCode:(id)sender
{
    
    BarCodeViewController *barCodeViewController = [BarCodeViewController new];
    barCodeViewController.delegate = self;
    [self presentViewController:barCodeViewController animated:YES completion:^{
        [self addOverlayCamera:barCodeViewController.view withFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-50, self.view.bounds.size.width, 50) cancelDelegate:barCodeViewController];
    }];
    
}

- (IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem *)sender;
        if (button.tag == 1) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else if (button.tag == 2) {
            UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
            UITextField *textField = (UITextField *)[cell viewWithTag:1];
            if (textField.text.length >= 7 && textField.text.length <= 17) {
                [self request];
            } else {
                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Nomor resi antara 7 - 17 karakter"]
                                                                               delegate:self];
                [alert show];
            }
        }
    }
}

#pragma mark - Resktit methods for actions

- (void)configureActionReskit
{
    _actionObjectManager =  [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ActionOrder class]];
    [statusMapping addAttributeMappingsFromDictionary:@{
                                                        kTKPD_APISTATUSKEY              : kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY   : kTKPD_APISERVERPROCESSTIMEKEY,
                                                        kTKPD_APISTATUSMESSAGEKEY       : kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY        : kTKPD_APIERRORMESSAGEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ActionOrderResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPD_APIISSUCCESSKEY : kTKPD_APIISSUCCESSKEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    RKResponseDescriptor *actionResponseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                        method:RKRequestMethodPOST
                                                                                                   pathPattern:API_NEW_ORDER_ACTION_PATH
                                                                                                       keyPath:@""
                                                                                                   statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_actionObjectManager addResponseDescriptor:actionResponseDescriptorStatus];
}

- (void)request
{
    [self configureActionReskit];
    
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    NSString *userId = auth.getUserId;
    
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    UITextField *textField = (UITextField *)[cell viewWithTag:1];
    
    NSDictionary *param = @{
                  API_ACTION_KEY              : API_PROCEED_SHIPPING_KEY,
                  API_ACTION_TYPE_KEY         : @"confirm",
                  API_USER_ID_KEY             : userId,
                  API_ORDER_ID_KEY            : _order.order_detail.detail_order_id,
                  API_SHIPMENT_ID_KEY         : _selectedCourier.shipment_id ?: [NSNumber numberWithInteger:_order.order_shipment.shipment_id],
                  API_SHIPMENT_NAME_KEY       : _selectedCourier.shipment_name ?: _order.order_shipment.shipment_name,
                  API_SHIPMENT_PACKAGE_ID_KEY : _selectedCourierPackage.sp_id ?: _order.order_shipment.shipment_package_id,
                  API_SHIPMENT_REF_KEY        : textField.text ?: @"",
                  };
    
    _actionRequest = [_actionObjectManager appropriateObjectRequestOperationWithObject:self
                                                                                method:RKRequestMethodPOST
                                                                                  path:API_NEW_ORDER_ACTION_PATH
                                                                            parameters:[param encrypt]];
    [_operationQueue addOperation:_actionRequest];
    
    NSLog(@"\n\n\nRequest Operation : %@\n\n\n", _actionRequest);
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                                      target:self
                                                    selector:@selector(timeout:)
                                                    userInfo:nil
                                                     repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    [_actionRequest setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self actionRequestSuccess:mappingResult withOperation:operation];
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [TPLocalytics trackShipmentConfirmation:NO];
        [self actionRequestFailure:error orderId:self.order.order_detail.detail_order_id];
        [timer invalidate];
    }];
}

- (void)actionRequestSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult *)object).dictionary;
    
    ActionOrder *actionOrder = [result objectForKey:@""];
    BOOL status = [actionOrder.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status && [actionOrder.result.is_success boolValue]) {
        [TPLocalytics trackShipmentConfirmation:YES];
        NSString *message = @"Anda telah berhasil mengkonfirmasi pengiriman barang.";
        
        StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[(message) ?: @""] delegate:self];
        [alert show];
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        
        if ([self.delegate respondsToSelector:@selector(successConfirmOrder:)]) {
            [self.delegate successConfirmOrder:self.order];
        }
        
    } else {
        [TPLocalytics trackShipmentConfirmation:NO];
        NSLog(@"\n\nRequest Message status : %@\n\n", actionOrder.message_error);
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:actionOrder.message_error
                                                                       delegate:self];
        [alert show];
    }
}

- (void)actionRequestFailure:(id)object orderId:(NSString *)orderId
{
    NSLog(@"\n\nRequest error : %@\n\n", object);
    NSString *error = [object localizedDescription];
    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[error]
                                                                   delegate:self];
    [alert show];
}

- (void)timeout:(NSTimer *)timer
{
}


#pragma mark - BarCode Delegate
- (void)didFinishScan:(NSString *)strResult
{
    if(strResult != nil) {
        strNoResi = strResult;
        [_tableView reloadData];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelCamera:(id)camera {
    
}

#pragma mark - Keyboard Notification

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardFrameBeginRect.size.height+25, 0);
}

- (void)keyboardWillHide:(NSNotification *)info {
    self.tableView.contentInset = UIEdgeInsetsZero;
}

@end