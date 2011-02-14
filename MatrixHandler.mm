/*
 *  MatrixHandler.mm
 *  awesomesauce
 *
 *  Created by Ravi Parikh on 2/13/11.
 *  Copyright 2011 AwesomeBox. All rights reserved.
 *
 */

#import "MatrixHandler.h"
#import "graphics.h"
#import "audio.h"

using namespace std;

MatrixHandler::MatrixHandler() {
	//initialize with one tone matrix
	TouchMatrix *firstMatrix = new TouchMatrix(0);
	firstMatrix->track_id = 0;
	matrices.push_back(firstMatrix);
	currentMatrix = 0;

	time_elapsed = 0.;
	current_column = 0;
	bpm = 480.; //actually 120
	
	//set up networking junk
	NSLog(@"matrixhandler makear");
	networkHandler = [[MatrixNetworkHandler alloc] init];
}

void MatrixHandler::addNewMatrix() {
	TouchMatrix *newMatrix = new TouchMatrix(0);
	newMatrix->track_id = matrices.size();
	matrices.push_back(newMatrix);
	currentMatrix = matrices.size() - 1;
}

void MatrixHandler::addNewMatrix(TouchMatrix *matrix) {
	matrices.push_back(matrix);
	currentMatrix = matrices.size() - 1;
	trackAddedEvent(currentMatrix);
}

void trackAddedEvent(int newIndex) {
	NSNumber *tid = [NSNumber numberWithInt:newIndex];
	NSMutableDictionary *dict = [[NSMutableDictionary dictionaryWithObjectsAndKeys:tid, @"tid", nil] retain];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"trackAddedEvent" object:nil userInfo:dict];
}

void trackClearedEvent(int index) {
	NSNumber *tid = [NSNumber numberWithInt:index];
	NSMutableDictionary *dict = [[NSMutableDictionary dictionaryWithObjectsAndKeys:tid, @"tid", nil] retain];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"trackClearedEvent" object:nil userInfo:dict];
}
/*
void trackEditedEvent(int index, bool isOn, int instrument) {
	NSNumber *instnum = [NSNumber numberWithInt:instrument];
	NSNumber *onnum = [NSNumber numberWithBool:isOn];
	NSNumber *tid = [NSNumber numberWithInt:index];
	NSMutableDictionary *dict = [[NSMutableDictionary dictionaryWithObjectsAndKeys:instnum, @"inst", onnum, @"on", tid, @"tid", nil] retain];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"squareChangedEvent" object:nil userInfo:dict];
}
*/

void MatrixHandler::clearCurrentMatrix() {
	getCurrentMatrix()->clear();
	trackClearedEvent(currentMatrix);
}

void MatrixHandler::changeInstrument(int newInst) {
	getCurrentMatrix()->setInst(newInst);
	//trackEditedEvent(currentMatrix, getCurrentMatrix()->isOn, newInst);
}

void MatrixHandler::advanceTime(float timeElapsed) {
	time_elapsed += timeElapsed;
	
	//current column is time_elapsed * beats/sec % number of columns
	current_column = (int)(time_elapsed * (bpm / 60.)) % 16;
	
	for(int i = 0; i < matrices.size(); i++) {
		matrices[i]->time_elapsed = time_elapsed;
		matrices[i]->current_column = current_column;
	}
}

void MatrixHandler::displayCurrentMatrix() {
	displayMatrix(getCurrentMatrix());
}

void MatrixHandler::sonifyAllMatrices(Float32 * buffer, UInt32 numFrames, void * userData) {
	int numMatrices = matrices.size();
	for(int i = 0; i < numMatrices; i++) {
		if(matrices[i]->isOn) {
			sonifyMatrix(buffer, numFrames, userData, matrices[i], numMatrices);
		}
	}
}

TouchMatrix *MatrixHandler::getCurrentMatrix() {
	return matrices[currentMatrix];
}