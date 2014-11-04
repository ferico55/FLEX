//
//  URLCacheController.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/23/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "URLCacheConnection.h"
#import "URLCacheAlert.h"

@interface URLCacheController : NSObject

@property (nonatomic, copy) NSString *dataPath;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) NSDate *fileDate;
@property (nonatomic, strong) NSMutableArray *urlArray;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSError *error;
@property (nonatomic) float URLCacheInterval;

- (void)initCacheWithDocumentPath:(NSString*)path;
- (void) getFileModificationDate;
- (void) clearCache;
- (void) connectionDidFinish:(URLCacheConnection *)theConnection;


@end
