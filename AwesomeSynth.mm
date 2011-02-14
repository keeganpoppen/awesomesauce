//
//  AwesomeSynth.mm
//  awesomesauce
//
//  Created by Ravi Parikh on 2/13/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import "AwesomeSynth.h"
#import "SineWave.h"
#import "BlitSquare.h"
#import "BlitSaw.h"

AwesomeSynth::AwesomeSynth(int inst) {
	instrument = inst;
	if(instrument == 0) {
		gen = new SineWave();
	}
	else if(instrument == 1){
		gen = new BlitSquare();
	}
	else {
		gen = new BlitSaw();
	}
}

StkFloat AwesomeSynth::tick() {
	if(instrument == 0) {
		return ((SineWave *) gen)->tick();
	}
	else if(instrument == 1){
		return ((BlitSquare *) gen)->tick();
	}
	else {
		return ((BlitSaw *) gen)->tick();
	}
}

void AwesomeSynth::setInstrument(int newInst) {
	instrument = newInst;
	if(instrument == 0) {
		gen = new SineWave();
	}
	else if(instrument == 1){
		gen = new BlitSquare();
	}
	else {
		gen = new BlitSaw();
	}
	setFrequency(frequency);
}

void AwesomeSynth::setFrequency(Float32 inFreq) {
	frequency = inFreq;
	if(instrument == 0) {
		((SineWave *) gen)->setFrequency(frequency);
	}
	else if(instrument == 1){
		((BlitSquare *) gen)->setFrequency(frequency);
	}
	else {
		((BlitSaw *) gen)->setFrequency(frequency);
	}
}