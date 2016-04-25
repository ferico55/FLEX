//
//  OpenShopViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 4/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "OpenShopViewController.h"
#import "OpenShopDomainViewCell.h"
#import "OpenShopImageViewCell.h"
#import "OpenShopNameViewCell.h"
#import "EditShopDescriptionViewCell.h"

@implementation OpenShopViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.tableView.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Buka Toko";

    UIBarButtonItem *continueButton = [[UIBarButtonItem alloc] initWithTitle:@"Lanjut" style:UIBarButtonItemStyleDone target:self action:nil];
    self.navigationItem.rightBarButtonItem = continueButton;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"OpenShopDomainViewCell" bundle:nil] forCellReuseIdentifier:@"OpenShopDomain"];
    [self.tableView registerNib:[UINib nibWithNibName:@"OpenShopImageViewCell" bundle:nil] forCellReuseIdentifier:@"OpenShopImage"];
    [self.tableView registerNib:[UINib nibWithNibName:@"OpenShopNameViewCell" bundle:nil] forCellReuseIdentifier:@"OpenShopName"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EditShopDescriptionViewCell" bundle:nil] forCellReuseIdentifier:@"shopDescription"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    if (section == 0) {
        numberOfRows = 1;
    } else if (section == 1) {
        numberOfRows = 1;
    } else if (section == 2) {
        numberOfRows = 3;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        OpenShopDomainViewCell *domainCell = [tableView dequeueReusableCellWithIdentifier:@"OpenShopDomain"];
        cell = domainCell;
    } else if (indexPath.section == 1) {
        OpenShopImageViewCell *imageCell = [tableView dequeueReusableCellWithIdentifier:@"OpenShopImage"];
        cell = imageCell;
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            OpenShopNameViewCell *nameCell = [tableView dequeueReusableCellWithIdentifier:@"OpenShopName"];
            cell = nameCell;
        } else if (indexPath.row == 1) {
            EditShopDescriptionViewCell *taglineCell = [tableView dequeueReusableCellWithIdentifier:@"shopDescription"];
            cell = taglineCell;
        } else if (indexPath.row == 2) {
            EditShopDescriptionViewCell *descriptionCell = [tableView dequeueReusableCellWithIdentifier:@"shopDescription"];
            cell = descriptionCell;
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        OpenShopDomainViewCell *domainCell = [tableView dequeueReusableCellWithIdentifier:@"OpenShopDomain"];
        cell = domainCell;
    } else if (indexPath.section == 1) {
        OpenShopImageViewCell *imageCell = [tableView dequeueReusableCellWithIdentifier:@"OpenShopImage"];
        cell = imageCell;
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            OpenShopNameViewCell *nameCell = [tableView dequeueReusableCellWithIdentifier:@"OpenShopName"];
            cell = nameCell;
        } else if (indexPath.row == 1) {
            EditShopDescriptionViewCell *taglineCell = [tableView dequeueReusableCellWithIdentifier:@"shopDescription"];
            cell = taglineCell;
        } else if (indexPath.row == 2) {
            EditShopDescriptionViewCell *descriptionCell = [tableView dequeueReusableCellWithIdentifier:@"shopDescription"];
            cell = descriptionCell;
        }
    }
    return cell.frame.size.height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title;
    if (section == 0) {
        title = @"Domain";
    } else if (section == 1) {
        title = @"Gambar Toko";
    } else if (section == 2) {
        title = @"Deskripsi Toko";
    }
    return title;
}

@end
