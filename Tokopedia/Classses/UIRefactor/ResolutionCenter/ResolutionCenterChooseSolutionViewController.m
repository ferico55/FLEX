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
@property (strong, nonatomic) ResolutionCenterCreatePOSTFormSolution *selectedList;
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
    if(_selectedList){
        [self.delegate didSelectSolution:_selectedList];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        StickyAlertView* alert = [[StickyAlertView alloc]initWithErrorMessages:@[@"Anda belum memilih masalah pada barang yang Anda terima."] delegate:self];
        [alert show];
    }
}

#pragma mark - UITableView Delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ResolutionCenterCreatePOSTFormSolution* currentList = [_formSolutions objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = currentList.solution_text;
    if(_selectedList && [currentList.solution_id isEqualToString:_selectedList.solution_id]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _formSolutions.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _selectedList = [_formSolutions objectAtIndex:indexPath.row];
    [_tableView reloadData];
    
}


@end
