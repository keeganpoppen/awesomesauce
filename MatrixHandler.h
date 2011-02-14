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
#import <vector>

using namespace std;

class MatrixHandler {
	
public:
	MatrixHandler();
	
	void advanceTime(float timeElapsed);
	void displayCurrentMatrix();
	void sonifyAllMatrices(Float32 * buffer, UInt32 numFrames, void * userData);
	TouchMatrix *getCurrentMatrix();
	
	vector<TouchMatrix *> matrices;
	int currentMatrix;
};