//
//  ResolutionCenterCreateStepOneViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterCreateStepOneViewController.h"
#import "ResolutionCenterCreateStepOneCell.h"
#import "RequestResolutionData.h"
#import "ResolutionCenterCreateData.h"

@interface ResolutionCenterCreateStepOneViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *problemCell;

@property (strong, nonatomic) ResolutionCenterCreateData* formData;
@end

@implementation ResolutionCenterCreateStepOneViewController{
    BOOL _shouldShowProblematicProduct;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self fetchForm];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Table View Delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return _problemCell;
    }else{
        ResolutionCenterCreateStepOneCell *cell = nil;
        NSString *cellid = @"ResolutionCenterCreateStepOneCell";
        cell = (ResolutionCenterCreateStepOneCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if(cell == nil){
            cell = [ResolutionCenterCreateStepOneCell newcell];
        }
        return cell;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 1;
    }else{
        return _shouldShowProblematicProduct?3:0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return _problemCell.frame.size.height;
    }else{
        return _shouldShowProblematicProduct?70:0;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        _shouldShowProblematicProduct = YES;
    }
    [tableView reloadData];
}

#pragma mark - Methods
-(void)fetchForm{
    [RequestResolutionData fetchCreateResolutionDataWithOrderId:@"123123"
                                                        success:^(ResolutionCenterCreateResponse *data) {
                                                            _formData = data.data;
                                                        } failure:^(NSError *error) {
                                                            
                                                        }];
}
@end
