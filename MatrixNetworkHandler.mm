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

#define NUM_TIMING_TRIES 20


@implementation MatrixNetworkHandler

@synthesize sesh;
@synthesize response_times;

- (id)init {
	self = [super init];
	if (self) {
		father_time = false;
		now = [[NSDate date] retain];
		global_offset = 0.;
		
		//initialize timing infrastructure
		response_times = [[NSMutableDictionary alloc] initWithCapacity:NUM_TIMING_TRIES];
		aggregate_round_trip_times = 0.;
		aggregate_recipient_displacement = 0.;
		num_timing_responses = 0;
		
		//set up dispatch on different message types
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeHandler:) name:@"time_sync" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendAllDataHandler:) name:@"send_all_data" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(awesomeShitHandler:) name:@"awesome_shit" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(squareChangeHandler:) name:@"square_change" object:nil];
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackAddedHandler:) name:@"track_added" object:nil]; TODO:DEPRECATED FOR NOW
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
				
				NSLog(@"SYNCING CLOCKS");
				for (unsigned i = 0; i < NUM_TIMING_TRIES; ++i) {
					NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:i], @"iter_num",
													[NSNumber numberWithDouble:(-[now timeIntervalSinceNow])], @"sender_age", nil];
					
					[self sendData:dict withMessageType:@"time_sync" toPeers:[NSArray arrayWithObject:peerID] withDataMode:GKSendDataReliable];
				}
				
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
	
	//NSMutableDictionary *dict = [[[NSMutableDictionary alloc] initWithDictionary:[notification object]] retain];
	NSMutableDictionary *dict = [[notification userInfo] retain];
	
	NSString *originator = [dict objectForKey:@"originator_id"];
	
	//if we sent the time packets originally
	if ([originator compare:sesh.peerID] == NSOrderedSame) {
		NSNumber *old_time = [dict objectForKey:@"sender_age"];
		NSNumber *cur_time = [NSNumber numberWithDouble:(-[now timeIntervalSinceNow])];
		NSNumber *their_time = [dict objectForKey:@"receiver_age"];
		
		double middletime = ([cur_time doubleValue] + [old_time doubleValue]) / 2.0;
		aggregate_recipient_displacement +=  [their_time doubleValue] - middletime;
		NSLog(@"AGE STUFF old: %@, cur: %@, their %@", old_time, cur_time, their_time);
		++num_timing_responses;
		
		if (num_timing_responses == NUM_TIMING_TRIES) {
			double offset = aggregate_recipient_displacement / NUM_TIMING_TRIES;
			bool sender_is_older = false;
			NSString *receiver_id = [dict objectForKey:@"receiver_id"];
			if(offset < 0) {
				//we are older
				sender_is_older = true;
				[self sendAllDataToPeer:receiver_id inSession:sesh];
			}
			else {
				global_offset = offset;
				NSLog(@"global_offset: %f", global_offset);
				MatrixHandler *matrixHandler = [(awesomesauceAppDelegate*)[[UIApplication sharedApplication] delegate] getMatrixHandler];
				matrixHandler->addOffset(global_offset);
			}
			
			//send sender_is_older, global_offset to receiver
			NSMutableDictionary *offset_dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
												[NSNumber numberWithDouble:(-offset)], @"offset",
												[NSNumber numberWithBool:sender_is_older], @"sender_is_older", nil];
			[self sendData:offset_dict withMessageType:@"awesome_shit"
				   toPeers:[NSArray arrayWithObject:receiver_id]
			  withDataMode:GKSendDataReliable];
			
			/*
			double offset = aggregate_recipient_displacement / NUM_TIMING_TRIES;
			NSLog(@"RECEIPIENT AVG: %f", offset);
			NSTimeInterval age = -[now timeIntervalSinceNow];
			NSMutableDictionary *offset_dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										 [NSNumber numberWithDouble:offset], @"offset",
										 [NSNumber numberWithDouble:age], @"age",
										[NSNumber numberWithBool:father_time], @"the_answer", nil];
			NSString *receiver_id = [dict objectForKey:@"receiver_id"];
			[self sendData:offset_dict withMessageType:@"derive_time" toPeers:[NSArray arrayWithObject:receiver_id] withDataMode:GKSendDataReliable];
			 */
		}
		
		if(num_timing_responses % 10 == 0) NSLog(@"num timing responses: %d", num_timing_responses); 
	} else {
		[dict setObject:[NSNumber numberWithDouble:(-[now timeIntervalSinceNow])] forKey:@"receiver_age"];
		[dict setObject:sesh.peerID forKey:@"receiver_id"];
		
		[self sendData:dict withMessageType:@"time_sync" toPeers:[NSArray arrayWithObject:originator] withDataMode:GKSendDataReliable];
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
	TouchMatrix *toDelete = matrixHandler->matrices[0];
	matrixHandler->matrices[0] = matrix;	//TODO: memory leak!!!
	delete toDelete;
	
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
	int tid = [[dict objectForKey:@"track_id"] intValue];
	
	MatrixHandler *handler = [(awesomesauceAppDelegate*)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	handler->matrices[tid]->setSquare(row, col, new_value);
}

/*
- (void) trackAddedHandler:(NSNotification *)notification {
	//TODO:unnecessary for now, and need to be more careful with IDs!
	
	//NSMutableDictionary *dict = [[notification userInfo] retain];
	//int tid = [[dict objectForKey:@"track_id"] intValue];
		
	MatrixHandler *handler = [(awesomesauceAppDelegate*)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	handler->addNewMatrix(false);
}
 */

- (void) trackClearedHandler:(NSNotification *)notification {
	NSMutableDictionary *dict = [[notification userInfo] retain];
	
	int tid = [[dict objectForKey:@"track_id"] intValue];
	MatrixHandler *handler = [(awesomesauceAppDelegate*)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	handler->matrices[tid]->clear();
}

- (void) awesomeShitHandler:(NSNotification *)notification {
	NSMutableDictionary *dict = [[notification userInfo] retain];
	bool sender_is_older = [[dict objectForKey:@"sender_is_older"] boolValue];
	double offset = [[dict objectForKey:@"offset"] doubleValue];
	if(sender_is_older) {
		//then we are younger and must do offset
		global_offset = offset;
		NSLog(@"global_offset: %f", global_offset);
		MatrixHandler *matrixHandler = [(awesomesauceAppDelegate*)[[UIApplication sharedApplication] delegate] getMatrixHandler];
		matrixHandler->addOffset(global_offset);
	}
	
	/*
	NSMutableDictionary *dict = [[notification userInfo] retain];
	NSString *originator = [dict objectForKey:@"originator_id"];
	if ([originator compare:sesh.peerID] == NSOrderedSame) {
	//	[self sendAllDataToPeer:sesh.peerID inSession:sesh];
		if (![dict objectForKey:@"are_older"]) {
			[self sendAllDataToPeer:[NSArray arrayWithObject:originator] inSession:sesh];
		}
		if (![dict objectForKey:@"did_accept_offset"]) {
			global_offset = [[dict objectForKey:@"offset"] doubleValue];
			MatrixHandler *matrixHandler = [(awesomesauceAppDelegate*)[[UIApplication sharedApplication] delegate] getMatrixHandler];
			[self keegan];
			//matrixHandler->addOffset(global_offset); //TODO
		}
	}
	else {
		bool answer = [[dict objectForKey:@"the_answer"] boolValue];
		double offset = [[dict objectForKey:@"offset"] doubleValue];
		double their_age = [[dict objectForKey:@"age"] doubleValue];
		NSTimeInterval our_age = -[now timeIntervalSinceNow];
		NSLog(@"their age: %f, our age: %f, offset: %f", their_age, our_age, offset);
		//Their age + half round trip
		
		bool ourResponse = false;
		if(!father_time) {
			global_offset = offset;
			MatrixHandler *matrixHandler = [(awesomesauceAppDelegate*)[[UIApplication sharedApplication] delegate] getMatrixHandler];
			[self keegan];
			//matrixHandler->addOffset(global_offset); //TODO
			ourResponse = true;
		}
		
		bool older = (our_age >= their_age);
		
		if(older) {
			[self sendAllDataToPeer:originator inSession:sesh];
		}
		
		NSMutableDictionary *response_dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									 [NSNumber numberWithBool:ourResponse], @"did_accept_offset",
									 [NSNumber numberWithBool:older], @"are_older",
									 [NSNumber numberWithDouble:offset], @"offset", nil];
		[self sendData:response_dict withMessageType:@"derive_time" toPeers:[NSArray arrayWithObject:originator] withDataMode:GKSendDataReliable];

	}
	*/
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
}

-(void) sendTrackAddedNotification:(NSNotification *)notification {
	[self broadcastNotificationWithData:[[notification userInfo] retain] andMessageType:@"track_added"];
}

-(void) sendTrackClearedNotification:(NSNotification *)notification {
	[self broadcastNotificationWithData:[[notification userInfo] retain] andMessageType:@"track_cleared"];
}


- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
	[data retain];
	[peer retain];

	NSMutableDictionary *unarch = [[NSKeyedUnarchiver unarchiveObjectWithData:data] retain];
	
	if(unarch == nil) NSLog(@"UNAARCH WAS NILLLLL");
	
	//TODO: RELEASE / MEM ISSUES???
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] initWithDictionary:unarch] retain];
	
	NSString *notificationType = [[dict objectForKey:@"msg_type"] retain];
	
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
	
	NSData *tosend = [[[NSData alloc] initWithData:arch] retain];
	
	NSError *err;
	//send data using UDP for better numbers / faster results (I think, anyway)
	if (![sesh sendData:tosend toPeers:peers withDataMode:mode error:&err]) {
		NSLog(@"DATA SEND ERROR: %@", [err localizedDescription]);
	}
	
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
	
	//NSLog(@"sending all data to peer: %@", [sesh displayNameForPeer:peer]);
	//NSLog(@"here are the data: %@", [data description]);
	
	[self sendData:data withMessageType:@"send_all_data" toPeers:[NSArray arrayWithObject:peer] withDataMode:GKSendDataReliable];
	
	//[data autorelease];
}

@end
