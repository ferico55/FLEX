//
//  ResolutionCenterCreateStepThreeViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterCreateStepThreeViewController.h"

@interface ResolutionCenterCreateStepThreeViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *solutionCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *refundCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *photoCell;

@property (strong, nonatomic) IBOutlet UIButton *uploadButtons;

@end

@implementation ResolutionCenterCreateStepThreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            return _solutionCell;
        }else{
            return _refundCell;
        }
    }else{
        return _photoCell;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 2;
    }else{
        return 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            return _solutionCell.frame.size.height;
        }else{
            return _refundCell.frame.size.height;
        }
    }else{
        return _photoCell.frame.size.height;
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header = nil;
    if(section == 0){
        header = [[UIView alloc]initWithFrame:CGRectMake(16, 28, 320, 40)];
        header.backgroundColor = [UIColor clearColor];
        
        UILabel *lbl = [[UILabel alloc]initWithFrame:header.frame];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.text = @"Masalah pada barang yang Anda terima";
        lbl.textAlignment = NSTextAlignmentLeft;
        lbl.font = [UIFont fontWithName:@"Gotham Book" size:12.0];
        [lbl setNumberOfLines:0];
        [lbl sizeToFit];
        [header addSubview:lbl];
    }
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 50;
    }
    return 0;
}

@end
