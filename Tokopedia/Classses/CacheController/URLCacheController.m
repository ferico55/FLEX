//
//  URLCacheController.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/23/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "URLCacheController.h"

@implementation URLCacheController

- (void)initCacheWithDocumentPath:(NSString*)path
{
	/* create path to cache directory inside the application's Documents directory */
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //_dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:path];
    //NSString* path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    _dataPath = path;
    
	/* check for existence of cache directory */
	if ([[NSFileManager defaultManager] fileExistsAtPath:_dataPath]) {
		return;
	}
    
	/* create a new cache directory */
	if (![[NSFileManager defaultManager] createDirectoryAtPath:_dataPath
								   withIntermediateDirectories:NO
													attributes:nil
														 error:nil]) {
		URLCacheAlertWithError(_error);
		return;
	}

}

/* get modification date of the current cached image */
- (void) getFileModificationDate
{
	/* default date if file doesn't exist (not an error) */
	_fileDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    
	if ([[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
		/* retrieve file attributes */
		NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:_filePath error:nil];
		if (attributes != nil) {
			_fileDate = [attributes fileModificationDate];
		}
		else {
			URLCacheAlertWithError(_error);
		}
	}
    
    /* remove cache with interval */
    [self clearCache];
}

- (void) connectionDidFinish:(URLCacheConnection *)theConnection
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:_filePath] == YES) {

		/* apply the modified date policy */

		[self getFileModificationDate];
		NSComparisonResult result = [theConnection.lastModified compare:_fileDate];
		if (result == NSOrderedDescending) {
			/* file is outdated, so remove it */
			if (![[NSFileManager defaultManager] removeItemAtPath:_filePath error:nil]) {
				//URLCacheAlertWithError(error);
			}
		}
	}

	if ([[NSFileManager defaultManager] fileExistsAtPath:_filePath] == NO) {
		/* file doesn't exist, so create it */
		[[NSFileManager defaultManager] createFileAtPath:_filePath
												contents:theConnection.receivedData
											  attributes:nil];

		NSLog(@"not found in cache or new data available.");
	}
	else {
		NSLog(@"Cached is up to date, updated and no new image available.");
	}

	/* reset the file's modification date to indicate that the URL has been checked */

	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSDate date], NSFileModificationDate, nil];
	if (![[NSFileManager defaultManager] setAttributes:dict ofItemAtPath:_filePath error:nil]) {
		//URLCacheAlertWithError(error);
	}
}


/* removes every file in the cache directory */
- (void) clearCache
{    
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    NSDirectoryEnumerator* en = [fileManager enumeratorAtPath:_dataPath];
    
    NSString* file;
    while (file = [en nextObject])
    {
        NSError *error= nil;
        
        NSString *filepath=[NSString stringWithFormat:[_dataPath stringByAppendingString:@"/%@"],file];
        
        NSDate *filedate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
            /* retrieve file attributes */
            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filepath error:nil];
            if (attributes != nil) {
                filedate = [attributes fileModificationDate];
            }
            else {
                URLCacheAlertWithError(_error);
            }
        }
        
        NSTimeInterval timeinterval = fabs([filedate timeIntervalSinceNow]);
        if (timeinterval > _URLCacheInterval) {
            NSLog(@"File To Delete : %@",file);
            [[NSFileManager defaultManager] removeItemAtPath:[_dataPath stringByAppendingPathComponent:file] error:&error];
        }
    }
    
    ///* remove the cache directory and its contents */
    //if (![[NSFileManager defaultManager] removeItemAtPath:_filePath error:nil]) {
    //    URLCacheAlertWithError(_error);
    //    return;
    //}
    //
    ///* create a new cache directory */
    //if (![[NSFileManager defaultManager] createDirectoryAtPath:_dataPath
    //                               withIntermediateDirectories:NO
    //                                                attributes:nil
    //                                                     error:nil]) {
    //    URLCacheAlertWithError(_error);
    //    return;
    //}
}

@end
