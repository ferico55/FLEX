//
//  TransactionCCDetailViewController.m
//  Tokopedia
//
//  Created by Renny Runiawati on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionCCDetailViewController.h"

@interface TransactionCCDetailViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *tableViewCells;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *CCNumberTextField;
@property (weak, nonatomic) IBOutlet UILabel *expDateLabel;
@property (weak, nonatomic) IBOutlet UITextField *CVVTextField;

@end

@implementation TransactionCCDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableViewCells = [NSArray sortViewsWithTagInArray:_tableViewCells];
    
    self.title = @"Informasi Tagihan";
    
    UIBarButtonItem *nextBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Bayar" style:UIBarButtonItemStylePlain target:self action:@selector(nextButton:)];
    self.navigationItem.rightBarButtonItem = nextBarButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableViewCells.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = _tableViewCells[indexPath.row];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width,1)];
    lineView.backgroundColor = [UIColor colorWithRed:(230.0/255.0f) green:(233/255.0f) blue:(237.0/255.0f) alpha:1.0f];
    [cell.contentView addSubview:lineView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ((UITableViewCell*)_tableViewCells[indexPath.row]).frame.size.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 1:
            [_nameTextField becomeFirstResponder];
            break;
        case 2:
            [_CCNumberTextField becomeFirstResponder];
            break;
        case 3:
            break;
        case 4:
            [_CVVTextField becomeFirstResponder];
            break;
        default:
            break;
    }
}

#pragma mark - Methods
-(IBAction)nextButton:(id)sender
{
    
}

@end
