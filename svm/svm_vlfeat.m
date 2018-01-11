function fres = svm_vlfeat(encOpts,C,T)
if nargin < 2 || isempty(C),    C = logspace(-2,2,5);   end
if nargin < 3 || isempty(T),    T = 1;                  end
fversion(.15);

% This means we're going to do crossvalidation
CV = numel(C) > 1;
assert(all(mod(log10(C),1) == 0),'We assume C = {.01 .1 1 10 ...}');
K    = encOpts.svm.vlf.kernel;
eval = encOpts.svm.eval;
evalS= encOpts.svm.evalS;

fprintf('%s | using %s (%s)\n',mfilename,evalS,eval);
if CV == 1,
    P = zeros(1,numel(C));
    
    %% Do cross validation experiment with CC
    for c=1:numel(C),
        CC      = C(c);
        cname   = sprintf('CV_%5.0e',CC);
        cvname  = enc_getName('vlf-file',encOpts,struct('name',cname));
        
        fprintf('Cross Validation using C %5.0e | %f \n',CC,CC);
        if exist(cvname,'file') ~= 2,
            %% Load the train x train kernel, and the train x val kernel
            if exist('Ftrain','var') ~= 1 || exist('Fval','var') ~= 1,
                fprintf('\t --> Load Train and Val features\n');
                kName       = enc_getName('fv-file',encOpts,struct('name','TRAIN'));
                Ftrain      = load(kName);
                
                kName       = enc_getName('fv-file',encOpts,struct('name','VAL'));
                Fval        = load(kName);
                
                ImgId       = encOpts.imdb.images.id;
                Fval.Id     = ImgId(encOpts.imdb.images.set == encOpts.imdb.sets.('VAL'));
                Ftrain.Id   = ImgId(encOpts.imdb.images.set == encOpts.imdb.sets.('TRAIN'));
                
                if K > 0,
                    fprintf('\t --> Compute VL Homkermap\n');
                    Ftrain.X    = vl_homkermap(Ftrain.X, K, 'Kinters') ;
                    Kval.X     = vl_homkermap(Kval.X, K, 'Kinters') ;
                end
                
            end
            
            %% Load the train data vector
            NrClass     = numel(encOpts.imdb.classes.name);
            NrVal       = numel(Fval.Id);
            
            PP          = zeros(NrVal,NrClass);
            GG          = zeros(NrVal,NrClass);
            
            fprintf('\t--> Learn for class %3d',0);
            for ci = 1:NrClass,
                fprintf('\b\b\b%3d',ci);
                
                % Set class specific data
                ClsId = encOpts.imdb.classes.imageIds{ci};
                Ytrain= double(ismember(Ftrain.Id,ClsId)); Ytrain(Ytrain == 0) = -1; Ytrain = int8(Ytrain)';
                Yval  = double(ismember(Fval.Id,ClsId));   Yval(Yval == 0) = -1;     Yval   = int8(Yval)';
                
                % Learn SVM
                lambda = max(0.8,1 / (C * numel(Ytrain))) ;
                vl_twister('state',0) ;

                if K > 0,
                  [W,b,info] = vl_pegasos(Ftrain.X, Ytrain, lambda, 'MaxIterations', 10000, 'BiasMultiplier', 1,'HOMKERMAP',K) ;
                else
                  [W,b,info] = vl_pegasos(Ftrain.X, Ytrain, lambda, 'MaxIterations', 10000, 'BiasMultiplier', 1) ;
                end

                pred = W' * Fval.X + b;
                
                PP(:,ci) = pred';
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
    cvname  = enc_getName('vlf-file',encOpts,struct('name',cname));
    ImgId   = encOpts.imdb.images.id;
    
 
    fprintf('Evaluate: using trainval and test, with C %5.0e | %f\n',Cbest,Cbest);
    if exist(cvname,'file') ~= 2,
        fnames                  = fieldnames(encOpts.imdb.sets);
        msk = false(size(fnames));
        for f=1:numel(fnames), msk(f) = encOpts.imdb.sets.(fnames{f}) <= 0; end;
        fnames(msk) = [];
        
        if exist('Ftrain','var') ~= 1,
            fprintf('\t --> Load Train Features\n');
            kName       = enc_getName('fv-file',encOpts,struct('name','TRAIN'));
            Ftrain      = load(kName);
            Ftrain.Id   = ImgId(encOpts.imdb.images.set == encOpts.imdb.sets.('TRAIN'));
            
            if K > 0,
                Ftrain.X    = vl_homkermap(Ftrain.X, K, 'Kinters') ;
            end
        end
        
        if ismember('VAL',fnames),
            if exist('Fval','var') ~= 1,
                fprintf('\t --> Load Val Features\n');
                kName       = enc_getName('fv-file',encOpts,struct('name','VAL'));
                Fval        = load(kName);
                Fval.Id     = ImgId(encOpts.imdb.images.set == encOpts.imdb.sets.('VAL'));
                
                if K > 0,
                    Fval.X    = vl_homkermap(Fval.X, K, 'Kinters') ;
                end
            end
            
            Ftrain.X2  = [Ftrain.X Fval.X];
            Ftrain.Id2 = [Ftrain.Id Fval.Id];
        else
            Ftrain.X2  = Ftrain.X;
            Ftrain.Id2 = Ftrain.Id;
        end
        if exist('Ftest','var') ~= 1,
            fprintf('\t --> Load Test Features\n');
            kName       = enc_getName('fv-file',encOpts,struct('name','TEST'));
            Ftest       = load(kName);
            Ftest.Id    = ImgId(encOpts.imdb.images.set == encOpts.imdb.sets.('TEST'));
            
            if K > 0,
                Ftest.X = vl_homkermap(Ftest.X, K, 'Kinters') ;
            end
        end
        
        %% Load the train data vector
        NrClass     = numel(encOpts.imdb.classes.name);
        NrTst       = numel(Ftest.Id);
        
        PP          = zeros(NrTst,NrClass);
        GG          = zeros(NrTst,NrClass);
        
        fprintf('\t--> Learn for class %3d',0);
        for ci = 1:NrClass,
            fprintf('\b\b\b%3d',ci);
            
            ClsId = encOpts.imdb.classes.imageIds{ci};
            Ytrain= double(ismember(Ftrain.Id2,ClsId)); Ytrain(Ytrain == 0) = -1; Ytrain = int8(Ytrain)';
            Ytest = double(ismember(Ftest.Id,ClsId));  Ytest(Ytest == 0) = -1;   Ytest  = int8(Ytest)';

            lambda = min(0.8,1 / (C * numel(Ytrain)));
            vl_twister('state',0) ;
            if K > 0,
              [W,b,info] = vl_pegasos(Ftrain.X2, Ytrain, lambda, 'MaxIterations', 10000, 'BiasMultiplier', 1,'HOMKERMAP',K) ;
            else
              [W,b,info] = vl_pegasos(Ftrain.X2, Ytrain, lambda, 'MaxIterations', 10000, 'BiasMultiplier', 1) ;
            end
            pred = W' * Ftest.X + b;
            
            PP(:,ci) = pred';
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
    
    fres.tst.det= res.det;
end
end
