//
//  RequestResolutionCenter.m
//  Tokopedia
//
//  Created by Renny Runiawati on 10/9/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestResolutionCenter.h"
#import "RequestUploadImageSteps.h"

@interface RequestResolutionCenter()<TokopediaNetworkManagerDelegate, RequestUploadImageDelegate>
{
    RequestUploadImageSteps *_requestUploadImageReplay;
    RequestUploadImageSteps *_requestUploadImageCreate;
}

@end

@implementation RequestResolutionCenter
{
    NSDictionary *_paramValidation;
    NSDictionary *_paramResolutionPicture;
    NSDictionary *_paramSubmit;
}

-(RequestUploadImageSteps*)requestUploadImageReplay
{
    if (!_requestUploadImageReplay) {
        _requestUploadImageReplay = [RequestUploadImageSteps new];
        _requestUploadImageReplay.delegate = self;
        _requestUploadImageReplay.tag = 10;
    }
    return _requestUploadImageReplay;
}

-(RequestUploadImageSteps*)requestUploadImageCreate
{
    if (!_requestUploadImageCreate) {
        _requestUploadImageCreate = [RequestUploadImageSteps new];
        _requestUploadImageCreate.delegate = self;
        _requestUploadImageCreate.tag = 11;
    }
    return _requestUploadImageCreate;
}

-(void)doRequestReplay
{
    [[self requestUploadImageReplay] doRequest];
}

-(void)doRequestCreate
{
    [[self requestUploadImageCreate] doRequest];
}

#pragma mark - Methods
-(void)setParamReplayValidationFromID:(NSString*)resolutionID
                              message:(NSString*)message
                               photos:(NSString*)photos
                              serverID:(NSString*)serverID
                     editSolutionFlag:(NSString*)editSolutionFlag
                             solution:(NSString*)solution
                         refundAmount:(NSString*)refundAmount
                         flagReceived:(NSString*)flagReceived
                          troubleType:(NSString*)troubleType
                               action:(NSString*)action
{
    NSMutableArray *paramPhotos = [NSMutableArray new];
    NSArray *allPhotos = [photos componentsSeparatedByString:@"~"];
    for (NSString *photo in allPhotos) {
        if (![photo isEqualToString:@""]) {
            [paramPhotos addObject:photo];
        }
    }
    NSString *photo = [[[paramPhotos copy] valueForKey:@"description"]componentsJoinedByString:@"~"];
    
    NSDictionary *param = @{@"action"            :action?:@"",
                            @"resolution_id"     :resolutionID?:@"",
                            @"reply_msg"         :message?:@"",
                            @"photos"            :photo?:@"",
                            @"server_id"         :serverID?:@"",
                            @"edit_solution_flag":editSolutionFlag?:@"",
                            @"solution"          :solution?:@"",
                            @"refund_amount"     :refundAmount?:@"",
                            @"flag_received"     :flagReceived?:@"",
                            @"trouble_type"      :troubleType?:@"",
                            @"remark"            :message?:@""
                            };
    _paramValidation = param;
    
    [self setParamResolutionImageFromID:resolutionID attachmentString:photo serverID:serverID];
    
    NSMutableArray *actionSubmitArray = [NSMutableArray new];
    [actionSubmitArray addObjectsFromArray:[action componentsSeparatedByString:@"_"]];
    [actionSubmitArray removeLastObject];
    NSString * actionSubmit = [[[actionSubmitArray copy] valueForKey:@"description"] componentsJoinedByString:@"_"];
    actionSubmit = [actionSubmit stringByAppendingString:@"_submit"];
    [self setParamresolutionID:resolutionID action:actionSubmit];
    
    [self adjustParameterImageReplay];
}

-(void)setParamCreateValidationFromID:(NSString *)orderID flagReceived:(NSString *)flagReceived troubleType:(NSString *)troubleType solution:(NSString *)solution refundAmount:(NSString *)refundAmount remark:(NSString *)remark photos:(NSString *)photos serverID:(NSString *)serverID
{
    NSMutableArray *paramPhotos = [NSMutableArray new];
    NSArray *allPhotos = [photos componentsSeparatedByString:@"~"];
    for (NSString *photo in allPhotos) {
        if (![photo isEqualToString:@""]) {
            [paramPhotos addObject:photo];
        }
    }
    NSString *photo = [[[paramPhotos copy] valueForKey:@"description"]componentsJoinedByString:@"~"];
    NSString *action = @"create_resolution_validation";
    
    NSDictionary *param = @{@"action"            :action?:@"",
                            @"order_id"          :orderID?:@"",
                            @"remark"            :remark?:@"",
                            @"photos"            :photo?:@"",
                            @"server_id"         :serverID?:@"",
                            @"solution"          :solution?:@"",
                            @"refund_amount"     :refundAmount?:@"",
                            @"flag_received"     :flagReceived?:@"",
                            @"trouble_type"      :troubleType?:@"",
                            @"app_new"           :@"1"              //harus kasi image buat create reso
                            };
    _paramValidation = param;
    
    [self setParamCreateResolutionImageFromID:orderID attachmentString:photo serverID:serverID];
    [self setParamCreateResolutionID:orderID action:@"create_resolution_submit"];
    
    [self adjustParameterImageCreate];
    
}

