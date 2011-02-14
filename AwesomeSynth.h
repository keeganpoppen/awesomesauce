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
	void tick();
	
	Float32 frequnecy;
}