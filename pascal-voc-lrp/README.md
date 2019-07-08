### PASCAL-VOC LRP Evaluation Kit ###

Requirements:

Python 2.7
scipy
numpy

Preperation:
  Clone this repository into your local.

  ```
    git clone https://github.com/cancam/LRP
  ```

  Dataset:
    This repository follows the offical structure of PASCAL-VOC development kit.
    1. Download training, validation (optional) and test data and VOC-devkit.
    ```
    wget http://host.robots.ox.ac.uk/pascal/VOC/voc2007/VOCtrainval_06-Nov-2007.tar
    wget http://host.robots.ox.ac.uk/pascal/VOC/voc2007/VOCtest_06-Nov-2007.tar
    wget http://host.robots.ox.ac.uk/pascal/VOC/voc2007/VOCdevkit_08-Jun-2007.tar
    ```
    2. Extract all content.
    ```
    tar xvf VOCtrainval_06-Nov-2007.tar
    tar xvf VOCtest_06-Nov-2007.tar
    tar xvf VOCdevkit_08-Jun-2007.tar
    ```
    3. Directory should have the following basis structure.
    ```
    $VOCdevkit/                           # development kit
    $VOCdevkit/VOCcode/                   # VOC utility code
    $VOCdevkit/VOC2007                    # image sets, annotations, etc.
    # ... and several other directories ...
    ```
    4. Either you can put the entire pascal-voc evaluation kit under the pascal-voc-lrp directory or a better approach is that you can create symbolic link to "VOCdevkit" under pascal-voc-lrp directory with the following command.
    
    ```
    ln -s $VOCdevkit VOCdevkit
    ```
    
Execution: 
  pascal-voc-lrp evaluation kit can be executed with two ways. Either you can provide a pickle file in which all the detections are included or you can provide offical pascal-voc class-wise text files. The pickle file should have the same format with the one provided as an example (see: ${pascal-voc-lrp}/results/det/detections_voc_test_base.pkl). Evaluation results will be provided by a text file that contains class-wise and overall results in ${pascal-voc-lrp}/results/eval/lrp_results.txt by default.

Example Execution:
The toolkit can be tested using the example pickle file that is located under "/results/det".
```
python pascal_voc --use_pickle --boxes_path ${lrp_eval}/results/det/detections_voc_test_base.pkl
```
Or the framework can evaluate the detections using standart form of PASCAL-VOC text file detections.
```
python pascal_voc
```

  Arguments:
    ```
    --use_pickle: Flag to evaluate model detections directly from saved pickle file.*
    
    --boxes_path: Path to previously mentioned pickle file.
    
    --tau: IoU threshold to evaluate detection.
    
    --save_results: To specify the path of the text file that contains class-wise and overall results under lrp and ap metrics.
    
    --set: Which set to perform evaluation on. (train, val, test)
    
    --year: Which year to perform evaluation on. (i.e.: VOC2007, VOC2012)
    
    --comp: Whether to use competition mode or not.
    
    --devkit_path: To specify a different devkit path.
    ```
