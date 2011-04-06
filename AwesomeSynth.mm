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

AwesomeSynth::AwesomeSynth(int inInstType, int inFreq, int inInstClass) {
	setInstrument(inInstType, inFreq, inInstClass);
}

void AwesomeSynth::setInstrument(int inInst, int inFreq, int inInstClass) {
	instrument = inInst;
	instClass = inInstClass;
	frequency = inFreq;
	char fileName[15];
	if(instClass == 0) {
		sprintf(fileName, "s%d-%d", instrument, frequency); //synth class
	}
	else {
		sprintf(fileName, "d%d-%d", instrument, frequency); //drum class
	}
	wavFile = new MoAudioFileIn();
	wavFile->openFile(fileName, "wav");
}

int AwesomeSynth::getInst() {
	return instrument;
}

int AwesomeSynth::getFrequency() {
	return frequency;
}

StkFloat AwesomeSynth::tick() {
	StkFloat tick_val = 0.0;
	int num = 3;
	for(int i = 0; i < 3; i++) {
		SAMPLE tempS = wavFile->tick();
		tick_val += tempS;
	}
	return tick_val / num;
}

void AwesomeSynth::reset() {
	wavFile->reset();
}