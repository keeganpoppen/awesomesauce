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
	oscillator[1] = -10;
	oscillator[2] = -10;
}

int AwesomeSynth::getInst(int index) {
	return oscillator[index];
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
		else if(oscillator[i] == -1) {
			if(!wavSet || wavFile->m_filename == NULL || strcmp(wavFile->m_filename,"") == 0) {
				//nothing happens
			}
			else {
				SAMPLE tempS = wavFile->tick();
				tick_val += tempS;
			}
		}
		else {
			num--;
		}
	}
	return tick_val / num;
}

void AwesomeSynth::reset() {
	if(!wavSet || getInst(0) != -1) {
		return;
	}
	/*
	if(wavFile == NULL) {
		return;
	}
	if(wavFile->m_filename == NULL) {
		return;
	}
	if(strcmp(wavFile->m_filename,"") == 0) {
		return;
	}
	*/
	//TODO how do i set the sound back to the beginning?
	//wavFile->closeFile();
	wavFile->reset();
}

void AwesomeSynth::setWave(const char *inFileName) {
	fileName = inFileName;
	wavFile = new MoAudioFileIn();
	wavFile->openFile(fileName, "wav");
	//NSLog(@"set filename: %s", wavFile->m_filename);
	wavSet = true;
}

void AwesomeSynth::setOscillator(int newVal, int index) {
	if(newVal < -1 || newVal > 2) {
		oscillator[index] = -10;
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