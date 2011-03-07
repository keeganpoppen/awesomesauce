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

AwesomeSynth::AwesomeSynth() {
	gen[0] = new SineWave();
	gen[1] = NULL;
	gen[2] = NULL;
	oscillator[0] = 0;
	oscillator[1] = -1;
	oscillator[2] = -1;
}

StkFloat AwesomeSynth::tick() {
	StkFloat tick_val = 0.0;
	int num = 3;
	for(int i = 0; i < 3; i++) {
		if(oscillator[i] == 0) {
			tick_val += ((SineWave *) gen[i])->tick();
		}
		else if(oscillator[i] == 1){
			tick_val += ((BlitSquare *) gen[i])->tick();
		}
		else if(oscillator[i] == 2) {
			tick_val += ((BlitSaw *) gen[i])->tick();
		}
		else {
			num--;
		}
	}
	return tick_val / num;
}

void AwesomeSynth::setOscillator(int newVal, int index) {
	if(newVal < 0 || newVal > 2) {
		oscillator[index] = -1;
	}
	else {
		oscillator[index] = newVal;
	}
	if(newVal == 0) {
		gen[index] = new SineWave();
	}
	else if(newVal == 1){
		gen[index] = new BlitSquare();
	}
	else if(newVal == 2) {
		gen[index] = new BlitSaw();
	}
	else {
		gen[index] = NULL;
	}
	setFrequency(frequency);
}

void AwesomeSynth::setFrequency(Float32 inFreq) {
	frequency = inFreq;
	for(int i = 0; i < 3; i++) {
		if(oscillator[i] == 0) {
			((SineWave *) gen[i])->setFrequency(frequency);
		}
		else if(oscillator[i] == 1){
			((BlitSquare *) gen[i])->setFrequency(frequency);
		}
		else if(oscillator[i] == 2){
			((BlitSaw *) gen[i])->setFrequency(frequency);
		}
	}
}