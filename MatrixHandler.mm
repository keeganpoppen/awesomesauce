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
#import "awesomesauceAppDelegate.h"

using namespace std;

//TODO
void trackEditedEvent(int index, bool isOn) {
	/*
	 
	NSNumber *instnum = [NSNumber numberWithInt:instrument];
	NSNumber *onnum = [NSNumber numberWithBool:isOn];
	NSNumber *tid = [NSNumber numberWithInt:index];
	NSMutableDictionary *dict = [[NSMutableDictionary dictionaryWithObjectsAndKeys:instnum, @"inst", onnum, @"on", tid, @"track_id", nil] retain];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"squareChangedEvent" object:nil userInfo:dict];
	
	 */
}

MatrixHandler::MatrixHandler() {
	drumPad = new DrumPad();
	
	//initialize with one tone matrix
	TouchMatrix *firstMatrix = new TouchMatrix();
	firstMatrix->track_id = 0;
	matrices.push_back(firstMatrix);
	
	drumMatrix = new TouchMatrix();
	drumMatrix->track_id = -1;
	drumMatrix->initialize_drums();
	
	currentMatrix = 0;
	col_progress = 0.;
	time_elapsed = 0.;
	current_column = 0;
	bpm = 480.; //actually 120
	
	//set up networking junk
	/*
	NSLog(@"matrixhandler makear");
	networkHandler = [[MatrixNetworkHandler alloc] init]; //TODO: MEMORY LEAK!!!
	 */
	NSLog(@"gonna test some of that newar awesomenetworker");
	awesomeNetworker = [[AwesomeNetworker alloc] initWithMatrixHandler:this];
	
	
	NSLog(@"setting up the awesome server delegate");
	serverDelegate = [[AwesomeServerDelegate alloc] init]; //TODO: MEMORY LEAK!!!
	
	NSLog(@"setting up the awesome data persistence handler");
	dataPersistenceHandler = [[AwesomeDataPersistenceHandler alloc] init];
	
	/* TODO: DELETE
	NSLog(@"getting a list of them all");
	NSDictionary *comps = [[[serverDelegate getCompositionListFromServer] retain] autorelease];
	
	NSLog(@"getting one of them");
	NSDictionary *comp = [[[serverDelegate getCompositionFromServerWithID:2] retain] autorelease];
	*/
}

void MatrixHandler::pressPad(int i) {
	drumPad->reset(i);
}

void MatrixHandler::addNewMatrix(bool sendNotification) {
	TouchMatrix *newMatrix = new TouchMatrix();
	newMatrix->track_id = matrices.size();
	matrices.push_back(newMatrix);
	if(sendNotification) {
		currentMatrix = matrices.size() - 1;
		AwesomeNetworkSyncer *temp = awesomeNetworker.networkSyncer;
		[[temp trackAddSync] sendTrackAddedWithId:newMatrix->track_id];
	}
}

void MatrixHandler::addNewMatrix(TouchMatrix *matrix, bool sendNotification) {
	matrix->track_id = matrices.size();
	matrices.push_back(matrix);
	if(sendNotification) {
		currentMatrix = matrices.size() - 1;
		AwesomeNetworkSyncer *temp = awesomeNetworker.networkSyncer;
		[[temp trackAddSync] sendTrackAddedWithId:matrix->track_id];
	}
}

void MatrixHandler::setMatrixOn(int trackId, bool newOnState) {
	if(trackId == -1) {
		drumMatrix->isOn = newOnState;
	}
	else {
		matrices[trackId]->isOn = newOnState;
	}
	//trackEditedEvent(trackId, newOnState, matrices[trackId]->instrument);
}

void MatrixHandler::clearCurrentMatrix(bool sendNotification) {
	getCurrentMatrix()->clear();
	if(sendNotification) {
		AwesomeNetworkSyncer *temp = awesomeNetworker.networkSyncer;
		[[temp trackClearSync] sendTrackClearedWithId:getCurrentMatrix()->track_id];
	}
}

