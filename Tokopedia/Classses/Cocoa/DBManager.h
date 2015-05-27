//
//  SqliteLibViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/3/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBManager : NSObject
{
    NSString *databasePath;
}

+(DBManager*)getSharedInstance;
-(BOOL)createDB;
- (NSArray*)LoadDataQueryDepartement:(NSString*)query;
- (NSArray*)LoadDataQueryLocationName:(NSString*)query;
- (NSArray*)LoadDataQueryLocationValue:(NSString*)query;

- (NSArray*)LoadDataQueryLocationNameAndID:(NSString*)query;

- (NSDictionary*)dataFromDepartmentID:(NSString*)departmentID;

@end
