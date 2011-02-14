//
//  AwesomeSynth.h
//  awesomesauce
//
//  Created by Ravi Parikh on 2/13/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import "Instrmnt.h"

using namespace stk;
using namespace std;

class AwesomeSynth {
public:
	AwesomeSynth(int inst);
	StkFloat tick();
	void setFrequency(Float32 inFreq);
	
	int instrument;
	
	Instrmnt *gen;
	Float32 frequency;
};