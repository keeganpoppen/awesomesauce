//
//  AwesomeSynth.mm
//  awesomesauce
//
//  Created by Ravi Parikh on 2/13/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import "AwesomeSynth.h"
#import "Clarinet.h"
#import "Flute.h"
#import "Plucked.h"
#import "Drummer.h"

AwesomeSynth::AwesomeSynth(int inst) {
	instrument = inst;
	if(instrument == 0) {
		gen = new Clarinet();
	}
	else if(instrument == 1){
		gen = new Flute();
	}
	else if(instrument == 2){
		gen = new Plucked();
	}
	else {
		gen = new Drummer();
	}
}

StkFloat AwesomeSynth::tick() {
	gen->tick();
}

void AwesomeSynth::setFrequency(Float32 inFreq) {
	frequency = inFreq;
	gen->setFrequency(frequency);
}