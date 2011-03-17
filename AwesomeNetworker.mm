//
//  AwesomeNetworker.mm
//  awesomesauce
//
//  Created by Keegan Poppen on 3/16/11.
//  Copyright 2011 Lord Keeganus Industries. All rights reserved.
//

#import "AwesomeNetworker.h"
#import "awesomesauceAppDelegate.h"
#import "MatrixHandler.h"
#import <math.h>

#define NUM_SYNCHRO_OFFSETS 50

@implementation TimeSync

@synthesize offsets;
@synthesize networker;
@synthesize startTime;

-(id)init {
	self = [super init];
	if (self) {
		startTime = [NSDate timeIntervalSinceReferenceDate];
		NSLog(@"initting timesync.... setting start time to %f", startTime);
		
		offsets = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void)receiveData:(NSDictionary*)data fromTime:(NSTimeInterval)updateTime {

	NSNumber *time_received = [data objectForKey:@"time_received"];
	NSNumber *age_offset = [data objectForKey:@"age_offset"];
	
	NSTimeInterval cur_time = [NSDate timeIntervalSinceReferenceDate] - startTime;
	
	//check if we were the sender, or the recipient
	if (age_offset != nil) {
		globalOffset = [age_offset doubleValue];
		NSLog(@"global offset set to: %f", globalOffset);
		
		MatrixHandler *matrixHandler = [(awesomesauceAppDelegate*)[[UIApplication sharedApplication] delegate] getMatrixHandler];

		matrixHandler->time_elapsed = ([NSDate timeIntervalSinceReferenceDate] - startTime) + globalOffset;

		NSLog(@"set global time to %f thanks to being told as such", matrixHandler->time_elapsed);
		
		if(globalOffset < 0.001) {
			NSLog(@"gonna send all m'data");
			NSDictionary *matrixData = matrixHandler->encode();
			[networker sendData:matrixData withEventName:@"load_data"];
		}
		
	} else if (time_received == nil) {
		//NSLog(@"gonna forward that packet right the fuck back, yo");
		
 		NSMutableDictionary *toSend = [[[NSMutableDictionary dictionaryWithDictionary:data] retain] autorelease];
		[toSend setObject:[NSNumber numberWithDouble:cur_time] forKey:@"time_received"];
		
		[self.networker sendData:toSend withEventName:@"time_sync" overrideTime:YES];
	} else {
		NSTimeInterval rec_time = [time_received doubleValue];
		NSTimeInterval sent_time = [[data objectForKey:@"time_sent"] doubleValue];
		
		NSTimeInterval offset = rec_time - ((sent_time + cur_time) / 2.);
		
		//NSLog(@"rec time: %f, sent_time; %f, cur_time: %f, offset: %f", rec_time, sent_time, cur_time, offset);
		
		[offsets addObject:[NSNumber numberWithDouble:offset]];
		totalOffset += offset;
				
		if([offsets count] != NUM_SYNCHRO_OFFSETS) {
			
			//if we haven't gotten enough data, send some more
			[networker sendData:nil withEventName:@"time_sync"];
			
		} else {
			NSTimeInterval mean = totalOffset / (double)[offsets count];
			NSTimeInterval sd_accum = 0;
			
			for (unsigned i = 0; i < NUM_SYNCHRO_OFFSETS; ++i) {
				sd_accum += pow([[offsets objectAtIndex:i] doubleValue] - mean, 2.);
			}
			
			sd_accum /= pow((double)NUM_SYNCHRO_OFFSETS, .5);
			sd_accum = pow(sd_accum, .5);
			
			NSLog(@"mean: %f", mean);
			NSLog(@"standard deviation of mean offset: %f", sd_accum);
						
			MatrixHandler *matrixHandler = [(awesomesauceAppDelegate*)[[UIApplication sharedApplication] delegate] getMatrixHandler];
			
			//if(mean > 0) then they are older than us
			if(mean > 0) {
				NSLog(@"they're older, so I'm updating my age and sending 0");
				globalOffset = mean;
				
				[networker sendData:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:0.0], @"age_offset", nil] withEventName:@"time_sync"];
			} else {
				NSLog(@"I'm older, so they're gonna have to grow up");
				globalOffset = 0;
				
				[networker sendData:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:-mean], @"age_offset", nil] withEventName:@"time_sync"];
				
				NSLog(@"I'm gonna go ahead and send them my data too");
				
				NSDictionary *matrixData = matrixHandler->encode();
								
				[networker sendData:matrixData withEventName:@"load_data"];
			}
			
			matrixHandler->time_elapsed = ([NSDate timeIntervalSinceReferenceDate] - startTime) + globalOffset;
			NSLog(@"set global time to %f thanks to my own volition", matrixHandler->time_elapsed);
		}
	}

}

@end


@implementation LoadDataSync

@synthesize networker;


