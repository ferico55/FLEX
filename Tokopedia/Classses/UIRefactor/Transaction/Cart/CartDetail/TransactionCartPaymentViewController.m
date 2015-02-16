//
//  TransactionCartPaymentViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/14/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "string_transaction.h"
#import "TransactionCartGateway.h"
#import "TransactionCartPaymentViewController.h"
#import "GeneralCheckmarkCell.h"

@interface TransactionCartPaymentViewController ()
{
    NSArray *_list;
    NSIndexPath *_selectedIndexPath;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TransactionCartPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _list = [_data objectForKey:DATA_CART_GATEWAY_KEY];
    
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [cancelBarButtonItem setTintColor:[UIColor whiteColor]];
    cancelBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_BACK;
    self.navigationItem.rightBarButtonItem = cancelBarButtonItem;
    
    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [saveBarButtonItem setTintColor:[UIColor blackColor]];
    saveBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_DONE;
    self.navigationItem.rightBarButtonItem = saveBarButtonItem;
    
    _selectedIndexPath = [_data objectForKey:DATA_INDEXPATH_KEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    UIBarButtonItem *button = (UIBarButtonItem*)sender;
    switch (button.tag) {
        case TAG_BAR_BUTTON_TRANSACTION_BACK:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case TAG_BAR_BUTTON_TRANSACTION_DONE:
        {
            NSDictionary *userInfo = @{DATA_INDEXPATH_KEY:_selectedIndexPath};
            [_delegate TransactionCartPaymentViewController:self withUserInfo:userInfo];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _list.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    NSString *cellid = GENERAL_CHECKMARK_CELL_IDENTIFIER;
    
    cell = (GeneralCheckmarkCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [GeneralCheckmarkCell newcell];
        
    }
    
    if (_list.count > indexPath.row) {
        NSIndexPath *indexpath = _selectedIndexPath;
        if (indexPath.row != indexpath.row) {
            ((GeneralCheckmarkCell*)cell).checkmarkImageView.hidden = YES;
        }
        else
            ((GeneralCheckmarkCell*)cell).checkmarkImageView.hidden = NO;
        
        TransactionCartGateway *gateway = _list[indexPath.row];
        ((GeneralCheckmarkCell*)cell).cellLabel.text = gateway.gateway_name;
    }
    
    
    return cell;
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedIndexPath = indexPath;
    [_tableView reloadData];
}

@end
