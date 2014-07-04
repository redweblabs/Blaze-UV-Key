#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"
#include "fft.h"

#import <Accelerate/Accelerate.h>

#define BUFFER_SIZE 512
#define NUM_WINDOWS 80

#define BLACK 0x000000
#define GREEN 0x209700
#define YELLOW 0xf8e600
#define ORANGE 0xfb5800
#define RED 0xdb000f
#define PURPLE 0x6b43cb
#define BLAZEBLUE 0x0eb6d5

class ofApp : public ofxiOSApp{
	
    public:
        void setup();
        void update();
        void draw();
        void drawWaveForm();
        void exit();
    
        ofImage background;
        ofImage logo;
    
        int loadingPoint = 0;
        long frameTime = 0;
        ofPoint loadingCoords;
    
        ofImage loading0;
        ofImage loading1;
        ofImage loading2;
        ofImage loading3;
    
        void touchDown(ofTouchEventArgs & touch);
        void touchUp(ofTouchEventArgs & touch);

        ofTrueTypeFont txt;
        string fontName = "opensans.ttf";
    
        ofTrueTypeFont smallTxt;

        void processBinary();
        int  binaryToBase10(int n);
    
        // new method for getting the samples from the microphone
        void audioIn( float * input, int bufferSize, int nChannels );
        void audioOut(float *output, int bufferSize, int nChannels, int deviceID, unsigned long long tickCount);
    
        int     width, height;
        
        // variables which will help us deal with audio
        int     initialBufferSize;
        int     sampleRate;
        float   * buffer;
    
        int bytes;
        int count = 0;
    
        int lastGrab = 0;
        long time = ofGetElapsedTimeMillis();
        
        //FFT Stuff
        float * left;
        float * right;
        int 	bufferCounter;
        fft		myfft;
        
        float magnitude[BUFFER_SIZE];
        float phase[BUFFER_SIZE];
        float power[BUFFER_SIZE];
        
        float freq[NUM_WINDOWS][BUFFER_SIZE/2];
        float freq_phase[NUM_WINDOWS][BUFFER_SIZE/2];
        
        //Bits and bobs for converting our FSK signal back into a useable digit
        bool analysing = false;
    
        int binSize = 8;
    
        int binary[8];
        int binPos = 0;
    
        int currentUVReading = 0;
        int uvColor = BLACK;
        
        //Some useful variables for handling interaction
        bool analysed = false;
    
        ofPoint buttonCoords;
    
        bool buttonDown = false;
        bool buttonTapped = false;
    
        long tapTime;
    
};


