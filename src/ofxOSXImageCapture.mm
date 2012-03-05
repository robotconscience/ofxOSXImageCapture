//
//  ofxOSXImageCapture.cpp
//  ChromatcCapture
//
//  Created by Brett Renfer on 3/4/12.
//  Copyright (c) 2012 Robotconscience. All rights reserved.
//

#include <iostream>
#import "ofxOSXImageCapture.h"

//--------------------------------------------------------------
ofxOSXImageCapture::ofxOSXImageCapture(){
    state = STATE_WAITING;
    bDoneListing = bDeviceReady = bTakingImage = false;
    captureControl = [ImageCaptureControl alloc];
    [captureControl initWithOFHandler:this];
};

//--------------------------------------------------------------
ofxOSXImageCapture::~ofxOSXImageCapture(){
    [captureControl exit];
};

//--------------------------------------------------------------
void ofxOSXImageCapture::listDevices(){
    cout<<"listing devices"<<endl;
    [captureControl listCameras];
    state = STATE_LISTING_DEVICES;
    startThread(false, false);
}

//--------------------------------------------------------------
bool ofxOSXImageCapture::doneListing(){
    return bDoneListing;
};

//--------------------------------------------------------------
bool ofxOSXImageCapture::isDeviceReady(){
    return bDeviceReady;
}

//--------------------------------------------------------------
void ofxOSXImageCapture::threadedFunction(){
    if ( state == STATE_LISTING_DEVICES ){
        while ( ![captureControl isDoneListing] ){
        }
        bDoneListing = true;
        NSArray * devices = [captureControl currentDevices];
        ofLog(OF_LOG_VERBOSE, "found "+ofToString([devices count])+" devices");
        state = STATE_WAITING;
    } else if ( state == STATE_CONNECTING_DEVICE ){
        while ( ![captureControl isCurrentDeviceReady] ){
            //wait for it...
        }
        bDeviceReady = true;
        state = STATE_WAITING;
    }
}

//--------------------------------------------------------------
bool ofxOSXImageCapture::openDevice( int ID ){
    bDeviceReady = false;
    if (!bDoneListing){
        return false;
    }
    deviceId = ID;
    state = STATE_CONNECTING_DEVICE;
    bool bSetup = [captureControl openCamera:ID]; //just open cameras for now
    if (bSetup) startThread(false, false);
    return bSetup;
}

//--------------------------------------------------------------
void ofxOSXImageCapture::takePicture(){
    bTakingImage = true;
    [captureControl takePicture:deviceId];
}

//--------------------------------------------------------------
void ofxOSXImageCapture::gotNewImage( ICCameraItem* image){
    if (bTakingImage){
        bTakingImage = false;
        NSLog(@"%@", image);
        currentImage = string([[image name] UTF8String]);
        cout<<currentImage<<endl;
        ofNotifyEvent(onNewImage, currentImage, this);
    } else {
        // don't do anything, probably just from the first time you opened camera
    }
}