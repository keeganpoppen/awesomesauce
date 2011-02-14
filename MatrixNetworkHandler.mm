//
//  MatrixNetworkHandler.mm
//  awesomesauce
//
//  Created by The Colonel on 2/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/*
 
 TODO: FREE MEMORY AND REMOVE OBSERVERS!!!!!!!!
 
 */

#import "MatrixNetworkHandler.h"
#import "awesomesauceAppDelegate.h"
#import "MatrixHandler.h"

#define NUM_TIMING_TRIES 100


@implementation MatrixNetworkHandler

@synthesize sesh;
@synthesize response_times;

- (id)init {
	self = [super init];
	if (self) {
		//initialize timing infrastructure
		response_times = [[NSMutableDictionary alloc] initWithCapacity:NUM_TIMING_TRIES];
		aggregate_round_trip_times = 0.;
		num_timing_responses = 0;
		
		//set up dispatch on different message types
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeHandler:) name:@"time_sync" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendAllDataHandler:) name:@"send_all_data" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(squareChangeHandler:) name:@"square_change" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackAddedHandler:) name:@"track_added" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackClearedHandler:) name:@"track_cleared" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendSquareChangeNotification:) name:@"squareChangedEvent" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendTrackAddedNotification:) name:@"trackAddedEvent" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendTrackClearedNotification:) name:@"trackClearedEvent" object:nil];
		
		sesh = [[GKSession alloc] initWithSessionID:@"awesomesauce" displayName:nil sessionMode:GKSessionModePeer];
		[sesh setDelegate:self];
		[sesh setDataReceiveHandler:self withContext:nil];
		[sesh setAvailable:YES];
		NSLog(@"starting server in peer mode w/ peerID %@", sesh.peerID);
	}
	return self;
}
		 
- (BOOL) comparePeerID:(NSString*)otherID {
	return [otherID compare:sesh.peerID] == NSOrderedAscending;
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
	
	NSLog(@"peer state change for peer %@ with display name %@", peerID, [sesh displayNameForPeer:peerID]);
	
	switch (state) {
		case GKPeerStateConnected:
		{
			NSLog(@"connected to peer %@", [sesh displayNameForPeer:peerID]);
			
			//this way only one peer tries to send connection junk
			if ([self comparePeerID:peerID]) {
				/*
				NSLog(@"SYNCING CLOCKS");
				for (unsigned i = 0; i < NUM_TIMING_TRIES; ++i) {
					NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:i], @"iter_num",
													[NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]], @"sender_time", nil];
					
					[self sendData:dict withMessageType:@"time_sync" toPeers:[NSArray arrayWithObject:peerID] withDataMode:GKSendDataUnreliable];
					
					//send data using UDP for better numbers / faster results (I think, anyway)
					NSError *err;
					if (![sesh sendData:[NSKeyedArchiver archivedDataWithRootObject:dict] toPeers:[NSArray arrayWithObject:peerID] withDataMode:GKSendDataUnreliable error:&err]) {
						NSLog(@"DATA SEND ERROR: %@", [err localizedDescription]);
					}
					
				}
				 */
				[self sendAllDataToPeer:peerID inSession:session];
			}
		}
			break;
		case GKPeerStateConnecting:
			NSLog(@"connecting");
			break;
		case GKPeerStateAvailable:
			NSLog(@"availability found");
			if ([self comparePeerID:peerID]) {
				NSLog(@"available... gonna try and connect");
				[sesh connectToPeer:peerID withTimeout:30.];
			}
			break;
		case GKPeerStateUnavailable:
			NSLog(@"unavailable");
			break;
		case GKPeerStateDisconnected:
			NSLog(@"disconnected");
			break;
	}

}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
	NSLog(@"cnxn request from peer %@, dawg", peerID);
	NSLog(@"accepting said connection");
	

	NSError *err;
	if (![session acceptConnectionFromPeer:peerID error:&err]) {
		NSLog(@"ERROR: %@", [err localizedDescription]);
	}
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
	NSLog(@"session failed with error %@", [error localizedDescription]);
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
	NSLog(@"connection with peer %@ failed with error: %@", peerID, [error localizedDescription]);
}

/*
 * handlers for incoming messages
 */
- (void) timeHandler:(NSNotification *)notification {
	[notification retain];
	
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] initWithDictionary:[notification object]] retain];
	
	NSString *originator = [dict objectForKey:@"originator_id"];
	
	//if we sent the time packets originally
	if ([originator compare:sesh.peerID] == NSOrderedSame) {
		NSNumber *old_time = [dict objectForKey:@"sender_time"];		
		NSNumber *cur_time = [NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]];
		
		aggregate_round_trip_times += [cur_time doubleValue] - [old_time doubleValue];
		
		/*
		if([dict objectForKey:@"receiver_time"] == nil){
			NSLog(@"PEN14");
			NSLog(@"OBJ: %@", [dict description]);
		}
		if([dict objectForKey:@"iter_num"] == nil) {
			NSLog(@"PEN15");
			NSLog(@"OBJ: %@", [dict description]);
		}
		 */
		
		//[response_times setObject:[dict objectForKey:@"receiver_time"] forKey:[dict objectForKey:@"iter_num"]]; TODO: MEM ISSUES!!
		++num_timing_responses;
		
		if (num_timing_responses == NUM_TIMING_TRIES) {
			NSLog(@"ROUND TRIP AVG: %f", aggregate_round_trip_times / NUM_TIMING_TRIES);
		}
		
		if(num_timing_responses % 10 == 0) NSLog(@"num timing responses: %d", num_timing_responses); 
	} else {
		[dict setObject:[NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]] forKey:@"receiver_time"];
		
		[self sendData:dict withMessageType:@"time_sync" toPeers:[NSArray arrayWithObject:originator] withDataMode:GKSendDataUnreliable];
	}
	
	[notification autorelease];
	[dict autorelease];
}

