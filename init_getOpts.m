function enc = init_getOpts(enc,dataset)
    % Initialze options for Fisher Vector extraction
    %
    % This file sets most options used in the FVKit.
    % It ensures that all options are correctly set
    %
    % Part of FVKit - initial release
    % copyright, 2014-2018
    % Thomas Mensink, University of Amsterdam
    % thomas.mensink@uva.nl
    
    if nargin < 1 || isempty(enc),      enc                     = struct;           end
    if nargin < 2 || isempty(dataset),  dataset                 = 'VOC2007';        end
    
    init_getOptsSetPath
    enc = init_getOptsDataset(enc,dataset);
    
    % Set Low Level Extraction Options
    if ~isfield(enc,'llf'),             enc.llf                 = struct;           end
    enc.llf =                           llf_opts(enc.llf,enc);
    
    % Set PCA options
    if ~isfield(enc,'pca'),             enc.pca                 = struct;           end
    enc.pca =                           pca_opts(enc.pca,enc);
    
    % Set GMM options
    if ~isfield(enc,'prob'),            enc.prob                = struct;           end
    if ~isfield(enc.prob,'base'),       enc.prob.base           = 'gmm';            end
    
    delpath(genpath('prob'));
    addpath(['prob/' enc.prob.base]);
    probOpts = str2func([enc.prob.base '_opts']);
    enc.prob =                          probOpts(enc.prob,enc);
    
    % Set FV options
    if ~isfield(enc,'fv'),              enc.fv                  = struct;           end
    if ~isfield(enc.fv,'extract'),      enc.fv.extract          = 1;                end
    fvOpts = str2func([enc.prob.base '_fv_opts']);
    enc.fv  =                           fvOpts(enc.fv,enc);
    
    %Set Pooling opts
    if ~isfield(enc,'pool'),            enc.pool                = struct;           end
    enc.pool =                          pool_opts(enc.pool,enc);
    
    %Set SVM/Learning opts
    if ~isfield(enc,'svm'),             enc.svm                 = struct;           end
    enc.svm =                           svm_opts(enc.svm,enc);
    
    %Ensure paths are existing
    fn = {'llf','pca','prob','fv','pool'};
    for i=1:numel(fn),
        if isfield(enc.(fn{i}),'path') && exist(enc.(fn{i}).path,'dir') ~= 7,
            mkdir(enc.(fn{i}).path),
            fprintf('\t Create dir | %s\n',enc.(fn{i}).path);
        end;
    end
    
    inx     = strfind(enc.pool.path,enc.path.results);
    enc.sum = enc.pool.path(inx+numel(enc.path.results):end);
end
