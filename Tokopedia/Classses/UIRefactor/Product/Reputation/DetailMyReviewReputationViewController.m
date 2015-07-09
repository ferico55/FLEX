//
//  DetailMyReviewReputationViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "DetailMyReviewReputationCell.h"
#import "DetailMyInboxReputation.h"
#import "DetailReputationReview.h"
#import "DetailMyReviewReputationViewController.h"
#import "GiveReviewViewController.h"
#import "MyReviewReputation.h"
#import "MyReviewReputationViewModel.h"
#import "MyReviewReputationCell.h"
#import "NoResultView.h"
#import "ProductDetailReputationViewController.h"
#import "Paging.h"
#import "TokopediaNetworkManager.h"
#import "LoadingView.h"

#define CCellIdentifier @"cell"
#define CGetListReputationReview @"get_list_reputation_review"
#define CTagListReputationReview 1

@interface DetailMyReviewReputationViewController ()<TokopediaNetworkManagerDelegate, LoadingViewDelegate, detailMyReviewReputationCell>

@end

@implementation DetailMyReviewReputationViewController
{
    NSMutableArray *arrList;
    TokopediaNetworkManager *tokopediaNetworkManager;
    NSString *strUriNext;
    int page;
    NSMutableParagraphStyle *style;
    
    MyReviewReputationCell *myReviewReputationCell;
    LoadingView *loadingView;
    NoResultView *noResultView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    page = 0;
    
    [self initTable];
    [self loadMoreData:YES];
    [[self getNetworkManager:CTagListReputationReview] doRequest];
    
    style = [NSMutableParagraphStyle new];
    style.lineSpacing = 4.0f;
    tableContent.backgroundColor = [UIColor colorWithRed:231/255.0f green:231/255.0f blue:231/255.0f alpha:1.0f];
    arrList = [[NSMutableArray alloc] init];
    
    tableContent.delegate = self;
    tableContent.dataSource = self;
    [tableContent reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma mark - UITableView Delegate and DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailMyReviewReputationCell *cell = [tableView dequeueReusableCellWithIdentifier:CCellIdentifier];
    if(cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DetailMyReviewReputationCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.delegate = self;
        [self setPropertyLabelDesc:cell.getLabelDesc];
    }
    
    DetailReputationReview *detailReputationReview = arrList[indexPath.row];
    cell.getLabelDesc.tag = indexPath.row;
    cell.getBtnKomentar.tag = indexPath.row;
    [cell setView:detailReputationReview.viewModel];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailReputationReview *detailReputationReview = arrList[indexPath.row];
    int height = 0;
    
    if(YES)//Hidden star
        height = CHeightContentStar;
    
    TTTAttributedLabel *tempLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-(CPaddingTopBottom*4), 0)];
    [self setPropertyLabelDesc:tempLabel];
    [self initLabelDesc:tempLabel withText:detailReputationReview.viewModel.review_message];
    CGSize tempSizeDesc = [tempLabel sizeThatFits:CGSizeMake(tempLabel.bounds.size.width, 9999)];
    return (CPaddingTopBottom*6) + height + CHeightContentAction + CDiameterImage + tempSizeDesc.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    DetailReputationReview *detailReputationReview = arrList[indexPath.row];
    ProductDetailReputationViewController *productDetailReputationViewController = [ProductDetailReputationViewController new];
    productDetailReputationViewController.detailReputaitonReview = detailReputationReview;
    [self.navigationController pushViewController:productDetailReputationViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(arrList!=nil && arrList.count-1 == indexPath.row) {
        if (strUriNext!=nil && ![strUriNext isEqualToString:@"0"]) {
            [self loadMoreData:YES];
            [[self getNetworkManager:CTagListReputationReview] doRequest];
        }
    }
}


#pragma mark - Method View
- (void)initTable {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MyReviewReputationCell" owner:self options:nil];
    myReviewReputationCell = [topLevelObjects objectAtIndex:0];
    [myReviewReputationCell setView:_detailMyInboxReputation.viewModel];
    [myReviewReputationCell.getBtnFooter removeFromSuperview];
    
    CGRect tempRect = myReviewReputationCell.contentView.frame;
    tempRect.size.height -= myReviewReputationCell.getBtnFooter.bounds.size.height;
    myReviewReputationCell.contentView.frame = tempRect;
    tableContent.tableHeaderView = myReviewReputationCell.contentView;
}


