//
//  MatlabFFT.h
//  FFT_Test
//
//  Created by Kendall Lui on 3/30/16.
//  Copyright (c) 2016 Kendall Lui. All rights reserved.
//
#include <Accelerate/Accelerate.h>

#ifndef FFT_Test_MatlabFFT_h
#define FFT_Test_MatlabFFT_h

DSPSplitComplex fft(NSArray *dataInput, const int log2n);
NSMutableArray* fftAbsoluteMagnitude(NSArray *dataInput, const int log2n);

#endif
