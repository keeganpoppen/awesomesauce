//
//  AwesomeDataPersistenceHandler.h
//  awesomesauce
//
//  Created by Keegan Poppen on 3/31/11.
//  Copyright 2011 Lord Keeganus Industries. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Composition : NSManagedObject {}

@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *data;

@end


@interface AwesomeDataPersistenceHandler : NSObject {
	NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(id)init;
-(void)dealloc;
-(void)saveContext;

-(NSURL *)applicationDocumentsDirectory;
-(NSArray*)getAllSavedCompositions;

-(NSDictionary*)getDataForComposition:(NSString*)title;
-(Composition*)getManagedObjectForComposition:(NSString*)title;
-(void)setData:(NSDictionary*)data forComposition:(NSString*)title;

@end
