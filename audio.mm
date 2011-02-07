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
#import <math.h>

#define SRATE 44100
#define FRAMESIZE 512
#define NUM_CHANNELS 2

/*
 * TouchMatrixSonifier methods
 */

TouchMatrixSonifier::TouchMatrixSonifier(TouchMatrix *parentMatrix) {
	parent = parentMatrix;
	
	static int pentatonic_indices[5] = {0, 2, 4, 7, 9};
	static float base_freq = 110.;
	
	for (int i = 0; i < 16; ++i) {
		int index = i % 5;
		int octave = i / 5 + 1;
				
		float freq = base_freq * pow(2, octave + (pentatonic_indices[index]/12.));
		
		waves[i] = new SineWave();
		waves[i]->setFrequency(freq);		
	}
}

void TouchMatrixSonifier::sonify(Float32 * buffer, UInt32 numFrames, void *userData) {
	int col = parent->getColumn();
	
	for (UInt32 i = 0; i < numFrames; ++i) {
		Float32 val = 0.;
		int num_notes = 0;
		
		for (int row = 0; row < 16; ++row) {
			if(!parent->squares[row][col]) continue;
			
			val += waves[row]->tick();
			++num_notes;
		}
		val /= num_notes;
		buffer[2*i] += val;
		buffer[2*i + 1] += val;
	}
}

/*
 * END TouchMatrixSonifier methods
 */



/*
 * Global setup stuff
 */

void audio_callback( Float32 * buffer, UInt32 numFrames, void * userData ) {
	for (int i = 0; i < numFrames; ++i) buffer[2*i] = buffer[2*i + 1] = 0.;
	
	[(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] sonifyMatricesInfoBuffer:buffer withNumFrames:numFrames withUserData:userData];
	[(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] timePassed:(numFrames/(float)SRATE)];
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


/*
@implementation audio

@end
*/