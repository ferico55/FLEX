//
//  ProductListMyShopFilterViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 4/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "category.h"

#import "ProductListMyShopFilterViewController.h"
#import "GeneralTableViewController.h"
#import "EtalaseViewController.h"
#import "CategoryMenuViewController.h"

@interface ProductListMyShopFilterViewController ()
<
    GeneralTableViewControllerDelegate,
    CategoryMenuViewDelegate,
EtalaseViewControllerDelegate
>
{
    EtalaseList *_etalase;
    Breadcrumb *_department;
    NSString *_departmentName;
    NSString *_catalogValue;
    NSString *_pictureValue;
    NSString *_conditionValue;
}
@end

@implementation ProductListMyShopFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Filter";
    
    _departmentName = _breadcrumb.department_name?:@"Semua Kategori";
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
    canceBarButton.tag = 10;
    self.navigationItem.leftBarButtonItem = canceBarButton;

    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Selesai"
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(tap:)];
    doneBarButton.tag = 11;
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
        cell.detailTextLabel.text = _etalase.etalase_name?:@"Semua Produk";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"Kategori";
        cell.detailTextLabel.text = _breadcrumb.department_name?:@"Semua Kategori";
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
        EtalaseViewController *vc = [EtalaseViewController new];
        vc.delegate = self;
        vc.isEditable = NO;
        vc.showOtherEtalase = YES;
        vc.initialSelectedEtalase = _etalase;
        
        [vc setShopId:_shopID];
        [self.navigationController pushViewController:vc animated:YES];
        
        
    } else if (indexPath.row == 1) {
        CategoryMenuViewController *controller = [CategoryMenuViewController new];
        controller.delegate = self;
        controller.data = @{
                            DATA_CATEGORY_MENU_PREVIOUS_VIEW_TYPE:@(CATEGORY_MENU_PREVIOUS_VIEW_ADD_PRODUCT)
                            };
        controller.selectedCategoryID = [_breadcrumb.department_id integerValue];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
        nav.navigationBar.translucent = NO;
        
        [self.navigationController presentViewController:nav animated:YES completion:nil];
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
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem *)sender;
        if (button.tag == 10) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else if (button.tag == 11) {
            if ([self.delegate respondsToSelector:@selector(filterProductEtalase:department:catalog:picture:condition:)]) {
                
                NSString *catalogValueID = @"";
                NSString *pictureValueID = @"";
                NSString *conditionValueID = @"";

                if ([_catalogValue isEqualToString:@"Dengan Katalog"]) {
                    catalogValueID = @"1";
                } else if ([_catalogValue isEqualToString:@"Tanpa Katalog"]) {
                    catalogValueID = @"2";
                }
                
                if ([_pictureValue isEqualToString:@"Dengan Gambar"]) {
                    pictureValueID = @"1";
                } else if ([_pictureValue isEqualToString:@"Tanpa Gambar"]) {
                    pictureValueID = @"2";
                }
                
                if ([_conditionValue isEqualToString:@"Baru"]) {
                    conditionValueID = @"1";
                } else if ([_conditionValue isEqualToString:@"Bekas"]) {
                    conditionValueID = @"2";
                }
                
                [self.delegate filterProductEtalase:_etalase
                                         department:_breadcrumb
                                            catalog:catalogValueID
                                            picture:pictureValueID
                                          condition:conditionValueID];
            }
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark - Myshop etalase filter delegate

-(void)didSelectEtalase:(EtalaseList *)selectedEtalase{
    _etalase = selectedEtalase;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.detailTextLabel.text = _etalase.etalase_name;
}


#pragma mark - Category menu delegate

-(void)CategoryMenuViewController:(CategoryMenuViewController *)viewController userInfo:(NSDictionary *)userInfo
{
    NSString * departmentID = [userInfo objectForKey:kTKPDCATEGORY_DATADEPARTMENTIDKEY];
    _departmentName = [userInfo objectForKey:kTKPDCATEGORY_DATATITLEKEY];
    
    _breadcrumb.department_name = _departmentName;
    _breadcrumb.department_id = departmentID;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    cell.detailTextLabel.text = _departmentName;
}
@end
