//
//  FilterCategoryViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 2/10/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "FilterCategoryViewController.h"

#define cellIdentifier @"filterCategoryCell"

@interface FilterCategoryViewController () <TokopediaNetworkManagerDelegate>

@property (strong, nonatomic) NSMutableArray *categories;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

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
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.delegate = self;
    [networkManager doRequest];
    
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
    NSInteger tree = [[category objectForKey:@"tree"] integerValue];
    cell.textLabel.text = [category objectForKey:@"name"];
    cell.textLabel.font = [UIFont fontWithName:@"GothamBook" size:12];
    cell.indentationLevel = tree;
    if ([self.selectedIndexPath isEqual:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *category = [self.categories objectAtIndex:indexPath.row];

    NSArray *child = [category objectForKey:@"child"];
    if (child.count > 0) {
        [self.categories removeObjectsInArray:child];
    }
    
    NSInteger row = indexPath.row + 1;
    NSRange range = NSMakeRange(row, child.count);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.categories insertObjects:child atIndexes:indexSet];
    
    self.selectedIndexPath = indexPath;
    [self.tableView reloadData];
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//
//    if (self.selectedIndexPath) {
//        UITableViewCell *previousCell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
//        previousCell.accessoryType = UITableViewCellAccessoryNone;
//    }
//    
//    UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
//    currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
//    
//    NSDictionary *category = [self.categories objectAtIndex:indexPath.row];
//    NSArray *child = [category objectForKey:@"child"];
//    // sebelumnya sudah klik kategori
//    if (self.selectedCategory) {
//        // klik kategory yg sama
//        if ([self.selectedCategory isEqual:category]) {
//            // deselect level 1 atau 2
//            if (child.count > 0) {
//                if ([[self.selectedCategory objectForKey:@"id"] isEqualToString:[category objectForKey:@"id"]]) {
//                    [self showCategories:child afterIndexPath:indexPath];
//                } else {
//                    [self hideCategories:child afterIndexPath:indexPath];
//                }
//            }
//            // deselect level 3
//            else {
//                // ga usah ngapa2in
//            }
//        }
//        // klik beda category
//        else {
//            if (child.count > 0) {
//                NSString *previousSelectedCategoryId = [self.selectedCategory objectForKey:@"id"];
//                NSString *selectedParentId = [[category objectForKey:@"parent"] stringValue];
//                if ([previousSelectedCategoryId isEqualToString:selectedParentId]) {
//                    [self showCategories:child afterIndexPath:indexPath];
//                } else {
//                    [self hideCategories:[self.selectedCategory objectForKey:@"child"] afterIndexPath:self.selectedIndexPath];
//                    self.selectedCategory = category;
//                    self.selectedIndexPath = indexPath;
//                    [self showCategories:child afterIndexPath:indexPath];
//                }
//            } else {
//                
//            }
//        }
//    }
//    // belum ada kategori yg di klik
//    else {
//        // select category di level 1 atau 2
//        if (child.count > 0) {
//            [self showCategories:child afterIndexPath:indexPath];
//        }
//        // select category terakhir
//        else {
//            // ga usah ngapa2in
//        }
//    }
//    self.selectedCategory = category;
//    self.selectedIndexPath = indexPath;
//}

//- (void)showCategories:(NSArray *)categories afterIndexPath:(NSIndexPath *)indexPath {
//    NSInteger row = indexPath.row + 1;
//    NSRange range = NSMakeRange(row, categories.count);
//    // insert objects
//    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
//    [self.categories insertObjects:categories atIndexes:indexSet];
//    // insert rows animation
////    NSArray *indexPathArray = [self indexPathsFromRange:range];
////    [self.tableView beginUpdates];
////    [self.tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationAutomatic];
////    [self.tableView endUpdates];
//    [self.tableView reloadData];
//}
//
//- (void)hideCategories:(NSArray *)categories afterIndexPath:(NSIndexPath *)indexPath {
//    // remove objects
//    [self.categories removeObjectsInArray:categories];
//    // remove rows animations
////    NSInteger row = indexPath.row + 1;
////    NSArray *indexPathArray = [self indexPathsFromRange:NSMakeRange(row, categories.count)];
////    [self.tableView beginUpdates];
////    [self.tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationAutomatic];
////    [self.tableView endUpdates];
//    [self.tableView reloadData];
//}
//
//- (NSArray *)indexPathsFromRange:(NSRange)range {
//    NSMutableArray *indexArray = [NSMutableArray new];
//    NSInteger location = range.location;
//    NSInteger length = range.length;
//    while (location <= length) {
//        [indexArray addObject:[NSIndexPath indexPathForRow:location inSection:0]];
//        location++;
//    }
//    return indexArray;
//}

@end
