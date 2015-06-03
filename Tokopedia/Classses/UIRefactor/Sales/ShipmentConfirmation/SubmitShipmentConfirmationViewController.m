//
//  SubmitShipmentConfirmationViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "SubmitShipmentConfirmationViewController.h"
#import "GeneralTableViewController.h"
#import "StickyAlertView.h"
#import "ZBarSDK.h"
#import "ActionOrder.h"
#import "Order.h"
#import "OrderTransaction.h"
#import "string_order.h"

@interface SubmitShipmentConfirmationViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    GeneralTableViewControllerDelegate,
    ZBarReaderDelegate
>
{
    BOOL _changeCourier;
    NSString *_receiptNumber;
    ShipmentCourier *_selectedCourier;
    ShipmentCourierPackage *_selectedCourierPackage;
    ZBarReaderViewController *codeReader;
    
    NSString *strNoResi;
    BOOL _shouldReloadData;

    __weak RKObjectManager *_actionObjectManager;
    __weak RKManagedObjectRequestOperation *_actionRequest;
    RKResponseDescriptor *_responseActionDescriptorStatus;

    NSOperationQueue *_operationQueue;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SubmitShipmentConfirmationViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.title = @"Konfirmasi";

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

    _changeCourier = NO;
    _selectedCourier = [_shipmentCouriers objectAtIndex:0];
    _selectedCourierPackage = [_selectedCourier.shipment_package objectAtIndex:0];
    
    _shouldReloadData = NO;
    
    _operationQueue = [NSOperationQueue new];
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
        if (_changeCourier) {
            rows = 3;
        } else {
            rows = 1;
        }
    } else if (section == 1) {
        rows = 1;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {

            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            
            UISwitch *changeCourierSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 65, 7, 0, 0)];
            [changeCourierSwitch setOn:_changeCourier];
            [changeCourierSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:changeCourierSwitch];
            
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        }
    } else {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Perlu mengganti kurir";
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Agen kurir";
            cell.detailTextLabel.text = _selectedCourier.shipment_name;
            cell.detailTextLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
            cell.detailTextLabel.textColor = [UIColor grayColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Paket pengiriman";
            cell.detailTextLabel.text = _selectedCourierPackage.name;
            cell.detailTextLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
            cell.detailTextLabel.textColor = [UIColor grayColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
    } else if (indexPath.section == 1) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width-15, 44)];
        textField.placeholder = @"Nomor resi";
        textField.tag = 1;
        textField.font = [UIFont fontWithName:@"GothamBook" size:14];
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


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Biaya pergantian kurir ditanggung sepenuhnya oleh penjual";
    } else {
        return nil;
    }
}

#pragma mark - Table delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return NO;
    } else if (indexPath.section == 1) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row > 0) {
        GeneralTableViewController *controller = [GeneralTableViewController new];
        if (indexPath.row == 1) {
            controller.title = @"Agen Kurir";
            controller.objects = _shipmentCouriers;
            controller.selectedObject = _selectedCourier ?: [_shipmentCouriers objectAtIndex:0];
            controller.delegate = self;
            controller.senderIndexPath = indexPath;
        } else if (indexPath.row == 2) {
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
    if (indexPath.row == 1 && _selectedCourier != object) {

        _selectedCourier = object;
        _selectedCourierPackage = [[object shipment_package] objectAtIndex:0];

        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
        cell.detailTextLabel.text = [object description];
        
        cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        cell.detailTextLabel.text = _selectedCourierPackage.name;
        
    } else if (indexPath.row == 2) {
        
        _selectedCourierPackage = object;

        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
        cell.detailTextLabel.text = [object description];

    }

}


#pragma mark - UICamera Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)  break;
    
    [picker dismissViewControllerAnimated:YES completion:^(void){
        codeReader = nil;
        strNoResi = symbol.data;
        [_tableView reloadData];
    }];
}


#pragma mark - Actions
- (void)cancelCamera:(id)sender
{
    [codeReader dismissViewControllerAnimated:YES completion:^(void){
        codeReader = nil;
    }];
}

