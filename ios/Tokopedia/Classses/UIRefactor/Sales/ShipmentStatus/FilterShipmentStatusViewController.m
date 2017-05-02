//
//  FilterShipmentStatusViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "FilterShipmentStatusViewController.h"

@interface FilterShipmentStatusViewController () {
    NSString *_invoice;
}

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {

        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        
        CGRect frame = CGRectMake(15, 0, self.view.frame.size.width-30, 45);
        UITextField *textField = [[UITextField alloc] initWithFrame:frame];
        textField.placeholder = @"Invoice / Nama Pembeli / Nomor Resi";
        textField.font = [UIFont largeTheme];
        [textField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
        [textField becomeFirstResponder];
        [cell addSubview:textField];

    }
    return cell;
}

#pragma mark - Text field method

- (void)textFieldValueChanged:(UITextField *)textField
{
    _invoice = textField.text;
}

#pragma mark - Action

- (IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem *)sender;
        if (button.tag == 1) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else if (button.tag == 2) {
            if (_invoice.length > 2) {
                [self.delegate filterShipmentStatusInvoice:_invoice];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            } else {
                NSString *message = @"Search Keyword terlalu pendek, minimum 3 karakter";
                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[message] delegate:self];
                [alert show];
            }
        }
    }
}

@end
