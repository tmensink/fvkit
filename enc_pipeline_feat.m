function [encOpts, R] = enc_pipeline_feat(encOpts,dataset)    
    % Extract features for a dataset and setting
    
    % Refactoring of code for BMVC 2015
    % Thomas Mensink
    % Sept 2015
    
    if nargin < 1 || isempty(encOpts),      encOpts     = [];               end
    if nargin < 2 || isempty(dataset),      dataset     = [];               end

    fversion(.21);

    %% Pre-processing options
    encOpts     = enc_getOpts(encOpts,dataset);
    R.sum       = encOpts.sum;
    R.status    = 'preprocess'; 
    fprintf('Pipeline Summary | %s\n',encOpts.sum);
    fprintf('\t--> enc.Name \t%s\n',encOpts.name);
    
 
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
