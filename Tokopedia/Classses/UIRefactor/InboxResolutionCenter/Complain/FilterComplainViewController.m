//
//  FilterComplainViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "FilterComplainViewController.h"
#import "GeneralTableViewController.h"
#import "string_inbox_resolution_center.h"

@interface FilterComplainViewController () <GeneralTableViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FilterComplainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"Filter";
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.title = nil;
    [_delegate filterProcess:_filterProcess filterRead:_filterRead];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    NSString *cellid = @"cellid";
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellid];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = (indexPath.row==0)?_filterProcess:_filterRead;
    
    return cell;
}

#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GeneralTableViewController *controller = [GeneralTableViewController new];
    controller.delegate = self;
    controller.senderIndexPath = indexPath;
    controller.title = @"Filter";
    if (indexPath.row == 0) {
        controller.objects = ARRAY_FILTER_PROCESS;
        controller.selectedObject = _filterProcess;
    }
    if (indexPath.row == 1) {
        controller.objects = ARRAY_FILTER_UNREAD;
        controller.selectedObject = _filterRead;
    }
    
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        _filterProcess = (NSString*)object;
    else if (indexPath.row == 1)
        _filterRead = (NSString*)object;
    
    [_tableView reloadData];
}

@end
