//
//  FilterCatalogViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "FilterCatalogViewController.h"
#import "GeneralTableViewController.h"

@interface FilterCatalogViewController () <GeneralTableViewControllerDelegate> {
    NSString *_conditionValue;
    NSString *_locationValue;
}

@end

@implementation FilterCatalogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Filter";

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(tap:)];
    self.navigationItem.backBarButtonItem = backButton;

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(tap:)];
    cancelButton.tag = 1;
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Selesai"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(tap:)];
    doneButton.tag = 2;
    self.navigationItem.rightBarButtonItem = doneButton;

    self.tableView.backgroundColor = [UIColor colorWithRed:231.0/255.0
                                                     green:231.0/255.0
                                                      blue:231.0/255.0
                                                     alpha:1];
    
    _conditionValue = @"Semua Kondisi";
    _locationValue = @"Semua Lokasi";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Kondisi";
        cell.detailTextLabel.text = _conditionValue;
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"Lokasi Pengiriman";
        cell.detailTextLabel.text = _locationValue;
    }
    cell.textLabel.font = [UIFont title2Theme];
    cell.detailTextLabel.font = [UIFont title2Theme];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        
        GeneralTableViewController *controller = [GeneralTableViewController new];
        controller.title = @"Kondisi";
        controller.delegate = self;
        controller.objects = @[@"Semua Kondisi",
                               @"Baru",
                               @"Bekas"];
        controller.selectedObject = _conditionValue;
        controller.tag = 1;
        [self.navigationController pushViewController:controller animated:YES];
        
    } else if (indexPath.row == 1) {

        NSMutableArray *values = [NSMutableArray new];
        [values addObject:@"Semua Lokasi"];
        for (CatalogLocation *location in _catalog.result.catalog_location) {
            [values addObject:[NSString stringWithFormat:@"%@ (%@)", location.location_name, location.total_shop]];
        }
        
        GeneralTableViewController *controller = [GeneralTableViewController new];
        controller.title = @"Lokasi Pengiriman";
        controller.delegate = self;
        controller.objects = values;
        controller.selectedObject = _locationValue;
        controller.tag = 2;
        [self.navigationController pushViewController:controller animated:YES];

    }
}

#pragma mark - Actions

- (IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem *)sender;
        if (button.tag == 2 && [self.delegate respondsToSelector:@selector(didFinishFilterCatalog:condition:location:)]) {
            NSString *condition, *location;
            if ([_conditionValue isEqualToString:@"Semua Kondisi"]) {
                condition = @"";
            } else if ([_conditionValue isEqualToString:@"Baru"]) {
                condition = @"1";
            } else if ([_conditionValue isEqualToString:@"Bekas"]) {
                condition = @"2";
            }
            if ([_locationValue isEqualToString:@"Semua Lokasi"]) {
                location = @"";
            } else {
                for (CatalogLocation *catalogLocation in _catalog.result.catalog_location) {
                    NSString *tmp = [NSString stringWithFormat:@"%@ (%@)",
                                     catalogLocation.location_name,
                                     catalogLocation.total_shop];
                    if ([_locationValue isEqualToString:tmp]) {
                        location = catalogLocation.location_id;
                    }
                }
            }            
            [self.delegate didFinishFilterCatalog:_catalog
                                        condition:condition
                                         location:location];
        }
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - General table delegate

- (void)viewController:(UITableViewController *)viewController didSelectObject:(id)object
{
    GeneralTableViewController *controller = (GeneralTableViewController *)viewController;
    if (controller.tag == 1) {
        _conditionValue = object;
    } else if (controller.tag == 2) {
        _locationValue = object;
    }
    [self.tableView reloadData];
}

@end
