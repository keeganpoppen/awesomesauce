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
			NSLog(@"connected to peer %@", [sesh displayNameForPeer:peerID]);
			NSString *test = @"Keegan is awesome";
			NSData *data = [test dataUsingEncoding:NSUTF8StringEncoding];
			
			NSError *err;
			if (![sesh sendData:data toPeers:[NSArray arrayWithObject:peerID] withDataMode:GKSendDataReliable error:&err]) {
				NSLog(@"DATA SEND ERROR: %@", [err localizedDescription]);
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
	NSString *data = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSLog(@"data received! it was: %@", data);
}

@end
