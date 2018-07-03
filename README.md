# LRP Performance Metric&Thresholder for Object Detection

This is an implementation of [LRP](arxiv link) on Python and MATLAB for datasets PASCAL-VOC and MS COCO. 

LRP has mainly two purposes:

1. The Performance Metric for the Object Detection Problem : Average precision (AP), the area under the recall-precision (RP) curve, is the standard performance measure for object detection. Despite its wide acceptance, it has a number of shortcomings, the most important of which are (i) the inability to distinguish very different RP curves, and (ii) the lack of directly measuring bounding box localization accuracy. ''Localization Recall Precision (LRP) Error'' is a new metric which is specifically designed for object detection. LRP Error is composed of three components related to localization, false negative (FN) rate and false positive (FP) rate. Based on LRP, we introduce the ''Optimal LRP'', the minimum achievable LRP error representing the best achievable configuration of the detector in terms of recall-precision and the tightness of the boxes. In our experiments, we show that, for state-of-the-art object (SOTA) detectors, Optimal LRP provides richer and more discriminative information than AP.

2. LRP As a Thresholder : In contrast to AP, which considers precisions over the entire recall domain, Optimal LRP determines the ''best'' confidence score threshold for a class, which balances the trade-off between localization and recall-precision. We demonstrate that the best confidence score thresholds vary significantly among classes and detectors. Moreover, we present LRP results of a simple online video object detector which uses a SOTA still image object detector and show that the class-specific optimized thresholds increase the accuracy against the common approach of using a general threshold for all classes.

# Getting Started:
For MS COCO dataset, the official toolkit is modified for LRP Metric evaluation. So you will find a similar folder organization with the official toolkit. Currently, you can find the 2017 train/val annotations under the annotations folder of the cocoLRPapi-master and a Faster R-CNN result file under the results folder of cocoLRPapi-master.

For Pascal VOC dataset... (Coming Soon)

In any case, besides the paramaters of the evaluation, this implementation provides 4 different set of outputs

1. LRP values and LRP components for each class and each confidence score threshold
2. oLRP values and oLRP components for each class 
3. moLPR value and moLRP components for the detector
4. Optimal Class Specific Thresholds for each class

# Evaluation on MS COCO:
First clone/download cocoLRPapi-master folder
  ## Using Python:
  Python steps.
  ## Using MATLAB:
  1. For the demo, just run the evalDemoLRP.m script to test whether your computer satisfies the requirements.
  2. In order to test with your own ground truth and detection results, set the following 3 parameters in the evalDemoLRP.m script: the ground truth file path in line 7, the detection result file path in line 10 and the tau parameter, the minimum IoU to validate a detection in line 21. 

Note that MS COCO uses json files as the standard detection&annotation format. See http://cocodataset.org for further information.
# Evaluation on PASCAL-VOC:
Evaluation steps for PASCAL-VOC.
 ## Using Python:
 Python steps.
 ## Using MATLAB:
 MATLAB steps.

# Requirements:
Python 2.7 or MATLAB (The implementation is based on MATLAB R2017b)
