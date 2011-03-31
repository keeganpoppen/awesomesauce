//
//  graphics.mm
//  awesomesauce
//
//  Created by Keegan Poppen on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "graphics.h"
#import "mo_gfx.h"
#import "awesomesauceAppDelegate.h"

#import "mo_touch.h"

bool on_main_screen = true;
bool pad_is_on;
bool current_touches[16][16];
GLuint g_texture[3];
static const GLfloat half_width = 24;
bool future_mode = false;

void setMainScreen(bool newVal) {
	on_main_screen = newVal;
}

void setFutureMode(bool newVal) {
	future_mode = newVal;
}

bool isFutureMode() {
	return future_mode;
}

void displayMatrix(TouchMatrix *matrix) {
	// reset projection matrix
	glMatrixMode( GL_PROJECTION );
	glLoadIdentity();
	glOrthof( -1.0f, 1.0f, -1.5f, 1.5f, 1.0f, 1.0f);
	
	// modelview
	glMatrixMode( GL_MODELVIEW );
	glLoadIdentity();
	
	// set clear color to black
	glClearColor( 1.0, 1.0, 1.0, 1.0f );
	glClear( GL_COLOR_BUFFER_BIT );
	
	// map the viewport
	MoGfx::ortho( 1024, 768, 1 );
	
	glEnableClientState( GL_VERTEX_ARRAY );
	
	//draw stuff sample
	
    static const GLfloat squareVertices[] = {
        -half_width, -half_width,
        half_width, -half_width,
        -half_width, half_width,
        half_width, half_width,
    };
    static const GLfloat normals[] = {
        0, 0, 1,
        0, 0, 1,
        0, 0, 1,
        0, 0, 1
    };
    
    static const GLfloat texCoords[] = {
        0, 1,
        1, 1,
        0, 0,
        1, 0
    };
	
	
	//active color: lighter blue
	GLfloat active_r = 0.5;
	GLfloat active_g = 0.8;
	GLfloat active_b = 1.0;
	
	//on color: blue
	GLfloat on_r = 0.3;
	GLfloat on_g = 0.5;
	GLfloat on_b = 1.0;
	
	//off color: light grey
	GLfloat off_r = 0.92;
	GLfloat off_g = 0.92;
	GLfloat off_b = 0.92;
	
	int activeCol = matrix->getColumn();
	
	
	// enable texture mapping
    glEnable( GL_TEXTURE_2D );
    // enable blending
    glEnable( GL_BLEND );
    // blend function
    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
	
	for (int col = 0; col < 16; ++col) {
		for (int row = 0; row < 16; ++row) {
			bool isOff = true;
			glColor4f( off_r, off_g, off_b, 1.0 );
			if(matrix->squares[row][col]) {
				// bind the texture
				glBindTexture( GL_TEXTURE_2D, g_texture[1] );
				
				
				glColor4f( on_r, on_g, on_b, 1.0 );
				if(col == activeCol) {
					glColor4f( active_r, active_g, active_b, 1.0 );
				}
			}
			else {
				// bind the texture
				glBindTexture( GL_TEXTURE_2D, g_texture[0] );
			}
			GLfloat x = 768 - half_width - row * half_width * 2;
			GLfloat y = half_width + col * half_width * 2 + 256;
			
			glPushMatrix();
			glEnableClientState( GL_TEXTURE_COORD_ARRAY );
			glTranslatef( x, y, 0.0 );
			// vertex
			glVertexPointer( 2, GL_FLOAT, 0, squareVertices );
			// normal
			glNormalPointer( GL_FLOAT, 0, normals );
			// texture coordinate
			glTexCoordPointer( 2, GL_FLOAT, 0, texCoords );
			
			// triangle strip
			glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 );
			glDisableClientState( GL_TEXTURE_COORD_ARRAY );
			glPopMatrix();
		}
	}
	
    // disable
    glDisable( GL_TEXTURE_2D );
    glDisable( GL_BLEND );
}


