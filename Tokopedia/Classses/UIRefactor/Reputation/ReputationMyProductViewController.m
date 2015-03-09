//
//  ReputationMyProductViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 2/27/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ReputationMyProductViewController.h"
#import "ReputationCell.h"
#import "ReputationShopHeader.h"
#import "ReputationDetailFormViewController.h"
#import "ReputationDetailViewController.h"

#import "reputation_string.h"

@interface ReputationMyProductViewController () <UITableViewDataSource, UITableViewDelegate,
    ReputationCellDelegate
>

@property (weak, nonatomic) IBOutlet UITableView *table;

@end

@implementation ReputationMyProductViewController {
    BOOL *_isNoData;
    ReputationShopHeader *_shopReputation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = kTKPDREPUTATION_TITLE;
    
    _table.delegate = self;
    _table.dataSource = self;
  
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableData Source
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    _shopReputation = [ReputationShopHeader new];
    
    return _shopReputation.footer;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    _shopReputation = [ReputationShopHeader new];

    return _shopReputation;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 108.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 32.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = nil;
    
    if(!_isNoData) {
        NSString *cellid = kTKPDREPUTATION_CELL_ID;
        
        cell = (ReputationCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [ReputationCell newcell];
            ((ReputationCell *)cell).delegate = self;
        }
        
        ((ReputationCell *)cell).indexpath = indexPath;
        ((ReputationCell *)cell).productLabel.text = @"Cumi Kamu";

    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ReputationDetailViewController *reputationDetail = [ReputationDetailViewController new];
    [self.navigationController pushViewController:reputationDetail animated:YES];
}

#pragma mark - ReputationCell Delegate
- (void)ReputationCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
