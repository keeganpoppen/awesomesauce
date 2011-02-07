//
//  TouchMatrix.h
//  awesomesauce
//
//  Created by Keegan Poppen on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

class TouchMatrix {

public:
	TouchMatrix() {
		for (int i = 0; i < 4; ++i) {
			for (int j = 0; j < 4; ++j) {
				squares[i][j] = false;
			}
		}
		sonifier = new TouchMatrixSonifier();
		time_elapsed = 0.;
	}
	
	void setSquare(int row, int col, bool value) { squares[row][col] = value; }
	bool getSquare(int row, int col) { return squares[row][col]; }
	
	void advanceTime(float timeElapsed);
		
	TouchMatrixSonifier *sonifier;
	TouchMatrixDisplay *display;
	bool squares[16][16];
	float time_elapsed;
};


@interface TouchMatrix : NSObject {

}

@end
