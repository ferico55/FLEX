//
//  TransactionOrderConfirmationViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionOrderConfirmationViewController.h"
#import "TransactionOrderConfirmationCell.h"

@interface TransactionOrderConfirmationViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *_list;
    BOOL _isNodata;
    
    NSString *_URINext;
    __weak RKObjectManager *_objectManagerTransaction;
    __weak RKManagedObjectRequestOperation *_requestFormATC;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TransactionOrderConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _list = [NSMutableArray new];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef TRANSACTION_SHIPMENT_ISNODATA_ENABLE
    return _isNodata ? 1 : _list.count;
#else
    return _isNodata ? 0 : _list.count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    NSString *cellid = TRANSACTION_ORDER_CONFIRMATION_CELL_IDENTIFIER;
    
    cell = (TransactionOrderConfirmationCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [TransactionOrderConfirmationCell newcell];
    }
    
    return cell;
}

#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView reloadData];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isNodata) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    
    if (row == indexPath.row) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        NSLog(@"%ld", (long)row);
        
        if (_URINext != NULL && ![_URINext isEqualToString:@"0"] && _URINext != 0) {
            //[self configureRestKit];
            //[self request];
        }
    }
}

@end
