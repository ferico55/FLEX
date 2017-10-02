//
//  FilterSalesTransactionListViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/5/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "FilterSalesTransactionListViewController.h"
#import "GeneralTableViewController.h"
#import "Tokopedia-Swift.h"

#import "AlertDatePickerView.h"
#import "string_alert.h"

#define ARRAY_FILTER_TRANSACTION @[@"Semua Status",@"Konfirmasi Pembayaran",@"Verifikasi Pembayaran",@"Dalam Proses",@"Dalam Pengiriman",@"Transaksi Terkirim",@"Transaksi Selesai",@"Transaksi Dibatalkan"]

@interface FilterSalesTransactionListViewController ()
<
    TKPDAlertViewDelegate,
    GeneralTableViewControllerDelegate
>
{
    NSString *_invoice;
    NSString *_transactionStatus;
    NSDate *_startDate;
    NSDate *_endDate;
    NSString *_startDateString;
    NSString *_endDateString;
}

@end

@implementation FilterSalesTransactionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Filter";
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(tap:)];
    cancelButton.tag = 1;
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Selesai"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(tap:)];
    doneButton.tag = 2;
    self.navigationItem.rightBarButtonItem = doneButton;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    
    _startDate = _startDate?:[[NSDate date] dateByAddingTimeInterval:-30*24*60*60];
    _endDate = _endDate?:[NSDate date];
    _startDateString = [dateFormatter stringFromDate:_startDate];
    _endDateString = [dateFormatter stringFromDate:_endDate];
    
    if (_isOrderTransaction) {
        _startDate = (![_startDateMark isEqualToString:@""])?[dateFormatter dateFromString:_startDateMark]:[[NSDate date] dateByAddingTimeInterval:-30*24*60*60];
        _startDateString = [dateFormatter stringFromDate:_startDate];
        _endDate = [dateFormatter dateFromString:_endDateMark];
        _endDateString = (![_endDateMark isEqualToString:@""])?_endDateMark:[dateFormatter stringFromDate:[NSDate date]];
    }
    
    _transactionStatus = @"Transaksi Belum Selesai";
    
    if (_isOrderTransaction) {
        if ([_transactionStatusMark isEqualToString:@"0"]) {
            _transactionStatus = @"Semua Status";
        } else if ([_transactionStatusMark isEqualToString:@"1"]) {
            _transactionStatus = @"Konfirmasi Pembayaran";
        } else if ([_transactionStatusMark isEqualToString:@"2"]) {
            _transactionStatus = @"Verifikasi Pembayaran";
        } else if ([_transactionStatusMark isEqualToString:@"8"]) {
            _transactionStatus = @"Dalam Proses";
        } else if ([_transactionStatusMark isEqualToString:@"3"]) {
            _transactionStatus = @"Dalam Pengiriman";
        } else if ([_transactionStatusMark isEqualToString:@"9"]) {
            _transactionStatus = @"Transaksi Terkirim";
        } else if ([_transactionStatusMark isEqualToString:@"4"]) {
            _transactionStatus = @"Transaksi Selesai";
        } else if ([_transactionStatusMark isEqualToString:@"5"]) {
            _transactionStatus = @"Transaksi Dibatalkan";
        } else {
            _transactionStatus = @"Semua Status";
        }
    } 
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(tap:)];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
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
            textField.placeholder = _isOrderTransaction?@"Nama Penerima / Invoice":@"Nama Pembeli / Invoice";
            textField.text = _invoiceMark?_invoiceMark:@"";
            textField.font = [UIFont title2Theme];
            [textField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
            [cell addSubview:textField];
        } else if (indexPath.section == 1) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            cell.textLabel.font = [UIFont title2Theme];
            cell.detailTextLabel.font = [UIFont title2Theme];
            cell.detailTextLabel.textColor = [UIColor grayColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Status Transaksi";
                cell.detailTextLabel.text = _transactionStatus;
            } else if (indexPath.row == 1) {
                cell.textLabel.text = @"Tanggal Awal";
                cell.detailTextLabel.text = _startDateString;
            } else if (indexPath.row == 2) {
                cell.textLabel.text = @"Tanggal Akhir";
                cell.detailTextLabel.text = _endDateString;
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

            if (_isOrderTransaction) {
                controller.objects = ARRAY_FILTER_TRANSACTION;
            }
            
            controller.selectedObject = _transactionStatus;
            [self.navigationController pushViewController:controller animated:YES];
            
        } else if (indexPath.row == 1) {
            
            AlertDatePickerView *datePicker = [AlertDatePickerView new];
            datePicker.delegate = self;
            datePicker.tag = 1;
            datePicker.currentdate = _startDate;
            [datePicker show];
            
        } else if (indexPath.row == 2) {
            
            AlertDatePickerView *datePicker = [AlertDatePickerView new];
            datePicker.delegate = self;
            datePicker.tag = 2;
            datePicker.currentdate = _endDate;
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

        _startDate = date;
        _startDateString = [dateFormatter stringFromDate:date];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        cell.detailTextLabel.text = _startDateString;
        
    } else {
        
        _endDate = date;
        _endDateString = [dateFormatter stringFromDate:date];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]];
        cell.detailTextLabel.text = _endDateString;
        
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
            if ([_startDate compare:_endDate] == NSOrderedDescending) {
                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Tanggal awal harus sebelum tanggal akhir."] delegate:self];
                [alert show];
            } else {
                NSString *status = @"";
                if (_isOrderTransaction) {
                    if ([_transactionStatus isEqualToString:ARRAY_FILTER_TRANSACTION[0]]) {
                        status = @"0";
                    } else if ([_transactionStatus isEqualToString:ARRAY_FILTER_TRANSACTION[1]]) {
                        status = @"1";
                    } else if ([_transactionStatus isEqualToString:ARRAY_FILTER_TRANSACTION[2]]) {
                        status = @"2";
                    } else if ([_transactionStatus isEqualToString:ARRAY_FILTER_TRANSACTION[3]]) {
                        status = @"8";
                    } else if ([_transactionStatus isEqualToString:ARRAY_FILTER_TRANSACTION[4]]) {
                        status = @"3";
                    } else if ([_transactionStatus isEqualToString:ARRAY_FILTER_TRANSACTION[5]]) {
                        status = @"9";
                    } else if ([_transactionStatus isEqualToString:ARRAY_FILTER_TRANSACTION[6]]) {
                        status = @"4";
                    } else if ([_transactionStatus isEqualToString:ARRAY_FILTER_TRANSACTION[7]]) {
                        status = @"5";
                    }
                } else {
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
                }
                [self.delegate filterOrderInvoice:_invoice
                                transactionStatus:status
                                        startDate:_startDateString
                                          endDate:_endDateString];
                
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }
        } else {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
        
    }
}

#pragma mark - Text field delegate

- (void)textFieldValueChanged:(UITextField *)textField
{
    _invoice = textField.text;
}

@end