-(void)receiveData:(NSDictionary*)data fromTime:(NSTimeInterval)updateTime {
	//NSLog(@"received some matrix data: %@", data);
	
	MatrixHandler *matrixHandler = [(awesomesauceAppDelegate*)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	matrixHandler->decode(data);
}


@end


@implementation AwesomeNetworker

@synthesize handlerMap;
@synthesize session;
@synthesize timeSync, loadDataSync;


- (id)init {
	self = [super init];
	if (self) {
		handlerMap = [[NSMutableDictionary alloc] init];
		
		//set self to handle incoming data from gamekit
		[session setDataReceiveHandler:self withContext:NULL];

		//set up time_sync handler
		timeSync = [[TimeSync alloc] init];
		[self registerEventHandler:@"time_sync" withSyncee:timeSync];
		
		//set up load_data handler
		loadDataSync = [[LoadDataSync alloc] init];
		[self registerEventHandler:@"load_data" withSyncee:loadDataSync];
		
		session = [[GKSession alloc] initWithSessionID:@"awesomesauce" displayName:nil sessionMode:GKSessionModePeer];
		[session setDelegate:self];
		[session setDataReceiveHandler:self withContext:nil];
		[session setAvailable:YES];
		
		NSLog(@"starting server in peer mode w/ peerID %@", session.peerID);
	}
	return self;
}

//registers an ASDataSyncee to handle all events with name eventName
-(void)registerEventHandler:(NSString*)eventName withSyncee:(id<ASDataSyncee>)syncee {
	NSLog(@"registering handler for key: %@", eventName);
	
	[handlerMap setObject:syncee forKey:eventName];
	syncee.networker = self;
}

-(id<ASDataSyncee>)handlerForEvent:(NSString*)eventName {
	id<ASDataSyncee> syncee = [handlerMap objectForKey:eventName];
	
	if (syncee == nil) NSLog(@"no handler for event w/ name: %@", eventName);
	
	return syncee;
}

-(NSTimeInterval)sendData:(NSDictionary*)data withEventName:(NSString*)eventName {
	return [self sendData:data withEventName:eventName overrideTime:NO];
}

//sends data and returns the time that the data was sent
-(NSTimeInterval)sendData:(NSDictionary*)data withEventName:(NSString*)eventName overrideTime:(BOOL)shouldOverride{
	//id<ASDataSyncee> syncee = [self handlerForEvent:eventName];
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:data];
	[dict setObject:eventName forKey:@"event_name"];
	
	NSTimeInterval curAge = [NSDate timeIntervalSinceReferenceDate] - timeSync.startTime;
	if (!shouldOverride) {	
		[dict setObject:[NSNumber numberWithDouble:curAge] forKey:@"time_sent"];
	}
	
	//NSLog(@"sending some data that looks like this: %@", [dict description]);
	
	NSData *toSend = [[[NSKeyedArchiver archivedDataWithRootObject:dict] retain] autorelease];
	
	NSError *err;
	if (![session sendDataToAllPeers:toSend withDataMode:GKSendDataReliable error:&err]) {
		NSLog(@"DATA SEND ERROR: %@", err);
	}
	
	return curAge;
}


/*
 * gk functions
 */

- (BOOL) comparePeerID:(NSString*)otherID {
	//return [otherID compare:session.peerID] == NSOrderedAscending;
	NSString *otherPeer = [session displayNameForPeer:otherID];
	NSComparisonResult comp = [otherPeer caseInsensitiveCompare:@"Chewbacca"];
	return comp != NSOrderedSame;
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
	NSLog(@"peer state change for peer %@ with display name %@", peerID, [session displayNameForPeer:peerID]);
	
	switch (state) {
		case GKPeerStateConnected:
			NSLog(@"connected to peer %@", [session displayNameForPeer:peerID]);
			
			if ([self comparePeerID:peerID]) {
				NSLog(@"sending timing packets");
				
				//send the (first of the) timing packets. most of the work is done by default, which is why this looks a bit silly
				[self sendData:nil withEventName:@"time_sync"];

			} else {
				NSLog(@"waiting for timing packets");
			}

			
			//TODO: LOAD DATA FROM PEER IF YOUNGER
			
			break;
		case GKPeerStateConnecting:
			NSLog(@"connecting");
			break;
		case GKPeerStateAvailable:
			NSLog(@"availability found");
			if ([self comparePeerID:peerID]) {
				NSLog(@"available... gonna try and connect");
				[session connectToPeer:peerID withTimeout:30.];
			} else {
				NSLog(@"gonna wait for peer to connect to me");
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
	NSLog(@"cnxn request from peer %@, dawg. gonna accept it.", [session displayNameForPeer:peerID]);
	
	NSError *err;
	if (![session acceptConnectionFromPeer:peerID error:&err]) {
		NSLog(@"ERROR: %@", [err localizedDescription]);
	}

}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
	NSLog(@"CONNECTION FAILED with error: %@", error);
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
	NSLog(@"SESSION FAILED with error: %@", error);	
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
	//unserialize data from peer
	NSMutableDictionary *dict = [[[NSKeyedUnarchiver unarchiveObjectWithData:data] retain] autorelease];
	
	//NSLog(@"got some data, yo. it's: %@", [dict description]);

	NSString *eventName = [dict objectForKey:@"event_name"];
	if (eventName == nil) {
		NSLog(@"GOT MESSAGE I DON'T UNDERSTAND!!!!");
		NSLog(@"%@", [dict description]);
		return;
	}
	
	NSNumber *time_obj = (NSNumber*)[dict objectForKey:@"time_sent"];
	if (time_obj == nil) {
		NSLog(@"time not attached... problem?");
	}
	
	id<ASDataSyncee> syncee = [self handlerForEvent:eventName];
	if(syncee == nil) {
		NSLog(@"event: %@ has no handler!", eventName);
		return;
	}
	
	NSTimeInterval send_time = [time_obj doubleValue];
	
	//let syncee take care of the rest
	[syncee receiveData:dict fromTime:send_time];
}


@end