-(void)adjustParameterImageReplay
{
    [self requestUploadImageReplay].paramValidation = _paramValidation;
    [self requestUploadImageReplay].paramImage = _paramResolutionPicture;
    [self requestUploadImageReplay].paramSubmit = _paramSubmit;
    [self requestUploadImageReplay].pathValidation = [self requestUploadImageReplay].pathSubmit = @"action/resolution-center.pl";
    [self requestUploadImageReplay].generatedHost = _generatedHost;
}

-(void)adjustParameterImageCreate
{
    [self requestUploadImageCreate].paramValidation = _paramValidation;
    [self requestUploadImageCreate].paramImage = _paramResolutionPicture;
    [self requestUploadImageCreate].paramSubmit = _paramSubmit;
    [self requestUploadImageCreate].pathValidation = [self requestUploadImageCreate].pathSubmit = @"action/resolution-center.pl";
    [self requestUploadImageCreate].generatedHost = _generatedHost;
}

-(void)setParamResolutionImageFromID:(NSString*)resolutionID
                    attachmentString:(NSString*)attachmentString
                            serverID:(NSString*)serverID
{
    NSDictionary *param = @{@"action"            :@"create_resolution_picture",
                            @"resolution_id"     :resolutionID?:@"",
                            @"attachment_string" :attachmentString?:@"",
                            @"server_id"         :serverID?:@"",
                            @"user_id"           :@(_generatedHost.user_id)?:@""
                            };
    _paramResolutionPicture = param;
}

-(void)setParamCreateResolutionImageFromID:(NSString*)orderID
                          attachmentString:(NSString*)attachmentString
                                  serverID:(NSString*)serverID
{
    NSDictionary *param = @{@"action"            :@"create_resolution_picture",
                            @"order_id"          :orderID?:@"",
                            @"attachment_string" :attachmentString?:@"",
                            @"server_id"         :serverID?:@"",
                            @"user_id"           :@(_generatedHost.user_id)?:@""
                            };
    _paramResolutionPicture = param;
}

-(void)setParamresolutionID:(NSString*)resolutionID
                action:(NSString*)action
{
    NSDictionary *param = @{@"action"            :action,
                            @"resolution_id"     :resolutionID?:@""
                            };
    _paramSubmit = param;
}

-(void)setParamCreateResolutionID:(NSString*)orderID
                           action:(NSString*)action
{
    NSDictionary *param = @{@"action"       :action,
                            @"order_id"     :orderID?:@""
                            };
    _paramSubmit = param;
}

-(NSDictionary *)getParameter:(int)tag
{
    return @{};
}

-(NSString *)getPath:(int)tag
{
    return @"";
}

-(id)getObjectManager:(int)tag
{
    return nil;
}

-(NSString *)getRequestStatus:(id)result withTag:(int)tag
{
    return nil;
}

-(UIViewController*)lastViewController
{
    UIViewController * lastVC = [((UINavigationController*)((UITabBarController*)[[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentedViewController]).selectedViewController). viewControllers lastObject];
    return lastVC;
}

-(void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag
{

}

-(NSString *)setSuccessMessage:(NSInteger)tag
{
    NSString *successMessage = @"";
    if (tag == 10) {
        NSInteger isChangeSolution = [[_paramValidation objectForKey:@"edit_solution_flag"] integerValue];
        successMessage = (isChangeSolution == 1)?@"Anda telah berhasil mengubah solusi":@"Sukses mengirim pesan diskusi";
    }
    else if (tag == 11)
    {
        successMessage = @"Anda telah berhasil membuka komplain.";
    }

    return successMessage;
}

-(void)didSuccessUploadImage:(NSInteger)tag
{
    switch (tag) {
        case 10:
            [_delegate didSuccessReplay];
            break;
        case 11:
            [_delegate didSuccessCreate];
            break;
        default:
            break;
    }
}

@end
