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

void TouchMatrix::setInstrument(int newVal) {
	instrument = newVal;
	int num = 16;
	if(instClass == 1) {
		num = 8;
	}
	for (int i = 1; i <= num; ++i) {
		waves[i-1]->setInstrument(newVal, i, instClass);
	}
}

//instantiate a touchmatrix from a NSMutableDictionary
TouchMatrix::TouchMatrix(NSMutableDictionary *fromDictionary) {
	initialize_junk();
	//setInst(instToCopy);
	
	NSMutableArray *notes = [fromDictionary objectForKey:@"notes"];
	NSMutableArray *futureNotes = [fromDictionary objectForKey:@"futureNotes"];
		
	for (int i = 0; i < 16; ++i) {
		for (int j = 0; j < 16; ++j) {
			bool val = [[notes objectAtIndex:(i*16 + j)] boolValue];
			bool futureVal = [[futureNotes objectAtIndex:(i*16 + j)] boolValue];
			setSquare(i, j, val);
			setFutureSquare(i, j, futureVal);
		}
	}
	
	track_id = [[fromDictionary objectForKey:@"track_id"] intValue];
	future_steps_remaining = [[fromDictionary objectForKey:@"future_steps_remaining"] intValue];
	is_futuring = [[fromDictionary objectForKey:@"is_futuring"] boolValue];
	instClass = [[fromDictionary objectForKey:@"instClass"] intValue];
	setInstrument([[fromDictionary objectForKey:@"instrument"] intValue]);
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
	NSMutableArray *future_notes = [[[NSMutableArray alloc] initWithCapacity:256] retain];
	for (int i = 0; i < 16; ++i) {
		for (int j = 0; j < 16; ++j) {
			NSNumber *boolnum = [[[NSNumber alloc] initWithBool:squares[i][j]] retain];
			[flat_notes insertObject:boolnum atIndex:(i*16 + j)];
			
			NSNumber *boolnum2 = [[[NSNumber alloc] initWithBool:futureSquares[i][j]] retain];
			[future_notes insertObject:boolnum2 atIndex:(i*16 + j)];
		}
	}
	
	[dict setObject:flat_notes forKey:@"notes"];
	[dict setObject:future_notes forKey:@"futureNotes"];
	[dict setObject:[NSNumber numberWithInt:track_id] forKey:@"track_id"];
	[dict setObject:[NSNumber numberWithInt:future_steps_remaining] forKey:@"future_steps_remaining"];
	[dict setObject:[NSNumber numberWithBool:is_futuring] forKey:@"is_futuring"];
	[dict setObject:[NSNumber numberWithInt:instrument] forKey:@"instrument"];
	[dict setObject:[NSNumber numberWithInt:instClass] forKey:@"instClass"];
	
	//return [dict autorelease];
	return dict;
}

void TouchMatrix::startFuture(int future_length, int mode) {
	future_steps_remaining = future_length;
	total_future_steps = future_length;
	is_futuring = true;
	future_mode = mode;
	if(mode == 1) {
		future_steps_remaining = (int) (((float) future_steps_remaining)/2.0);
		for (int i = 0; i < 16; ++i) {
			for (int j = 0; j < 16; ++j) {
				beginSquares[i][j] = squares[i][j];
			}
		}
	}
}

void TouchMatrix::clearFuture() {
	for (int i = 0; i < 16; ++i) {
		for (int j = 0; j < 16; ++j) {
			futureSquares[i][j] = false;
		}
	}
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
		if(future_mode == 1) {
			future_mode = 0;
			for (int i = 0; i < 16; ++i) {
				for (int j = 0; j < 16; ++j) {
					futureSquares[i][j] = beginSquares[i][j];
					beginSquares[i][j] = false;
				}
			}
			future_steps_remaining = (int) (((float) total_future_steps)/2.0);
		}
		else {
			is_futuring = false;
		}
	}
	else {
		int futureCount = 0;
		int currentCount = 0;
		for (int i = 0; i < 16; ++i) {
			int index1 = -1;
			int index2 = -1;
			for (int j = 0; j < 16; ++j) {
				if(squares[j][i]) {
					index1 = j;
					currentCount++;
				}
				if(futureSquares[j][i]) {
					index2 = j;
					futureCount++;
				}
			}
		}
		if(futureCount == 0 && currentCount == 0) {
			future_steps_remaining = 0;
			return;
		}
		else if(futureCount == 0) {
			srand ( time(NULL) );
			for (int i = 0; i < 16; ++i) {
				for (int j = 0; j < 16; ++j) {
					if(squares[i][j]) {
						int randNum = rand() % (future_steps_remaining+1);
						if(randNum == 0) {
							squares[i][j] = false;
						}
					}
				}
			}
		}
		else if(currentCount == 0) {
			squares[0][0] = true;
		}
		else if(currentCount >= futureCount){
			bool newSquares[16][16];
			for (int i = 0; i < 16; ++i) {
				for (int j = 0; j < 16; ++j) {
					newSquares[i][j] = false;
				}
			}
			int numDuplicates = 0;
			for (int i = 0; i < 16; ++i) {
				for (int j = 0; j < 16; ++j) {
					if(squares[j][i]) {
						float min_dist = -1.0;
						int min_j = -1;
						int min_i = -1;
						for (int i2 = 0; i2 < 16; ++i2) {
							for (int j2 = 0; j2 < 16; ++j2) {
								if(futureSquares[j2][i2]) {
									float dist = (i - i2)*(i - i2) + (j - j2)*(j - j2);
									if(dist < min_dist || min_dist < 0) {
										int new_i = (int) (((float)(i2 - i)) / (float)(future_steps_remaining+1)) + i;
										int new_j = (int) (((float)(j2 - j)) / (float)(future_steps_remaining+1)) + j;
										if(newSquares[new_j][new_i] && numDuplicates >= currentCount - futureCount) {
											//keep fishing
										}
										else {
											min_i = new_i;
											min_j = new_j;
											min_dist = dist;
										}
									}
								}
							}
						}
						if(newSquares[min_j][min_i]) {
							numDuplicates++;
						}
						else {
							newSquares[min_j][min_i] = true;
						}
					}
				}
			}
			for (int i = 0; i < 16; ++i) {
				for (int j = 0; j < 16; ++j) {
					squares[i][j] = newSquares[i][j];
				}
			}
		}
		else {
			bool newSquares[16][16];
			for (int i = 0; i < 16; ++i) {
				for (int j = 0; j < 16; ++j) {
					newSquares[i][j] = false;
				}
			}
			int numDuplicates = 0;
			for (int i = 0; i < 16; ++i) {
				for (int j = 0; j < 16; ++j) {
					if(futureSquares[j][i]) {
						float min_dist = -1.0;
						int min_j = -1;
						int min_i = -1;
						for (int i2 = 0; i2 < 16; ++i2) {
							for (int j2 = 0; j2 < 16; ++j2) {
								if(squares[j2][i2]) {
									float dist = (i - i2)*(i - i2) + (j - j2)*(j - j2);
									if(dist < min_dist || min_dist < 0) {
										int new_i = (int) (((float)(i - i2)) / (float)(future_steps_remaining+1)) + i2;
										int new_j = (int) (((float)(j - j2)) / (float)(future_steps_remaining+1)) + j2;
										if(newSquares[new_j][new_i] && numDuplicates >= futureCount - currentCount) {
											//keep fishing
										}
										else {
											min_i = new_i;
											min_j = new_j;
											min_dist = dist;
										}
									}
								}
							}
						}
						if(newSquares[min_j][min_i]) {
							numDuplicates++;
						}
						else {
							newSquares[min_j][min_i] = true;
						}
					}
				}
			}
			for (int i = 0; i < 16; ++i) {
				for (int j = 0; j < 16; ++j) {
					squares[i][j] = newSquares[i][j];
				}
			}
		}
	}
}

