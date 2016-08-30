//
//  ResolutionCenterChooseProblemViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterChooseProblemViewController.h"

@interface ResolutionCenterChooseProblemViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) ResolutionCenterCreateList* selectedList;

@end

@implementation ResolutionCenterChooseProblemViewController

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
        [_delegate didSelectProblem:_selectedList];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        StickyAlertView* alert = [[StickyAlertView alloc]initWithErrorMessages:@[@"Anda belum memilih masalah pada barang yang Anda terima."] delegate:self];
        [alert show];
    }
}

#pragma mark - UITableView Delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ResolutionCenterCreateList* currentList = [_list_ts objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    if(_selectedList && [currentList.category_trouble_id isEqualToString:_selectedList.category_trouble_id]){
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
    return _list_ts.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _selectedList = [_list_ts objectAtIndex:indexPath.row];
    [_tableView reloadData];

}
@end
