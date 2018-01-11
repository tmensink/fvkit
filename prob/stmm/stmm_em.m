function [ smm ] = stmm_em(X, smm, Xs )
    % SMM EM - compute the EM algorithm
    %
    % Input
    %   smm         struct
    %       mean    [d x k]     component means
    %       sigma   [d x d x k] scaling matrix Sigma
    %       var     [d x k]     variance when assuming diagonal cov matrix
    %       weight  [1 x k]     weight vectors
    %       nu      [1 x k]     scaling vectors
    %       k       scalar      number of components
    %       params  struct      parameters (see gmm_opts)
    %       X       [d x n]     feature matrix
    %
    % Output
    %   smm         struct
    %       mu       [d x k]     component means
    %       sigma    [d x d x k] scaling matrix Sigma
    %       var      [d x k]     variance when assuming diagonal cov matrix
    %       nu       [1 x k]     scaling vectors
    %       weight   [1 x k]     weight vectors
    %
    % See also: smm_expectation, smm_maximization, smm_init
    %
    % Written by Markus Nagel
    % October 2014, University of Amsterdam
    % (c) 2014
    
    % Check input
    if isempty(smm),            smm = struct;                               end
    if ~isfield(smm,'params'),  smm.params = struct;                        end
    smm.params      = smm_opts(smm.params);
    
    if isfield(smm,'mean') && isfield(smm,'var') && isfield(smm,'weight'),
        smm.k       = size(smm.mean,2);
    else
        smm.mean    = [];
        smm.sigma   = [];
        smm.weight  = [];
        
        if ~isfield(smm,'k'),
            smm.k = smm.params.k;
        end
    end
    
    
    %% Random init of the SMM
    if isempty(smm.mean),  fprintf('\t\t-->Init\n');
        smm = smm_init(smm,X);        
    end
    
    %% Obtain squared features - speed up expectation step
    if nargin < 3 || isempty(Xs),   Xs     = X.^2;                          end
    
    %% Start EM
    smm.logl                = -inf(1,smm.params.MaxIter);
    
    for i=1:smm.params.MaxIter+1,
        fprintf('%4d |',i);
        [ tau, u, ~, logl ]     = smm_expectation(smm,X,Xs);                        
        fprintf('E %20.12f logl |',logl);
        
        if ~isfinite(logl),
            keyboard,
        end
        smm.logl(i)             = logl;
        
        
        
        if i > 1,
            dll     = (smm.logl(i)-smm.logl(i-1))/(smm.logl(i)-smm.logl(1));
            adll    = smm.logl(i)-smm.logl(i-1);
            
            fprintf('diff %12.5f - %11.4e | abs diff %11.4e',dll,dll,adll);
            
            if dll < smm.params.LlhDiffThr,
                fprintf('Converged!\n');
                break;
            end
        end
        
        if i <= smm.params.MaxIter,
            fprintf('|M|');
            smm         = smm_maximization(tau,u,X,Xs,smm);
            fprintf('.');
        end
        fprintf('\n');
    end
    smm.det.iter = i;
    smm.det.logl = smm.logl(1:i);
    smm.logl     = smm.logl(i);
    
    fprintf('\t\t--> Means [%d x %d] - after EM:\n',size(smm.mean));
    for i=1:min(5,size(X,1)),
        fprintf('\t\t\t');fprintf(' %7.2f ',smm.mean(i,1:min(smm.k,10)));fprintf('\n');
    end
end