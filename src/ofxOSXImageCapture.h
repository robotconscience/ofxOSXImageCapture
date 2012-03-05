//
//  ofxOSXImageCapture.h
//  ChromatcCapture
//
//  Created by Brett Renfer on 3/4/12.
//  Copyright (c) 2012 Robotconscience. All rights reserved.
//
//  Make sure you add ImageCaptureCore.framework to your project
//  NOTE: This currently works with the 10.6 SDK

#pragma once

#include "ofMain.h"
#include "ImageCaptureControl.h"

enum {
    STATE_WAITING,
    STATE_LISTING_DEVICES,
    STATE_CONNECTING_DEVICE
};

class ofxOSXImageCapture : public ofThread {
public:
    
    ofxOSXImageCapture();
    ~ofxOSXImageCapture();
    
    void listDevices();
    bool doneListing();
    bool isDeviceReady();
    bool openDevice( int ID=0 );
    void takePicture();    
    
    void gotNewImage( ICCameraItem* image);
    
    ImageCaptureControl * captureControl;
    
    ofEvent <string> onNewImage;
    
private:
    void threadedFunction();
    bool bDoneListing, bDeviceReady, bTakingImage;
    
    string  currentImage;
    int     deviceId;
    int     state;
};
