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
	int instToCopy = [[fromDictionary objectForKey:@"instrument"] intValue];
	
	initialize_junk();
	//setInst(instToCopy);
	
	NSMutableArray *notes = [fromDictionary objectForKey:@"notes"];
	
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