void TouchMatrix::updateIntermediateSquares_naive() {
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
		int futureCount = 0;
		int currentCount = 0;
		for (int i = 0; i < 16; ++i) {
			int index1 = -1;
			int index2 = -1;
			for (int j = 0; j < 16; ++j) {
				if(squares[j][i]) {
					index1 = j;
					currentCount++;
				}
				if(futureSquares[j][i]) {
					index2 = j;
					futureCount++;
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
				/*
				 int newindex = (int) (((float)(index2 - index1)) / (float)(future_steps_remaining+1)) + index1;
				 squares[index1][i] = false;
				 squares[newindex][i] = true;
				 */
			}
		}
		if(futureCount == 0 && currentCount == 0) {
			//dust to dust
		}
		else if(futureCount == 0) {
			
		}
		else if(currentCount == 0) {
			
		}
		else if(currentCount > futureCount){
			bool newSquares[16][16];
			for (int i = 0; i < 16; ++i) {
				for (int j = 0; j < 16; ++j) {
					newSquares[i][j] = false;
				}
			}
			for (int i = 0; i < 16; ++i) {
				for (int j = 0; j < 16; ++j) {
					if(squares[j][i]) {
						float min_dist = -1.0;
						int min_j = -1;
						int min_i = -1;
						for (int i2 = 0; i2 < 16; ++i2) {
							for (int j2 = 0; j2 < 16; ++j2) {
								if(futureSquares[j2][i2]) {
									float dist = (i - i2)*(i - i2) + (j - j2)*(j - j2);
									if(dist < min_dist || min_dist < 0) {
										min_dist = dist;
										min_j = j2;
										min_i = i2;
									}
								}
							}
						}
						int new_i = (int) (((float)(min_i - i)) / (float)(future_steps_remaining+1)) + i;
						int new_j = (int) (((float)(min_j - j)) / (float)(future_steps_remaining+1)) + j;
						newSquares[new_j][new_i] = true;
					}
				}
			}
			for (int i = 0; i < 16; ++i) {
				for (int j = 0; j < 16; ++j) {
					squares[i][j] = newSquares[i][j];
				}
			}
		}
		else {
			bool newSquares[16][16];
			for (int i = 0; i < 16; ++i) {
				for (int j = 0; j < 16; ++j) {
					newSquares[i][j] = false;
				}
			}
			for (int i = 0; i < 16; ++i) {
				for (int j = 0; j < 16; ++j) {
					if(futureSquares[j][i]) {
						float min_dist = -1.0;
						int min_j = -1;
						int min_i = -1;
						for (int i2 = 0; i2 < 16; ++i2) {
							for (int j2 = 0; j2 < 16; ++j2) {
								if(squares[j2][i2]) {
									float dist = (i - i2)*(i - i2) + (j - j2)*(j - j2);
									if(dist < min_dist || min_dist < 0) {
										min_dist = dist;
										min_j = j2;
										min_i = i2;
									}
								}
							}
						}
						int new_i = (int) (((float)(i - min_i)) / (float)(future_steps_remaining+1)) + min_i;
						int new_j = (int) (((float)(j - min_j)) / (float)(future_steps_remaining+1)) + min_j;
						newSquares[new_j][new_i] = true;
					}
				}
			}
			for (int i = 0; i < 16; ++i) {
				for (int j = 0; j < 16; ++j) {
					squares[i][j] = newSquares[i][j];
				}
			}
		}
	}
}