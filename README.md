# LRP Performance Metric for Object Detection

This is an implementation of [LRP](arxiv link) on Python and MATLAB for datasets PASCAL-VOC and MS COCO. The evaluation methodology uses number of false negative detections, number of false positive detections and a tightness measure for true positive detections. 

# Getting Started:
Some installation information.

# Evaluation on MS COCO:
Evaluation steps for MS COCO
  ## Using Python:
  Python steps.
  ## Using MATLAB:
  MATLAB steps.
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
Python 2.7 or MATLAB. (extend with other requirements such as frameworks)

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