void displayDrumMatrix(TouchMatrix *matrix) {
	// reset projection matrix
	glMatrixMode( GL_PROJECTION );
	glLoadIdentity();
	glOrthof( -1.0f, 1.0f, -1.5f, 1.5f, 1.0f, 1.0f);
	
	// modelview
	glMatrixMode( GL_MODELVIEW );
	glLoadIdentity();
	
	// set clear color to black
	glClearColor( 1.0, 1.0, 1.0, 1.0f );
	glClear( GL_COLOR_BUFFER_BIT );
	
	// map the viewport
	MoGfx::ortho( 1024, 768, 1 );
	
	glEnableClientState( GL_VERTEX_ARRAY );
	
	//draw stuff sample
	
    static const GLfloat squareVertices[] = {
        -half_width, -half_width,
        half_width, -half_width,
        -half_width, half_width,
        half_width, half_width,
    };
    static const GLfloat normals[] = {
        0, 0, 1,
        0, 0, 1,
        0, 0, 1,
        0, 0, 1
    };
    
    static const GLfloat texCoords[] = {
        0, 1,
        1, 1,
        0, 0,
        1, 0
    };
	
	
	//active color: lighter blue
	GLfloat active_r = 0.5;
	GLfloat active_g = 0.8;
	GLfloat active_b = 1.0;
	
	//on color: blue
	GLfloat on_r = 0.3;
	GLfloat on_g = 0.5;
	GLfloat on_b = 1.0;
	
	//off color: light grey
	GLfloat off_r = 0.92;
	GLfloat off_g = 0.92;
	GLfloat off_b = 0.92;
	
	int activeCol = matrix->getColumn();
	
	
	// enable texture mapping
    glEnable( GL_TEXTURE_2D );
    // enable blending
    glEnable( GL_BLEND );
    // blend function
    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
	
	for (int col = 0; col < 16; ++col) {
		for (int row = 0; row < 8; ++row) {
			bool isOff = true;
			glColor4f( off_r, off_g, off_b, 1.0 );
			if(matrix->squares[row][col]) {
				// bind the texture
				glBindTexture( GL_TEXTURE_2D, g_texture[1] );
				
				
				glColor4f( on_r, on_g, on_b, 1.0 );
				if(col == activeCol) {
					glColor4f( active_r, active_g, active_b, 1.0 );
				}
			}
			else {
				// bind the texture
				glBindTexture( GL_TEXTURE_2D, g_texture[0] );
			}
			GLfloat x = 768 - half_width - row * half_width * 2;
			GLfloat y = half_width + col * half_width * 2 + 256;
			
			glPushMatrix();
			glEnableClientState( GL_TEXTURE_COORD_ARRAY );
			glTranslatef( x, y, 0.0 );
			// vertex
			glVertexPointer( 2, GL_FLOAT, 0, squareVertices );
			// normal
			glNormalPointer( GL_FLOAT, 0, normals );
			// texture coordinate
			glTexCoordPointer( 2, GL_FLOAT, 0, texCoords );
			
			// triangle strip
			glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 );
			glDisableClientState( GL_TEXTURE_COORD_ARRAY );
			glPopMatrix();
		}
	}
	
    // disable
    glDisable( GL_TEXTURE_2D );
    glDisable( GL_BLEND );
}

