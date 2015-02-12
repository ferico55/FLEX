//
//  GeneralTableViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "GeneralTableViewController.h"

@interface GeneralTableViewController () {
    NSIndexPath *_selectedIndexPath;
    NSDictionary *_textAttributes;
}

@end

@implementation GeneralTableViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(tap:)];
    cancelButton.tag = 1;
    self.navigationItem.backBarButtonItem = cancelButton;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5.0;

    _textAttributes = @{
                        NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:14],
                        NSParagraphStyleAttributeName  : style,
                        };
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.delegate didSelectObject:_selectedObject senderIndexPath:_senderIndexPath];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_objects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }

    id object = [_objects objectAtIndex:indexPath.row];

    cell.textLabel.text = [object description];
    cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:[object description]
                                                                    attributes:_textAttributes];
    cell.textLabel.numberOfLines = 0;
    
    if ([object isEqual:_selectedObject]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _selectedIndexPath = indexPath;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:_selectedIndexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    _selectedObject = [_objects objectAtIndex:indexPath.row];
    _selectedIndexPath = indexPath;
    
    cell = [tableView cellForRowAtIndexPath:_selectedIndexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

#pragma mark - Actions

- (IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem *)sender;
        if (button.tag == 1) {
            [self.delegate didSelectObject:_selectedObject senderIndexPath:_senderIndexPath];
            [self.navigationController popViewControllerAnimated:YES];            
        }
    }
}

@end
