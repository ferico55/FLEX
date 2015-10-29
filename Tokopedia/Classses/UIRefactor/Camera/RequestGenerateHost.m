//
//  requestGenerateHost.m
//  Tokopedia
//
//  Created by IT Tkpd on 3/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestGenerateHost.h"

#import "UserAuthentificationManager.h"

@implementation RequestGenerateHost
{
    __weak RKObjectManager *_objectManagerGenerateHost;
    __weak RKManagedObjectRequestOperation *_requestGenerateHost;
    
    NSOperationQueue *_operationQueue;
    GenerateHost *_generatehost;
    NSInteger _requestCount;
}

#pragma mark Request Generate Host
-(void)configureRestkitGenerateHost
{
    _operationQueue = [NSOperationQueue new];
    _objectManagerGenerateHost =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[GenerateHost class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GenerateHostResult class]];
    
    RKObjectMapping *generatedhostMapping = [RKObjectMapping mappingForClass:[GeneratedHost class]];
    [generatedhostMapping addAttributeMappingsFromDictionary:@{
                                                               API_SERVER_ID_KEY:API_SERVER_ID_KEY,
                                                               API_UPLOAD_HOST_KEY:API_UPLOAD_HOST_KEY,
                                                               API_USER_ID_KEY:API_USER_ID_KEY
                                                               }];
    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_GENERATED_HOST_KEY
                                                                                  toKeyPath:API_GENERATED_HOST_KEY
                                                                                withMapping:generatedhostMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_UPLOAD_GENERATE_HOST_PATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerGenerateHost addResponseDescriptor:responseDescriptor];
}

-(void)cancelGenerateHost
{
    [_requestGenerateHost cancel];
    _requestGenerateHost = nil;
    
    [_objectManagerGenerateHost.operationQueue cancelAllOperations];
    _objectManagerGenerateHost = nil;
}

- (void)requestGenerateHost
{
    if(_requestGenerateHost.isExecuting) return;
    
    [self configureRestkitGenerateHost];

    _requestCount ++;
    
    NSTimer *timer;
    UserAuthentificationManager *userManager = [UserAuthentificationManager new];
    NSString *userID = [userManager getUserId];
    
    NSString *newAdd = [NSString stringWithFormat:@"%d", _isNotUsingNewAdd?0:1];
    NSString *uploadVersion = [NSString stringWithFormat:@"%d", _isNotUsingNewAdd?0:2];
   
    NSDictionary* param = @{
                            API_ACTION_KEY : API_ACTION_GENERATE_HOST,
                            kTKPD_USERIDKEY : userID,
                            @"new_add" : newAdd, //product,contact,
                            @"upload_version" :uploadVersion
                            };
    
    _requestGenerateHost = [_objectManagerGenerateHost appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_UPLOAD_GENERATE_HOST_PATH parameters:param];
    
    [_requestGenerateHost setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"%@",operation.HTTPRequestOperation.responseString);
        [self requestSuccessGenerateHost:mappingResult withOperation:operation];
        [timer invalidate];
         
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFailureGenerateHost:error];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestGenerateHost];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutGenerateHost) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}


-(void)requestSuccessGenerateHost:(id)object withOperation:(RKObjectRequestOperation*)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    _generatehost = info;
    NSString *statusstring = _generatehost.status;
    BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessGenerateHost:object];
    }
}

-(void)requestFailureGenerateHost:(NSError*)object
{
    if(_delegate!=nil && [_delegate respondsToSelector:@selector(failedGenerateHost:)])
    {
        NSArray *errors;
        if(object.code == -1011) {
            errors = @[@"Mohon maaf, terjadi kendala pada server"];
        } else if (object.code==-1009 || object.code==-999) {
            errors = @[@"Tidak ada koneksi internet"];
        } else {
            errors = @[object.localizedDescription];
        }
        [_delegate failedGenerateHost:errors];
    }
}

-(void)requestProcessGenerateHost:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id info = [result objectForKey:@""];
            _generatehost = info;
            NSString *statusstring = _generatehost.status;
            BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if (_generatehost.message_error) {
                    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:_generatehost.message_error delegate:_delegate];
                    [alert show];
                }
                else
                {
                    if (_generatehost.result.generated_host == 0) {
                        if (_requestCount<3) {
                            [self requestGenerateHost];
                        }
                        else{
                            //error
                            [_delegate failedGenerateHost:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULT]];
                        }
                    }
                    else{
                        [_delegate successGenerateHost:_generatehost];
                    }
                }
            }
        }
        else
        {
            NSError *error = object;
            if (!([error code] == NSURLErrorCancelled)){
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:_delegate cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeoutGenerateHost
{
    [self cancelGenerateHost];
}

@end
