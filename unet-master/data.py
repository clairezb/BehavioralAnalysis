from __future__ import print_function
from keras.preprocessing.image import ImageDataGenerator
import numpy as np 
import os
import glob
import skimage.io as io
import skimage.transform as trans


Sky = [128,128,128]
Building = [128,0,0]
Pole = [192,192,128]
Road = [128,64,128]
Pavement = [60,40,222]
Tree = [128,128,0]
SignSymbol = [192,128,128]
Fence = [64,64,128]
Car = [64,0,128]
Pedestrian = [64,64,0]
Bicyclist = [0,128,192]
Unlabelled = [0,0,0]


COLOR_DICT = np.array([Sky, Building, Pole, Road, Pavement, Tree, SignSymbol, Fence, Car, Pedestrian, Bicyclist, Unlabelled])


def adjustData(img, label, flag_multi_class, num_class):
    if(flag_multi_class):
        img = img / 255
        label = label[:,:,:,0] if(len(label.shape) == 4) else label[:,:,0]
        new_label = np.zeros(label.shape + (num_class,))
        for i in range(num_class):
            new_label[label == i,i] = 1
        new_label = np.reshape(new_label, (new_label.shape[0], new_label.shape[1] * new_label.shape[2], new_label.shape[3])) if flag_multi_class else np.reshape(new_label, (new_label.shape[0]*new_label.shape[1], new_label.shape[2]))
        label = new_label
    elif(np.max(img) > 1):
        img = img / 255
        label = label / 255
        label[label > 0.5] = 1
        label[label <= 0.5] = 0
    return (img, label)



def trainGenerator(batch_size, train_path, trainImage_folder, trainLabel_folder, target_size, aug_dict, save_to_dir,
                   trainImage_color_mode, trainLabel_color_mode, trainImage_save_prefix, trainLabel_save_prefix, seed,
                   flag_multi_class, num_class):

    trainImage_datagen = ImageDataGenerator(**aug_dict)
    trainLabel_datagen = ImageDataGenerator(**aug_dict)

    trainImage_generator = trainImage_datagen.flow_from_directory(
        directory = train_path,
        classes = [trainImage_folder],
        class_mode = None,
        color_mode = trainImage_color_mode,
        target_size = target_size,
        batch_size = batch_size,
        save_to_dir = save_to_dir,
        save_prefix  = trainImage_save_prefix,
        seed = seed)

    trainLabel_generator = trainLabel_datagen.flow_from_directory(
        directory = train_path,
        classes = [trainLabel_folder],
        class_mode = None,
        color_mode = trainLabel_color_mode,
        target_size = target_size,
        batch_size = batch_size,
        save_to_dir = save_to_dir,
        save_prefix  = trainLabel_save_prefix,
        seed = seed)

    train_generator = zip(trainImage_generator, trainLabel_generator)
    for (trainImg, trainLabel) in train_generator:
        trainImg, trainLabel = adjustData(trainImg, trainLabel, flag_multi_class, num_class)
        yield (trainImg, trainLabel)

"""
def validationGenerator(validation_path, validationImage_path, validationLabel_path, target_size, flag_multi_class, as_gray):
    validationImage_path = os.path.join(validation_path, validationImage_path)
    validationLabel_path = os.path.join(validation_path, validationLabel_path)
    for i in range(len(os.listdir(validationImage_path))):
        img = io.imread(os.path.join(validationImage_path, os.listdir(validationImage_path)[i]), as_gray = as_gray)
        img = img / 255
        img = trans.resize(img, target_size)
        img = np.reshape(img, img.shape+(1,)) if (not flag_multi_class) else img
        img = np.reshape(img, (1,)+img.shape)
        label = io.imread(os.path.join(validationLabel_path, os.listdir(validationLabel_path)[i]), as_gray = as_gray)
        label = label / 255
        label = trans.resize(label, target_size)
        label = np.reshape(label, label.shape + (1,)) if (not flag_multi_class) else label
        label = np.reshape(label, (1,) + label.shape)
        yield (img, label)
"""

def testGenerator(test_path, target_size, flag_multi_class, as_gray):
    testImageList = os.listdir(test_path)
    for i in range(len(testImageList)):
        img = io.imread(os.path.join(test_path, testImageList[i]), as_gray = as_gray)
        img = img / 255
        img = trans.resize(img, target_size)
        img = np.reshape(img,img.shape+(1,)) if (not flag_multi_class) else img
        img = np.reshape(img,(1,)+img.shape)
        yield img


def geneTrainNpy(image_path,mask_path,flag_multi_class = False,num_class = 2,image_prefix = "image",mask_prefix = "mask",image_as_gray = True,mask_as_gray = True):
    image_name_arr = glob.glob(os.path.join(image_path,"%s*.png"%image_prefix))
    image_arr = []
    mask_arr = []
    for index,item in enumerate(image_name_arr):
        img = io.imread(item,as_gray = image_as_gray)
        img = np.reshape(img,img.shape + (1,)) if image_as_gray else img
        mask = io.imread(item.replace(image_path,mask_path).replace(image_prefix,mask_prefix),as_gray = mask_as_gray)
        mask = np.reshape(mask,mask.shape + (1,)) if mask_as_gray else mask
        img,mask = adjustData(img,mask,flag_multi_class,num_class)
        image_arr.append(img)
        mask_arr.append(mask)
    image_arr = np.array(image_arr)
    mask_arr = np.array(mask_arr)
    return image_arr,mask_arr


def labelVisualize(num_class, color_dict, img):
    img = img[:,:,0] if len(img.shape) == 3 else img
    img_out = np.zeros(img.shape + (3,))
    for i in range(num_class):
        img_out[img == i,:] = color_dict[i]
    return img_out / 255




def saveResult(save_path, npyfile, flag_multi_class = False, num_class = 2):
    for i, item in enumerate(npyfile):
        img = labelVisualize(num_class, COLOR_DICT, item) if flag_multi_class else item[:,:,0]
        img = img * 255
        io.imsave(os.path.join(save_path,"%d_predict.tif"%i),img.astype('uint8'))