AwesomeNetworkSyncer *MatrixHandler::getSyncer() {
	return awesomeNetworker.networkSyncer;
}

bool MatrixHandler::toggleSquare(int row, int col) {
	if(currentMatrix == -1 && row >= 8) {
		return false;
	}
	bool toggled = getCurrentMatrix()->toggleSquare(row, col);
	AwesomeNetworkSyncer *temp = awesomeNetworker.networkSyncer;
	if(temp != nil) {
		[[temp squareSync] presentMatrixSquareChangedAtRow:row andColumn:col toValue:toggled withTrackId:currentMatrix];
	}
	return toggled;
}

void MatrixHandler::setSquare(int row, int col, bool value) {
	if(currentMatrix == -1 && row >= 8) {
		return;
	}
	AwesomeNetworkSyncer *temp = awesomeNetworker.networkSyncer;
	if(temp != nil) {
		[[temp squareSync] presentMatrixSquareChangedAtRow:row andColumn:col toValue:value withTrackId:currentMatrix];
	}
	getCurrentMatrix()->setSquare(row, col, value);
}

bool MatrixHandler::toggleFutureSquare(int row, int col) {
	bool toggled = getCurrentMatrix()->toggleFutureSquare(row, col);
	AwesomeNetworkSyncer *temp = awesomeNetworker.networkSyncer;
	if(temp != nil) {
		[[temp squareSync] futureMatrixSquareChangedAtRow:row andColumn:col toValue:toggled withTrackId:currentMatrix];
	}
	return toggled;
}

void MatrixHandler::setFutureSquare(int row, int col, bool value) {
	AwesomeNetworkSyncer *temp = awesomeNetworker.networkSyncer;
	if(temp != nil) {
		[[temp squareSync] futureMatrixSquareChangedAtRow:row andColumn:col toValue:value withTrackId:currentMatrix];
	}
	getCurrentMatrix()->setFutureSquare(row, col, value);
}

void MatrixHandler::changeInstrument(int newVal, bool sendNotification) {
	getCurrentMatrix()->setInstrument(newVal);
	if(sendNotification) {
		AwesomeNetworkSyncer *temp = awesomeNetworker.networkSyncer;
		[[temp instrumentChangeSync] sendInstrumentChanged:newVal onTrack:getCurrentMatrix()->track_id];
	}
}

void MatrixHandler::advanceTime(float timeElapsed) {
	time_elapsed += timeElapsed;
	
	//current column is time_elapsed * beats/sec % number of columns
	float col_exact = (time_elapsed * (bpm / 60.));
	
	bool cusp = false;
	if(current_column == 15) {
		cusp = true;
	}
	
	int old_column = current_column;
	current_column = (int)col_exact % 16;
	if(old_column != current_column) {
		drumMatrix->reset_synths();
		for(int i = 0; i < matrices.size(); i++) {
			matrices[i]->reset_synths();
		}
	}
	
	col_progress = col_exact - (float)((int)col_exact);
	
	for(int i = 0; i < matrices.size(); i++) {
		matrices[i]->time_elapsed = time_elapsed;
		matrices[i]->current_column = current_column;
		matrices[i]->col_progress = col_progress;
	}
	drumMatrix->time_elapsed = time_elapsed;
	drumMatrix->current_column = current_column;
	drumMatrix->col_progress = col_progress;
	
	if(cusp && current_column == 0) {
		//we have switched to a new frame
		for(int i = 0; i < matrices.size(); i++) {
			matrices[i]->updateIntermediateSquares();
		}
	}
}

void MatrixHandler::resetTime() {
	time_elapsed = 0.0;
	current_column = 0;
	col_progress = 0.0;
}

void MatrixHandler::addOffset(double offset) {
	time_elapsed += offset;
}

void MatrixHandler::displayCurrentMatrix() {
	if(isFutureMode()) {
		displayMatrixFuture(getCurrentMatrix());
	}
	else if(currentMatrix == -1) {
		displayDrumMatrix(getCurrentMatrix());
	}
	else {
		displayMatrix(getCurrentMatrix());
	}
}

