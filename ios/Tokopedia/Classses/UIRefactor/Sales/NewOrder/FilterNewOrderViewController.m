//
//  FilterNewOrderViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "FilterNewOrderViewController.h"
#import "DueDateViewController.h"

@interface FilterNewOrderViewController ()

@property (weak, nonatomic) IBOutlet UITextField *invoiceTextField;
@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;

@end

@implementation FilterNewOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!_dueDate || [_dueDate isEqualToString:@""]) _dueDate = @"0";
    self.invoiceTextField.text = _filter;

    NSString *dueDate = @"Pilih";
    if ([_dueDate isEqualToString:@"3"]) {
        dueDate = @"Hari Ini";
    } else if ([_dueDate isEqualToString:@"2"]) {
        dueDate = @"Besok";
    } else if ([_dueDate isEqualToString:@"1"]) {
        dueDate = @"2 Hari";
    }
    
    self.dueDateLabel.text = dueDate;
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

        NSString *dueDate = @"Pilih";
        if ([_dueDate isEqualToString:@"3"]) {
            dueDate = @"Hari Ini";
        } else if ([_dueDate isEqualToString:@"2"]) {
            dueDate = @"Besok";
        } else if ([_dueDate isEqualToString:@"1"]) {
            dueDate = @"2 Hari";
        }

        DueDateViewController *controller = segue.destinationViewController;
        controller.delegate = self;
        controller.dueDate = dueDate;
    }
}

- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *barButton = (UIBarButtonItem *)sender;
        if (barButton.tag == 2) {
            [self.delegate didFinishFilterInvoice:_invoiceTextField.text?:@"" dueDate:_dueDate];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Due date delegate

- (void)didSelectDueDate:(NSString *)dueDate
{
    if ([dueDate isEqualToString:@"Hari Ini"]) {
        _dueDate = @"3";
    } else if ([dueDate isEqualToString:@"Besok"]) {
        _dueDate = @"2";
    } else if ([dueDate isEqualToString:@"2 Hari"]) {
        _dueDate = @"1";
    } else {
        _dueDate = @"0";
    }
  
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    cell.detailTextLabel.text = dueDate;
    
    if ([dueDate isEqualToString:@"Pilih"]) {
        cell.detailTextLabel.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1];
    } else {
        cell.detailTextLabel.textColor = [UIColor colorWithRed:10.0/255.0 green:126.0/255.0 blue:7.0/255.0 alpha:1];
    }
}

@end
