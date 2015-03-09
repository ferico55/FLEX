//
//  GeneralTableViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "GeneralTableViewController.h"

@interface GeneralTableViewController ()
<
    UISearchBarDelegate
>
{
    NSIndexPath *_selectedIndexPath;
    NSDictionary *_textAttributes;
    NSMutableArray *_searchResults;
    NSMutableArray *_searchContents;

    UISearchBar *_searchBar;
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
    
    if (!_tableViewCellStyle) {
        _tableViewCellStyle = UITableViewCellStyleDefault;
    }
    
    if (_enableSearch) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        _searchBar.placeholder = @"Search";
        _searchBar.delegate = self;
        self.tableView.tableHeaderView = _searchBar;

        if (_tableViewCellStyle == UITableViewCellStyleSubtitle) {
            _searchContents = [NSMutableArray new];
            for (NSArray *array in _objects) {
                [_searchContents addObject:[array objectAtIndex:0]];
            }
        } else if (_tableViewCellStyle == UITableViewCellStyleDefault) {
            _searchContents = [NSMutableArray arrayWithArray:_objects];
        }
        
        _searchResults = [NSMutableArray new];
    }
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
    if (_searchBar.text.length > 0) {
        return [_searchResults count];
    }
    return [_objects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:_tableViewCellStyle reuseIdentifier:nil];
    }

    id object;
    
    if (_searchBar.text.length > 0) {
        object = [_searchResults objectAtIndex:indexPath.row];
    } else {
        object = [_objects objectAtIndex:indexPath.row];
    }
    
    if (_tableViewCellStyle == UITableViewCellStyleDefault) {
        cell.textLabel.text = [object description];
        cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:[object description]
                                                                        attributes:_textAttributes];
        cell.textLabel.numberOfLines = 0;
    }
    
    else if (_tableViewCellStyle == UITableViewCellStyleSubtitle) {
        if ([object isKindOfClass:[NSArray class]]) {
            cell.textLabel.text = [object objectAtIndex:0];
            cell.textLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
            
            cell.detailTextLabel.text = [object objectAtIndex:1];
            cell.detailTextLabel.font = [UIFont fontWithName:@"GothamBook" size:12];
            cell.detailTextLabel.textColor = [UIColor grayColor];
        }
    }
    
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

#pragma mark - Search bar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchText];
    if (_tableViewCellStyle == UITableViewCellStyleDefault) {
        _searchResults = [NSMutableArray arrayWithArray:[_searchContents filteredArrayUsingPredicate:resultPredicate]];
    } else if (_tableViewCellStyle == UITableViewCellStyleSubtitle) {
        NSArray *searchResult = [_searchContents filteredArrayUsingPredicate:resultPredicate];
        _searchResults = [NSMutableArray new];
        for (NSString *result in searchResult) {
            for (NSArray *arary in _objects) {
                if ([[arary objectAtIndex:0] isEqualToString:result]) {
                    [_searchResults addObject:arary];
                }
            }
        }
    }
    [self.tableView reloadData];
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
