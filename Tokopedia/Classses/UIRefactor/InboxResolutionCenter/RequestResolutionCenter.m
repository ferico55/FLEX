//
//  RequestResolutionCenter.m
//  Tokopedia
//
//  Created by Renny Runiawati on 10/9/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestResolutionCenter.h"

@interface RequestResolutionCenter()<TokopediaNetworkManagerDelegate>
{
    TokopediaNetworkManager *_networkManagerReplayValidation;
    TokopediaNetworkManager *_networkManagerResolutionPicture;
    TokopediaNetworkManager *_networkManagerReplaySubmit;
}

@end

typedef enum {
    TagRequestResolutionReplayValidation = 10,
    TagRequestResolutionResolutionPicture = 11,
    TagRequestResolutionReplaySubmit = 12,
}TagRequestResolution;

@implementation RequestResolutionCenter
{
    NSDictionary *_paramReplayValidation;
    NSDictionary *_paramResolutionPicture;
    NSDictionary *_paramReplaySubmit;
}

-(TokopediaNetworkManager*)networkManagerReplayValidation
{
    if (!_networkManagerReplayValidation) {
        _networkManagerReplayValidation = [TokopediaNetworkManager new];
        _networkManagerReplayValidation.tagRequest = TagRequestResolutionReplayValidation;
        _networkManagerReplayValidation.delegate = self;
    }
    return _networkManagerReplayValidation;
}

-(TokopediaNetworkManager*)networkManagerResolutionPicture
{
    if (!_networkManagerResolutionPicture) {
        _networkManagerResolutionPicture = [TokopediaNetworkManager new];
        _networkManagerResolutionPicture.tagRequest = TagRequestResolutionReplaySubmit;
        _networkManagerResolutionPicture.delegate = self;
    }
    return _networkManagerResolutionPicture;
}

-(TokopediaNetworkManager*)networkManagerReplaySubmit
{
    if (!_networkManagerReplaySubmit) {
        _networkManagerReplaySubmit = [TokopediaNetworkManager new];
        _networkManagerReplaySubmit.tagRequest = TagRequestResolutionReplaySubmit;
        _networkManagerReplaySubmit.delegate = self;
    }
    return _networkManagerReplaySubmit;
}

-(void)doRequestReplay
{
    [[self networkManagerReplayValidation] doRequest];
}

#pragma mark - Network Manager Delegate
-(void)setParamReplayValidationFromID:(NSString*)resolutionID
                              message:(NSString*)message
                               photos:(NSString*)photos
                              serveID:(NSString*)serverID
                     editSolutionFlag:(NSString*)editSolutionFlag
                             solution:(NSString*)solution
                         refundAmount:(NSString*)refundAmount
                         flagReceived:(NSString*)flagReceived
                          troubleType:(NSString*)troubleType
{
    NSDictionary *param = @{@"action"            :@"reply_conversation_validation",
                            @"resolution_id"     :resolutionID?:@"",
                            @"reply_msg"         :message?:@"",
                            @"photos"            :photos?:@"",
                            @"server_id"         :serverID?:@"",
                            @"edit_solution_flag":editSolutionFlag?:@"",
                            @"solution"          :solution?:@"",
                            @"refund_amount"     :refundAmount?:@"",
                            @"flag_received"     :flagReceived?:@"",
                            @"trouble_type"      :troubleType?:@""
                            };
    _paramReplayValidation = param;
}

-(void)setParamResolutionImageFromID:(NSString*)resolutionID
                    attachmentString:(NSString*)attachmentString
                            serverID:(NSString*)serverID
{
    NSDictionary *param = @{@"action"            :@"create_resolution_picture",
                            @"resolution_id"     :resolutionID?:@"",
                            @"attachment_string" :attachmentString?:@"",
                            @"server_id"         :serverID?:@""
                            };
    _paramResolutionPicture = param;
}

