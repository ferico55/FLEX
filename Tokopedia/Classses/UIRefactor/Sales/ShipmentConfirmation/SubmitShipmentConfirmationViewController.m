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
    NSInteger rows;
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
            if (textField.text.length >= 9 && textField.text.length <= 17) {
                if (_changeCourier) {
                    [self.delegate submitConfirmationReceiptNumber:textField.text
                                                           courier:_selectedCourier
                                                    courierPackage:_selectedCourierPackage];
                } else {
                    [self.delegate submitConfirmationReceiptNumber:textField.text
                                                           courier:nil
                                                    courierPackage:nil];
                }
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            } else {
                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Nomor resi antara 9 - 17 karakter"]
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
    if (_changeCourier) {
        [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