void displayMatrixFuture(TouchMatrix *matrix) {
	// reset projection matrix
	glMatrixMode( GL_PROJECTION );
	glLoadIdentity();
	glOrthof( -1.0f, 1.0f, -1.5f, 1.5f, 1.0f, 1.0f);
	
	// modelview
	glMatrixMode( GL_MODELVIEW );
	glLoadIdentity();
	
	// set clear color to black
	glClearColor( 1.0, 1.0, 1.0, 1.0f );
	glClear( GL_COLOR_BUFFER_BIT );
	
	// map the viewport
	MoGfx::ortho( 1024, 768, 1 );
	
	glEnableClientState( GL_VERTEX_ARRAY );
	
	//draw stuff sample
	
    static const GLfloat squareVertices[] = {
        -half_width, -half_width,
        half_width, -half_width,
        -half_width, half_width,
        half_width, half_width,
    };
    static const GLfloat normals[] = {
        0, 0, 1,
        0, 0, 1,
        0, 0, 1,
        0, 0, 1
    };
    
    static const GLfloat texCoords[] = {
        0, 1,
        1, 1,
        0, 0,
        1, 0
    };
	
	
	//active color: lighter blue
	GLfloat active_r = 0.7;
	GLfloat active_g = 0.85;
	GLfloat active_b = 1.0;
	
	//on color: blue
	GLfloat on_r = 0.5;
	GLfloat on_g = 0.65;
	GLfloat on_b = 0.8;
	
	//off color: light grey
	GLfloat off_r = 0.92;
	GLfloat off_g = 0.92;
	GLfloat off_b = 0.92;
	
	//future color: orange
	GLfloat f_on_r = 1.0;
	GLfloat f_on_g = 0.5;
	GLfloat f_on_b = 0.0;
		
	//future active color: yellow
	GLfloat f_active_r = 1.0;
	GLfloat f_active_g = 1.0;
	GLfloat f_active_b = 0.0;
	
	int activeCol = matrix->getColumn();
	
	
	// enable texture mapping
    glEnable( GL_TEXTURE_2D );
    // enable blending
    glEnable( GL_BLEND );
    // blend function
    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
	
	for (int col = 0; col < 16; ++col) {
		for (int row = 0; row < 16; ++row) {
			glColor4f( off_r, off_g, off_b, 1.0 );
			if(matrix->futureSquares[row][col]) {
				glBindTexture( GL_TEXTURE_2D, g_texture[1] );
				glColor4f( f_on_r, f_on_g, f_on_b, 1.0 );
				if(col == activeCol) {
					glColor4f( f_active_r, f_active_g, f_active_b, 1.0 );
				}
			}
			else if(matrix->squares[row][col]) {
				// bind the texture
				glBindTexture( GL_TEXTURE_2D, g_texture[1] );
				glColor4f( on_r, on_g, on_b, 1.0 );
				if(col == activeCol) {
					glColor4f( active_r, active_g, active_b, 1.0 );
				}
			}
			else {
				// bind the texture
				glBindTexture( GL_TEXTURE_2D, g_texture[0] );
			}
			GLfloat x = 768 - half_width - row * half_width * 2;
			GLfloat y = half_width + col * half_width * 2 + 256;
			
			glPushMatrix();
			glEnableClientState( GL_TEXTURE_COORD_ARRAY );
			glTranslatef( x, y, 0.0 );
			// vertex
			glVertexPointer( 2, GL_FLOAT, 0, squareVertices );
			// normal
			glNormalPointer( GL_FLOAT, 0, normals );
			// texture coordinate
			glTexCoordPointer( 2, GL_FLOAT, 0, texCoords );
			
			// triangle strip
			glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 );
			glDisableClientState( GL_TEXTURE_COORD_ARRAY );
			glPopMatrix();
		}
	}
	
    // disable
    glDisable( GL_TEXTURE_2D );
    glDisable( GL_BLEND );
}

void resetCurrentTouches() {
	for (int i = 0; i < 16; ++i) {
		for (int j = 0; j < 16; ++j) {
			current_touches[i][j] = false;
		}
	}
}

// touch callback
void touchCallback( NSSet * touches, UIView * view, const std::vector<MoTouchTrack> & touchPts, void * data)
{
	if(!on_main_screen) {
		return;
	}
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
		
		float cell_size = half_width * 2;
		
		int xval = (int) location.y / cell_size;
		int yval = (int) (location.x - 256.0) / cell_size;
		if(yval >= 16 || xval >= 16 || yval < 0 || xval < 0) {
			//out of square
		}
		else {
			if( touch.phase == UITouchPhaseBegan )
			{
				//NSLog(@"x: %d, y: %d", xval, yval);
				pad_is_on = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] toggleTouch:xval withYval:yval];
				current_touches[xval][yval] = true;
			}
			else if( touch.phase == UITouchPhaseMoved )
			{
				if(!current_touches[xval][yval]) {
					[(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] setTouch:xval withYval:yval withBool:pad_is_on];
					current_touches[xval][yval] = true;
				}
			}
			else if( touch.phase == UITouchPhaseEnded )
			{
				resetCurrentTouches();
			}
		}
    }
}

// initialize
bool graphicsInit() {
	MoTouch::addCallback( touchCallback, NULL );
	resetCurrentTouches();
	
	// TEXTURE STUFF
    // generate texture name
    glGenTextures( 3, &g_texture[0] );
    // bind the texture
    glBindTexture( GL_TEXTURE_2D, g_texture[0] );
    // setting parameters
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	//load the texture
    MoGfx::loadTexture( @"square_texture3", @"png" );
	
    // bind the texture
    glBindTexture( GL_TEXTURE_2D, g_texture[1] );
    // setting parameters
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	//load the texture
    MoGfx::loadTexture( @"white_gradient2", @"png" );
	
    // bind the texture
    glBindTexture( GL_TEXTURE_2D, g_texture[2] );
    // setting parameters
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	//load the texture
    MoGfx::loadTexture( @"white_gradient3", @"png" );
	
	return true;
}
