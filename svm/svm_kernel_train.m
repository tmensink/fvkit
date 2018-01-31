function fres = svm_kernel_train(encOpts)
    % Train (linear) kernel SVMs
    %
    % This files uses
    %  - svmtrain
    %  - svmpredict
    % from the liblinear library (included in lib, see README).
    %
    % Part of FVKit - initial release
    % Copyright, 2013-2018
    % Thomas Mensink, University of Amsterdam
    % thomas.mensink@uva.nl
    
    C   = encOpts.svm.C;
    T   = encOpts.svm.test;
    fversion(.15);
    
    % This means we're going to do crossvalidation
    CV = numel(C) > 1;
    assert(all(mod(log10(C),1) == 0),'We assume C = {.01 .1 1 10 ...}');
    
    eval = encOpts.svm.eval;
    evalS= encOpts.svm.evalS;
    
    bpath = encOpts.svm.path;
    bfile = sprintf('%s/kernelsvm',bpath);
    
    fprintf('%s | using %s (%s)\n',mfilename,evalS,eval);
    if CV == 1,
        P = zeros(1,numel(C));
        
        %% Do cross validation experiment with CC
        for c=1:numel(C),
            CC      = C(c);
            cname   = sprintf('CV_%5.0e',CC);
            cvname  = sprintf('%s_%s.mat',bfile,cname);
            
            fprintf('Cross Validation using C %5.0e | %f \n',CC,CC);
            if exist(cvname,'file') ~= 2,
                %% Load the train x train kernel, and the train x val kernel
                if exist('Ktrain','var') ~= 1 || exist('Kval','var') ~= 1,
                    fprintf('\t --> Load Train and Val kernels\n');
                    kName       = sprintf('%s/kernel_TRN2TRN.mat',bpath);
                    Ktrain      = load(kName);
                    Ktrain.K    = double([(1:size(Ktrain.K))' Ktrain.K]);
                    
                    kName       = sprintf('%s/kernel_VAL2TRN.mat',bpath);
                    Kval        = load(kName);
                    Kval.K      = double([(1:size(Kval.K))' Kval.K]);
                    
                    ImgId       = encOpts.imdb.images.id;
                    Kval.Id     = ImgId(encOpts.imdb.images.set == encOpts.imdb.sets.('VAL'));
                    Ktrain.Id   = ImgId(encOpts.imdb.images.set == encOpts.imdb.sets.('TRAIN'));
                end
                
                %% Load the train data vector
                NrClass     = numel(encOpts.imdb.classes.name);
                NrVal       = numel(Kval.Id);
                
                PP          = zeros(NrVal,NrClass);
                GG          = zeros(NrVal,NrClass);
                
                fprintf('\t--> Learn for class %3d',0);
                for ci = 1:NrClass,
                    fprintf('\b\b\b%3d',ci);
                    
                    % Set class specific data
                    ClsId = encOpts.imdb.classes.imageIds{ci};
                    Ytrain= double(ismember(Ktrain.Id,ClsId)); Ytrain(Ytrain == 0) = -1; Ytrain = Ytrain';
                    Yval  = double(ismember(Kval.Id,ClsId));   Yval(Yval == 0) = -1;     Yval   = Yval';
                    
                    % Learn SVM
                    model           = svmtrain(Ytrain, Ktrain.K, sprintf('-t 4 -c %f -q',CC)); %#ok<*SVMTRAIN>
                    [~,~,pred]      = svmpredict(Yval, Kval.K, model);
                    if model.Label(1) == -1, pred = -1 * pred; end
                    
                    PP(:,ci) = pred;
                    GG(:,ci) = Yval;
                end
                fprintf('|done\n');
                
                [res.iap,res.nap,res.det]       = eval_map(PP,GG);
                [res.clac, res.clai, res.cdet]  = eval_classacc(PP,GG);
                save(cvname,'res')
            else
                fprintf('\t\t--> load %s\n',cvname);
                load(cvname)
            end
            P(c) = res.(eval);
            fprintf('\t --> Performance %s (%s): %6.2f\n',evalS,eval,P(c)*100);
        end
        fprintf('\n%s\n',repmat('-',1,60));
        
        [pVal, pInx] = max(P);
        Cbest = C(pInx);
        fprintf('Best Performance with: C %5.0e | %s (%s) %6.2f\n',Cbest,evalS,eval,pVal*100);
        clear res
        fres.cv.C = C;
        fres.cv.P = P;
    else
        Cbest = C;
    end
    
    if T == 1,
        cname   = sprintf('test_%5.0e',Cbest);
        cvname  = sprintf('%s_%s.mat',bfile,cname);
        
        fprintf('Evaluate: using trainval and test, with C %5.0e | %f\n',Cbest,Cbest);
        
        if exist(cvname,'file') ~= 2,
            fnames                  = fieldnames(encOpts.imdb.sets);
            msk = false(size(fnames));
            for f=1:numel(fnames), msk(f) = encOpts.imdb.sets.(fnames{f}) <= 0; end;
            fnames(msk) = [];
            
            if ismember('VAL',fnames),
                %% Load the train x train kernel, and the train x val kernel
                kName       = sprintf('%s/kernel_TRV2TRV.mat',bpath);
                fprintf('\t--> Load Train Kernel: %s\n',kName);
                Ktrain      = load(kName);
                Ktrain.K    = double([(1:size(Ktrain.K))' Ktrain.K]);
                
                kName       = sprintf('%s/kernel_TST2TRV.mat',bpath);
                fprintf('\t--> Load Test Kernel: %s\n',kName);
                Ktest       = load(kName);
                Ktest.K     = double([(1:size(Ktest.K))' Ktest.K]);
                
                ImgId       = encOpts.imdb.images.id;
                Ktest.Id    = ImgId(encOpts.imdb.images.set == encOpts.imdb.sets.('TEST'));
                Ktrain.Id   = [ImgId(encOpts.imdb.images.set == encOpts.imdb.sets.('TRAIN')),...
                    ImgId(encOpts.imdb.images.set == encOpts.imdb.sets.('VAL'))  ];
            else
                %% Load the train x train kernel, and the train x val kernel
                kName       = sprintf('%s/kernel_TRN2TRN.mat',bpath);
                fprintf('\t--> Load Train Kernel: %s\n',kName);
                Ktrain      = load(kName);
                Ktrain.K    = double([(1:size(Ktrain.K))' Ktrain.K]);
                
                kName       = sprintf('%s/kernel_TST2TRN.mat',bpath);
                fprintf('\t--> Load Test Kernel: %s\n',kName);
                Ktest       = load(kName);
                Ktest.K     = double([(1:size(Ktest.K))' Ktest.K]);
                
                ImgId       = encOpts.imdb.images.id;
                Ktest.Id    = ImgId(encOpts.imdb.images.set == encOpts.imdb.sets.('TEST'));
                Ktrain.Id   = ImgId(encOpts.imdb.images.set == encOpts.imdb.sets.('TRAIN'));
            end
            
            %% Load the train data vector
            NrClass     = numel(encOpts.imdb.classes.name);
            NrTst       = numel(Ktest.Id);
            
            PP          = zeros(NrTst,NrClass);
            GG          = zeros(NrTst,NrClass);
            
            fprintf('\t--> Learn for class %3d',0);
            for ci = 1:NrClass,
                fprintf('\b\b\b%3d',ci);
                
                ClsId = encOpts.imdb.classes.imageIds{ci};
                Ytrain= double(ismember(Ktrain.Id,ClsId)); Ytrain(Ytrain == 0) = -1; Ytrain = Ytrain';
                Ytest = double(ismember(Ktest.Id,ClsId));  Ytest(Ytest == 0) = -1;   Ytest  = Ytest';
                
                model           = svmtrain(Ytrain, Ktrain.K, sprintf('-t 4 -c %f -q',Cbest));
                [~,~,pred]      = svmpredict(Ytest, Ktest.K, model);
                if model.Label(1) == -1, pred = -1 * pred; end
                
                PP(:,ci) = pred;
                GG(:,ci) = Ytest;
            end
            fprintf('|done\n');
            [res.iap,res.nap,res.det]           = eval_map(PP,GG);
            [res.clac, res.clai, res.cdet]      = eval_classacc(PP,GG);
            save(cvname,'res')
        else
            fprintf('\t--> Load results\n');
            load(cvname)
        end
        
        fprintf('\t--> Average over %d classes:',res.det.NrQ);
        f = fieldnames(res);
        for i=1:numel(f),
            fname = f{i};
            fval  = res.(fname);
            if isempty(strfind(fname,'det')) && isnumeric(fval)
                fprintf('%s %6.2f |',fname,fval*100);
            end
        end
        fprintf('\n');
        
        fres.tst.C  = Cbest;
        if isfield(res,'clac') && isfield(res,'clai'),
            fres.tst.P  = [res.iap res.nap res.clac res.clai];
        else
            fres.tst.P  = [res.iap res.nap];
        end
        fres.tst.str  = sprintf('LibSVM Kernel C%5.0e | %d classes | %s %6.2f',Cbest,res.det.NrQ,eval,res.(eval)*100);
        fres.tst.det= res.det;
    end
end