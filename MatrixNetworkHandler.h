//
//  MatrixNetworkHandler.h
//  awesomesauce
//
//  Created by The Colonel on 2/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>


@interface MatrixNetworkHandler : NSObject <GKSessionDelegate> {
	GKSession *sesh;
}

- (void)init_networking;

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state;
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID;

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error;
- (void)session:(GKSession *)session didFailWithError:(NSError *)error;

@property (retain) GKSession *sesh;

@end