-(void)setParamPostKey:(NSString*)postKey
          fileUploaded:(NSString*)fileUploaded
          resolutionID:(NSString*)resolutionID
{
    NSDictionary *param = @{@"action"            :@"reply_conversation_submit",
                            @"resolution_id"     :resolutionID?:@"",
                            @"post_key"          :postKey?:@"",
                            @"file_uploaded"     :fileUploaded?:@""
                            };
    _paramReplaySubmit = param;
}

-(NSDictionary *)getParameter:(int)tag
{
    switch (tag) {
        case TagRequestResolutionReplayValidation:
            return _paramReplayValidation;
            break;
        case TagRequestResolutionResolutionPicture:
            return _paramResolutionPicture;
            break;
        case TagRequestResolutionReplaySubmit:
            return _paramReplaySubmit;
            break;
        default:
            break;
    }
    
    return @{};
}

-(NSString *)getPath:(int)tag
{
    switch (tag) {
        case TagRequestResolutionReplayValidation:
            return @"resolution-center.pl";
            break;
        case TagRequestResolutionResolutionPicture:
            return @"action/upload-image-helper.pl";
            break;
        case TagRequestResolutionReplaySubmit:
            return @"resolution-center.pl";
            break;
        default:
            break;
    }
    
    return nil;
}

-(id)getObjectManager:(int)tag
{
    switch (tag) {
        case TagRequestResolutionReplayValidation:
            return [self objectManagerValidation];
            break;
        case TagRequestResolutionResolutionPicture:
            return [self objectManagerPicture];
            break;
        case TagRequestResolutionReplaySubmit:
            return [self objectManagerSubmit];
            break;
        default:
            break;
    }
    
    return nil;
}

-(NSString *)getRequestStatus:(id)result withTag:(int)tag
{
    switch (tag) {
        case TagRequestResolutionReplayValidation:
        {
            ResolutionValidation *reso = [((RKMappingResult *) result).dictionary objectForKey:@""];
            return reso.status;
        }
            break;
        case TagRequestResolutionResolutionPicture:
        {
            ResolutionPicture *reso = [((RKMappingResult *) result).dictionary objectForKey:@""];
            return reso.status;
        }
            break;
        case TagRequestResolutionReplaySubmit:
        {
            ResolutionSubmit *reso = [((RKMappingResult *) result).dictionary objectForKey:@""];
            return reso.status;
        }
            break;
        default:
            break;
    }
    
    return nil;
}

-(void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag
{

}

-(void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
    NSError *error = errorResult;
    NSArray *errors;
    
    if (error.code==-1009 || error.code==-999) {
        errors = @[@"Tidak ada koneksi internet"];
    } else {
        errors = @[@"Mohon maaf, terjadi kendala pada server"];
    }
    
    StickyAlertView *failedAlert = [[StickyAlertView alloc]initWithErrorMessages:errors?:@[@"Error"] delegate:_delegate];
    [failedAlert show];
}

-(void)actionAfterFailRequestMaxTries:(int)tag
{
    
}

-(RKObjectManager*)objectManagerValidation
{
    RKObjectManager *objectManager = [RKObjectManager sharedClient];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[ResolutionValidation mapping]
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:nil
                                                                                           keyPath:[self getPath:TagRequestResolutionReplayValidation]
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    return objectManager;
}

-(RKObjectManager*)objectManagerSubmit
{
    RKObjectManager *objectManager = [RKObjectManager sharedClient];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[ResolutionSubmit mapping]
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:nil
                                                                                           keyPath:[self getPath:TagRequestResolutionReplaySubmit]
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    return objectManager;
}

-(RKObjectManager*)objectManagerPicture
{
    RKObjectManager *objectManager = [RKObjectManager sharedClient];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[ResolutionPicture mapping]
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:nil
                                                                                           keyPath:[self getPath:TagRequestResolutionResolutionPicture]
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    return objectManager;
}

@end
