//
//  audio.h
//  awesomesauce
//
//  Created by Keegan Poppen on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

class TouchMatrix;

static float base_freq = 110.;
static int pentatonic_indices[5] = {0, 2, 4, 7, 9};

void audioInit();
void sonifyMatrix(Float32 *buffer, UInt32 numFrames, void *userData, TouchMatrix *matrix, int numMatrices);
void setPlayback(bool inval);