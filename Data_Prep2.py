#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon May 20 12:37:50 2024

@author: kevin
"""

import os
import numpy as np
from PIL import Image
import h5py


def create_hdf5_dataset(dataset_path, dataset_shape,imgx,imgy):
    with h5py.File(dataset_path, 'w') as hdf:
        hdf.create_dataset('xtrain', data=imgx, maxshape=(None, dataset_shape[1],dataset_shape[2]),compression="gzip", compression_opts=9)
        hdf.create_dataset('ytrain', data=imgy, maxshape=(None, dataset_shape[1],dataset_shape[2]),compression="gzip", compression_opts=9)

def load_images_from_folder(folderx,foldery,dataset_path):
    # Get sorted list of filenames
    filenamesx = sorted(os.listdir(folderx))
    filenamesy = sorted(os.listdir(foldery))
    for i in range(len(filenamesx)):
        img_pathx = os.path.join(folderx, filenamesx[i])
        imgx = Image.open(img_pathx)
        img_pathy = os.path.join(foldery, filenamesy[i])
        imgy = Image.open(img_pathy)
        imgx = np.array(imgx, dtype='uint16')
        imgy = np.array(imgy, dtype='uint16')
        imgx = np.expand_dims(imgx, axis=0)
        imgy = np.expand_dims(imgy, axis=0)
        if i==0:
            create_hdf5_dataset(dataset_path, np.shape(imgx),imgx,imgy)
            f = h5py.File(dataset_path, 'a')
        else:
            f['xtrain'].resize((f['xtrain'].shape[0] + 1), axis=0)
            f['xtrain'][-1] = imgx
            f['ytrain'].resize((f['ytrain'].shape[0] + 1), axis=0)
            f['ytrain'][-1] = imgy
    f.close()

            



outputDir = './Dataset_Random'
outputDirImagesx = outputDir + '/Images/xtrain/'
outputDirImagesy = outputDir + '/Images/ytrain/'
outputDirSinogramsx = outputDir + '/Sinograms/xtrain/'
outputDirSinogramsy = outputDir + '/Sinograms/ytrain/'
load_images_from_folder(outputDirImagesx,outputDirImagesy,outputDir+"/Image.h5")
print("Done with 1")
load_images_from_folder(outputDirSinogramsx,outputDirSinogramsy,outputDir+"/Sinogram.h5")
print("Done with 2")