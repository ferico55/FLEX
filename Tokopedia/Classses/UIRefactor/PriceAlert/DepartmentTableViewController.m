//
//  DepartmentTableViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 5/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "Breadcrumb.h"
#import "string_price_alert.h"
#import "DepartmentTableViewController.h"
#define CCellIdentifier @"cell"
@interface DepartmentTableViewController ()

@end

@implementation DepartmentTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.navigationItem.title==nil || [self.navigationItem.title isEqualToString:@""]) {
        self.navigationItem.title = CStringDepartment;
    }
 
    self.tableView.contentInset = UIEdgeInsetsMake(30, 0, 0, 0);
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:CStringSelesai style:UIBarButtonItemStylePlain target:self action:@selector(actionSelesai:)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = [UIColor colorWithRed:231/255.0f green:231/255.0f blue:231/255.0f alpha:1.0f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CCellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CCellIdentifier];
        cell.textLabel.font = [UIFont title2Theme];
        cell.accessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.bounds.size.height-25, cell.bounds.size.height-25)];
        ((UIImageView *) cell.accessoryView).image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_check_orange" ofType:@"png"]];
    }
    
    
    if(indexPath.row == _selectedIndex) {
        cell.accessoryView.hidden = NO;
    }
    else {
        cell.accessoryView.hidden = YES;
    }
    
    
    id object = [_arrList objectAtIndex:indexPath.row];
    if([object isMemberOfClass:[Breadcrumb class]]) {
        cell.textLabel.text = ((Breadcrumb *)object).department_name;
    }
    else {
        cell.textLabel.text = (NSString *)object;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == _selectedIndex) {
        return;
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryView.hidden = NO;
    
    cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0]];
    cell.accessoryView.hidden = YES;
    _selectedIndex = (int)indexPath.row;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Method
- (void)actionSelesai:(id)sender
{
    [_del didFinishSelectedAtRow:_selectedIndex];
}

- (void)actionBatal:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
