//
//  ProductListMyShopFilterViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 4/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ProductListMyShopFilterViewController.h"
#import "GeneralTableViewController.h"

@interface ProductListMyShopFilterViewController ()
<
    GeneralTableViewControllerDelegate
>
{
    NSString *_etalaseValue;
    NSString *_categoryValue;
    NSString *_catalogValue;
    NSString *_pictureValue;
    NSString *_conditionValue;
}
@end

@implementation ProductListMyShopFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Filter";
    
    _etalaseValue = @"Semua Produk";
    _categoryValue = @"Semua Kategori";
    _catalogValue = @"Dengan & Tanpa Katalog";
    _pictureValue = @"Dengan & Tanpa Gambar";
    _conditionValue = @"Semua Kondisi";
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:nil];
    self.navigationItem.backBarButtonItem = backBarButton;
    
    UIBarButtonItem *canceBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(tap:)];
    self.navigationItem.leftBarButtonItem = canceBarButton;

    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Selesai"
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(tap:)];
    self.navigationItem.rightBarButtonItem = doneBarButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                   reuseIdentifier:nil];
    cell.textLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
    cell.detailTextLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    if (indexPath.row == 0) {
        cell.textLabel.text = @"Etalase";
        cell.detailTextLabel.text = _etalaseValue;
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"Kategori";
        cell.detailTextLabel.text = _categoryValue;
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"Katalog";
        cell.detailTextLabel.text = _catalogValue;
    } else if (indexPath.row == 3) {
        cell.textLabel.text = @"Gambar";
        cell.detailTextLabel.text = _pictureValue;
    } else if (indexPath.row == 4) {
        cell.textLabel.text = @"Kondisi";
        cell.detailTextLabel.text = _conditionValue;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
    } else if (indexPath.row == 1) {
    } else if (indexPath.row == 2) {
        GeneralTableViewController *controller = [GeneralTableViewController new];
        controller.objects = @[
                               @"Dengan & Tanpa Katalog",
                               @"Dengan Katalog",
                               @"Tanpa Katalog",
                               ];
        controller.selectedObject = _catalogValue;
        controller.senderIndexPath = indexPath;
        controller.delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.row == 3) {
        GeneralTableViewController *controller = [GeneralTableViewController new];
        controller.objects = @[
                               @"Dengan & Tanpa Gambar",
                               @"Dengan Gambar",
                               @"Tanpa Gambar",
                               ];
        controller.selectedObject = _pictureValue;
        controller.senderIndexPath = indexPath;
        controller.delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.row == 4) {
        GeneralTableViewController *controller = [GeneralTableViewController new];
        controller.objects = @[
                               @"Semua Kondisi",
                               @"Baru",
                               @"Bekas",
                               ];
        controller.selectedObject = _conditionValue;
        controller.senderIndexPath = indexPath;
        controller.delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - General table delegate

- (void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        _catalogValue = object;
    } else if (indexPath.row == 3) {
        _pictureValue = object;
    } else if (indexPath.row == 4) {
        _conditionValue = object;
    }
    [self.tableView reloadData];
}

#pragma mark - Action

- (void)tap:(id)sender
{
    
}

@end
