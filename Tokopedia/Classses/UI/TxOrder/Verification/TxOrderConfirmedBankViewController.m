//
//  TxOrderConfirmedBankViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderConfirmedBankViewController.h"

@interface TxOrderConfirmedBankViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section0Cell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section1Cell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section2Cell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section3Cell;

@end

@implementation TxOrderConfirmedBankViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rowCount = 0;
    switch (section) {
        case 0:
            rowCount = _section0Cell.count;
            break;
        case 1:
            rowCount = _section1Cell.count;
            break;
        case 2:
            rowCount = _section2Cell.count;
            break;
        case 3:
            rowCount = _section3Cell.count;
        default:
            break;
    }
    return rowCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    
    switch (indexPath.section) {
        case 0:
            cell = _section0Cell[indexPath.row];
            break;
        case 1:
            cell = _section1Cell[indexPath.row];
            break;
        case 2:
            cell = _section2Cell[indexPath.row];
            break;
        case 3:
            cell = _section3Cell[indexPath.row];
        default:
            break;
    }

    return cell;
}

#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}


@end
