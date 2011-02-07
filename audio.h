//
//  audio.h
//  awesomesauce
//
//  Created by Keegan Poppen on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

class TouchMatrixSonifier {

public:
	TouchMatrixSonifier(TouchMatrix *parentMatrix) : parent(parentMatrix){}
	
	void sonify( Float32 * buffer, UInt32 numFrames, void * userData );
	
	TouchMatrix *parent;
};

void audioInit();


@interface audio : NSObject {

}

@end
