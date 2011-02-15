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
	NSMutableDictionary *response_times;
	NSDate *now;
	double aggregate_round_trip_times;
	double aggregate_recipient_displacement;
	int num_timing_responses;
	bool father_time;
	double global_offset;
}

- (id)init;
- (BOOL) comparePeerID:(NSString*)otherID;

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state;
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID;

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error;
- (void)session:(GKSession *)session didFailWithError:(NSError *)error;

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context;
- (void) sendData:(NSMutableDictionary *)dict withMessageType:(NSString *)msgType toPeers:(NSArray *)peers withDataMode:(GKSendDataMode)mode;

- (void) sendAllDataToPeer:(NSString *)peer inSession:(GKSession *)session;

@property (nonatomic, retain) GKSession *sesh;
@property (nonatomic, retain) NSMutableDictionary *response_times;

@end
