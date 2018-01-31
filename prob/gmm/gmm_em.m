function gmm = gmm_em(X,gmm,Xs)
    % GMM EM - compute the EM algorithm
    % assumes diagonal covariance matrices
    % Input
    %   gmm         struct
    %       mean    [d x k]     component means
    %       var     [d x k]     diagonal variances
    %       weight  [1 x k]     weight vectors
    %       k       scalar      number of components
    %       params  struct      parameters (see gmm_opts)
    %   X           [d x n]     feature matrix
    %   Xs          [d x n]     feature matrix with squared features (optional)
    %
    % Output
    %   gmm         struct
    %       mean    [d x k]     component means
    %       var     [d x k]     diagonal variances
    %       weight  [1 x k]     weight vectors
    %
    % See also: gmm_expectation, gmm_maximization, gmm_rnd_init
    %
    %
    % Part of FVKit - initial release
    % Copyright, 2013-2018
    % Thomas Mensink, University of Amsterdam
    % thomas.mensink@uva.nl
    
    if isfield(gmm,'mean') && isfield(gmm,'var') && isfield(gmm,'weight'),
        gmm.k       = size(gmm.mean,2);
    else
        gmm.mean    = [];
        gmm.var     = [];
        gmm.weight  = [];
        assert(isnumeric(gmm.k),'Not valid gmm struct');
    end
    
    
    %% Random init of the GMM
    if isempty(gmm.mean),
        gmm = gmm_rnd_init(gmm,X);
    end
    
    %% Obtain squared features - speed up expectation step
    if nargin < 3 || isempty(Xs),   Xs     = X.^2;                          end
    
    %% Compute Variance Floor per dimension
    var_floor = gmm.params.VarFloorFactor * var(X,[],2);
    var_floor = max(gmm.params.VarFloor, var_floor);
    gmm.params.VarFloor = var_floor;
    
    %% Start EM
    gmm.logl                = -inf(1,gmm.params.MaxIter);
    
    for i=1:gmm.params.MaxIter+1,
        [P, logl]   = gmm_expectation(gmm,X,Xs);
        gmm.logl(i) = logl;
        
        fprintf('%4d | E %20.12f logl |',i,logl);
        
        if isfield(gmm.params,'Name') && ~isempty(gmm.params.Name),
            fprintf('SAVE|');
            iName = sprintf(gmm.params.Name,i);
            save(iName,'gmm');
        end
        
        if i > 1,
            dll     = (gmm.logl(i)-gmm.logl(i-1))/(gmm.logl(i)-gmm.logl(1));
            adll    = gmm.logl(i)-gmm.logl(i-1);
            
            fprintf('diff %12.5f - %11.4e | abs diff %11.4e',dll,dll,adll);
            
            if dll < gmm.params.LlhDiffThr,
                fprintf('Converged!\n');
                break;
            end
        end
        
        if i <= gmm.params.MaxIter,
            fprintf('|M|');
            gmm         = gmm_maximization(P,X,Xs,gmm);
        end
        fprintf('\n');
    end
    gmm.det.iter = i;
    gmm.det.logl = gmm.logl(1:i);
    gmm.logl     = gmm.logl(i);
end