#pragma mark - Method
- (void)setPropertyLabelDesc:(TTTAttributedLabel *)lblDesc {
    lblDesc.backgroundColor = [UIColor clearColor];
    lblDesc.textAlignment = NSTextAlignmentLeft;
    lblDesc.font = [UIFont fontWithName:@"GothamBook" size:13.0f];
    lblDesc.textColor = [UIColor colorWithRed:117/255.0f green:117/255.0f blue:117/255.0f alpha:1.0f];
    lblDesc.lineBreakMode = NSLineBreakByWordWrapping;
    lblDesc.numberOfLines = 0;
}


- (LoadingView *)getLoadView {
    if(loadingView == nil) {
        loadingView = [LoadingView new];
    }
    
    return loadingView;
}

- (TokopediaNetworkManager *)getNetworkManager:(int)tag {
    if(tag == CTagListReputationReview) {
        if(tokopediaNetworkManager == nil) {
            tokopediaNetworkManager = [TokopediaNetworkManager new];
            tokopediaNetworkManager.delegate = self;
            tokopediaNetworkManager.tagRequest = tag;

            return tokopediaNetworkManager;
        }
    }
    
    return nil;
}

- (void)loadMoreData:(BOOL)load {
    if(load) {
        tableContent.tableFooterView = viewFooter;
        [actIndicator startAnimating];
    }
    else {
        tableContent.tableFooterView = nil;
        [actIndicator stopAnimating];
    }
}


#pragma mark - Tokopedia Network Manager
- (NSDictionary*)getParameter:(int)tag {
    if(tag == CTagListReputationReview) {
        return @{@"action":CGetListReputationReview,
                 @"reputation_id":_detailMyInboxReputation.reputation_id};
    }
    
    return nil;
}

- (NSString*)getPath:(int)tag {
    if(tag == CTagListReputationReview) {
        return @"inbox-reputation.pl";
    }
    
    return nil;
}

- (id)getObjectManager:(int)tag {
    if(tag == CTagListReputationReview) {
        RKObjectManager *objectManager = [RKObjectManager sharedClient];
        
        // setup object mappings
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[MyReviewReputation class]];
        [statusMapping addAttributeMappingsFromDictionary:@{CStatus:CStatus,
                                                            CMessageError:CMessageError,
                                                            CMessageStatus:CMessageStatus,
                                                            CServerProcessTime:CServerProcessTime}];
        
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[MyReviewReputationResult class]];
        RKObjectMapping *detailReputationMapping = [RKObjectMapping mappingForClass:[DetailReputationReview class]];
        [detailReputationMapping addAttributeMappingsFromArray:@[CShopID,
                                                                 CProductRatingPoint,
                                                                 CReviewIsSkipable,
                                                                 CProductStatus,
                                                                 CReviewFullName,
                                                                 CReviewMessage,
                                                                 CProductSpeedDesc,
                                                                 CReviewReadStatus,
                                                                 CProductUri,
                                                                 CReviewUserID,
                                                                 CProductServiceDesc,
                                                                 CProductSpeedPoint,
                                                                 CReviewStatus,
                                                                 CReviewUpdateTime,
                                                                 CProductServicePoint,
                                                                 CProductAccuracyPoint,
                                                                 CReputationID,
                                                                 CProductID,
                                                                 CProductRatingDesc,
                                                                 CProductImage,
                                                                 CProductAccuracyDesc,
                                                                 CUserImage,
                                                                 CReputationInboxID,
                                                                 CReviewCreateTime,
                                                                 CUserURL,
                                                                 CShopName,
                                                                 CReviewMessageEdit,
                                                                 CReviewID,
                                                                 CReviewPostTime,
                                                                 CReviewIsAllowEdit,
                                                                 CProductName,
                                                                 CShopDomain
                                                                 ]];
        
        
        RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
        [pagingMapping addAttributeMappingsFromDictionary:@{CUriNext:CUriNext,
                                                            CUriPrevious:CUriPrevious}];
        
        RKObjectMapping *reviewUserReputationMapping = [RKObjectMapping mappingForClass:[ReputationDetail class]];
        [reviewUserReputationMapping addAttributeMappingsFromArray:@[CPositivePercentage,
                                                                     CNegative,
                                                                     CNeutral,
                                                                     CPositif]];
        
        
        RKObjectMapping *productOwnerMapping = [RKObjectMapping mappingForClass:[ProductOwner class]];
        [productOwnerMapping addAttributeMappingsFromArray:@[CShopID,
                                                             CUserLabelID,
                                                             CUserURL,
                                                             CShopImg,
                                                             CShopUrl,
                                                             CShopName,
                                                             CFullName,
                                                             CShopReputation,
                                                             CUserImg,
                                                             CUserLabel,
                                                             CuserID
                                                             ]];
        
        
        RKObjectMapping *reviewResponseMapping = [RKObjectMapping mappingForClass:[ReviewResponse class]];
        [reviewResponseMapping addAttributeMappingsFromDictionary:@{CResponseMsg:CResponseMessage,
                                                                    CResponseTimeFmt:CResponseTimeFmt}];
        
        
        //relation
        [detailReputationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReviewUserReputation toKeyPath:CReviewUserReputation withMapping:reviewUserReputationMapping]];
        [detailReputationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CProductOwner toKeyPath:CProductOwner withMapping:productOwnerMapping]];
        [detailReputationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReviewResponse toKeyPath:CReviewResponse withMapping:reviewResponseMapping]];
        [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CList toKeyPath:CList withMapping:detailReputationMapping]];
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CPaging toKeyPath:CPaging withMapping:pagingMapping]];
        
        //register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:[self getPath:tag] keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
        [objectManager addResponseDescriptor:responseDescriptorStatus];
        
        return objectManager;
    }
    
    return nil;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    if(tag == CTagListReputationReview) {
        MyReviewReputation *reviewReputationn = (MyReviewReputation *)stat;
        return reviewReputationn.status;
    }
    
    return nil;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*) successResult).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    if(tag == CTagListReputationReview) {
        MyReviewReputation *result = (MyReviewReputation *)stat;
        if(page == 0) {
            arrList = [[NSMutableArray alloc] initWithArray:result.result.list];
        }
        else {
            [arrList addObjectsFromArray:result.result.list];
        }
        
        strUriNext = result.result.paging.uri_next;
        page = [[[self getNetworkManager:tag] splitUriToPage:strUriNext] intValue];
        
        
        //Check any data or not
        if(arrList.count == 0) {
            if(noResultView == nil) {
                noResultView = [NoResultView new];
            }
            
            tableContent.tableFooterView = noResultView.view;
        }
        else
            [self loadMoreData:NO];
        if(tableContent.delegate == nil) {
            tableContent.delegate = self;
            tableContent.dataSource = self;
        }
        [tableContent reloadData];
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
    if(tag == CTagListReputationReview) {
        
    }
}

