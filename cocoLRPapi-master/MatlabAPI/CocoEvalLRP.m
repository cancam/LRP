classdef CocoEvalLRP < handle
  % Interface for evaluating detection on the Microsoft COCO dataset.
  %
  % The usage for CocoEval is as follows:
  %  cocoGt=..., cocoDt=...       % load dataset and results
  %  E = CocoEval(cocoGt,cocoDt); % initialize CocoEval object
  %  E.params.confScores = ...;      % set parameters as desired
  %  E.evaluate();                % run per image evaluation
  %  disp( E.evalImgs )           % inspect per image results
  %  E.accumulate();              % accumulate per image results
  %  disp( E.eval )               % inspect accumulated results
  %  E.summarize();               % display summary metrics of results
  % For example usage see evalDemoLRP.m
  %
  % The evaluation parameters are as follows (defaults in brackets):
  %  imgIds     - [all] N img ids to use for evaluation
  %  catIds     - [all] K cat ids to use for evaluation
  %  iouThrs    - 0.05 IoU threshold for evaluation
  %  confScores - [0:.01:1] S=101 confidence score thresholds for evaluation
  %  areaRng    - [...] A=4 object area ranges for evaluation
  %  maxDets    - [1 10 100] M=3 thresholds on max detections per image
  %  useCats    - [1] if true use category labels for evaluation
  % Note: if useCats=0 category labels are ignored as in proposal scoring.
  % Note: by default areaRng=[0 1e5; 0 32; 32 96; 96 1e5].^2. These A=4
  % settings correspond to all, small, medium, and large objects, resp.
  %
  % evaluate(): evaluates detections on every image 
  %
  % accumulate(): accumulates the per-image, per-category evaluation
  % results in "evalImgs" into the struct "eval" with fields:
  %  params     - parameters used for evaluation
  %  date       - date evaluation was performed
  %  counts     - [SxK] parameter dimensions (see above)
  %  LRPError   - [SxK] LRP Error for each class for each confidence score threshold
  %  BoxLocComp - [SxK] Box Localization Component for each class for each confidence score threshold
  %  FPComp     - [SxK] False Positive Component for each class for each confidence score threshold
  %  FNComp     - [SxK] False Negative Component for each class for each confidence score threshold
  %  oLRPError  - [1xK] Optimal LRP Error for each class 
  %  oBoxLocComp- [1xK] Optimal Box Localization Component for each class 
  %  oFPComp    - [1xK] Optimal False Positive Component for each class
  %  oFNComp    - [1xK] Optimal False Negative Component for each class
  %  moLRP      - Mean Optimal LRP Error for detector
  %  moLRPLoc   - Mean Optimal LRP Error Box Localization Component for detector
  %  moLRPFP   - Mean Optimal LRP Error False Positive Component for detector
  %  moLRPFN   - Mean Optimal LRP Error False Negative Component for detector
  %
  % summarize(): Displays mean Optimal Error for the detector
  %
  % Microsoft COCO Toolbox LRP Extension. version 1.0
  % Paper is available at:  
  % Code originally written by Piotr Dollar and Tsung-Yi Lin, 2015.
  % The code is modified to measure LRP error by Kemal Oksuz, 2018. 
  % Licensed under the Simplified BSD License [see coco/license.txt]
  
  properties
    cocoGt      % ground truth COCO API
    cocoDt      % detections COCO API
    params      % evaluation parameters
    evalImgs    % per-image per-category evaluation results
    eval        % accumulated evaluation results
  end
  
  methods
    function ev = CocoEvalLRP( cocoGt, cocoDt,tau )
      % Initialize CocoEval using coco APIs for gt and dt.
      if(nargin>0), ev.cocoGt = cocoGt; end
      if(nargin>1), ev.cocoDt = cocoDt; end
      if(nargin>0), ev.params.imgIds = sort(ev.cocoGt.getImgIds()); end
      if(nargin>0), ev.params.catIds = sort(ev.cocoGt.getCatIds()); end
      ev.params.iouThrs = tau;
      ev.params.confScores = 0:.01:1;
      ev.params.areaRng = [0 1e5].^2;
      ev.params.maxDets = 100;
      ev.params.useCats = 1;
    end
    
    function evaluate( ev )
      % Run per image evaluation on given images.
      fprintf('Running per image evaluation...      '); clk=clock;
      p=ev.params; if(~p.useCats), p.catIds=1; end
      p.imgIds=unique(p.imgIds); p.catIds=unique(p.catIds); ev.params=p;
      N=length(p.imgIds); K=length(p.catIds); A=size(p.areaRng,1);
      [nGt,iGt]=getAnnCounts(ev.cocoGt,p.imgIds,p.catIds,p.useCats);
      [nDt,iDt]=getAnnCounts(ev.cocoDt,p.imgIds,p.catIds,p.useCats);
      [ks,is]=ndgrid(1:K,1:N); ev.evalImgs=cell(N,K,A);
      for i=1:K*N, if(nGt(i)==0 && nDt(i)==0), continue; end
        gt=ev.cocoGt.data.annotations(iGt(i):iGt(i)+nGt(i)-1);
        dt=ev.cocoDt.data.annotations(iDt(i):iDt(i)+nDt(i)-1);
        if(~isfield(gt,'ignore')), [gt(:).ignore]=deal(0); end
        f='bbox'; if(isempty(dt)), [dt(:).(f)]=deal(); end
        if(~isfield(dt,f)), s=MaskApi.toBbox([dt.segmentation]);
          for d=1:nDt(i), dt(d).(f)=s(d,:); end; end
        q=p; q.imgIds=p.imgIds(is(i)); q.maxDets=max(p.maxDets);
        for j=1:A, q.areaRng=p.areaRng(j,:);
          ev.evalImgs{is(i),ks(i),j}=CocoEvalLRP.evaluateImg(gt,dt,q); end
      end
      E=ev.evalImgs; nms={'dtIds','gtIds','dtImgIds','gtImgIds',...
        'dtMatches','gtMatches','dtScores','dtIgnore','gtIgnore','dtIoU'};
      ev.evalImgs=repmat(cell2struct(cell(10,1),nms,1),K,A);
      for i=1:K, is=find(nGt(i,:)>0|nDt(i,:)>0);
        if(~isempty(is)), for j=1:A, E0=[E{is,i,j}]; for k=1:10
              ev.evalImgs(i,j).(nms{k})=[E0{k:10:end}]; end; end; end
      end
      fprintf('DONE (t=%0.2fs).\n',etime(clock,clk));
      
      function [ns,is] = getAnnCounts( coco, imgIds, catIds, useCats )
        % Return ann counts and indices for given imgIds and catIds.
        as=sort(coco.getCatIds()); [~,a]=ismember(coco.inds.annCatIds,as);
        bs=sort(coco.getImgIds()); [~,b]=ismember(coco.inds.annImgIds,bs);
        if(~useCats), a(:)=1; as=1; end; ns=zeros(length(as),length(bs));
        for ind=1:length(a), ns(a(ind),b(ind))=ns(a(ind),b(ind))+1; end
        is=reshape(cumsum([0 ns(1:end-1)])+1,size(ns));
        [~,a]=ismember(catIds,as); [~,b]=ismember(imgIds,bs);
        ns=ns(a,b); is=is(a,b);
      end
    end
    
    function accumulate( ev )
      % Accumulate per image evaluation results.
      fprintf('Accumulating evaluation results...   '); clk=clock;
      if(isempty(ev.evalImgs)), error('Please run evaluate() first'); end
      p=ev.params; T=length(p.iouThrs); S=length(p.confScores);
      K=length(p.catIds); 
      TP=zeros(S,K);FP=zeros(S,K);FN=zeros(S,K);
      LRPError=-ones(S,K); LocError=-ones(S,K);
      FPError=-ones(S,K); FNError=-ones(S,K);
      OptLRPError=-ones(1,K); OptLocError=-ones(1,K);
      OptFPError=-ones(1,K); OptFNError=-ones(1,K);
      Threshold=-ones(1,K);
      index=zeros(1,K);
      for k=1:K
        E=ev.evalImgs(k); is=E.dtImgIds; mx=p.maxDets;
        np=nnz(~E.gtIgnore);
        thrind=zeros(1,S);
        if(np==0), continue; end
        t=[0 find(diff(is)) length(is)];
        t=t(2:end)-t(1:end-1); is=is<0;
        r=0; for i=1:length(t), is(r+1:r+min(mx,t(i)))=1; r=r+t(i); end

        dtm=E.dtMatches(:,is); dtIg=E.dtIgnore(:,is);IoUoverlap=E.dtIoU(:,is);
        [sortedscores,o]=sort(E.dtScores(is),'descend');
        tps=reshape( dtm & ~dtIg,T,[]); tps=tps(:,o);IoUoverlap=IoUoverlap(:,o);
        fps=reshape(~dtm & ~dtIg,T,[]); fps=fps(:,o);
        [~, detcount]=size(tps);
        for i=1:detcount
            if IoUoverlap(1,i)~=0
                IoUoverlap(1,i)=1-IoUoverlap(1,i);
            end
        end
        IoUoverlap=IoUoverlap.*tps;
        for s=1:S
            thrind(s)=sum(sortedscores>=p.confScores(s));
            TP(s,k)=sum(tps(1,1:thrind(s)));
            FP(s,k)=sum(fps(1,1:thrind(s))) ;
            FN(s,k)=np-TP(s,k);
            %For stability, svoid dividing zero
            l=max((TP(s,k)+FP(s,k)),np);
            FPError(s,k)=(1-p.iouThrs)*(FP(s,k)/l);
            FNError(s,k)=(1-p.iouThrs)*(FN(s,k)/l);
            Z=((TP(s,k)+FN(s,k)+FP(s,k))/l);
            
            %Compute LRP error
            LRPError(s,k)=(sum(IoUoverlap(1:thrind(s)))/l)+FPError(s,k)+FNError(s,k);            
            LRPError(s,k)=LRPError(s,k)/Z;
            LRPError(s,k)=LRPError(s,k)/(1-p.iouThrs);
            
            %Compute Components
            LocError(s,k)=sum(IoUoverlap(1:thrind(s)))/TP(s,k);
            FPError(s,k)=FP(s,k)/(TP(s,k)+FP(s,k));
            FNError(s,k)=FN(s,k)/np;
        end
        %Compute oLRP
        [OptLRPError(1,k),index(1,k)]=min(LRPError(:,k));
        OptLocError(1,k)=LocError(index(1,k),k);
        OptFPError(1,k)=FPError(index(1,k),k);
        OptFNError(1,k)=FNError(index(1,k),k);
        %Compute Threshold
        Threshold(1,k)=(index(1,k)-1)*0.01;         
      end
      %Compute moLRP
      moLRPLoc=mean(OptLocError,'omitNaN');
      moLRPFP=mean(OptFPError,'omitNaN');
      moLRPFN=mean(OptFNError,'omitNaN');
      moLRP=mean(OptLRPError);      
      
      ev.eval=struct('params',p,'date',date,'counts',[S K],...
        'LRPError',LRPError,'BoxLocComp',LocError,'FPComp',FPError,'FNComp',FNError, ...
        'oLRPError',OptLRPError,'oBoxLocComp',OptLocError,'oFPComp',OptFPError,'oFNComp',OptFNError,...
        'moLRP',moLRP,'moLRPLoc',moLRPLoc,'moLRPFP',moLRPFP,'moLRPFN',moLRPFN,'ClassSpecificThresholds',Threshold);
      fprintf('DONE (t=%0.2fs).\n',etime(clock,clk));
    end
    
    function summarize( ev )
      % Compute and display summary metrics for evaluation results.
      if(isempty(ev.eval)), error('Please run accumulate() first'); end
      disp('Mean Optimal LRP and Components:')
      fStr=' moLRP=%.4f, moLRP_LocComp=%.4f, moLRP_FPComp=%.4f, moLRP_FPComp=%.4f\n';
      fprintf(fStr,ev.eval.moLRP,ev.eval.moLRPLoc,ev.eval.moLRPFP,ev.eval.moLRPFN);
      disp('See cocoEvalLRP.eval for the complete evaluation result including class specific performance and optimal thresholds')
    end
  end
  
  methods( Static )
    function o = boxoverlap(a, b)
        x1 = max(a(1), b(1));
        y1 = max(a(2), b(2));
        x2 = min(a(3), b(3));
        y2 = min(a(4), b(4));

        w = x2-x1+1;
        h = y2-y1+1;
        inter = w*h;
        aarea = (a(3)-a(1)+1) * (a(4)-a(2)+1);
        barea = (b(3)-b(1)+1) * (b(4)-b(2)+1);
        % intersection over union overlap
        o = inter / (aarea+barea-inter);
        % set invalid entries to 0 overlap
        o(w <= 0) = 0;
        o(h <= 0) = 0;  
    end
    
    function e = evaluateImg( gt, dt, params )
      % Run evaluation for a single image and category.
      p=params; T=length(p.iouThrs); aRng=p.areaRng;
      a=[gt.area]; gtIg=[gt.iscrowd]|[gt.ignore]|a<aRng(1)|a>aRng(2);
      G=length(gt); D=length(dt); for g=1:G, gt(g).ignore=gtIg(g); end
      % sort dt highest score first, sort gt ignore last
      [~,o]=sort([gt.ignore],'ascend'); gt=gt(o);
      [~,o]=sort([dt.score],'descend'); dt=dt(o);
      if(D>p.maxDets), D=p.maxDets; dt=dt(1:D); end
      % compute iou between each dt and gt region
      iscrowd = uint8([gt.iscrowd]);
      
      g=cat(1,gt.bbox);
      d=cat(1,dt.bbox);
      ious=MaskApi.iou(d,g,iscrowd);
      % attempt to match each (sorted) dt to each (sorted) gt
      gtm=zeros(T,G); gtIds=[gt.id]; gtIg=[gt.ignore];
      dtm=zeros(T,D); dtIds=[dt.id]; dtIg=zeros(T,D); dtIoU=zeros(T,D);
      for t=1:T
        for d=1:D
          % information about best match so far (m=0 -> unmatched)
          iou=min(p.iouThrs(t),1-1e-10); m=0;
          for g=1:G
            % if this gt already matched, and not a crowd, continue
            if( gtm(t,g)>0 && ~iscrowd(g) ), continue; end
            % if dt matched to reg gt, and on ignore gt, stop
            if( m>0 && gtIg(m)==0 && gtIg(g)==1 ), break; end
            % if match successful and best so far, store appropriately
            if( ious(d,g)>=iou ), iou=ious(d,g); m=g; end
          end
          % if match made store id of match for both dt and gt
          if(~m), continue; end; dtIg(t,d)=gtIg(m);
          dtm(t,d)=gtIds(m); gtm(t,m)=dtIds(d); dtIoU(t,d)=iou;
        end
      end
      % set unmatched detections outside of area range to ignore
      if(isempty(dt)), a=zeros(1,0); else a=[dt.area]; end
      dtIg = dtIg | (dtm==0 & repmat(a<aRng(1)|a>aRng(2),T,1));
      % store results for given image and category
      dtImgIds=ones(1,D)*p.imgIds; gtImgIds=ones(1,G)*p.imgIds;
      e = {dtIds,gtIds,dtImgIds,gtImgIds,dtm,gtm,[dt.score],dtIg,gtIg,dtIoU};
    end
  end
end
