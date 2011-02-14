//
//  audio.h
//  awesomesauce
//
//  Created by Keegan Poppen on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

class TouchMatrix;

void audioInit();
void sonifyMatrix(Float32 *buffer, UInt32 numFrames, void *userData, TouchMatrix *matrix, int numMatrices);

/*
 
 class TouchMatrix;
 
 using namespace stk;
 
 class TouchMatrixSonifier {
 
 public:
 TouchMatrixSonifier(TouchMatrix *parentMatrix);
 
 void sonify( Float32 * buffer, UInt32 numFrames, void * userData );
 
 TouchMatrix *parent;	
 
 };

*/