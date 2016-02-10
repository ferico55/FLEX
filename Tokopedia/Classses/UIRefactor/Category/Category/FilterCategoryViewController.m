//
//  FilterCategoryViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 2/10/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "FilterCategoryViewController.h"

#define cellIdentifier @"filterCategoryCell"

@interface FilterCategoryViewController ()

@property (strong, nonatomic) NSMutableArray *categories;

@end

@implementation FilterCategoryViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Pilih Kategori";
    [self setCancelButton];
    [self setDoneButton];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setCancelButton {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal" style:UIBarButtonItemStyleBordered target:self action:@selector(didTapCancelButton)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}


- (void)setDoneButton {
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Selesai" style:UIBarButtonItemStyleDone target:self action:@selector(didTapDoneButton)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)didTapCancelButton {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapDoneButton {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadData {
    NSString *str = @"https://hades.tokopedia.com/v0/categories";
    NSURL *url = [NSURL URLWithString:str];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSError *error = nil;
    id response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSArray *categories = [[response objectForKey:@"data"] objectForKey:@"categories"];
    self.categories = [NSMutableArray arrayWithArray:categories];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSDictionary *category = [self.categories objectAtIndex:indexPath.row];
    cell.textLabel.text = [category objectForKey:@"name"];
    cell.textLabel.font = [UIFont fontWithName:@"GothamBook" size:12];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *category = [self.categories objectAtIndex:indexPath.row];
    NSArray *child = [category objectForKey:@"child"];
    if (child.count > 0) {
        NSInteger row = indexPath.row + 1;
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(row, child.count)];
        [self.categories insertObjects:child atIndexes:indexSet];
        NSMutableArray *indexPathArray = [NSMutableArray new];
        NSInteger index = row;
        while (index < child.count) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [indexPathArray addObject:indexPath];
            index++;
        }
        [self.tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        
    }
}

@end
