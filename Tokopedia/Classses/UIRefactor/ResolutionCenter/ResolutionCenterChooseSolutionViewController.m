//
//  ResolutionCenterChooseSolutionViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterChooseSolutionViewController.h"

@interface ResolutionCenterChooseSolutionViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ResolutionCenterChooseSolutionViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView reloadData];
    
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Selesai" style: UIBarButtonItemStyleDone target:self action:@selector(didTapFinishButton)];
    self.navigationItem.rightBarButtonItem = nextButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)didTapFinishButton{
    [self.navigationController popViewControllerAnimated:YES];
    /*
    if(_selectedList){
        [_delegate didSelectProblem:_selectedList];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        StickyAlertView* alert = [[StickyAlertView alloc]initWithErrorMessages:@[@"Anda belum memilih masalah pada barang yang Anda terima."] delegate:self];
        [alert show];
    }
     */
}

#pragma mark - UITableView Delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    /*
    ResolutionCenterCreateList* currentList = [_list_ts objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.font = [UIFont fontWithName:@"GothamBook" size:13];
    cell.textLabel.text = currentList.category_trouble_text;
    if(_selectedList && [currentList.category_trouble_id isEqualToString:_selectedList.category_trouble_id]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
     */
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = @"asd asd asd";
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //_selectedList = [_list_ts objectAtIndex:indexPath.row];
    [_tableView reloadData];
    
}


@end
