//
//  MatlabFFT.m
//  FFT_Test
//
//  Created by Kendall Lui on 3/30/16.
//  Copyright (c) 2016 Kendall Lui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MatlabFFT.h"

DSPSplitComplex fft(NSArray *dataInput, const int log2n){
    const int n = 1 << log2n;
    const int nOver2 = n/2;
    float *input;
    input = malloc(n * sizeof(float));
    
    FFTSetup fftSetup = vDSP_create_fftsetup (log2n+1, kFFTRadix2);
    
    
    int i;
    for(i = 0; i < n; i++){
        input[i] = [(NSNumber *)[dataInput objectAtIndex:i] floatValue];
    }
    
    DSPSplitComplex fft_data;
    fft_data.realp = malloc(nOver2 * sizeof(float));
    fft_data.imagp = malloc(nOver2 * sizeof(float));
    
    vDSP_ctoz(( DSPComplex *)(input), 2, &fft_data, 1, n/2);
    vDSP_fft_zrip (fftSetup, &fft_data, 1, log2n, kFFTDirection_Forward);
    
    //Scaling factor 0.5
    for (i = 0; i < nOver2; ++i)
    {
        fft_data.realp[i] *= 0.5;
        fft_data.imagp[i] *= 0.5;
    }
    return fft_data;
}

NSMutableArray* fftAbsoluteMagnitude(NSArray *dataInput, const int log2n)
{
    const int n = 1 << log2n;
    const int nOver2 = n/2;

    DSPSplitComplex fft_data = fft(dataInput,log2n);
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:nOver2];
    float* output;
    output = malloc(n * sizeof(float));
    vDSP_zvabs(&fft_data, 1, output, 1, nOver2);
    int i;
    for(i = 0; i < nOver2; i++){
        array[i] = [NSNumber numberWithFloat:output[i]];
    }
    return array;
}
