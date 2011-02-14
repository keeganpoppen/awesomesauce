//
//  MatrixNetworkHandler.mm
//  awesomesauce
//
//  Created by The Colonel on 2/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MatrixNetworkHandler.h"


@implementation MatrixNetworkHandler

@synthesize sesh;

- (id)init {
	self = [super init];
	if (self) {
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
				for (int i = 0; i < 10; ++i) {					
					NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:i],
											@"iter_num", [NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]], @"sender_time", nil];
					
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
		
		NSLog(@"ROUND TRIP TIME ESTIMATE: %@, iter num: %@", [cur_time doubleValue] - [old_time doubleValue], [dict objectForKey:@"iter_num"]);
	} else {
		NSLog(@"they sent from sys time: %@", [dict objectForKey:@"sender_time"]);
		
		[dict setValue:[NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]] forKey:@"receiver_time"];
		
		NSError *err;
		//send data using UDP for better numbers / faster results (I think, anyway)
		if (![sesh sendData:[NSKeyedArchiver archivedDataWithRootObject:dict] toPeers:[NSArray arrayWithObject:peer] withDataMode:GKSendDataUnreliable error:&err]) {
			NSLog(@"DATA SEND ERROR: %@", [err localizedDescription]);
		}
	}

	

}

@end
