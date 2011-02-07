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
		for (int i = 0; i < 4; ++i) {
			for (int j = 0; j < 4; ++j) {
				squares[i][j] = false;
			}
		}
		sonifier = new TouchMatrixSonifier(this);
		time_elapsed = 0.;
		current_column = 0;
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
};

/*
@interface TouchMatrix : NSObject {

}

@end
*/