void MatrixHandler::sonifyAllMatrices(Float32 * buffer, UInt32 numFrames, void * userData) {
	int numMatrices = matrices.size();
	for(int i = 0; i < numMatrices; i++) {
		if(matrices[i]->isOn) {
			sonifyMatrix(buffer, numFrames, userData, matrices[i], 0.4/((Float32)numMatrices));
		}
	}
	if(drumMatrix->isOn) {
		sonifyMatrix(buffer, numFrames, userData, drumMatrix, 0.6);
	}
	//TODO: should drumpad shut off when drums are off? probably not
	sonifyDrumPad(buffer, numFrames, userData, drumPad, 0.6);
}

void MatrixHandler::setBpm(float newBpm, bool sendNotification) {
	if(newBpm < 60.0 || newBpm > 180.0) {
		NSLog(@"BPM invalid: %f", newBpm);
		return;
	}
	bpm = newBpm * 4.0;
	NSLog(@"BPM set: %f", newBpm);
	if(sendNotification) {
		AwesomeNetworkSyncer *temp = awesomeNetworker.networkSyncer;
		[[temp bpmChangeSync] sendBPMChanged:newBpm];
	}
}

void MatrixHandler::saveCurrentComposition(NSString *name) {
	NSLog(@"serializing self in order to save on the server");
	[serverDelegate requestSendCompositionToServerWithName:name];
	NSLog(@"ideally, done being saved on the server");
}

//TODO: fix encode to account for drums
NSDictionary *MatrixHandler::encode() {
	//vars:
	//vector<TouchMatrix *> matrices;
	//float bpm;
	//will not encode current column, current matrix, or time elapsed
	//will not encode the network handler, probably unnecessary to do so?
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	int numMatrices = matrices.size();
	NSMutableArray *array = [[NSMutableArray alloc] init]; 
	for(int i = 0; i < numMatrices; i++) {
		NSMutableDictionary *temp = matrices[i]->toDictionary();
		[array addObject:temp];
	}
	NSMutableDictionary *drumDict = drumMatrix->toDictionary();
	[dict setObject:array forKey:@"matrices"];
	[dict setObject:drumDict forKey:@"drumMatrix"];
	[dict setObject:[NSNumber numberWithFloat:bpm] forKey:@"bpm"];
	return dict;
}

void MatrixHandler::startFuture(int future_length, int f_mode, bool sendNotification) {
	getCurrentMatrix()->startFuture(future_length, f_mode);
	if(sendNotification) {
		AwesomeNetworkSyncer *temp = awesomeNetworker.networkSyncer;
		[[temp futureStartSync] sendFutureStartWithLength:future_length withMode:f_mode withTrackId:getCurrentMatrix()->track_id];
	}
}

void MatrixHandler::cancelFuture() {
	getCurrentMatrix()->clearFuture();
}

//TODO: fix decode to account for drums
void MatrixHandler::decode(NSDictionary *dict) {
	matrices.clear();
		
	NSArray *array = (NSArray *) [dict objectForKey:@"matrices"];
	NSEnumerator *enumerator = [array objectEnumerator];
	id element;
	while(element = [enumerator nextObject])
    {
		TouchMatrix *newMatrix = new TouchMatrix(element);
		matrices.push_back(newMatrix);
    }
	
	drumMatrix = new TouchMatrix([dict objectForKey:@"drumMatrix"]);
	
	currentMatrix = 0;
	bpm = [((NSNumber *)[dict objectForKey:@"bpm"]) floatValue];
	for(int i = 0; i < matrices.size() - 1; i++) {
		[(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] addMatrixInterface];
	}
}

TouchMatrix *MatrixHandler::getCurrentMatrix() {
	if(currentMatrix == -1) {
		return drumMatrix;
	}
	return matrices[currentMatrix];
}

TouchMatrix *MatrixHandler::getMatrix(int matrix_id) {
	if(matrix_id == -1) {
		return drumMatrix;
	}
	return matrices[matrix_id];
}
