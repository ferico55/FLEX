//
//  SearchAutoCompleteViewController.m
//  Tokopedia
//
//  Created by Tonito Acen on 6/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "SearchAutoCompleteViewController.h"
#import "TokopediaNetworkManager.h"

@interface SearchAutoCompleteViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {

}

@property (weak, nonatomic) IBOutlet UITableView *table;

@end



@implementation SearchAutoCompleteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _searchBar.delegate = self;
    [_table setHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return @"Catalog";
    } else {
        return @"Kategori";
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    return cell;
}

#pragma mark - Search delegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if([searchText isEqualToString:@""]) {
        [_table setHidden:YES];
    } else {
        [_table reloadData];
        [_table setHidden:NO];
    }

}

#pragma mark - Network
- (void)configureRestkit {
    
}

- (void)doRequest {
    
}


@end
