//
//  RequestLDExtension.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/24/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestLDExtension.h"
#import "MappingLDExtension.h"
#import "LuckyDeal.h"

#import "AlertLuckyView.h"

#define TagRequestMemberExtend 10

@implementation RequestLDExtension 
{
    TokopediaNetworkManager *_networkManagerMemberExtend;
    
    NSString *_stringURL;
}

-(void)doRequestMemberExtendURLString:(NSString*)urlString
{
    _stringURL = urlString;

    [[self networkManagerMemberExtend] doRequest];
}

-(TokopediaNetworkManager*)networkManagerMemberExtend;
{
    if (!_networkManagerMemberExtend) {
        _networkManagerMemberExtend = [TokopediaNetworkManager new];
        _networkManagerMemberExtend.isUsingHmac = YES;
        _networkManagerMemberExtend.tagRequest =TagRequestMemberExtend;
    }
    
    return _networkManagerMemberExtend;
}

-(id)getObjectManager:(int)tag
{
    if (TagRequestMemberExtend) {
        NSURL *url = [NSURL URLWithString:_stringURL];
        NSString *baseURL = [NSString stringWithFormat:@"%@://%@",[url scheme],[url host]];
        return [MappingLDExtension objectManagerMemberExtendBaseURL:baseURL];
    }
     return nil;
}



-(NSDictionary *)getParameter:(int)tag
{
    return nil;
}

-(NSString *)getPath:(int)tag
{
    if (TagRequestMemberExtend) {
        NSURL *url = [NSURL URLWithString:_stringURL];
        return [url path];
    }
    return nil;
}

-(void)actionBeforeRequest:(int)tag
{

}

-(NSString *)getRequestStatus:(id)result withTag:(int)tag
{
    if (TagRequestMemberExtend) {

        NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
        id stat = [resultDict objectForKey:@""];
        LuckyDeal *ld = stat;
        
        return ld.status;
    }
    return nil;
}

-(void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag
{
    if (TagRequestMemberExtend) {

        NSDictionary *resultDict = ((RKMappingResult*)successResult).dictionary;
        id stat = [resultDict objectForKey:@""];
        LuckyDeal *ld = stat;
        if ([ld.data.attributes.success integerValue] == 1) {
            [self showLuckyBuyer:ld.data.attributes.words];
        }
    }
}

-(void)showLuckyMerchant:(LuckyDealWord*)words
{
    NSURL *url = [NSURL URLWithString:_stringURL];
    NSString *baseURL = [NSString stringWithFormat:@"%@://%@",[url scheme],[url host]];
    
    AlertLuckyView *alertLucky = [AlertLuckyView new];
    NSString *line1 = words.content_merchant_1?:@"";
    NSString *line2 = words.content_merchant_2?:@"";
    NSString *line3 = words.content_merchant_3?:@"";
    NSString *urlString = baseURL;
    
    alertLucky.upperView.backgroundColor = [UIColor colorWithRed:(12.0f/255.0f) green:(170.0f/255.0f) blue:85.0f/255.0f alpha:1];
    alertLucky.upperColor = alertLucky.upperView.backgroundColor;
    [alertLucky.FirstLineLabel setCustomAttributedText:line1];
    [alertLucky.secondLineLabel setCustomAttributedText:line2];
    [alertLucky.Line3Label setCustomAttributedText:line3];
    alertLucky.urlString = urlString;
    
    [alertLucky show];
    
}

-(void)showLuckyBuyer:(LuckyDealWord*)words
{
    NSURL *url = [NSURL URLWithString:_stringURL];
    NSString *baseURL = [NSString stringWithFormat:@"%@://%@",[url scheme],[url host]];
    
    AlertLuckyView *alertLucky = [AlertLuckyView new];
    NSString *line1 = words.content_buyer_1?:@"";
    NSString *line2 = words.content_buyer_2?:@"";
    NSString *line3 = words.content_buyer_3?:@"";
    NSString *urlString = baseURL;
    
    alertLucky.upperView.backgroundColor = [UIColor colorWithRed:(42.0f/255.0f) green:(180.0f/255.0f) blue:193.0f/255.0f alpha:1];
    alertLucky.upperColor = alertLucky.upperView.backgroundColor;
    [alertLucky.FirstLineLabel setCustomAttributedText:line1];
    [alertLucky.secondLineLabel setCustomAttributedText:line2];
    [alertLucky.Line3Label setCustomAttributedText:line3];
    alertLucky.urlString = urlString;
    
    [alertLucky show];
}

-(void)actionAfterFailRequestMaxTries:(int)tag
{
    [_act stopAnimating];
    [_refreshControll endRefreshing];
    
    if (_page == 1) {
        _tableView.contentOffset = CGPointZero;
    }
    
    _tableView.tableFooterView = _loadingView.view;
}

@end
