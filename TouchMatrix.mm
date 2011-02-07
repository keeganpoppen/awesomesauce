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
	
	//current column is time_elapsed * beats/sec % number of columns
	current_column = (int)(time_elapsed * (bpm / 60.)) % 16;
}

/*
@implementation TouchMatrix

@end
*/