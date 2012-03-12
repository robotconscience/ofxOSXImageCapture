#include "testApp.h"
#include "ofAppGlutWindow.h"

//========================================================================
int main(){
    
    ofAppGlutWindow window;
	ofSetupOpenGL(&window, 1024,768, OF_FULLSCREEN);			// <-------- setup the GL context
    
	// Initialize testApp(...) with the host and port that will be used to connect ot the controller.
	ofRunApp( new testApp());
}