- (void)actionBeforeRequest:(int)tag {
}

- (void)actionRequestAsync:(int)tag {
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    if(tag == CTagListReputationReview) {
        tableContent.tableFooterView = [self getLoadView].view;
    }
}

#pragma mark - Loading View Delegate
- (void)pressRetryButton
{
    [self loadMoreData:YES];
    [[self getNetworkManager:CTagListReputationReview] doRequest];
}


#pragma mark - DetailMyReviewReputationCell Delegate
- (void)initLabelDesc:(TTTAttributedLabel *)lblDesc withText:(NSString *)strDescription {
    NSString *strLihatSelengkapnya = @"Lihat Selengkapnya";
    if(strDescription.length > 100) {
        strDescription = [NSString stringWithFormat:@"%@... %@", [strDescription substringToIndex:100], strLihatSelengkapnya];
        
        NSRange range = [strDescription rangeOfString:strLihatSelengkapnya];
        lblDesc.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        lblDesc.activeLinkAttributes = @{(id)kCTForegroundColorAttributeName:[UIColor lightGrayColor], NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone)};
        lblDesc.linkAttributes = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone)};
        [lblDesc addLinkToURL:[NSURL URLWithString:@""] withRange:range];
        
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:strDescription];
        [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, strDescription.length)];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(strDescription.length-strLihatSelengkapnya.length, strLihatSelengkapnya.length)];
        lblDesc.attributedText = str;
    }
    else {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:strDescription];
        [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, strDescription.length)];
        lblDesc.attributedText = str;
        lblDesc.delegate = nil;
        [lblDesc addLinkToURL:[NSURL URLWithString:@""] withRange:NSMakeRange(0, 0)];
    }
}

- (void)actionBeriReview:(id)sender
{
    GiveReviewViewController *giveReviewViewController = [GiveReviewViewController new];
    DetailReputationReview *detailReputationReview = arrList[((UIButton *) sender).tag];

    giveReviewViewController.detailReputationView = detailReputationReview;
    [self.navigationController pushViewController:giveReviewViewController animated:YES];
}

- (void)actionProduct:(id)sender {

}

- (void)actionUbah:(id)sender {

}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    DetailReputationReview *detailReputationReview = arrList[label.tag];
    ProductDetailReputationViewController *productDetailReputationViewController = [ProductDetailReputationViewController new];
    productDetailReputationViewController.detailReputaitonReview = detailReputationReview;
    [self.navigationController pushViewController:productDetailReputationViewController animated:YES];
}
@end
