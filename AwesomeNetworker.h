//
//  AwesomeNetworker.h
//  awesomesauce
//
//  Created by Keegan Poppen on 3/16/11.
//  Copyright 2011 Lord Keeganus Industries. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "ASDataSyncee.h"
//#import "AwesomeNetworkSyncer.h"

//forward declaration (obviously)
@class AwesomeNetworker;
@class AwesomeNetworkSyncer;

//ASDataSyncee for time sync messages
@interface TimeSync : NSObject <ASDataSyncee>
{
	AwesomeNetworker *networker;
	
	//NSTimeInterval startTime;
	NSTimeInterval totalOffset;
	NSMutableArray *offsets;
	
	NSTimeInterval globalOffset;
	int num_packets_handled;
}

-(void)receiveData:(NSDictionary*)data fromTime:(NSTimeInterval)updateTime;

@property(nonatomic, retain) NSMutableArray *offsets;
@property(nonatomic, retain) AwesomeNetworker *networker;
//@property(nonatomic) NSTimeInterval startTime;

@end


//ASDataSyncee for loading data
@interface LoadDataSync : NSObject <ASDataSyncee>
{
	AwesomeNetworker *networker;
}

-(void)receiveData:(NSDictionary*)data fromTime:(NSTimeInterval)updateTime;

@property(nonatomic, retain) AwesomeNetworker *networker;

@end



/**
 *
 * Actually does the aforementioned networking
 *
 */

@interface AwesomeNetworker : NSObject <GKSessionDelegate> {
	NSMutableDictionary *handlerMap;
	GKSession *session;
	TimeSync *timeSync;
	LoadDataSync *loadDataSync;
	AwesomeNetworkSyncer *networkSyncer;
}

/*
 * useful stuff
 */

//registers an ASDataSyncee to handle all events with name eventName
-(void)registerEventHandler:(NSString*)eventName withSyncee:(id<ASDataSyncee>)syncee;

//sends data and returns the time that the data was sent. overrideTime defaults to NO.
-(NSTimeInterval)sendData:(NSDictionary*)data withEventName:(NSString*)eventName;
-(NSTimeInterval)sendData:(NSDictionary*)data withEventName:(NSString*)eventName overrideTime:(BOOL)shouldOverride;
	

-(id<ASDataSyncee>)handlerForEvent:(NSString*)eventName;

/*
 * GKSessionDelegate stuff
 */

- (BOOL)comparePeerID:(NSString*)otherID;
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state;
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID;

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error;
- (void)session:(GKSession *)session didFailWithError:(NSError *)error;

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context;

@property(nonatomic, retain) NSMutableDictionary *handlerMap;
@property(nonatomic, retain) GKSession *session;
@property(nonatomic, retain) TimeSync *timeSync;
@property(nonatomic, retain) LoadDataSync *loadDataSync;
@property(nonatomic, retain) AwesomeNetworkSyncer *networkSyncer;

@end