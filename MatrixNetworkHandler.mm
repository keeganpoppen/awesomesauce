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
		
		sesh = [[GKSession alloc] initWithSessionID:@"awesomesauce" displayName:nil sessionMode:GKSessionModePeer];
		[sesh setDelegate:self];
		[sesh setDataReceiveHandler:self withContext:nil];
		[sesh setAvailable:YES];
		NSLog(@"starting server in peer mode");
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
				for (unsigned i = 0; i < NUM_TIMING_TRIES; ++i) {					
					NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:i], @"iter_num",
													[NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]], @"sender_time", nil];
					
					[self sendData:dict withMessageType:@"time_sync" toPeers:[NSArray arrayWithObject:peerID] withDataMode:GKSendDataUnreliable];
					
					/*
					//send data using UDP for better numbers / faster results (I think, anyway)
					NSError *err;
					if (![sesh sendData:[NSKeyedArchiver archivedDataWithRootObject:dict] toPeers:[NSArray arrayWithObject:peerID] withDataMode:GKSendDataUnreliable error:&err]) {
						NSLog(@"DATA SEND ERROR: %@", [err localizedDescription]);
					}
					 */
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
- (void) timeHandler:(NSMutableDictionary *)dict {
	NSString *originator = [dict objectForKey:@"originator_id"];
	
	//if we sent the time packets originally
	if ([originator compare:sesh.peerID] == NSOrderedSame) {
		NSNumber *old_time = [dict objectForKey:@"sender_time"];		
		NSNumber *cur_time = [NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]];
		
		aggregate_round_trip_times += [cur_time doubleValue] - [old_time doubleValue];
		
		[response_times setObject:[dict objectForKey:@"receiver_time"] forKey:[dict objectForKey:@"iter_num"]];
		++num_timing_responses;
		
		if (num_timing_responses == NUM_TIMING_TRIES) {
			NSLog(@"ROUND TRIP AVG: %f", aggregate_round_trip_times / NUM_TIMING_TRIES);
		}
		
		if(num_timing_responses % 10 == 0) NSLog(@"num timing responses: %d", num_timing_responses); 
	} else {		
		[dict setValue:[NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]] forKey:@"receiver_time"];
		
		[self sendData:dict withMessageType:@"time_sync" toPeers:[NSArray arrayWithObject:originator] withDataMode:GKSendDataUnreliable];
	}
}

-(void) sendAllDataHandler:(NSDictionary *)dict {
	//TODO: SEND ALL YO' DATA, HO'!
}

/*
 * END INCOMING HANDLERS
 */


/*
 * MESSAGING HELPERS
 */

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
	NSMutableDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	
	NSString *notificationType = [dict objectForKey:@"msg_type"];
	
	NSLog(@"sending notification of type: %@", notificationType);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:notificationType object:nil userInfo:dict];
}


//helper wrapper function for 
- (void) sendData:(NSMutableDictionary *)dict withMessageType:(NSString *)msgType toPeers:(NSArray *)peers withDataMode:(GKSendDataMode)mode {
	//make sure the type specifcation is in there
	[dict setObject:msgType forKey:@"msg_type"];
	
	NSLog(@"sending notification of type: %@", msgType);
	
	//make it easier to dispatch on the originator
	if([dict objectForKey:@"originator_id"] == nil) [dict setObject:sesh.peerID forKey:@"originator_id"];
	
	//TODO: also add the universal time (estimation)	
	
	NSError *err;
	//send data using UDP for better numbers / faster results (I think, anyway)
	if (![sesh sendData:[NSKeyedArchiver archivedDataWithRootObject:dict] toPeers:peers withDataMode:mode error:&err]) {
		NSLog(@"DATA SEND ERROR: %@", [err localizedDescription]);
	}
}


/*
 * END MESSAGING HELPERS
 */


- (void) sendAllDataToPeer:(NSString *)peer inSession:(GKSession *)session {
	//MatrixHandler *handler = [(awesomesauceAppDelegate*)[[UIApplication sharedApplication] delegate] matrixHandler];
	
	/*
		SEND: the notes, the instrument, and the track name
	 */
	
	/*
	for (unsigned i = 0; i < handler->matrices.size(); ++i) {
		
	}
	 */
}

- (void) receiveAllDataFromPeer:(NSString *)peer andData:(NSDictionary*)data {
	//TODO: init touchmatrices from the data
	//TODO: tell the peer that it's sync time
}

@end
