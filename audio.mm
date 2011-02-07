//
//  audio.mm
//  awesomesauce
//
//  Created by Keegan Poppen on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "audio.h"
#import "mo_audio.h"

#define SRATE 44100
#define FRAMESIZE 512
#define NUM_CHANNELS 2

/*
 * TouchMatrixSonifier methods
 */

void TouchMatrixSonifier::sonify( Float32 * buffer, UInt32 numFrames, void * userData ) {

	
	
}

/*
 * END TouchMatrixSonifier methods
 */



/*
 * Global setup stuff
 */

void audio_callback( Float32 * buffer, UInt32 numFrames, void * userData ) {
	[(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] sonifyMatricesInfoBuffer:buffer withNumFrames:numFrames withUserData:userData];
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


@implementation audio

@end
