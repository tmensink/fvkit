function [ smm ] = smm_init( smm, X )
%SMM_INIT Summary of this function goes here
%   Detailed explanation goes here
    
    var_flr     = 0.01;
    rs          = RandStream.create('mt19937ar','seed',smm.params.Seed);    
    d           = size(X,1);    
    a           = whos('X');
    ftype       = a.class;
    k           = smm.params.k;


    % Compute the range of X
    dmin        = min(X,[],2);
    dmax        = max(X,[],2);
    drange      = dmax-dmin;
    
    % Set mean (rand), var (pre-defined based on range) and weights (1/k)
    M           = rand(rs,d,k,ftype);
    M           = bsxfun(@times,M,drange);
    smm.mean    = bsxfun(@plus,M,dmin);
    smm.var     = repmat(max(drange.^2 * .1,var_flr),1,k);
    smm.weight  = normalize(ones(1,k,ftype));    
    
    smm.nu      = ones(1,k,ftype) * smm.params.nu;
end

