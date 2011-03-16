//
//  TouchMatrix.mm
//  awesomesauce
//
//  Created by Keegan Poppen on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TouchMatrix.h"

void TouchMatrix::clear() {
    for (int i = 0; i < 16; ++i) {
		for (int j = 0; j < 16; ++j) {
			squares[i][j] = false;
		}
	}
}

void TouchMatrix::setOscillator(int newVal, int index) {
	for (int i = 0; i < 16; ++i) {
		waves[i]->setOscillator(newVal, index);
	}
}

//instantiate a touchmatrix from a NSMutableDictionary
TouchMatrix::TouchMatrix(NSMutableDictionary *fromDictionary) {
	initialize_junk();
	//setInst(instToCopy);
	
	NSMutableArray *notes = [fromDictionary objectForKey:@"notes"];
	
	NSLog(@"NOTES: %@", notes);
	
	for (int i = 0; i < 16; ++i) {
		for (int j = 0; j < 16; ++j) {
			bool val = [[notes objectAtIndex:(i*16 + j)] boolValue];
			setSquare(i, j, val);
		}
	}
	
	track_id = [[fromDictionary objectForKey:@"track_id"] intValue];
}

/*
 * serialize the touchmatrix to a NSMutableDictionary. the return value is of the form:
 {notes: [[row1],[row2],...,[row16]], track_id: ###, instrument: ###}
 */
NSMutableDictionary *TouchMatrix::toDictionary() {
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] initWithCapacity:(256 + 2)] retain];
	
	//flatten squares array (NOTE: technically this is probably the same as the squares array already is in memory...)
	//NSMutableArray *flat_notes = [NSMutableArray arrayWithCapacity:256];
	NSMutableArray *flat_notes = [[[NSMutableArray alloc] initWithCapacity:256] retain];
	for (int i = 0; i < 16; ++i) {
		for (int j = 0; j < 16; ++j) {
			NSNumber *boolnum = [[[NSNumber alloc] initWithBool:squares[i][j]] retain];
			[flat_notes insertObject:boolnum atIndex:(i*16 + j)];
		}
	}
	
	[dict setObject:flat_notes forKey:@"notes"];
	
	[dict setObject:[NSNumber numberWithInt:track_id] forKey:@"track_id"];
	//[dict setObject:[NSNumber numberWithInt:instrument] forKey:@"instrument"];
	
	//return [dict autorelease];
	return dict;
}

void TouchMatrix::startFuture(int future_length) {
	future_steps_remaining = future_length;
	is_futuring = true;
}

void TouchMatrix::updateIntermediateSquares() {
	if(!is_futuring) {
		return;
	}
	future_steps_remaining--;
	if(future_steps_remaining == 0) {
		for (int i = 0; i < 16; ++i) {
			for (int j = 0; j < 16; ++j) {
				squares[i][j] = futureSquares[i][j];
				futureSquares[i][j] = false;
			}
		}
		is_futuring = false;
	}
	else {
		for (int i = 0; i < 16; ++i) {
			int index1 = -1;
			int index2 = -1;
			for (int j = 0; j < 16; ++j) {
				if(squares[j][i]) {
					index1 = j;
				}
				if(futureSquares[j][i]) {
					index2 = j;
				}
			}
			if(index1 == -1 && index2 == -1) {
				//nothing
			}
			else if(index1 == -1) {
				
			}
			else if(index2 == -1) {
				
			}
			else {
				int newindex = (int) (((float)(index2 - index1)) / (float)future_steps_remaining) + index1;
				squares[index1][i] = false;
				squares[newindex][i] = true;
			}
		}
	}
}