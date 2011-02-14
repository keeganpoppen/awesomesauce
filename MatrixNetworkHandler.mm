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
		sesh = [[GKSession alloc] initWithSessionID:@"awesomesauce" displayName:@"lord keeganus" sessionMode:GKSessionModePeer];
		[sesh setDelegate:self];
		[sesh setDataReceiveHandler:self withContext:nil];
		NSLog(@"starting server in peer mode");
	}
	return self;
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
	NSLog(@"peer state change: %s", peerID);
	
	switch (state) {
		case GKPeerStateConnected:
			NSLog(@"connected");
			break;
		case GKPeerStateConnecting:
			NSLog(@"connecting");
			break;
		case GKPeerStateAvailable:
			NSLog(@"available");
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
	NSLog(@"cnxn request from peer %s, dawg", peerID);
	NSLog(@"accepting said connection");
	
	NSError *err = [[NSError alloc] autorelease];
	[session acceptConnectionFromPeer:peerID error:&err];
	if (err != NULL) {
		NSLog(@"ERROR: %s", [err localizedDescription]);
	}
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
	NSLog(@"session failed with error %s", error);
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
	NSLog(@"connection with peer %s failed with error: %s", peerID, error);
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
	NSLog(@"data received!");
}

@end
