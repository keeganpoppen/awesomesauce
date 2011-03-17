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

-(void)presentMatrixSquareChangedAtRow:(int)row andColumn:(int)column toValue:(BOOL)squareValue withTrackId:(int)trackId;
-(void)futureMatrixSquareChangedAtRow:(int)row andColumn:(int)column toValue:(BOOL)squareValue withTrackId:(int)trackId;
-(void)sendSquareChangedInMatrix:(NSString*)matrix AtRow:(int)row andColumn:(int)column toValue:(BOOL)squareValue withTrackId:(int)trackId;

@property(nonatomic, retain) AwesomeNetworker *networker;
@property(nonatomic) MatrixHandler *matrixHandler;

@end

//ASDataSyncee for future starting
@interface FutureStartSync : NSObject <ASDataSyncee>
{
	AwesomeNetworker *networker;
	MatrixHandler *matrixHandler;
}

-(void)sendFutureStartWithLength:(int)length withTrackId:(int)trackId;
-(void)receiveData:(NSDictionary*)data fromTime:(NSTimeInterval)updateTime;

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


//ASDataSyncee for track removing
@interface TrackClearSync : NSObject <ASDataSyncee>
{
	AwesomeNetworker *networker;
	MatrixHandler *matrixHandler;
}

-(void)receiveData:(NSDictionary*)data fromTime:(NSTimeInterval)updateTime;
-(void)sendTrackClearedWithId:(int)trackId;

@property(nonatomic, retain) AwesomeNetworker *networker;
@property(nonatomic) MatrixHandler *matrixHandler;

@end


@interface InstrumentChangeSync : NSObject <ASDataSyncee>
{
	AwesomeNetworker *networker;
	MatrixHandler *matrixHandler;
}

-(void)receiveData:(NSDictionary*)data fromTime:(NSTimeInterval)updateTime;
-(void)sendInstrumentChanged:(int)instrument withIndex:(int)index onTrack:(int)trackId;

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
	TrackClearSync *trackClearSync;
	FutureStartSync *futureStartSync;
	InstrumentChangeSync *instrumentChangeSync;
}

- (id)initWithNetworker:(AwesomeNetworker*)awesomeNetworker andMatrixHandler:(MatrixHandler*)handler;

@property(nonatomic, retain) AwesomeNetworker *networker;
@property(nonatomic, retain) SquareChangeSync *squareSync;
@property(nonatomic, retain) TrackAddSync *trackAddSync;
@property(nonatomic, retain) TrackRemoveSync *trackRemoveSync;
@property(nonatomic, retain) TrackClearSync *trackClearSync;
@property(nonatomic, retain) FutureStartSync *futureStartSync;
@property(nonatomic, retain) InstrumentChangeSync *instrumentChangeSync;

@end
