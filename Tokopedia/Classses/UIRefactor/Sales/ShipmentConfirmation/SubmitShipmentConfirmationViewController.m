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
#import "Tokopedia-Swift.h"

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
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:nil];
    self.navigationItem.backBarButtonItem = backBarButton;
}

- (void)setCancelButton {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                     style:UIBarButtonItemStylePlain
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
            cell.detailTextLabel.font = [UIFont title2Theme];
            cell.detailTextLabel.textColor = [UIColor grayColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Paket pengiriman";
            cell.detailTextLabel.text = _selectedCourierPackage.name;
            cell.detailTextLabel.font = [UIFont title2Theme];
            cell.detailTextLabel.textColor = [UIColor grayColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.font = [UIFont title2Theme];
    } else if (indexPath.section == 1) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width-15, 44)];
        textField.placeholder = @"Nomor resi";
        textField.tag = 1;
        textField.font = [UIFont title2Theme];
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
            [AnalyticsManager trackEventName:@"clickShipping" category:GA_EVENT_CATEGORY_SHIPMENT_CONFIRMATION action:GA_EVENT_ACTION_CLICK label:@"Cancel"];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else if (button.tag == 2) {
            if ([self isInstantCourier] && !_changeCourier) {
                //UIAlertView *pickupAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Dengan mengklik tombol \"Ya\", pihak kurir akan segera melakukan pickup ke tempat Anda. Tidak perlu bayar ongkir pada kurir." delegate:self cancelButtonTitle:@"Tidak" otherButtonTitles:@"Ya", nil];
                //[pickupAlert show];
                __weak typeof(self) weakSelf = self;
                UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Konfirmasi" message:@"Dengan mengklik tombol \"Ya\", pihak kurir akan segera melakukan pickup ke tempat Anda. Tidak perlu bayar ongkir pada kurir."];
                [alertView bk_addButtonWithTitle:@"Tidak" handler:nil];
                [alertView bk_addButtonWithTitle:@"Ya" handler:^{
                    [AnalyticsManager trackEventName:@"clickShipping" category:GA_EVENT_CATEGORY_SHIPMENT_CONFIRMATION action:GA_EVENT_ACTION_CLICK label:@"Confirmation"];
                    [weakSelf request];
                }];
                [alertView show];
                return;
            }
            
            UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
            UITextField *textField = (UITextField *)[cell viewWithTag:1];
            if (textField.text.length < 7 || textField.text.length > 17) {
                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Nomor resi antara 7 - 17 karakter"] delegate:self];
                [alert show];
            }else if(_selectedCourier == nil || [_selectedCourier.shipment_id isEqualToString:@""]){
                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Agen Kurir harus disi"] delegate:self];
                [alert show];
            }else{
                [AnalyticsManager trackEventName:@"clickShipping" category:GA_EVENT_CATEGORY_SHIPMENT_CONFIRMATION action:GA_EVENT_ACTION_CLICK label:@"Confirmation"];
                [self request];
            }
        }
    }
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (buttonIndex != [alertView cancelButtonIndex]){
//        [AnalyticsManager trackEventName:@"clickShipping" category:GA_EVENT_CATEGORY_SHIPMENT_CONFIRMATION action:GA_EVENT_ACTION_CLICK label:@"Confirmation"];
//        [self request];
//    }
//}

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

-(ProceedShippingObjectRequest*)proceedShippingObjectRequest{
    
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    UITextField *textField = (UITextField *)[cell viewWithTag:1];
    
    ProceedShippingObjectRequest *object = [ProceedShippingObjectRequest new];
    object.type = ProceedTypeConfirm;
    object.orderID = _order.order_detail.detail_order_id;
    object.shippingRef = textField.text;

    if (_changeCourier) {
        object.shipmentID = _selectedCourier.shipment_id;
        object.shipmentName = _selectedCourier.shipment_name;
        object.shipmentPackageID = _selectedCourierPackage.sp_id;
        _order.order_is_pickup = [self isInstantCourier] ? 0 : 1;
    }
    
    return object;
}

- (void)request {
    [ShipmentRequest fetchProceedShipping:[self proceedShippingObjectRequest] onSuccess:^{
        
        [AnalyticsManager localyticsTrackShipmentConfirmation:YES];
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        
        if ([self.delegate respondsToSelector:@selector(successConfirmOrder:)]) {
            [self.delegate successConfirmOrder:self.order];
        }
        
    } onFailure:^{
        
        [AnalyticsManager localyticsTrackShipmentConfirmation:NO];
        
    }];
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
