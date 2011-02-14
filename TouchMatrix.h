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

class TouchMatrix {

public:
	TouchMatrix() {
		for (int i = 0; i < 16; ++i) {
			for (int j = 0; j < 16; ++j) {
				squares[i][j] = false;
			}
		}
		
		time_elapsed = 0.;
		current_column = 0;
		bpm = 480.; //actually 120
	}
	
	bool toggleSquare(int row, int col) {
		squares[row][col] = !squares[row][col];
		return squares[row][col];
	}
	void setSquare(int row, int col, bool value) { squares[row][col] = value; }
	bool getSquare(int row, int col) { return squares[row][col]; }
	
	int getColumn() { return current_column; }
	
	void advanceTime(float timeElapsed);
	void clear();
	
	bool squares[16][16];
	float time_elapsed;
	int current_column;
	int bpm;
};