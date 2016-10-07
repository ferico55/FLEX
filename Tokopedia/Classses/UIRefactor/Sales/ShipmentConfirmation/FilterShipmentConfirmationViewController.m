//
//  FilterShipmentConfirmationViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "FilterShipmentConfirmationViewController.h"
#import "GeneralTableViewController.h"

@interface FilterShipmentConfirmationViewController () <GeneralTableViewControllerDelegate> {
    NSString *_invoice;
    NSString *_dueDate;
    NSString *_courier;
    ShipmentCourier *_selectedCourier;
}

@end

@implementation FilterShipmentConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Filter";
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(tap:)];
    cancelButton.tag = 1;
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Selesai"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(tap:)];
    doneButton.tag = 2;
    self.navigationItem.rightBarButtonItem = doneButton;

    _invoice = @"";
    _dueDate = @"Pilih";
    _courier = @"Pilih";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if (section == 0) {
        rows = 1;
    } else if (section == 1) {
        rows = 2;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        if (indexPath.section == 0) {

            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width-30, 45)];
            textField.placeholder = @"Nama Penerima / Invoice";
            textField.font = [UIFont title2Theme];
            [textField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
            [cell addSubview:textField];
            
        } else if (indexPath.section == 1) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            cell.textLabel.font = [UIFont title2Theme];
            cell.detailTextLabel.font = [UIFont title2Theme];
            cell.detailTextLabel.textColor = [UIColor grayColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        cell.textLabel.text = @"Jatuh tempo";
        cell.detailTextLabel.text = _dueDate;
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        cell.textLabel.text = @"Kurir";
        cell.detailTextLabel.text = _courier;
    }
    
    return cell;
}
 
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GeneralTableViewController *controller = [GeneralTableViewController new];
    controller.delegate = self;
    controller.senderIndexPath = indexPath;
    if (indexPath.section == 1 && indexPath.row == 0) {
        controller.title = @"Jatuh Tempo";
        controller.objects = @[
                               @"Pilih",
                               @"Hari ini",
                               @"Besok",
                               @"2 Hari",
                               @"3 Hari",
                               @"4 Hari",
                               @"5 Hari",
                               @"6 Hari"
                               ];
        controller.selectedObject = _dueDate;
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        controller.title = @"Agen Kurir";
        controller.objects = _couriers;
        controller.selectedObject = _selectedCourier ?: [_couriers objectAtIndex:0];
    }
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Text field method

- (void)textFieldValueChanged:(UITextField *)textField
{
    _invoice = textField.text;
}

#pragma mark - Actions

- (IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem *)sender;
        if (button.tag == 2) {
            NSString *dueDate;
            if ([_dueDate isEqualToString:@"Hari ini"]) dueDate = @"1";
            else if ([_dueDate isEqualToString:@"Besok"]) dueDate = @"2";
            else if ([_dueDate isEqualToString:@"2 Hari"]) dueDate = @"3";
            else if ([_dueDate isEqualToString:@"3 Hari"]) dueDate = @"4";
            else if ([_dueDate isEqualToString:@"4 Hari"]) dueDate = @"5";
            else if ([_dueDate isEqualToString:@"5 Hari"]) dueDate = @"6";
            else if ([_dueDate isEqualToString:@"6 Hari"]) dueDate = @"7";
            [self.delegate filterShipmentInvoice:_invoice
                                         dueDate:dueDate
                                         courier:_selectedCourier];
        }
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - General table view controller delegate

- (void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = [object description];
    if (indexPath.row == 0) {
        _dueDate = object;
    } else if (indexPath.row == 1) {
        _selectedCourier = object;
    }
}

@end
