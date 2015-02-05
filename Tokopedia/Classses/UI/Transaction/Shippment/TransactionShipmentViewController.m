//
//  TransactionShipmentViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionShipmentViewController.h"
#import "string_transaction.h"
#import "GeneralCheckmarkCell.h"
#import "ShippingInfoShipments.h"

@interface TransactionShipmentViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *_list;
    BOOL _isnodata;
    
    NSIndexPath *_selectionIndexPath;
}
@property (weak, nonatomic) IBOutlet UILabel *titleTableLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation TransactionShipmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _list = [NSMutableArray new];
    
    UIBarButtonItem *barbutton1;
    barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barbutton1 setTintColor:[UIColor blackColor]];
    [barbutton1 setTag:TAG_BAR_BUTTON_TRANSACTION_DONE];
    self.navigationItem.rightBarButtonItem = barbutton1;
    
    [_list addObjectsFromArray:[_data objectForKey:DATA_SHIPMENT_KEY]];

    _isnodata = NO;
    
    NSIndexPath *previousIndexPath = [_data objectForKey:DATA_INDEXPATH_KEY];
    _selectionIndexPath = previousIndexPath?:[NSIndexPath indexPathForRow:0 inSection:0];
    
    NSInteger type = [[_data objectForKey:DATA_TYPE_KEY]integerValue];
    NSString *titleTable = (type == TYPE_TRANSACTION_SHIPMENT_SHIPPING_AGENCY)?TITLE_TABLE_SHIPMENT:TITLE_TABLE_SHIPMENT_PACKAGE;
    _titleTableLabel.text =titleTable;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        switch (button.tag) {
            case TAG_BAR_BUTTON_TRANSACTION_BACK:
            {
                break;
            }
            case TAG_BAR_BUTTON_TRANSACTION_DONE:
            {
                NSInteger type = [[_data objectForKey:DATA_TYPE_KEY]integerValue];
                NSDictionary *userInfo = @{DATA_INDEXPATH_KEY: _selectionIndexPath,
                                           DATA_TYPE_KEY: @(type)
                                           };
                [_delegate TransactionShipmentViewController:self withUserInfo:userInfo];
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef TRANSACTION_SHIPMENT_ISNODATA_ENABLE
    return _isnodata ? 1 : _list.count;
#else
    return _isnodata ? 0 : _list.count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        NSString *cellid = GENERAL_CHECKMARK_CELL_IDENTIFIER;
        
        cell = (GeneralCheckmarkCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [GeneralCheckmarkCell newcell];
        }
        if (indexPath.row != _selectionIndexPath.row) {
            ((GeneralCheckmarkCell*)cell).checkmarkImageView.hidden = YES;
        }
        else
            ((GeneralCheckmarkCell*)cell).checkmarkImageView.hidden = NO;
        
        NSInteger type = [[_data objectForKey:DATA_TYPE_KEY]integerValue];
        if (type == TYPE_TRANSACTION_SHIPMENT_SHIPPING_AGENCY) {
            ShippingInfoShipments *shipment = _list[indexPath.row];
            ((GeneralCheckmarkCell*)cell).cellLabel.text = shipment.shipment_name;
        }
        else
        {
            ShippingInfoShipmentPackage *shipmentPackage = _list[indexPath.row];
            ((GeneralCheckmarkCell*)cell).cellLabel.text = shipmentPackage.name;
        }
        
    } else {
        static NSString *CellIdentifier = TRANSACTION_STANDARDTABLEVIEWCELLIDENTIFIER;
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = TRANSACTION_NODATACELLTITLE;
        cell.detailTextLabel.text = TRANSACTION_NODATACELLDESCS;
    }
    
    return cell;
}

#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectionIndexPath = indexPath;
    [_tableView reloadData];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isnodata) {
        cell.backgroundColor = [UIColor whiteColor];
    }
}

@end
