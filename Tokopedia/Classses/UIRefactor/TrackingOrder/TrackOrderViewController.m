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

@property (weak, nonatomic) IBOutlet UIView *headerViewComplete;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@end

@implementation TrackOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Lacak Pengiriman";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    }
    return cell;
}

- (void)configureRestKit
{
    
}

- (void)request
{
    
}

@end
