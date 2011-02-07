//
//  graphics.mm
//  awesomesauce
//
//  Created by Keegan Poppen on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "graphics.h"
#include "mo_gfx.h"

#import "mo_touch.h"

/*
 * TouchMatrixDisplay methods
 */

TouchMatrixDisplay::TouchMatrixDisplay(TouchMatrix *parentMatrix) {
	parent = parentMatrix;
}

void TouchMatrixDisplay::display() {
	// reset projection matrix
	glMatrixMode( GL_PROJECTION );
	glLoadIdentity();
	glOrthof( -1.0f, 1.0f, -1.5f, 1.5f, 1.0f, 1.0f);
	
	// modelview
	glMatrixMode( GL_MODELVIEW );
	glLoadIdentity();
	
	// set clear color to black
	glClearColor( 0, 0, 0, 1.0f );
	glClear( GL_COLOR_BUFFER_BIT );
	
	// map the viewport
	MoGfx::ortho( 320, 480, 1 );
	
	glEnableClientState( GL_VERTEX_ARRAY );
	
	//draw stuff sample
	
	static const GLfloat half_width = 30;
    static const GLfloat squareVertices[] = {
        -half_width, -half_width,
        half_width, -half_width,
        -half_width, half_width,
        half_width, half_width,
    };
	
	glPushMatrix();
	// translate
	glTranslatef( 50.0, 50.0, 0 );
	
    // color
    glColor4f( 1.0, 0.5, 0.0, 1.0 );
    // vertex
    glVertexPointer( 2, GL_FLOAT, 0, squareVertices );
    
    // triangle strip
    glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 );
	
	glPopMatrix();
}

/*
 * END TouchMatrixDisplay methods
 */

// touch callback
void touchCallback( NSSet * touches, UIView * view, const std::vector<MoTouchTrack> & touchPts, void * data)
{
    // iterate over touch points
    CGPoint location;
    for( UITouch * touch in touches )
    {
        // get the location
        location = [touch locationInView:nil];
		
		// transform: to make landscape
        double temp = location.x;
        location.x = location.y;
        location.y = temp;
		
        NSLog( @"touch: %f, %f,", location.x, location.y );
    }
}

// initialize
bool graphicsInit() {
	MoTouch::addCallback( touchCallback, NULL );
	return true;
}
