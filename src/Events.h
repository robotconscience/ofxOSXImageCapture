//
//  Events.h
//
//  Created by Brett Renfer on 3/11/12.
//  Copyright (c) 2012 Robotconscience. All rights reserved.
//

#pragma once

#include "Camera.h"
#include "ofEvents.h"

namespace ofxOSXImageCapture {
    class ofxOSXImageCaptureEvents {
        public:
            ofEvent <string> onListDevices;
            ofEvent <string> onNewImage;
            ofEvent <Camera> onDeviceReady;
            ofEvent <Camera> onDeviceRemoved;
    };
    
    extern ofxOSXImageCaptureEvents Events;
}