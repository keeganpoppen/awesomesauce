//
//  AwesomeNetworkSyncer.mm
//  awesomesauce
//
//  Created by Keegan Poppen on 3/17/11.
//  Copyright 2011 Lord Keeganus Industries. All rights reserved.
//

#import "AwesomeNetworkSyncer.h"
#import "awesomesauceAppDelegate.h"

@implementation SquareChangeSync

@synthesize networker;
@synthesize matrixHandler;

-(void)receiveData:(NSDictionary*)data fromTime:(NSTimeInterval)updateTime {
	NSString *matrix = (NSString*)[data objectForKey:@"matrix"];
	
	int row = [[data objectForKey:@"row"] intValue];
	int column = [[data objectForKey:@"column"] intValue];
	BOOL value = [[data	objectForKey:@"value"] boolValue];
	int track_id = [[data objectForKey:@"track_id"] intValue];
	
	NSLog(@"Square at (%d,%d) in matrix %@ should change to value: %d on track: %d", row, column, matrix, value, track_id);
	
	if ([matrix caseInsensitiveCompare:@"future"] == NSOrderedSame) {
		matrixHandler->getMatrix(track_id)->setFutureSquare(row, column, value);
		//TODO: set the square in the future matrix. This also implies the JITness of creating a future matrix if !exists
	} else {
		matrixHandler->getMatrix(track_id)->setSquare(row, column, value);
		//TODO: set square in the current matrix
	}

	
}

-(void)presentMatrixSquareChangedAtRow:(int)row andColumn:(int)column toValue:(BOOL)squareValue withTrackId:(int)trackId {
	[self sendSquareChangedInMatrix:@"present" AtRow:row andColumn:column toValue:squareValue withTrackId:trackId];
}

-(void)futureMatrixSquareChangedAtRow:(int)row andColumn:(int)column toValue:(BOOL)squareValue withTrackId:(int)trackId {
	[self sendSquareChangedInMatrix:@"future" AtRow:row andColumn:column toValue:squareValue withTrackId:(int)trackId];	
}

-(void)sendSquareChangedInMatrix:(NSString*)matrix AtRow:(int)row andColumn:(int)column toValue:(BOOL)squareValue withTrackId:(int)trackId{
	[networker sendData:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:row],@"row",
																	[NSNumber numberWithInt:column], @"column",
																	[NSNumber numberWithBool:squareValue], @"value",
																	[NSNumber numberWithInt:trackId], @"track_id",
																	matrix, @"matrix", nil] 
		  withEventName:@"square_change"];
}

@end


//handler for track add messages
@implementation TrackAddSync
	 
@synthesize networker;
@synthesize matrixHandler;

-(void)receiveData:(NSDictionary*)data fromTime:(NSTimeInterval)updateTime {
	matrixHandler->addNewMatrix(false);
}


-(NSTimeInterval)sendTrackAddedWithId:(int)trackId {
	return [networker sendData:[NSDictionary dictionaryWithObjectsAndKeys:@"id",[NSNumber numberWithInt:trackId],nil] withEventName:@"track_add"];
}	 
	 
@end


//handler for track remove messages
@implementation TrackRemoveSync

@synthesize networker;
@synthesize matrixHandler;

-(void)receiveData:(NSDictionary*)data fromTime:(NSTimeInterval)updateTime {
	//TODO: actually remove said track
}


-(void)sendTrackRemovedWithId:(int)trackId {
	[networker sendData:[NSDictionary dictionaryWithObjectsAndKeys:@"id",[NSNumber numberWithInt:trackId],nil] withEventName:@"track_remove"];
}

@end


//ASDataSyncee for track removing
@implementation TrackClearSync

@synthesize networker;
@synthesize matrixHandler;

-(void)receiveData:(NSDictionary*)data fromTime:(NSTimeInterval)updateTime {
	int trackId = [[data objectForKey:@"id"] intValue];
	matrixHandler->getMatrix(trackId)->clear();
}

-(void)sendTrackClearedWithId:(int)trackId {
	[networker sendData:[NSDictionary dictionaryWithObjectsAndKeys:@"id",[NSNumber numberWithInt:trackId],nil] withEventName:@"track_clear"];
}

@end


//handler for track add messages
@implementation FutureStartSync

@synthesize networker;
@synthesize matrixHandler;

-(void)receiveData:(NSDictionary*)data fromTime:(NSTimeInterval)updateTime {
	int futureLength = [[data objectForKey:@"length"] intValue];
	int trackId = [[data objectForKey:@"track_id"] intValue];
	matrixHandler->getMatrix(trackId)->startFuture(futureLength);
}

-(void)sendFutureStartWithLength:(int)length withTrackId:(int)trackId {
	[networker sendData:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:length],@"length",
																	[NSNumber numberWithInt:trackId], @"track_id",nil] withEventName:@"future_start"];
}

@end

//handler for track add messages
@implementation InstrumentChangeSync

@synthesize networker;
@synthesize matrixHandler;

-(void)receiveData:(NSDictionary*)data fromTime:(NSTimeInterval)updateTime {
	int intrument_id = [[data objectForKey:@"instrument_id"] intValue];
	int index = [[data objectForKey:@"index"] intValue];
	int track_id = [[data objectForKey:@"track_id"] intValue];
	matrixHandler->getMatrix(track_id)->setOscillator(intrument_id, index);
}

-(void)sendInstrumentChanged:(int)instrument withIndex:(int)index onTrack:(int)trackId {
	[networker sendData:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:instrument], @"instrument_id",
																	[NSNumber numberWithInt:index], @"index",
																	[NSNumber numberWithInt:trackId], @"track_id", nil] withEventName:@"instument_change"];
}

@end
	 

@implementation AwesomeNetworkSyncer

@synthesize networker;
@synthesize squareSync;
@synthesize trackAddSync, trackRemoveSync, futureStartSync;


- (id)initWithNetworker:(AwesomeNetworker*)awesomeNetworker andMatrixHandler:(MatrixHandler*)handler {
	self = [super init];
	if (self) {
		networker = awesomeNetworker;
		
		squareSync = [[SquareChangeSync alloc] init];
		[networker registerEventHandler:@"square_change" withSyncee:squareSync];
		squareSync.networker = networker;
		squareSync.matrixHandler = handler;
		
		trackAddSync = [[TrackAddSync alloc] init];
		[networker registerEventHandler:@"track_add" withSyncee:trackAddSync];
		trackAddSync.networker = networker;
		trackAddSync.matrixHandler = handler;
		
		trackRemoveSync = [[TrackRemoveSync alloc] init];
		[networker registerEventHandler:@"track_remove" withSyncee:trackRemoveSync];
		trackRemoveSync.networker = networker;
		trackRemoveSync.matrixHandler = handler;
		
		futureStartSync = [[FutureStartSync alloc] init];
		[networker registerEventHandler:@"future_start" withSyncee:futureStartSync];
		futureStartSync.networker = networker;
		futureStartSync.matrixHandler = handler;
	}
	return self;
}


@end
