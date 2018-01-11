function [ smm ] = smm_maximization(tau, u, X, Xs, smm)
    % SMM EM - computes the maximization step
    % assumes diagona covariance matrix
    %
    % Input
    %   tau         [k x n]     responsibility values
    %   u           [k x n]     expectation of the prior
    %   X           [d x n]     feature matrix
    %   Xs          [d x n]     feature matrix with squared features
    %   smm         struct
    %       params  struct
    %       mean    [d x k]     component means
    %       var     [d x k]     diagonal variances
    %       weight  [1 x k]     weight vectors
    %       nu      [1 x k]     nu vectors
    %
    % Output
    %   W   [1 x k]     weight vectors
    %   nu  [1 x k]     nu vectors
    %   M   [d x k]     component means
    %   C   [d x k]     diagonal variances
    %
    %
    % Written by Markus Nagel
    % March 2015, University of Amsterdam
    % (c) 2015
    
    if nargin < 3 || isempty(Xs),                               Xs          = X.^2;         end
    
    %Set parameters
    smmMinPost      = 1e-4; %gmm.params.MinPost;
    smmWeightPrior  = 1;  %gmm.params.WeightPrior;
    smmMinTau       = 1e-4; %gmm.params.MinGamma;
    NrX             = size(X,2);
    NrK             = size(tau,1);
    varFloor        = 1e-4;
    
    % calculate statistics
    sTau            = sum(tau,2)';
    tau(tau<smmMinTau) = 0;
    tauu            = tau .* u;
    
    sTauU           = sum(tauu,2)';
    S1              = double(X  * (tauu)');
    S2              = double(Xs  * (tauu)');
    
    
    M               = bsxfun(@times, S1, 1./sTauU);
    
    C               = bsxfun(@times,S2,1./sTauU) - M.^2;
%     % this is numerical more stable (especially if the variance gets close to zero)
%     C               = zeros(size(M));
%     for i=1:smm.k
%         Xzero       = bsxfun(@minus,X ,M(:,i));
%         C(:,i)      = ((Xzero.^2) * tauu(i,:)') /sTauU(i);
%     end
%    C               = bsxfun(@max,C,varFloor);
             
    msk             = sTau > (smmMinPost * NrX);                    % Check for a minimum of posterior
    smm.mean(:,msk) = M(:,msk);
    smm.var(:,msk)  = C(:,msk);
    smm.weight      = normalize(sTau + (smmWeightPrior*NrX/NrK));       % Add a dirichlet prior
    
    smm.var         = bsxfun(@max,smm.var,varFloor);     
end
