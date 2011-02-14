//
//  AwesomeSynth.h
//  awesomesauce
//
//  Created by Ravi Parikh on 2/13/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import "Generator.h"
#import "SineWave.h"

using namespace stk;
using namespace std;

class AwesomeSynth {
public:
	AwesomeSynth();
	StkFloat tick();
	void setFrequency(Float32 inFreq);
	
	SineWave *gen;
	Float32 frequency;
};