-(void) sendAllDataHandler:(NSNotification *)notification {
	[notification retain];
	
	NSMutableDictionary *dict = [[notification userInfo] retain];
	
	MatrixHandler *matrixHandler = [(awesomesauceAppDelegate*)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	
	NSMutableArray *matrices = [[dict objectForKey:@"matrices"] retain];
	
	TouchMatrix *matrix = new TouchMatrix([matrices objectAtIndex:0]);
	matrixHandler->matrices[0] = matrix;	//TODO: memory leak!!!
	
	for (int i = 1; i < matrixHandler->matrices.size(); ++i) {
		matrixHandler->matrices.pop_back();
	}
	
	for (int i = 1; i < [matrices count]; ++i) {
		TouchMatrix *matrix = new TouchMatrix([matrices objectAtIndex:i]);
		matrixHandler->addNewMatrix(matrix);
	}
	
	//[notification autorelease];
	//[data autorelease];
}

//handles being notified of someone else having changed a square
- (void) squareChangeHandler:(NSNotification *)notification {
	NSMutableDictionary *dict = [[notification userInfo] retain];
	
	int row = [[dict objectForKey:@"row"] intValue];
	int col = [[dict objectForKey:@"col"] intValue];
	bool new_value = [[dict objectForKey:@"value"] boolValue];
	int tid = [[dict objectForKey:@"tid"] intValue];
	
	MatrixHandler *handler = [(awesomesauceAppDelegate*)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	handler->matrices[tid]->setSquare(row, col, new_value);
}

- (void) trackAddedHandler:(NSNotification *)notification {
	/*
	 TODO:unnecessary for now, and need to be more careful with IDs!
	 */
	
	//NSMutableDictionary *dict = [[notification userInfo] retain];
	//int tid = [[dict objectForKey:@"tid"] intValue];
	
	MatrixHandler *handler = [(awesomesauceAppDelegate*)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	handler->addNewMatrix();
}

- (void) trackClearedHandler:(NSNotification *)notification {
	NSMutableDictionary *dict = [[notification userInfo] retain];
	
	int tid = [[dict objectForKey:@"tid"] intValue];
	MatrixHandler *handler = [(awesomesauceAppDelegate*)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	handler->matrices[tid]->clear();
}


/*
 * END INCOMING HANDLERS
 */


/*
 * MESSAGING HELPERS
 */

-(void) broadcastNotificationWithData:(NSMutableDictionary*)data andMessageType:(NSString*)msgType {
	[data retain];
	
	[data setObject:msgType forKey:@"msg_type"];
	[data setObject:sesh.peerID forKey:@"originator_id"];
	
	NSData *tosend = [[[NSData alloc] initWithData:[NSKeyedArchiver archivedDataWithRootObject:data]] retain];
	
	NSError *err;
	//send data using UDP for better numbers / faster results (I think, anyway)
	if (![sesh sendDataToAllPeers:tosend withDataMode:GKSendDataReliable error:&err]) {
		NSLog(@"DATA SEND ERROR: %@", [err localizedDescription]);
	}
}

//notifies other peers when the user has changed a square
-(void) sendSquareChangeNotification:(NSNotification *)notification {
	[self broadcastNotificationWithData:[[notification userInfo] retain] andMessageType:@"square_change"];
	/*
	NSMutableDictionary *dict = [[notification userInfo] retain];
		
	[dict setObject:@"square_change" forKey:@"msg_type"];
	[dict setObject:sesh.peerID forKey:@"originator_id"];
	
	NSData *tosend = [[[NSData alloc] initWithData:[NSKeyedArchiver archivedDataWithRootObject:dict]] retain];
	
	NSError *err;
	//send data using UDP for better numbers / faster results (I think, anyway)
	if (![sesh sendDataToAllPeers:tosend withDataMode:GKSendDataReliable error:&err]) {
		NSLog(@"DATA SEND ERROR: %@", [err localizedDescription]);
	}*/
}

//TODO: COPY!!
-(void) sendTrackAddedNotification:(NSNotification *)notification {
	[self broadcastNotificationWithData:[[notification userInfo] retain] andMessageType:@"track_added"];
	
	/*
	NSMutableDictionary *dict = [[notification userInfo] retain];

	[dict setObject:@"track_added" forKey:@"msg_type"];
	[dict setObject:sesh.peerID forKey:@"originator_id"];
	
	NSData *tosend = [[[NSData alloc] initWithData:[NSKeyedArchiver archivedDataWithRootObject:dict]] retain];
	
	NSError *err;
	//send data using UDP for better numbers / faster results (I think, anyway)
	if (![sesh sendDataToAllPeers:tosend withDataMode:GKSendDataReliable error:&err]) {
		NSLog(@"DATA SEND ERROR: %@", [err localizedDescription]);
	}*/
}


-(void) sendTrackClearedNotification:(NSNotification *)notification {
	[self broadcastNotificationWithData:[[notification userInfo] retain] andMessageType:@"track_cleared"];

	/*
	NSMutableDictionary *dict = [[notification userInfo] retain];
	
	[dict setObject:@"track_cleared" forKey:@"msg_type"];
	[dict setObject:sesh.peerID forKey:@"originator_id"];
	
	NSData *tosend = [[[NSData alloc] initWithData:[NSKeyedArchiver archivedDataWithRootObject:dict]] retain];
	
	NSError *err;
	//send data using UDP for better numbers / faster results (I think, anyway)
	if (![sesh sendDataToAllPeers:tosend withDataMode:GKSendDataReliable error:&err]) {
		NSLog(@"DATA SEND ERROR: %@", [err localizedDescription]);
	}*/
}


- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
	[data retain];
	[peer retain];
	
	NSLog(@"in data length: %d", [data length]);

	NSMutableDictionary *unarch = [[NSKeyedUnarchiver unarchiveObjectWithData:data] retain];
	
	NSLog(@"unarch size: %d", [unarch count]);
	
	NSLog(@"unarch scrip: %@", [unarch description]);
	
	if(unarch == nil) NSLog(@"UNAARCH WAS NILLLLL");
	
	//TODO: RELEASE / MEM ISSUES???
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] initWithDictionary:unarch] retain];
	
	NSString *notificationType = [[dict objectForKey:@"msg_type"] retain];
	
	NSLog(@"notification type: %@", notificationType);
	
	//NSLog(@"sending notification of type: %@", notificationType);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:notificationType object:nil userInfo:dict];
}


