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
	TouchMatrix(int inst) {
		instrument = inst;
		for (int i = 0; i < 16; ++i) {
			for (int j = 0; j < 16; ++j) {
				squares[i][j] = false;
			}
		}
		
		time_elapsed = 0.;
		current_column = 0;
		
		//init waves var
		for (int i = 0; i < 16; ++i) {
			int index = i % 5;
			int octave = i / 5 + 1;
			
			float freq = base_freq * pow(2, octave + (pentatonic_indices[index]/12.));
			
			waves[i] = new AwesomeSynth(instrument);
			waves[i]->setFrequency(freq);
		}
		isOn = true;
	}
	
	bool toggleSquare(int row, int col) {
		squares[row][col] = !squares[row][col];
		return squares[row][col];
	}
	void setSquare(int row, int col, bool value) { squares[row][col] = value; }
	bool getSquare(int row, int col) { return squares[row][col]; }
	
	bool isOn;
	
	void setInst(int newInst);
	
	int getColumn() { return current_column; }
	
	//void advanceTime(float timeElapsed);
	void clear();
	
	bool squares[16][16];
	AwesomeSynth *waves[16];
	float time_elapsed;
	int current_column;
	int instrument;
	NSString *track_name;
};