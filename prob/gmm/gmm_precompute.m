function [kConst, iC, MinvC]   = gmm_precompute(gmm)
    % Pre computes some variables used in gmm expectation
    % These are independent of the feature vectors X and therefore need to compute only once for a
    % mean, var, and weight
    %
    %
    % Part of FVKit - initial release
    % Copyright, 2013-2018
    % Thomas Mensink, University of Amsterdam
    % thomas.mensink@uva.nl
    
    d       = size(gmm.mean,1);
    dConst  = .5*d*log(2*pi);               % scalar    normalisation by dimensions
    
    
    LogW    = log(gmm.weight);              % 1 x k     log of weigh parameters
    
    logDetC = .5 * sum(log(gmm.var),1);     % 1 x k     log of determinant of C
    iC      = 1./gmm.var;                   % d x k     inverse covariance
    
    MinvC   = gmm.mean .* iC;               % d x k     mean weighted with covariance
    MuDst   = .5 * sum(gmm.mean .* MinvC,1);% 1 x k     norm of means (with covariance)
    
    % 1 x k     Constant value per component
    kConst  = LogW - dConst - logDetC - MuDst;
end