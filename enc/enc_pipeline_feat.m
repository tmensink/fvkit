function [encOpts, R] = enc_pipeline_feat(encOpts,dataset)
    % Encoding pipeline
    %
    % Part of FVKit - initial release
    % Copyright, 2013-2018
    % Thomas Mensink, University of Amsterdam
    % thomas.mensink@uva.nl
    
    if nargin < 1 || isempty(encOpts),      encOpts     = [];               end
    if nargin < 2 || isempty(dataset),      dataset     = [];               end
    fversion(.21);
    
    %% Pre-processing options
    encOpts     = init_getOpts(encOpts,dataset);
    R.sum       = encOpts.sum;
    R.status    = 'preprocess';
    fprintf('\t--> Summary | %s\n',encOpts.sum);
    fprintf('\t--> Dataset | %s\n',encOpts.name);
    
    if encOpts.svm.trainOnly == 0,
        %% Step 1: Extract a few sifts per image
        enc_computellf(encOpts);
        R.status    = 'computellf';
        
        %% Step 2: Compute PCA
        enc_computepca(encOpts);
        R.status    = 'computepca';
        
        %% Step 3: Compute GMM
        enc_computegmm(encOpts);
        R.status    = 'computegmm';
        
        %% Step 4: Extract FV for each image
        enc_computeimgrep(encOpts);
        R.status    = 'computeimgrep';
        
        %% Step 5: Compute kernel
        if encOpts.svm.kernel,
            enc_computekernel(encOpts);
            R.status    = 'computekernel';
        end
    end
    %% Step 6: SVM Train
    if encOpts.svm.train,
        R.res       = svm_kernel_train(encOpts);
        R.status    = R.res.tst.str;
    end
    fprintf('\t--> Status  |%s\n',R.status);
end
