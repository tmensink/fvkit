function [P, logl,S] = gmm_expectation(gmm,X,Xs,kConst,iC,MinvC)
    % GMM EM - compute the expectation step
    % assumes diagonal covariance matrices
    %
    % Input
    %   gmm         struct
    %       mean    [d x k]     component means
    %       var     [d x k]     diagonal variances
    %       weight  [1 x k]     weight vectors
    %   X           [d x n]     feature matrix
    %   Xs          [d x n]     feature matrix with squared features (optional)
    %   kConst      [1 x k]     Constant value per component depending on mean, weights and var
    %                           (optional, see gmm_precompute)
    %
    % Output
    %   P   [k x n]         responsibility values
    %   logl scalar         log likelihood
    %
    %
    % See also: gmm_precompute
    %
    % Written by Thomas Mensink
    % April 2013, University of Amsterdam
    % (c) 2013
    
    if nargin < 3 || isempty(Xs),       Xs      = X.^2;                     end
    if nargin < 6 || isempty(kConst) || isempty(iC) || isempty(MinvC),
        [kConst,iC,MinvC]  = gmm_precompute(gmm);
    end
    
    %% Compute the distance in the exponents:
    P       = MinvC' * X - .5 * iC' * Xs;
    S       = bsxfun(@plus,P,kConst');
    
    % Normalize using the softmax function
    [P, logl] = softmax(S,1);
    logl      = mean(logl);
        
end
