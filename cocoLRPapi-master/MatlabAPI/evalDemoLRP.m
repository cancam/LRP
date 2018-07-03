%% Demo demonstrating the algorithm result formats for COCO
% In order directly use this demo for your output file, just provide inputs by changing 
% lines 7 (the ground truth file path), 10 (the detection result file path) and 
% 21 (the tau parameter, the minimum IoU to validate a detection).

%% initialize COCO ground truth api
annFile='../annotations/instances_val2017.json';
cocoGt=CocoApi(annFile);
%% initialize COCO detections api
resFile='../results/FasterRCNNX-101-32x8d-FPN.json';
cocoDt=cocoGt.loadRes(resFile);

%% load raw JSON and show exact format for results
fprintf('results structure have the following format:\n');
res = gason(fileread(resFile)); disp(res)

%% the following command can be used to save the results back to disk
if(0), f=fopen(resFile,'w'); fwrite(f,gason(res)); fclose(f); end

%% set tau parameter for desired IoU validation threshold and run LRP metric COCO evaluation code 
tau=0.5;
cocoEvalLRP=CocoEvalLRP(cocoGt,cocoDt,tau);
cocoEvalLRP.evaluate();
cocoEvalLRP.accumulate();
cocoEvalLRP.summarize();
