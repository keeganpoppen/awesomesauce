//
//  AwesomeSynth.h
//  awesomesauce
//
//  Created by Ravi Parikh on 2/13/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import "Generator.h"

using namespace stk;
using namespace std;

class AwesomeSynth {
public:
	AwesomeSynth(int inst);
	StkFloat tick();
	void setFrequency(Float32 inFreq);
	void setInstrument(int newInst);
	
	int instrument;
	
	Generator *gen;
	Float32 frequency;
};