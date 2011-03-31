/*
 *  DrumPad.h
 *  awesomesauce
 *
 *  Created by Ravi Parikh on 3/30/11.
 *  Copyright 2011 AwesomeBox. All rights reserved.
 *
 */


#import "mo_io.h"

using namespace std;

class DrumPad {
public:
	DrumPad();
	SAMPLE tick();
	void reset(int i);
	MoAudioFileIn *pads[8];
	bool isOn[8];
};