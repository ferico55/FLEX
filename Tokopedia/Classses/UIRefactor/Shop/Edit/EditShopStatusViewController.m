//
//  EditShopStatusViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 3/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "EditShopStatusViewController.h"
#import "EditShopNoteViewCell.h"

@interface EditShopStatusViewController ()

@end

@implementation EditShopStatusViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Status Toko";
        self.navigationItem.rightBarButtonItem = self.doneButton;
        self.tableView.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1];
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerNib];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)registerNib {
    [self.tableView registerNib:[UINib nibWithNibName:@"EditShopNoteViewCell" bundle:nil] forCellReuseIdentifier:@"note"];
}

#pragma mark - Bar button item

- (UIBarButtonItem *)doneButton {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Selesai" style:UIBarButtonItemStyleDone target:self action:@selector(didTapDoneButton:)];
    return button;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.shop.isClosed) {
        return 3;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return 120;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [self statusViewCellForRowAtIndexPath:indexPath];
    } else if (indexPath.section == 1) {
        cell = [self noteViewCellForRowAtIndexPath:indexPath];
    } else if (indexPath.section == 2) {
        cell = [self dateViewCellForRowAtIndexPath:indexPath];
    }
    return cell;
}

- (UITableViewCell *)statusViewCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"status"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"status"];
        cell.textLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.tintColor = [UIColor colorWithRed:66.0/255.0 green:189.0/255.0 blue:65.0/255.0 alpha:1];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Buka";
    } else {
        cell.textLabel.text = @"Tutup";
    }
    return cell;
}

- (EditShopNoteViewCell *)noteViewCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EditShopNoteViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"note"];
    return cell;
}

- (UITableViewCell *)dateViewCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"date"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"date"];
        cell.textLabel.text = @"Tutup Sampai";
        cell.textLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
        cell.detailTextLabel.font = [UIFont fontWithName:@"GothamMedium" size:14];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:66.0/255.0 green:189.0/255.0 blue:65.0/255.0 alpha:1];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        self.shop.isClosed = NO;
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)];
        [tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (indexPath.row == 1) {
        self.shop.isClosed = YES;
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)];
        [tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Action

- (void)didTapDoneButton:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
