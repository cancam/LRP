# LRP Performance Metric&Thresholder for Object Detection

This is an implementation of [LRP](arxiv link) on Python and MATLAB for datasets PASCAL-VOC and MS COCO. The evaluation methodology uses number of false negative detections, number of false positive detections and a tightness measure for true positive detections. 

# Getting Started:
For MS COCO dataset, the official toolkit is modified for LRP Metric evaluation. So you will find a similar folder organization with the official toolkit. Currently, you can find the 2017 train/val annotations under the annotations folder of the cocoLRPapi-master and a Faster R-CNN result file under the results folder of cocoLRPapi-master.

For Pascal VOC dataset... (Coming Soon)

In any case, besides the paramaters of the evaluation, this implementation provides 4 different set of outputs

1. LRP values and LRP components for each class and each confidence score threshold
2. oLRP values and oLRP components for each class 
3. moLPR value and moLRP components for the detector
4. Optimal Class Specific Thresholds for each class

# Evaluation on MS COCO:
Evaluation steps for MS COCO
Download cocoLRPapi-master folder
  ## Using Python:
  Python steps.
  ## Using MATLAB:
  1. For the demo, just run the evalDemoLRP.m script to test whether your computer satisfies the requirements.
  2. In order to test with your own ground truth and detection results, set the following 3 parameters in the evalDemoLRP.m script: the ground truth file path in line 7, the detection result file path in line 10 and the tau parameter, the minimum IoU to validate a detection in line 21. Note that MS COCO uses json files as the standard detection&annotation format. See http://cocodataset.org for further information.
# Evaluation on PASCAL-VOC:
Evaluation steps for PASCAL-VOC.
 ## Using Python:
 Python steps.
 ## Using MATLAB:
 MATLAB steps.
 
# Evaluation on a custom dataset:
Whether needed or not?
 ## Using Python:
 ## Using MATLAB:

## Requirements:
Python 2.7 or MATLAB (The implementation is based on MATLAB R2017b). (extend with other requirements such as frameworks)

### MS COCO Requirements:
Describe MS COCO 
## Installation
Describe installation steps for MS COCO
1. Install dependencies
   ```bash
   pip3 install -r requirements.txt
   ```
2. Clone this repository
3. Run setup from the repository root directory
    ```bash
    python3 setup.py install
    ``` 
3. Download pre-trained COCO weights (mask_rcnn_coco.h5) from the [releases page](https://github.com/matterport/Mask_RCNN/releases).
4. (Optional) To train or test on MS COCO install `pycocotools` from one of these repos. They are forks of the original pycocotools with fixes for Python3 and Windows (the official repo doesn't seem to be active anymore).

    * Linux: https://github.com/waleedka/coco
    * Windows: https://github.com/philferriere/cocoapi.
    You must have the Visual C++ 2015 build tools on your path (see the repo for additional details)
### PASCAL-VOC Requirements:
Describe PASCAL-VOC installation steps for PASCAL-VOC
