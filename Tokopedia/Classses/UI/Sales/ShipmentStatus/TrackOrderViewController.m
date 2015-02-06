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
    if (section ==  0) {
        return 4;
    } else {
        return 2;
    }
}

@end
