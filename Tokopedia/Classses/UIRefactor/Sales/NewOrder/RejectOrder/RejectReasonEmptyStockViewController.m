//
//  RejectReasonEmptyStockViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 6/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RejectReasonEmptyStockViewController.h"
#import "RejectReasonEmptyStockCell.h"

@interface RejectReasonEmptyStockViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *confirmButton;

@end

@implementation RejectReasonEmptyStockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.dataSource = self;
    _tableView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifer = @"RejectReasonEmptyStockCell";
    
    RejectReasonEmptyStockCell *cell = (RejectReasonEmptyStockCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellIdentifer
                                                                 owner:self
                                                               options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *sectionTitle = @"Atur stok kosong pada produk:";
    
    // Create label with section title
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(8, 0, 280, 40);
    label.textColor = [UIColor blackColor];
    label.font = [UIFont fontWithName:@"GothamMedium" size:14];
    label.text = sectionTitle;
    label.backgroundColor = [UIColor clearColor];
    
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.window.frame.size.width, 100)];
    [view addSubview:label];
    
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end
