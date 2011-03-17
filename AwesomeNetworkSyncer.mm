//
//  AwesomeNetworkSyncer.mm
//  awesomesauce
//
//  Created by Keegan Poppen on 3/17/11.
//  Copyright 2011 Lord Keeganus Industries. All rights reserved.
//

#import "AwesomeNetworkSyncer.h"

@implementation SquareChangeSync

@synthesize networker;
@synthesize matrixHandler;

-(void)receiveData:(NSDictionary*)data fromTime:(NSTimeInterval)updateTime {
	NSString *matrix = (NSString*)[data objectForKey:@"matrix"];
	
	int row = [[data objectForKey:@"row"] intValue];
	int column = [[data objectForKey:@"column"] intValue];
	BOOL value = [[data	objectForKey:@"value"] boolValue];
	
	NSLog(@"Square at (%d,%d) in matrix %@ should change to value: %d", row, column, matrix, value);
	
	if ([matrix caseInsensitiveCompare:@"future"] == NSOrderedSame) {
		//TODO: set the square in the future matrix. This also implies the JITness of creating a future matrix if !exists
	} else {
		//TODO: set square in the current matrix
	}

	
}

-(void)presentMatrixSquareChangedAtRow:(int)row andColumn:(int)column toValue:(BOOL)squareValue {
	[self sendSquareChangedInMatrix:@"present" AtRow:row andColumn:column toValue:squareValue];
}

-(void)futureMatrixSquareChangedAtRow:(int)row andColumn:(int)column toValue:(BOOL)squareValue {
	[self sendSquareChangedInMatrix:@"future" AtRow:row andColumn:column toValue:squareValue];	
}

-(void)sendSquareChangedInMatrix:(NSString*)matrix AtRow:(int)row andColumn:(int)column toValue:(BOOL)squareValue {
	[networker sendData:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:row],@"row",
																	[NSNumber numberWithInt:column], @"column",
																	[NSNumber numberWithBool:squareValue], @"value",
																	matrix, @"matrix", nil] 
		  withEventName:@"square_change"];
}

@end

	 
@implementation TrackAddSync
	 
@synthesize networker;
@synthesize matrixHandler;

-(void)receiveData:(NSDictionary*)data fromTime:(NSTimeInterval)updateTime {
	//TODO: actually add said track
}


-(NSTimeInterval)sendTrackAddedWithId:(int)trackId {
	return [networker sendData:[NSDictionary dictionaryWithObjectsAndKeys:@"id",[NSNumber numberWithInt:trackId],nil] withEventName:@"track_add"];
}	 
	 
@end

	 

@implementation AwesomeNetworkSyncer

@synthesize networker;
@synthesize squareSync;
@synthesize trackAddSync;


- (id)init {
	self = [super init];
	if (self) {
		squareSync = [[SquareChangeSync alloc] init];
		[networker registerEventHandler:@"square_change" withSyncee:squareSync];
		
		trackAddSync = [[TrackAddSync alloc] init];
		[networker registerEventHandler:@"track_add" withSyncee:trackAddSync];
	}
	return self;
}


@end
