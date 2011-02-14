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
#import <vector>

using namespace std;

class MatrixHandler {
	
public:
	MatrixHandler();
	
	void addNewMatrix();
	void addNewMatrix(TouchMatrix *matrix);//NOTE: THIS IS AN UNSTABLE FORK OF THE NO-ARGUMENT VERSION
	void advanceTime(float timeElapsed);
	void changeInstrument(int newInst);
	void clearCurrentMatrix();
	void displayCurrentMatrix();
	void sonifyAllMatrices(Float32 * buffer, UInt32 numFrames, void * userData);
	TouchMatrix *getCurrentMatrix();
	
	vector<TouchMatrix *> matrices;
	int currentMatrix;
	
	float time_elapsed;
	int current_column;
	int bpm; //number of sixteenth notes per minute, actually
	
	MatrixNetworkHandler *networkHandler;
};