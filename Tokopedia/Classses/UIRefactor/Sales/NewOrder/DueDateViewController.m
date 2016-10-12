//
//  DueDateViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "DueDateViewController.h"

@interface DueDateViewController () {
    NSIndexPath *_selectedIndexPath;
}

@end

@implementation DueDateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Pilih"
                                                               style:UIBarButtonItemStyleDone
                                                              target:self
                                                              action:@selector(tap:)];
    button.tag = 1;
    self.navigationItem.rightBarButtonItem = button;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell.textLabel.text isEqualToString:_dueDate]) {
        _selectedIndexPath = indexPath;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    _dueDate = cell.textLabel.text;
    
    _selectedIndexPath = indexPath;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
}

- (void)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem *)sender;
        if (button.tag == 1) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_selectedIndexPath];
            [self.delegate didSelectDueDate:cell.textLabel.text];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

@end
