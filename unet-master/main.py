from model import *
from data import *
import os
import matplotlib.pyplot as plt
from sklearn.metrics import confusion_matrix

data_gen_args = dict(horizontal_flip = True,
                     vertical_flip = True)


imageTargetSize = (256, 256)


trainPath = '/work/scratch/zhangbin/EmbryoTracking_ClaireBinZhang/MotilityAnalysis/20160317 10 dpf 60 fps 15 min (2)/Training'
trainImagePath = 'Selected Images Training'
trainLabelPath = 'Selected Images Label Binarized Training'
#augTrainPath = '/work/scratch/zhangbin/EmbryoTracking_ClaireBinZhang/MotilityAnalysis/20160317 10 dpf 60 fps 15 min (2)/train/aug'

#validationPath = '/work/scratch/zhangbin/EmbryoTracking_ClaireBinZhang/MotilityAnalysis/20160317 10 dpf 60 fps 15 min (2)/validation'
#validationImagePath = 'Selected Images Resized Validation'
#validationLabelPath = 'Selected Images Label Resized Binarized Validation'


trainGene = trainGenerator(batch_size = 1,
                           train_path = trainPath,
                           trainImage_folder = trainImagePath,
                           trainLabel_folder = trainLabelPath,
                           aug_dict = data_gen_args,
                           save_to_dir = None,
                           target_size = imageTargetSize,
                           trainImage_color_mode = 'grayscale',
                           trainLabel_color_mode = 'grayscale',
                           trainImage_save_prefix = 'Image',
                           trainLabel_save_prefix = 'Label',
                           seed = 1,
                           flag_multi_class = False,
                           num_class = 2)

""""
validationGene = validationGenerator(validation_path = validationPath,
                                     validationImage_path = validationImagePath,
                                     validationLabel_path = validationLabelPath,
                                     target_size = imageTargetSize,
                                     flag_multi_class = False,
                                     as_gray = True)
"""

model = unet()
model_checkpoint = ModelCheckpoint('unet_testing.hdf5', monitor='loss',verbose=1, save_best_only=True)
trainHistory = model.fit_generator(trainGene,
                    steps_per_epoch=100,
                    epochs=7,
                    callbacks = [model_checkpoint]
                    )


testImagePath = '/work/scratch/zhangbin/EmbryoTracking_ClaireBinZhang/MotilityAnalysis/20160317 10 dpf 60 fps 15 min (2)/Test/Selected Images Test'
testGene = testGenerator(test_path = testImagePath,
                         target_size = imageTargetSize,
                         flag_multi_class = False,
                         as_gray = True)


results = model.predict_generator(testGene, len(os.listdir(testImagePath)), verbose = 1)
saveResult("/work/scratch/zhangbin/EmbryoTracking_ClaireBinZhang/MotilityAnalysis/20160317 10 dpf 60 fps 15 min (2)/here", results)


training_loss = trainHistory.history['loss']
#test_loss = history.history['val_loss']

epoch_count = range(1, len(training_loss)+1)


plt.plot(epoch_count, training_loss, 'r--')
#plt.plot(epoch_count, test_loss, 'b-')
plt.legend(['Training Loss'])
plt.xlabel('Epoch')
plt.ylabel('Loss')
plt.title('U-Net Training Loss Function')
plt.show();

