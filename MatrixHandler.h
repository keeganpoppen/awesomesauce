/*
 *  MatrixHandler.h
 *  awesomesauce
 *
 *  Created by Ravi Parikh on 2/13/11.
 *  Copyright 2011 AwesomeBox. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

#import "TouchMatrix.h"
#import "MatrixNetworkHandler.h"
#import "AwesomeServerDelegate.h"
#import "AwesomeNetworker.h"
#import "AwesomeDataPersistenceHandler.h"
#import "DrumPad.h"
#import <vector>

using namespace std;

class MatrixHandler {
	
public:
	MatrixHandler();
	
	void setBpm(float newBpm, bool sendNotification = true);
	void addNewMatrix(bool sendNotification = true);
	void addNewMatrix(TouchMatrix *matrix, bool sendNotification = false);//NOTE: THIS IS AN UNSTABLE FORK OF THE NO-ARGUMENT VERSION
	void advanceTime(float timeElapsed);
	void changeInstrument(int newInst, bool sendNotification = true);
	void clearCurrentMatrix(bool sendNotification = true);
	void displayCurrentMatrix();
	void setMatrixOn(int trackId, bool newOnState);
	void sonifyAllMatrices(Float32 * buffer, UInt32 numFrames, void * userData);
	void addOffset(double offset);
	
	void setSquare(int row, int col, bool value);
	bool toggleSquare(int row, int col);
	void setFutureSquare(int row, int col, bool value);
	bool toggleFutureSquare(int row, int col);
	
	NSDictionary *encode();
	void decode(NSDictionary *dict);
	void resetTime();
	void startFuture(int future_length, int f_mode, bool sendNotification=true);
	void cancelFuture();
	void pressPad(int i);
	AwesomeNetworkSyncer *getSyncer();
	
	void saveCurrentComposition(NSString *name);
	
	TouchMatrix *getCurrentMatrix();
	TouchMatrix *getMatrix(int matrix_id);
	
	DrumPad *drumPad;
	vector<TouchMatrix *> matrices;
	TouchMatrix *drumMatrix;
	int currentMatrix;
	
	float time_elapsed;
	float col_progress; //percentage of that column that has elapsed
	int current_column;
	float bpm; //number of sixteenth notes per minute, actually
	
	MatrixNetworkHandler *networkHandler;
	AwesomeNetworker *awesomeNetworker;
	
	AwesomeServerDelegate *serverDelegate;
	AwesomeDataPersistenceHandler *dataPersistenceHandler;
};