//helper wrapper function for 
- (void) sendData:(NSMutableDictionary *)dict withMessageType:(NSString *)msgType toPeers:(NSArray *)peers withDataMode:(GKSendDataMode)mode {
	[dict retain];
	[msgType retain];
	
	NSString *msgCpy = [[[NSString alloc] initWithString:msgType] retain];
	
	//make sure the type specifcation is in there
	[dict setObject:msgCpy forKey:@"msg_type"];
	
	//NSLog(@"sending message of type: %@", msgType);
	
	//make it easier to dispatch on the originator
	NSString *peerCpy = [[[NSString alloc] initWithString:sesh.peerID] retain];
	if([dict objectForKey:@"originator_id"] == nil) [dict setObject:peerCpy forKey:@"originator_id"];
	
	//TODO: also add the universal time (estimation)	
	NSData *arch = [[NSKeyedArchiver archivedDataWithRootObject:dict] retain];
	
	NSLog(@"arch length: %d", [arch length]);
	
	if(arch == nil) NSLog(@"AAARRRRCCCHHHH nil");
	
	NSData *tosend = [[[NSData alloc] initWithData:arch] retain];
	
	NSLog(@"to send length: %d", [tosend length]);
	
	NSError *err;
	//send data using UDP for better numbers / faster results (I think, anyway)
	if (![sesh sendData:tosend toPeers:peers withDataMode:mode error:&err]) {
		NSLog(@"DATA SEND ERROR: %@", [err localizedDescription]);
	}
	
	NSLog(@"data sent: %@", [dict description]);
	
	//[dict release];
}


/*
 * END MESSAGING HELPERS
 */


- (void) sendAllDataToPeer:(NSString *)peer inSession:(GKSession *)session {
	MatrixHandler *handler = [(awesomesauceAppDelegate*)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	
	/*
		SEND: the notes, the instrument, and the track name
	 */
	//NSMutableDictionary *data = [[NSMutableDictionary dictionaryWithCapacity:1] retain];
	NSMutableDictionary *data = [[[NSMutableDictionary alloc] initWithCapacity:1] retain];
	
	//NSMutableArray *matrices = [NSMutableArray arrayWithCapacity:handler->matrices.size()];
	NSMutableArray *matrices = [[[NSMutableArray alloc] initWithCapacity:handler->matrices.size()] retain];
	for (unsigned i = 0; i < handler->matrices.size(); ++i) {
		TouchMatrix *matrix = handler->matrices[i];
		
		NSMutableDictionary *dict = [matrix->toDictionary() retain];
		
		//TODO: mem leak?
		[matrices insertObject:dict atIndex:i];
		
		//[dict autorelease];
	}
	
	[data setObject:matrices forKey:@"matrices"];
	
	NSLog(@"sending all data to peer: %@", [sesh displayNameForPeer:peer]);
	
	NSLog(@"here are the data: %@", [data description]);
	
	[self sendData:data withMessageType:@"send_all_data" toPeers:[NSArray arrayWithObject:peer] withDataMode:GKSendDataReliable];
	
	//[data autorelease];
}

@end
