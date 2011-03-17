//
//  AwesomeNetworkSyncer.h
//  awesomesauce
//
//  Created by Keegan Poppen on 3/17/11.
//  Copyright 2011 Lord Keeganus Industries. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASDataSyncee.h"
#import "MatrixHandler.h"

/**
 *
 * Sync objects for all the matrix attribtues
 *
 */

@class AwesomeNetworker;

//ASDataSyncee for square changes
@interface SquareChangeSync : NSObject <ASDataSyncee>
{
	AwesomeNetworker *networker;
	MatrixHandler *matrixHandler;
}

-(void)receiveData:(NSDictionary*)data fromTime:(NSTimeInterval)updateTime;

-(void)presentMatrixSquareChangedAtRow:(int)row andColumn:(int)column toValue:(BOOL)squareValue;
-(void)futureMatrixSquareChangedAtRow:(int)row andColumn:(int)column toValue:(BOOL)squareValue;
-(void)sendSquareChangedInMatrix:(NSString*)matrix AtRow:(int)row andColumn:(int)column toValue:(BOOL)squareValue;

@property(nonatomic, retain) AwesomeNetworker *networker;
@property(nonatomic) MatrixHandler *matrixHandler;

@end

//ASDataSyncee for track adding
@interface TrackAddSync : NSObject <ASDataSyncee>
{
	AwesomeNetworker *networker;
	MatrixHandler *matrixHandler;
}

-(void)receiveData:(NSDictionary*)data fromTime:(NSTimeInterval)updateTime;

//send a track added notification. returns the time at which the track was addd.
-(NSTimeInterval)sendTrackAddedWithId:(int)trackId;

@property(nonatomic, retain) AwesomeNetworker *networker;
@property(nonatomic) MatrixHandler *matrixHandler;

@end


//ASDataSyncee for track removing
@interface TrackRemoveSync : NSObject <ASDataSyncee>
{
	AwesomeNetworker *networker;
	MatrixHandler *matrixHandler;
}

-(void)receiveData:(NSDictionary*)data fromTime:(NSTimeInterval)updateTime;

-(void)sendTrackRemovedWithId:(int)trackId;

@property(nonatomic, retain) AwesomeNetworker *networker;
@property(nonatomic) MatrixHandler *matrixHandler;

@end



/**
 *
 * The truck that holds all the attribute syncers
 *
 */

@interface AwesomeNetworkSyncer : NSObject {
	AwesomeNetworker *networker;
	SquareChangeSync *squareSync;
	TrackAddSync *trackAddSync;
	TrackRemoveSync *trackRemoveSync;
}

- (id)initWithNetworker:(AwesomeNetworker*)awesomeNetworker;

@property(nonatomic, retain) AwesomeNetworker *networker;
@property(nonatomic, retain) SquareChangeSync *squareSync;
@property(nonatomic, retain) TrackAddSync *trackAddSync;
@property(nonatomic, retain) TrackRemoveSync *trackRemoveSync;

@end
