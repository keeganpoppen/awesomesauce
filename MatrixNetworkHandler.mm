//
//  MatrixNetworkHandler.mm
//  awesomesauce
//
//  Created by The Colonel on 2/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MatrixNetworkHandler.h"

#define NUM_TIMING_TRIES 10000


@implementation MatrixNetworkHandler

@synthesize sesh;
@synthesize response_times;

- (id)init {
	self = [super init];
	if (self) {
		//initialize timing infrastructure
		response_times = [[NSMutableArray alloc] initWithCapacity:NUM_TIMING_TRIES];
		aggregate_round_trip_times = 0.;
		num_timing_responses = 0;
		
		sesh = [[GKSession alloc] initWithSessionID:@"awesomesauce" displayName:nil sessionMode:GKSessionModePeer];
		[sesh setDelegate:self];
		[sesh setDataReceiveHandler:self withContext:nil];
		[sesh setAvailable:YES];
		NSLog(@"starting server in peer mode");
	}
	return self;
}
		 
 - (BOOL) comparePeerID:(NSString*)otherID {
	 //TODO: CHANGE THIS, OBV!!! return [otherID compare:sesh.peerID] == NSOrderedAscending;
	 return [[sesh displayName] compare:@"chewbacca"];
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
					
					//send data using UDP for better numbers / faster results (I think, anyway)
					NSError *err;
					if (![sesh sendData:[NSKeyedArchiver archivedDataWithRootObject:dict] toPeers:[NSArray arrayWithObject:peerID] withDataMode:GKSendDataUnreliable error:&err]) {
						NSLog(@"DATA SEND ERROR: %@", [err localizedDescription]);
					}
				}
			}
		}
			break;
		case GKPeerStateConnecting:
			NSLog(@"connecting");
			break;
		case GKPeerStateAvailable:
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

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
	NSMutableDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	
	//if we sent the time packets originally
	if ([self comparePeerID:peer]) {
		NSNumber *old_time = [dict objectForKey:@"sender_time"];		
		NSNumber *cur_time = [NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]];
		
		aggregate_round_trip_times += [cur_time doubleValue] - [old_time doubleValue];
		[response_times insertObject:[dict objectForKey:@"receiver_time"] atIndex:[[dict objectForKey:@"iter_num"] unsignedIntValue]];
		num_timing_responses++;
		
		if (num_timing_responses == NUM_TIMING_TRIES) {
			NSLog(@"ROUND TRIP AVG: %f", aggregate_round_trip_times / NUM_TIMING_TRIES);
		}
		
		if (num_timing_responses > NUM_TIMING_TRIES - 100) {
			NSLog(@"reponses gotten %d", num_timing_responses);
		}
	} else {		
		[dict setValue:[NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]] forKey:@"receiver_time"];
		
		NSError *err;
		//send data using UDP for better numbers / faster results (I think, anyway)
		if (![sesh sendData:[NSKeyedArchiver archivedDataWithRootObject:dict] toPeers:[NSArray arrayWithObject:peer] withDataMode:GKSendDataUnreliable error:&err]) {
			NSLog(@"DATA SEND ERROR: %@", [err localizedDescription]);
		}
	}
}

@end
