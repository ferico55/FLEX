//
//  FilterShipmentStatusViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "FilterShipmentStatusViewController.h"
#import "AlertDatePickerView.h"
#import "string_alert.h"

@interface FilterShipmentStatusViewController ()
<
    TKPDAlertViewDelegate,
    UITableViewDataSource,
    UITableViewDelegate
>
{
    NSString *_invoice;
    NSString *_transactionStatus;
    NSString *_startDate;
    NSString *_endDate;
    
    NSArray *_status;
}

@property (weak, nonatomic) IBOutlet UILabel *transactionStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *endDateLabel;

@end

@implementation FilterShipmentStatusViewController

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
    
    _status = @[@"Semua Status",
                @"Transaksi Belum Selesai",
                @"Pesanan Baru",
                @"Dalam Pengiriman",
                @"Transaksi Terkirim",
                @"Transaksi Selesai",
                @"Transaksi Dibatalkan"];
    
    _transactionStatus = @"Semua Status";

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];

    _startDateLabel.text = [dateFormatter stringFromDate:[NSDate date]];
    _startDate = [dateFormatter stringFromDate:[NSDate date]];

    _endDateLabel.text = [dateFormatter stringFromDate:[NSDate date]];
    _endDate = [dateFormatter stringFromDate:[NSDate date]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        if (button.tag == 1) {
            
            UITableViewController *controller = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            controller.title = @"Status Transaksi";
            controller.tableView.dataSource = self;
            controller.tableView.delegate = self;
            controller.tableView.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1];
            
            [self.navigationController pushViewController:controller animated:YES];
            
        } else if (button.tag == 2) {

            AlertDatePickerView *datePicker = [AlertDatePickerView new];
            datePicker.delegate = self;
            datePicker.tag = 1;
            datePicker.startDate = [NSDate date];
            [datePicker show];

        } else if (button.tag == 3) {

            AlertDatePickerView *datePicker = [AlertDatePickerView new];
            datePicker.delegate = self;
            datePicker.tag = 2;
            datePicker.startDate = [NSDate date];
            [datePicker show];

        }
    } else if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem *)sender;
        if (button.tag == 2){
            [self.delegate didFinishFilterInvoice:_invoice
                                transactionStatus:_transactionStatus
                                        startDate:_startDate
                                          endDate:_endDate];
        }
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - TKPDAlertView delegate

- (void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    AlertDatePickerView *datePicker = (AlertDatePickerView *)alertView;
    NSDate *date = [datePicker.data objectForKey:kTKPDALERTVIEW_DATADATEPICKERKEY];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    
    if (datePicker.tag == 1) {
        _startDateLabel.text = [dateFormatter stringFromDate:date];
    } else {
        _endDateLabel.text = [dateFormatter stringFromDate:date];
    }
}

#pragma mark - Date transaction table data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    
    cell.textLabel.text = [_status objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"GothamBook" size:14];

    cell.tintColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];

    if ([cell.textLabel.text isEqualToString:_transactionStatus]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

#pragma mark - Date transaction table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    _transactionStatusLabel.text = cell.textLabel.text;
    _transactionStatus = cell.textLabel.text;
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
