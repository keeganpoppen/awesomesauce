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
	for(int i = 0; i < 8; i++) {
		pads[i] = new MoAudioFileIn();
		isOn[i] = false;
	}
	
	pads[0]->openFile("d1-1", "wav");
	pads[1]->openFile("d1-2", "wav");
	pads[2]->openFile("d1-3", "wav");
	pads[3]->openFile("d1-4", "wav");
	pads[4]->openFile("d1-5", "wav");
	pads[5]->openFile("d1-6", "wav");
	pads[6]->openFile("d1-7", "wav");
	pads[7]->openFile("d1-8", "wav");
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

