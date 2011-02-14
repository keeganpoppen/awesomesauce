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

void TouchMatrix::setInst(int newInst) {
	//init waves var
	for (int i = 0; i < 16; ++i) {
		waves[i]->setInstrument(newInst);
	}
}