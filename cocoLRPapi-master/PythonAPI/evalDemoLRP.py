import matplotlib.pyplot as plt
from pycocotools.coco import COCO
from pycocotools.cocoevalLRP import COCOevalLRP
import numpy as np
import skimage.io as io
import pylab
#initialize COCO ground truth api
annFile = '../annotations/instances_val2017.json'
cocoGt=COCO(annFile)
#initialize COCO detections api
resFile = '../results/FasterRCNNX-101-32x8d-FPN.json'
cocoDt=cocoGt.loadRes(resFile)
# running evaluation
tau=0.5
DetailedLRPResultNeeded=0
cocoEvalLRP = COCOevalLRP(cocoGt,cocoDt,tau)
cocoEvalLRP.evaluate()
cocoEvalLRP.accumulate()
cocoEvalLRP.summarize(DetailedLRPResultNeeded)