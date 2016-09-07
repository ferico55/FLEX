//
//  SubmitShipmentConfirmationViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "BarCodeViewController.h"
#import "SubmitShipmentConfirmationViewController.h"
#import "GeneralTableViewController.h"
#import "StickyAlertView.h"
#import "ActionOrder.h"
#import "Order.h"
#import "OrderTransaction.h"
#import "string_order.h"

@interface SubmitShipmentConfirmationViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    GeneralTableViewControllerDelegate,
    BarCodeDelegate
>

@property BOOL changeCourier;
@property (strong, nonatomic) NSString *receiptNumber;
@property (strong, nonatomic) ShipmentCourier *selectedCourier;
@property (strong, nonatomic) ShipmentCourierPackage *selectedCourierPackage;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UILabel *footerTextLabel;

@property (strong, nonatomic) TokopediaNetworkManager *networkManager;

@end

@implementation SubmitShipmentConfirmationViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.title = @"Konfirmasi";

    [self setBackButton];
    
    [self setCancelButton];

    [self setConfirmButton];
    
    _changeCourier = NO;

    for (ShipmentCourier *courier in _shipmentCouriers) {
        if ([courier.shipment_name isEqualToString:_order.order_shipment.shipment_name]) {
            _selectedCourier = courier;
        }
    }
    
    for (ShipmentCourierPackage *package in _selectedCourier.shipment_package) {
        if ([package.sp_id isEqualToString:_order.order_shipment.shipment_package_id]) {
            _selectedCourierPackage = package;
        }
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
    
    self.networkManager = [TokopediaNetworkManager new];
    self.networkManager.isUsingHmac = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setBackButton {
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:nil];
    self.navigationItem.backBarButtonItem = backBarButton;
}

- (void)setCancelButton {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(tap:)];
    cancelButton.tag = 1;
    self.navigationItem.leftBarButtonItem = cancelButton;
}

- (void)setConfirmButton {
    NSString *title = [self isInstantCourier] ? @"Pickup" : @"Selesai";
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:title
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(tap:)];
    doneButton.tag = 2;
    self.navigationItem.rightBarButtonItem = doneButton;
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
        if ([self showsReceiptInputText] || _changeCourier) {
            rows = 1;
        }
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
        textField.text = _receiptNumber;
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
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 4.0;
        
        NSDictionary *attributes = @{
            NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:12],
            NSParagraphStyleAttributeName  : style,
            NSForegroundColorAttributeName : [UIColor grayColor],
        };
        
        _footerTextLabel.attributedText = [[NSAttributedString alloc] initWithString:_footerTextLabel.text
                                                                          attributes:attributes];
        
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
            
            if ([self isInstantCourier]) {
                [self request];
                return;
            }

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

- (void)changeSwitch:(id)sender
{
    _changeCourier = [sender isOn];
    
    NSArray *indexPaths = @[
        [NSIndexPath indexPathForRow:1 inSection:0],
        [NSIndexPath indexPathForRow:2 inSection:0],
    ];

    NSArray *indexPathsForInstantCourier = @[
        [NSIndexPath indexPathForRow:1 inSection:0],
        [NSIndexPath indexPathForRow:2 inSection:0],
        [NSIndexPath indexPathForRow:0 inSection:1],
    ];
    
    if (_changeCourier && [self.tableView numberOfRowsInSection:0] == 1) {
        if ([self isInstantCourier]) {
            [_tableView insertRowsAtIndexPaths:indexPathsForInstantCourier withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
    } else if (!_changeCourier && [self.tableView numberOfRowsInSection:0] == 3) {
        if ([self isInstantCourier]) {
            [_tableView deleteRowsAtIndexPaths:indexPathsForInstantCourier withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

#pragma mark - Resktit methods for actions

- (void)request {
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    NSString *userId = auth.getUserId;

    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    UITextField *textField = (UITextField *)[cell viewWithTag:1];

    NSDictionary *parameters;
    if (_changeCourier) {
        parameters = @{
                  API_ACTION_KEY              : API_PROCEED_SHIPPING_KEY,
                  API_ACTION_TYPE_KEY         : @"confirm",
                  API_USER_ID_KEY             : userId,
                  API_ORDER_ID_KEY            : _order.order_detail.detail_order_id,
                  API_SHIPMENT_ID_KEY         : _selectedCourier.shipment_id ?: [NSNumber numberWithInteger:_order.order_shipment.shipment_id],
                  API_SHIPMENT_NAME_KEY       : _selectedCourier.shipment_name ?: _order.order_shipment.shipment_name,
                  API_SHIPMENT_PACKAGE_ID_KEY : _selectedCourierPackage.sp_id ?: _order.order_shipment.shipment_package_id,
                  API_SHIPMENT_REF_KEY        : textField.text ?: @"",
                  };
    } else {
        parameters = @{
                  API_ACTION_KEY              : API_PROCEED_SHIPPING_KEY,
                  API_ACTION_TYPE_KEY         : @"confirm",
                  API_USER_ID_KEY             : userId,
                  API_ORDER_ID_KEY            : _order.order_detail.detail_order_id,
                  API_SHIPMENT_REF_KEY        : textField.text ?: @"",
                  };
    }
    
    [self.networkManager requestWithBaseUrl:[NSString v4Url]
                                       path:@"/v4/action/myshop-order/proceed_shipping.pl"
                                     method:RKRequestMethodPOST
                                  parameter:parameters
                                    mapping:[ActionOrder mapping]
                                  onSuccess:^(RKMappingResult *mappingResult,
                                              RKObjectRequestOperation *operation) {
                                      [self actionRequestSuccess:mappingResult];
                                  } onFailure:^(NSError *error) {
                                      [self actionRequestFailure:error];
                                  }];
}

- (void)actionRequestSuccess:(RKMappingResult *)mappingResult {
    ActionOrder *actionOrder = [mappingResult.dictionary objectForKey:@""];
    BOOL status = [actionOrder.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status && [actionOrder.result.is_success boolValue]) {
        
        NSString *message = @"Anda telah berhasil mengkonfirmasi pengiriman barang.";
    
        StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[(message) ?: @""] delegate:self];
        [alert show];

        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        
        if ([self.delegate respondsToSelector:@selector(successConfirmOrder:)]) {
            [self.delegate successConfirmOrder:self.order];
        }
        
    } else if (actionOrder.message_error.count > 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:actionOrder.message_error[0]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
        alert.delegate = self;
        [alert show];
    }
}

- (void)actionRequestFailure:(NSError *)error {
    NSLog(@"\n\nRequest error : %@\n\n", error);
    NSString *errorString = [error localizedDescription];
    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[errorString]
                                                                   delegate:self];
    [alert show];
}

#pragma mark - BarCode Delegate

- (void)didFinishScan:(NSString *)receiptNumber {
    if(receiptNumber != nil) {
        self.receiptNumber = receiptNumber;
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

#pragma mark - Methods

- (BOOL)showsReceiptInputText {
    BOOL shows = YES;
    if ([self isInstantCourier]) {
        return NO;
    }
    return shows;
}

- (BOOL)isInstantCourier {
    if (_order.order_is_pickup == 1) {
        return YES;
    } else {
        return NO;
    }
}

@end
