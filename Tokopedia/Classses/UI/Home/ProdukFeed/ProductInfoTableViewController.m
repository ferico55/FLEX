//
//  ProductInfoTableViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 11/10/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ProductInfoTableViewController.h"
#import "detail.h"
#import "DetailProductWholesaleTableCell.h"
#import "WholesalePrice.h"

@interface ProductInfoTableViewController () {
    NSMutableArray *_wholesales;
    BOOL _isnodata;
    BOOL _tableHeightUpdate;
}

@end

@implementation ProductInfoTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        #ifdef kTKPDHOTLISTRESULT_NODATAENABLE
            return _isnodata?1:_wholesales.count;
        #else
            return _isnodata?0:_wholesales.count;
        #endif
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell* cell = nil;
    if (!_isnodata) {
        UITableViewCell* cell = nil;
        
        // Configure the cell...
        if (_wholesales.count > indexPath.row) {
            NSString *cellid = kTKPDDETAILPRODUCTWHOLESALETABLECELLIDENTIFIER;
            cell = (DetailProductWholesaleTableCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
            if (cell == nil) {
                cell = [DetailProductWholesaleTableCell newcell];
                //((DetailProductWholesaleCell*)cell).delegate = self;
            }
            
            if (indexPath.row == 0) {
                //                ((DetailProductWholesaleTableCell*)cell).quantity.text = @"adsasd";
                //                ((DetailProductWholesaleTableCell*)cell).price.text = @"asdsd";
            } else {
                //                WholesalePrice *wholesale = _wholesales[indexPath.row-1];
                //                if (indexPath.row == _wholesales.count-2)
                //                    ((DetailProductWholesaleTableCell*)cell).quantity.text = [NSString stringWithFormat:@" >= %@", wholesale.wholesale_min];
                //                else
                //                    ((DetailProductWholesaleTableCell*)cell).quantity.text = [NSString stringWithFormat:@"%@ - %@", wholesale.wholesale_min, wholesale.wholesale_max];
                //                ((DetailProductWholesaleTableCell*)cell).price.text = [NSString stringWithFormat:@"Rp. %@", wholesale.wholesale_price];
            }
            return cell;
        }
    }
    
    return cell;
}

@end
