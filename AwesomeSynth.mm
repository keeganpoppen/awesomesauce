//
//  AwesomeSynth.mm
//  awesomesauce
//
//  Created by Ravi Parikh on 2/13/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import "AwesomeSynth.h"

AwesomeSynth::AwesomeSynth() {
	gen = new SineWave();	
}

StkFloat AwesomeSynth::tick() {
	return gen->tick();
}

void AwesomeSynth::setFrequency(Float32 inFreq) {
	frequency = inFreq;
	gen->setFrequency(frequency);
}