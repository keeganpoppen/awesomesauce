//
//  TouchMatrix.h
//  awesomesauce
//
//  Created by Keegan Poppen on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "graphics.h"
#import "audio.h"
#import "AwesomeSynth.h"
//#import <string>

using namespace stk;
using namespace std;

class TouchMatrix {

public:
	TouchMatrix() {
		initialize_junk();
	}
	
	//instantiate a touchmatrix from a NSMutableDictionary
	TouchMatrix(NSMutableDictionary *fromDictionary);
	
	//serialize the touchmatrix to a NSMutableDictionary
	NSMutableDictionary *toDictionary();
	
	bool toggleSquare(int row, int col) {
		squares[row][col] = !squares[row][col];
		squareChangedEvent(row, col, squares[row][col]);
		return squares[row][col];
	}
	void setSquare(int row, int col, bool value) {
		if(squares[row][col] != value) {
			squareChangedEvent(row, col, value);
			squares[row][col] = value;
		}
	}
	
	bool toggleFutureSquare(int row, int col) {
		futureSquares[row][col] = !futureSquares[row][col];
		return futureSquares[row][col];
	}
	void setFutureSquare(int row, int col, bool value) {
		if(futureSquares[row][col] != value) {
			futureSquares[row][col] = value;
		}
	}
	bool getSquare(int row, int col) { return squares[row][col]; }
	bool getFutureSquare(int row, int col) { return futureSquares[row][col]; }
	
	void setInstrument(int newVal);
	
	int instClass;
	int instrument;
	
	//something like this?
	void squareChangedEvent(int row, int col, bool value) {
		NSNumber *rownum = [NSNumber numberWithInt:row];
		NSNumber *colnum = [NSNumber numberWithInt:col];
		NSNumber *newval = [NSNumber numberWithBool:value];
		NSNumber *tid = [NSNumber numberWithInt:track_id];
		NSMutableDictionary *dict = [[NSMutableDictionary dictionaryWithObjectsAndKeys:rownum, @"row", colnum, @"col", newval, @"value", tid, @"track_id", nil] retain];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"squareChangedEvent" object:nil userInfo:dict];
	}
	
	int getInstrument() {
		return waves[0]->getInst();
	}
	
	void reset_synths() {
		for (int i = 0; i < 16; ++i) {
			waves[i]->reset();
		}
	}
	
	void initialize_drums() {
		for (int i = 1; i <= 8; ++i) {
			waves[i-1] = new AwesomeSynth(1, i, 1);
		}
	}
	
	bool isOn;
	
	int getColumn() { return current_column; }
	
	//void advanceTime(float timeElapsed);
	void clear();
	
	bool squares[16][16];
	AwesomeSynth *waves[16];
	float time_elapsed;
	int current_column;
	int track_id;
	
	//envelope stuff
	float col_progress;
	
	//future stuff
	bool beginSquares[16][16];
	bool futureSquares[16][16];
	bool is_futuring;
	int future_steps_remaining;
	int total_future_steps;
	int future_mode; //0 = here to there, 1 = there and back
	void updateIntermediateSquares();
	void updateIntermediateSquares_naive();
	void startFuture(int future_length, int mode);
	void clearFuture();
	
private:
	void initialize_junk() {
		for (int i = 0; i < 16; ++i) {
			for (int j = 0; j < 16; ++j) {
				squares[i][j] = false;
				futureSquares[i][j] = false;
			}
		}
		
		time_elapsed = 0.;
		current_column = 0;
		is_futuring = false;
		future_steps_remaining = 0;
		
		//init waves var
		instrument = 1;
		instClass = 0;
		for (int i = 1; i <= 16; ++i) {
			waves[i-1] = new AwesomeSynth(1, i, 0);
		}
		isOn = true;
	}
};