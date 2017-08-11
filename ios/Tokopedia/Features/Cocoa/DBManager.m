//
//  SqliteLibViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/3/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "DBManager.h"
#import "sqlite3.h"

@interface DBManager ()

@end


/** create the instance of SQLite database: **/
@implementation DBManager

static DBManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

+(DBManager*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance openDatabase];
    }
    return sharedInstance;
}

-(BOOL)createDB{
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"TokopediaDB.db"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "create table if not exists studentsDetail (regno integer primary key, name text, department text, year text)";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }
            sqlite3_close(database);
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    return isSuccess;
}

// Creates a writable copy of the bundled default database in the application Documents directory.
- (void)createEditableCopyOfDatabaseIfNeeded {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"TokopediaDB.db"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [documentsDirectory stringByAppendingPathComponent: @"TokopediaDB.db"]];
    if (success)
        return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"TokopediaDB.db"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
    // Build the path to the database file
   // databasePath = [[NSString alloc] initWithString:
    //                [defaultDBPath stringByAppendingPathComponent: @"TokopediaDB.db"]];
}

- (NSArray*)LoadDataQueryDepartement:(NSString*)query
{
    NSString *d_id;
    NSString *name;
    
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        const char *query_stmt = [query UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSMutableDictionary* dict = [NSMutableDictionary new];
                //[dict removeAllObjects];
                if ( sqlite3_column_type(statement, 0) != SQLITE_NULL )
                    d_id = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                if (d_id != nil) {
                    [dict setObject:d_id forKey:@"d_id"];
                }
                //[dict setObject:d_id forKey:@"id"];
                if ( sqlite3_column_type(statement, 1) != SQLITE_NULL )
                    name = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)];
                if (name != nil) {
                    [dict setObject:name forKey:@"title"];
                }
                if ( sqlite3_column_type(statement, 2) != SQLITE_NULL )
                    name = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)];
                if (name != nil) {
                    [dict setObject:name forKey:@"tree"];
                }
                [resultArray addObject:dict];
            }
            //sqlite3_reset(statement);
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
        return resultArray;
    }
    return nil;
}

- (NSArray*)LoadDataQueryLocationName:(NSString*)query
{
    NSString *districtname;
    
    const char *dbpath = [databasePath UTF8String];
    
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        const char *query_stmt = [query UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                //NSMutableDictionary* dict = [NSMutableDictionary new];
                //[dict removeAllObjects];
                if ( sqlite3_column_type(statement, 0) != SQLITE_NULL )
                    districtname = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                if (districtname != nil) {
                    [resultArray addObject:districtname];
                }
            }
            //sqlite3_reset(statement);
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
        return resultArray;
    }
    return nil;
}

- (NSArray*)LoadDataQueryLocationNameAndID:(NSString*)query
{
    NSString *districtname;
    NSString *districtID;
    
    const char *dbpath = [databasePath UTF8String];
    
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        const char *query_stmt = [query UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                //NSMutableDictionary* dict = [NSMutableDictionary new];
                //[dict removeAllObjects];
                if ( sqlite3_column_type(statement, 0) != SQLITE_NULL )
                {
                    districtname = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                }
                if ( sqlite3_column_type(statement, 1) != SQLITE_NULL )
                {
                    districtID = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                }
                if (districtname != nil) {
                    NSDictionary *nameAndID = @{@"name":districtname, @"ID":districtID};
                    [resultArray addObject:nameAndID];
                }
            }
            //sqlite3_reset(statement);
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
        return resultArray;
    }
    return nil;
}

- (NSArray*)LoadDataQueryLocationValue:(NSString*)query
{
    NSString *districtvalue;
    
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        const char *query_stmt = [query UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                //NSMutableDictionary* dict = [NSMutableDictionary new];
                //[dict removeAllObjects];
                if ( sqlite3_column_type(statement, 0) != SQLITE_NULL )
                    districtvalue = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                if (districtvalue != nil) {
                    [resultArray addObject:districtvalue];   
                }
            }
            //sqlite3_reset(statement);
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
        return resultArray;
    }
    return nil;
}

-(NSDictionary*)dataFromDepartmentID:(NSString*)departmentID
{
    NSString *tree;
    NSString *parent;
    
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString * query = [NSString stringWithFormat:@"select tree,parent from ws_department where d_id=\"%@\"",departmentID];
        const char *query_stmt = [query UTF8String];
        
        NSMutableDictionary *data = [NSMutableDictionary new];
        
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                //[dict removeAllObjects];
                if ( sqlite3_column_type(statement, 0) != SQLITE_NULL )
                    tree = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                [data setObject:tree forKey:@"tree"];
                if ( sqlite3_column_type(statement, 1) != SQLITE_NULL )
                    parent = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                [data setObject:parent forKey:@"parent"];
            }
            sqlite3_reset(statement);
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
        return [data copy];
    }
    return nil;
}


-(void)openDatabase
{
    [self createEditableCopyOfDatabaseIfNeeded];
    
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        //Database Opened
        NSLog(@"Database opened");
    }
    else
    {
        NSLog(@"Database cannot be opened");
    }
}

-(void)closeDatabase
{
    sqlite3_close(database);
}

@end
