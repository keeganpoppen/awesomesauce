//
//  audio.h
//  awesomesauce
//
//  Created by Keegan Poppen on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SineWave.h"

using namespace stk;

class TouchMatrix;

class TouchMatrixSonifier {

public:
	TouchMatrixSonifier(TouchMatrix *parentMatrix);
	
	void sonify( Float32 * buffer, UInt32 numFrames, void * userData );
	
	TouchMatrix *parent;
	SineWave *wave;
};

void audioInit();

/*
@interface audio : NSObject {

}

@end
*/