//
//  EtalaseFilterViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 4/4/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "EtalaseViewController.h"
#import "EtalaseCell.h"

@interface EtalaseViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation EtalaseViewController{
    NSMutableArray<EtalaseList*>* etalaseList;
    NSMutableArray<EtalaseList*>* otherEtalaseList;
    
    NSInteger page;
    NSString *uriNext;
    
    TokopediaNetworkManager *etalaseNetworkManager;
    TokopediaNetworkManager *myEtalaseNetworkManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    etalaseList = [NSMutableArray new];
    otherEtalaseList = [NSMutableArray new];
    
    etalaseNetworkManager = [TokopediaNetworkManager new];
    myEtalaseNetworkManager = [TokopediaNetworkManager new];
    page = 0;
    
    if (self.navigationController.isBeingPresented) {
        UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                            style:UIBarButtonItemStyleBordered
                                                                           target:self
                                                                           action:@selector(tap:)];
        cancelBarButton.tag = 10;
        self.navigationItem.leftBarButtonItem = cancelBarButton;
    }
    
    UIBarButtonItem  *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Selesai"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:(self)
                                                                       action:@selector(tap:)];
    rightBarButton.tag = 11;
    self.navigationItem.rightBarButtonItem = rightBarButton;

    
    
    [self requestEtalase];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"EtalaseCell";
    EtalaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellIdentifier
                                                                 owner:self
                                                               options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    EtalaseList *currentEtalase;
    if(indexPath.section == 0){
        currentEtalase = [otherEtalaseList objectAtIndex:indexPath.row];
    }else{
        currentEtalase = [etalaseList objectAtIndex:indexPath.row];
    }
    
    [cell.nameLabel setText:currentEtalase.etalase_name];
    [cell.detailLabel setText:currentEtalase.etalase_num_product];
    
    if(_showChevron){
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }else{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    if(_showTotalProduct){
        [cell.detailLabel setHidden:NO];
    }else{
        [cell.detailLabel setHidden:YES];
    }
    
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return otherEtalaseList.count;
    }else if(section == 1){
        return etalaseList.count;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Method
-(IBAction)cancelButtonTapped:(id)sender
{
    
}

-(IBAction)finishButtonTapped:(id)sender
{
    
}


#pragma mark - Request

-(void)requestEtalase{
    if(_showOtherEtalase){
        [self requestCertainShopEtalase];
    }else{
        [self requestMyEtalase];
    }
}

-(void)requestCertainShopEtalase{
    etalaseNetworkManager.isUsingHmac = YES;
    [etalaseNetworkManager requestWithBaseUrl:[NSString v4Url]
                                   path:@"/v4/shop/get_shop_etalase.pl"
                                 method:RKRequestMethodGET
                              parameter:@{@"shop_id"    : _shopId,
                                          @"page"            : @(page)}
                                mapping:[Etalase mapping]
                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                  Etalase *etalase = [successResult.dictionary objectForKey:@""];
                                  [etalaseList addObjectsFromArray:etalase.result.list];
                                  [otherEtalaseList addObjectsFromArray:etalase.result.list_other];
                                  
                                  uriNext = etalase.result.paging.uri_next;
                                  if (uriNext) {
                                      page = [[etalaseNetworkManager splitUriToPage:uriNext] integerValue];
                                  }else{
                                      //[_footer setHidden:YES];
                                  }
                                  
                                  [_tableView reloadData];
                              }onFailure:^(NSError *errorResult) {
         
                              }];

}

-(void)requestMyEtalase{
    
}


@end
