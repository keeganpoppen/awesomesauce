/*
 *  DrumPad.mm
 *  awesomesauce
 *
 *  Created by Ravi Parikh on 3/30/11.
 *  Copyright 2011 AwesomeBox. All rights reserved.
 *
 */

#include "DrumPad.h"

DrumPad::DrumPad() {
	/*
	pads[0] = new MoAudioFileIn();
	pads[1] = new MoAudioFileIn();
	pads[2] = new MoAudioFileIn();
	pads[3] = new MoAudioFileIn();
	pads[4] = new MoAudioFileIn();
	pads[5] = new MoAudioFileIn();
	pads[6] = new MoAudioFileIn();
	pads[7] = new MoAudioFileIn();
	*/
	for(int i = 0; i < 8; i++) {
		pads[i] = new MoAudioFileIn();
		isOn[i] = false;
	}
	
	pads[0]->openFile("1kick", "wav");
	pads[1]->openFile("2snare", "wav");
	pads[2]->openFile("3snare2", "wav");
	pads[3]->openFile("4clap", "wav");
	pads[4]->openFile("5clap2", "wav");
	pads[5]->openFile("6hatopen", "wav");
	pads[6]->openFile("7hatclosed", "wav");
	pads[7]->openFile("8shaker", "wav");
}

SAMPLE DrumPad::tick() {
	SAMPLE tickVal = 0.0;
	for(int i = 0; i < 8; i++) {
		if(isOn[i]) {
			if(pads[i]->isFinished()) {
				isOn[i] = false;
			}
			tickVal += pads[i]->tick();
		}
	}
	return tickVal;
}

void DrumPad::reset(int i) {
	pads[i]->reset();
	isOn[i] = true;
}

