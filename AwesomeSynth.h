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
	AwesomeSynth();
	StkFloat tick();
	void reset();
	void setWave(const char *fileName);
	void setFrequency(Float32 inFreq);
	void setOscillator(int newVal, int index);
	int getInst(int index);
	
	int oscillator[3];
	
	Generator *gen[3];
	Float32 frequency;
	MoAudioFileIn *wavFile;
	bool wavSet;
	const char* fileName;
};