//
//  FilterSalesTransactionListViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/5/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "FilterSalesTransactionListViewController.h"
#import "GeneralTableViewController.h"

#import "AlertDatePickerView.h"

@interface FilterSalesTransactionListViewController ()
<
    TKPDAlertViewDelegate,
    GeneralTableViewControllerDelegate
>
{
    NSString *_invoice;
    NSString *_transactionStatus;
    NSString *_startDate;
    NSString *_endDate;
}

@end

@implementation FilterSalesTransactionListViewController

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
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    
    _startDate = [dateFormatter stringFromDate:[NSDate date]];
    _endDate = [dateFormatter stringFromDate:[NSDate date]];
    
    _transactionStatus = @"Transaksi Belum Selesai";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 3;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        if (indexPath.section == 0) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width-30, 45)];
            textField.placeholder = @"Nama Pembeli / Invoice";
            textField.font = [UIFont fontWithName:@"GothamBook" size:14];
            [textField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
            [cell addSubview:textField];
        } else if (indexPath.section == 1) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            cell.textLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
            cell.detailTextLabel.font = [UIFont fontWithName:@"GothamBook" size:13];
            cell.detailTextLabel.textColor = [UIColor grayColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Status Transaksi";
                cell.detailTextLabel.text = _transactionStatus;
            } else if (indexPath.row == 1) {
                cell.textLabel.text = @"Tanggal Awal";
                cell.detailTextLabel.text = _startDate;
            } else if (indexPath.row == 2) {
                cell.textLabel.text = @"Tanggal Akhir";
                cell.detailTextLabel.text = _endDate;
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            
            GeneralTableViewController *controller = [GeneralTableViewController new];
            controller.delegate = self;
            controller.senderIndexPath = indexPath;
            controller.title = @"Status Transaksi";
            controller.objects = @[
                                   @"Transaksi Belum Selesai",
                                   @"Semua Status",
                                   @"Pesanan Baru",
                                   @"Dalam Pengiriman",
                                   @"Transaksi Resi Invalid",
                                   @"Transaksi Terkirim",
                                   @"Transaksi Selesai",
                                   @"Transaksi Dibatalkan",
                                   ];
            controller.selectedObject = _transactionStatus;
            [self.navigationController pushViewController:controller animated:YES];
            
        } else if (indexPath.row == 1) {
            
            AlertDatePickerView *datePicker = [AlertDatePickerView new];
            datePicker.delegate = self;
            datePicker.tag = 1;
            datePicker.startDate = [NSDate date];
            [datePicker show];
            
        } else if (indexPath.row == 2) {
            
            AlertDatePickerView *datePicker = [AlertDatePickerView new];
            datePicker.delegate = self;
            datePicker.tag = 2;
            datePicker.startDate = [NSDate date];
            [datePicker show];
            
        }
    }
}

#pragma mark - TKPD Alert date picker delegate
    
- (void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    AlertDatePickerView *datePicker = (AlertDatePickerView *)alertView;
    NSDate *date = [datePicker.data objectForKey:kTKPDALERTVIEW_DATADATEPICKERKEY];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    
    if (datePicker.tag == 1) {
        
        _startDate = [dateFormatter stringFromDate:date];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        cell.detailTextLabel.text = _startDate;
        
    } else {
        
        _endDate = [dateFormatter stringFromDate:date];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]];
        cell.detailTextLabel.text = _endDate;
        
    }
}

#pragma mark - General table view controller delegate

- (void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath
{
    _transactionStatus = object;
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    cell.detailTextLabel.text = object;
}

- (IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem *)sender;
        if (button.tag == 2) {
            
            NSString *status = @"";
            if ([_transactionStatus isEqualToString:@"Semua Status"]) {
                status = @"9";
            } else if ([_transactionStatus isEqualToString:@"Pesanan Baru"]) {
                status = @"1";
            } else if ([_transactionStatus isEqualToString:@"Dalam Pengiriman"]) {
                status = @"2";
            } else if ([_transactionStatus isEqualToString:@"Transaksi Resi Invalid"]) {
                status = @"6";
            } else if ([_transactionStatus isEqualToString:@"Transaksi Terkirim"]) {
                status = @"7";
            } else if ([_transactionStatus isEqualToString:@"Transaksi Selesai"]) {
                status = @"3";
            } else if ([_transactionStatus isEqualToString:@"Transaksi Dibatalkan"]) {
                status = @"4";
            }
            
            [self.delegate filterOrderInvoice:_invoice
                            transactionStatus:status
                                    startDate:_startDate
                                      endDate:_endDate];
        }
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Text field delegate

- (void)textFieldValueChanged:(UITextField *)textField
{
    _invoice = textField.text;
}

@end