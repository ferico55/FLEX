//
//  RequestUploadImageSteps.m
//  Tokopedia
//
//  Created by Renny Runiawati on 10/12/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestUploadImageSteps.h"

#import "RequestUploadImageValidation.h"
#import "RequestUploadImageHelper.h"
#import "RequestUploadImageSubmit.h"

@interface RequestUploadImageSteps()<RequestUploadImageHelperDelegate, RequestUploadImageValidationDelegate, RequestUploadImageSubmitDelegate>
{
    RequestUploadImageValidation *_requestUploadImageValidation;
    RequestUploadImageHelper *_requestUploadImageHelper;
    RequestUploadImageSubmit *_requestUploadImageSubmit;
}

@end

@implementation RequestUploadImageSteps
{
    NSString *_post_key;
    NSString *_file_uploaded;
}

-(RequestUploadImageValidation*)requestUploadImageValidation
{
    if (!_requestUploadImageValidation) {
        _requestUploadImageValidation = [RequestUploadImageValidation new];
        _requestUploadImageValidation.delegate = self;
    }
    return _requestUploadImageValidation;
}

-(RequestUploadImageHelper*)requestUploadImageHelper
{
    if (!_requestUploadImageHelper) {
        _requestUploadImageHelper = [RequestUploadImageHelper new];
        _requestUploadImageHelper.delegate = self;
    }
    return _requestUploadImageHelper;
}

-(RequestUploadImageSubmit*)requestUploadImageSubmit
{
    if (!_requestUploadImageSubmit) {
        _requestUploadImageSubmit = [RequestUploadImageSubmit new];
        _requestUploadImageSubmit.delegate = self;
    }
    return _requestUploadImageSubmit;
}

-(void)doRequest
{
    [[self requestUploadImageValidation] setParam:_paramValidation];
    [[self requestUploadImageValidation] setPath:_pathValidation];
    [[self requestUploadImageValidation] doRequest];
}

-(UIViewController*)lastViewController
{
    UIViewController * lastVC = [((UINavigationController*)((UITabBarController*)[[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentedViewController]).selectedViewController). viewControllers lastObject];
    return lastVC;
}

-(void)showAlertSuccess:(NSArray*)successStatus
{
    [_delegate didSuccessUploadImage:_tag];
    
    NSString *customSuccessMessage = nil;
    if(_delegate && [_delegate respondsToSelector:@selector(setSuccessMessage:)]) {
        customSuccessMessage = [_delegate setSuccessMessage:_tag]?:@"";
    }

    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[customSuccessMessage]?:successStatus delegate:[self lastViewController]];
    [alert show];
    
}

-(void)showAlertFailedReplayConversation:(NSArray*)errorMessage
{
    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessage?:@[@"Maaf, Permohonan Anda tidak dapat diproses saat ini. Mohon dicoba kembali."] delegate:[self lastViewController]];
    [alert show];
}

-(void)setPostKey:(NSString *)postKey
{
    if ([[_paramValidation objectForKey:@"photos"] isEqualToString:@""]) {
        [self showAlertSuccess:nil];
        return;
    }
    
    if (postKey && ![postKey isEqualToString:@""]) {
        _post_key = postKey;
        [self requestUploadImageHelper].upload_host = _generatedHost.upload_host;
        [[self requestUploadImageHelper] setParam:_paramImage?:@{}];
        [[self requestUploadImageHelper] doRequest];
    }
    
}

-(void)setFileUploaded:(NSString *)fileUploaded
{
    if (fileUploaded && ![fileUploaded isEqualToString:@""]) {
        NSMutableDictionary *param = [NSMutableDictionary new];
        [param addEntriesFromDictionary:_paramSubmit];
        [param setObject:_post_key forKey:@"post_key"];
        [param setObject:fileUploaded forKey:@"file_uploaded"];
        [[self requestUploadImageSubmit] setParam:[param copy]];
        [[self requestUploadImageSubmit] setPath:_pathSubmit];
        [[self requestUploadImageSubmit] doRequest];
    }
}

-(void)successSubmitMessage:(NSArray *)successMessage
{
    [self showAlertSuccess:successMessage];

}

-(void)actionAfterFailRequestMaxTries:(int)tag
{

}

@end