- (void)showCameraCode:(id)sender
{
    codeReader = [ZBarReaderViewController new];
    codeReader.readerDelegate=self;
    codeReader.supportedOrientationsMask = ZBarOrientationMaskAll;
    codeReader.showsZBarControls = NO;
    codeReader.showsCameraControls = NO;
    
    
    ZBarImageScanner *scanner = codeReader.scanner;
    [scanner setSymbology: ZBAR_CODE128 config: ZBAR_CFG_ENABLE to: 0];
    [scanner setSymbology: ZBAR_I25 config: ZBAR_CFG_ENABLE to: 0];
    
    [self presentViewController:codeReader animated:YES completion:^{
        UIView *overLayView = [[UIView alloc] initWithFrame:CGRectMake(0, codeReader.view.bounds.size.height-50, self.view.bounds.size.width, 50)];
        overLayView.backgroundColor = [UIColor lightGrayColor];
        
        int diameterCancel = 10;
        UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCancel.frame = CGRectMake(diameterCancel, diameterCancel, overLayView.bounds.size.height-(diameterCancel*2), overLayView.bounds.size.height-(diameterCancel*2));
        btnCancel.layer.borderColor = [btnCancel.titleLabel.textColor CGColor];
        btnCancel.layer.borderWidth = 1.0f;
        btnCancel.layer.cornerRadius = (btnCancel.bounds.size.height-diameterCancel)/2.0f;
        btnCancel.layer.masksToBounds = YES;
        [btnCancel addTarget:self action:@selector(cancelCamera:) forControlEvents:UIControlEventTouchUpInside];
        [btnCancel setTitle:@"X" forState:UIControlStateNormal];
        [overLayView addSubview:btnCancel];
        
        [codeReader.view addSubview:overLayView];
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
            if (textField.text.length >= 8 && textField.text.length <= 17) {
                [self request];
            } else {
                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Nomor resi antara 8 - 17 karakter"]
                                                                               delegate:self];
                [alert show];
            }
        }
    }
}

- (void)changeSwitch:(id)sender
{
    _changeCourier = [sender isOn];
    
    NSArray *indexPaths = @[
                            [NSIndexPath indexPathForRow:1 inSection:0],
                            [NSIndexPath indexPathForRow:2 inSection:0],
                            ];
    if (_changeCourier && [self.tableView numberOfRowsInSection:0] == 1) {
        [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    } else if (!_changeCourier && [self.tableView numberOfRowsInSection:0] == 3) {
        [_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
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
    
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *auth = [secureStorage keychainDictionary];
    
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    UITextField *textField = (UITextField *)[cell viewWithTag:1];
    
    NSDictionary *param;
    if (_changeCourier) {
        param = @{
                  API_ACTION_KEY              : API_PROCEED_SHIPPING_KEY,
                  API_ACTION_TYPE_KEY         : @"confirm",
                  API_USER_ID_KEY             : [auth objectForKey:API_USER_ID_KEY],
                  API_ORDER_ID_KEY            : _order.order_detail.detail_order_id,
                  API_SHIPMENT_REF_KEY        : textField.text ?: @"",
                  };
    } else {
        param = @{
            API_ACTION_KEY              : API_PROCEED_SHIPPING_KEY,
            API_ACTION_TYPE_KEY         : @"confirm",
            API_USER_ID_KEY             : [auth objectForKey:API_USER_ID_KEY],
            API_ORDER_ID_KEY            : _order.order_detail.detail_order_id,
            API_SHIPMENT_ID_KEY         : _selectedCourier.shipment_id ?: [NSNumber numberWithInteger:_order.order_shipment.shipment_id],
            API_SHIPMENT_NAME_KEY       : _selectedCourier.shipment_name ?: _order.order_shipment.shipment_name,
            API_SHIPMENT_PACKAGE_ID_KEY : _selectedCourierPackage.sp_id ?: _order.order_shipment.shipment_package_id,
            API_SHIPMENT_REF_KEY        : textField.text ?: @"",
        };
    }
    
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
        
        NSString *message = @"Anda telah berhasil mengkonfirmasi pengiriman barang.";
    
        StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[(message) ?: @""] delegate:self];
        [alert show];

        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        
        if ([self.delegate respondsToSelector:@selector(successConfirmOrder:)]) {
            [self.delegate successConfirmOrder:self.order];
        }
        
    } else {
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

@end
