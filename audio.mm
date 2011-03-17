//
//  audio.mm
//  awesomesauce
//
//  Created by Keegan Poppen on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "audio.h"
#import "mo_audio.h"
#import "awesomesauceAppDelegate.h"
#import "AwesomeSynth.h"
#import <math.h>

#define SRATE 44100
#define FRAMESIZE 512
#define NUM_CHANNELS 2

using namespace stk;

bool playback_on = true;
bool is_mute = false;

void setPlayback(bool inval) {
	playback_on = inval;
}

void setMute(bool inval) {
	is_mute = inval;
}

void toggleMute() {
	is_mute = !is_mute;
}

void sonifyMatrix(Float32 *buffer, UInt32 numFrames, void *userData, TouchMatrix *matrix, int numMatrices) {
	if(is_mute) { return; }
	int col = matrix->getColumn();
	
	for (UInt32 i = 0; i < numFrames; ++i) {
		Float32 val = 0.;
		int num_notes = 0;
		
		for (int row = 0; row < 16; ++row) {
			if(!matrix->squares[row][col]) continue;
			if(matrix->col_progress > (matrix->note_length + matrix->note_release)) continue;
			
			Float32 tick_val = matrix->waves[row]->tick();
			if(matrix->col_progress > matrix->note_length) {
				Float32 rel_ratio = 1.0 - ((matrix->col_progress - matrix->note_length) / matrix->note_release);
				tick_val *= rel_ratio;
			}
			else if(matrix->col_progress < matrix->note_attack) {
				Float32 att_ratio = matrix->col_progress / matrix->note_attack;
				tick_val *= att_ratio;
			}
			
			val += tick_val;
			++num_notes;
		}
		if(val != 0) {
			val /= num_notes;
			val /= numMatrices;
			buffer[2*i] += val;
			buffer[2*i + 1] += val;
		}
	}
}

void audio_callback( Float32 * buffer, UInt32 numFrames, void * userData ) {
	if(is_mute) { return; }
	for (int i = 0; i < numFrames; ++i) buffer[2*i] = buffer[2*i + 1] = 0.;
	if(playback_on) {
		[(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] sonifyMatricesInfoBuffer:buffer withNumFrames:numFrames withUserData:userData];
		[(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] timePassed:(numFrames/(float)SRATE)];
	}
}

void audioInit() {
	
	// init
    bool result = MoAudio::init( SRATE, FRAMESIZE, NUM_CHANNELS );
    if( !result )
    {
        // do not do this:
        int * p = 0;
        *p = 0;
    }
	NSLog(@"MoAudio initted!");
	
    // start
    result = MoAudio::start( audio_callback, NULL );
    if( !result )
    {
        // do not do this:
        int * p = 0;
        *p = 0;
    }
	NSLog(@"MoAudio started!");
	
}