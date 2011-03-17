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
#import <vector>

using namespace std;

class MatrixHandler {
	
public:
	MatrixHandler();
	
	void setBpm(float newBpm);
	void setCurrentTrackEnvLength(float newVal);
	void setCurrentTrackEnvAttack(float newVal);
	void setCurrentTrackEnvRelease(float newVal);
	void addNewMatrix(bool sendNotification = true);
	void addNewMatrix(TouchMatrix *matrix, bool sendNotification = false);//NOTE: THIS IS AN UNSTABLE FORK OF THE NO-ARGUMENT VERSION
	void advanceTime(float timeElapsed);
	void changeInstrument(int newInst, int index);
	void clearCurrentMatrix();
	void displayCurrentMatrix();
	void setMatrixOn(int trackId, bool newOnState);
	void sonifyAllMatrices(Float32 * buffer, UInt32 numFrames, void * userData);
	void addOffset(double offset);
	NSDictionary *encode();
	void decode(NSDictionary *dict);
	
	void saveCurrentComposition(NSString *name);
	
	TouchMatrix *getCurrentMatrix();
	
	vector<TouchMatrix *> matrices;
	int currentMatrix;
	
	float time_elapsed;
	float col_progress; //percentage of that column that has elapsed
	int current_column;
	float bpm; //number of sixteenth notes per minute, actually
	
	MatrixNetworkHandler *networkHandler;
	AwesomeNetworker *awesomeNetworker;
	
	AwesomeServerDelegate *serverDelegate;
};