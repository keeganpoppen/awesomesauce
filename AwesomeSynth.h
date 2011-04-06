//
//  AwesomeSynth.h
//  awesomesauce
//
//  Created by Ravi Parikh on 2/13/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import "Generator.h"
#import "mo_io.h"

using namespace stk;
using namespace std;

class AwesomeSynth {
public:
	AwesomeSynth(int inInstType, int inFreq, int inInstClass);
	void setInstrument(int inInstType, int inFreq, int inInstClass);
	int getInst();
	int getFrequency();
	StkFloat tick();
	void reset();
	
	int instrument;
	int frequency;
	int instClass;
	MoAudioFileIn *wavFile;
};