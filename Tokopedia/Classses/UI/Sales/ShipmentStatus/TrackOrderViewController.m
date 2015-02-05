//
//  TrackOrderViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TrackOrderViewController.h"

@interface TrackOrderViewController () {

    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    RKResponseDescriptor *_responseDescriptorStatus;
    NSOperationQueue *_operationQueue;

}

@property (strong, nonatomic) IBOutlet UIView *headerView;

@end

@implementation TrackOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    }

    cell.textLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
    cell.detailTextLabel.font = [UIFont fontWithName:@"GothamBook" size:14];

    if (indexPath.section == 0) {
        if (indexPath.row == 0) cell.textLabel.text = @"Nama Pengirim";
        else cell.textLabel.text = @"Kota Pengirim";
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) cell.textLabel.text = @"Nama Penerima";
        else cell.textLabel.text = @"Kota Penerima";
    }
    
    return cell;
}

@end
