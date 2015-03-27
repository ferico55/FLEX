//
//  FilterNewOrderViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "FilterNewOrderViewController.h"
#import "DueDateViewController.h"

@interface FilterNewOrderViewController () <DueDateDelegate> {
    NSString *_dueDate;
}

@property (weak, nonatomic) IBOutlet UITextField *invoiceTextField;

@end

@implementation FilterNewOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dueDate = @"Pilih";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SelectDueDate"]) {
        DueDateViewController *controller = segue.destinationViewController;
        controller.delegate = self;
        controller.dueDate = _dueDate;
    }
}

- (IBAction)tap:(id)sender {
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *barButton = (UIBarButtonItem *)sender;
        if (barButton.tag == 2) {
            NSString *deadline = @"0";
            if ([_dueDate isEqualToString:@"Hari Ini"]) {
                deadline = @"4";
            } else if ([_dueDate isEqualToString:@"Besok"]) {
                deadline = @"3";
            } else if ([_dueDate isEqualToString:@"2 Hari"]) {
                deadline = @"2";
            } else if ([_dueDate isEqualToString:@"3 Hari"]) {
                deadline = @"1";
            }
            [self.delegate didFinishFilterInvoice:_invoiceTextField.text?:@"" dueDate:deadline];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Due date delegate

- (void)didSelectDueDate:(NSString *)dueDate
{
    _dueDate = dueDate;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    cell.detailTextLabel.text = _dueDate;
    
    if ([_dueDate isEqualToString:@"Pilih"]) {
        cell.detailTextLabel.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1];
    } else {
        cell.detailTextLabel.textColor = [UIColor colorWithRed:10.0/255.0 green:126.0/255.0 blue:7.0/255.0 alpha:1];
    }
}

@end
