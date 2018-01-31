function gmm = gmm_rnd_init(gmm,X)
    % GMM EM - randomly init the mean, var, weights of the GM struct
    % assumes diagonal covariance matrices
    %
    % Input
    %   gmm         struct
    %       k       scalar      number of components
    %       params  struct      parameters (see gmm_opts)
    %   X           [d x n]     feature matrix
    %
    % Output
    %   gmm         struct
    %       mean    [d x k]     component means
    %       var     [d x k]     diagonal variances
    %       weight  [1 x k]     weight vectors
    %
    % See also: gmm_em
    %
    %
    % Part of FVKit - initial release
    % Copyright, 2013-2018
    % Thomas Mensink, University of Amsterdam
    % thomas.mensink@uva.nl
    
    % Setup a few variables
    var_flr     = gmm.params.VarFloor;
    rs          = RandStream.create('mt19937ar','seed',gmm.params.Seed);
    d           = size(X,1);
    a           = whos('X');
    ftype       = a.class;
    k           = gmm.k;
    
    
    % Compute the range of X
    dmin        = min(X,[],2);
    dmax        = max(X,[],2);
    drange      = dmax-dmin;
    
    % Set mean (rand), var (pre-defined based on range) and weights (1/k)
    M           = rand(rs,d,k,ftype);
    M           = bsxfun(@times,M,drange);
    gmm.mean    = bsxfun(@plus,M,dmin);
    gmm.var     = repmat(max(drange.^2 * .1,var_flr),1,k);
    gmm.weight  = normalize(ones(1,k,ftype));
end
