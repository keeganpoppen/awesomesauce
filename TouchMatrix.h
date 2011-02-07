//
//  TouchMatrix.h
//  awesomesauce
//
//  Created by Keegan Poppen on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "audio.h"

class TouchMatrix {

public:
	TouchMatrix() {
		for (int i = 0; i < 16; ++i) {
			for (int j = 0; j < 16; ++j) {
				squares[i][j] = false;
			}
		}
		
		squares[0][0] = squares[1][0] = true;
		
		squares[0][5] = squares[2][5] = true;
		
		sonifier = new TouchMatrixSonifier(this);
		time_elapsed = 0.;
		current_column = 0;
		bpm = 120.;
	}
	
	void setSquare(int row, int col, bool value) { squares[row][col] = value; }
	bool getSquare(int row, int col) { return squares[row][col]; }
	
	int getColumn() { return current_column; }
	
	void advanceTime(float timeElapsed);
	
	void sonifyMatrix( Float32 * buffer, UInt32 numFrames, void * userData ) {
		sonifier->sonify(buffer, numFrames, userData);
	}
		
	
	TouchMatrixSonifier *sonifier;
	//TouchMatrixDisplay *display;
	bool squares[16][16];
	float time_elapsed;
	int current_column;
	int bpm;
};

/*
@interface TouchMatrix : NSObject {

}

@end
*/