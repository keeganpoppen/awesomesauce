//
//  TouchMatrix.mm
//  awesomesauce
//
//  Created by Keegan Poppen on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TouchMatrix.h"

void TouchMatrix::advanceTime(float timeElapsed) {
	time_elapsed += timeElapsed;
	
	NSLog(@"time elapsed: %f", time_elapsed);
	
	//if the time is right, tell the sonifier and the graphics thingy that the playhead has moved
}

/*
@implementation TouchMatrix

@end
*/