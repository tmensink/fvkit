function gmm = gmm_maximization(P,X,Xs,gmm)
    % GMM EM - computes the maximization step
    % assumes diagona covariance matrix
    %
    % Input
    %   P           [k x n]     responsibility values
    %   X           [d x n]     feature matrix
    %   Xs          [d x n]     feature matrix with squared features
    %   gmm         struct
    %       params  struct
    %       mean    [d x k]     component means
    %       var     [d x k]     diagonal variances
    %       weight  [1 x k]     weight vectors
    
    %
    % Output
    %   W   [1 x k]     weight vectors
    %   M   [d x k]     component means
    %   C   [d x k]     diagonal variances
    %
    %    
    % Written by Thomas Mensink
    % April 2013, University of Amsterdam
    % (c) 2013
    
    if nargin < 3 || isempty(Xs),                               Xs          = X.^2;         end
    if nargin < 4 || isempty(gmm) || ~isfield(gmm,'params'),    gmm.params  = gmm_opts;     end
    
    %Set parameters
    gmmMinPost      = gmm.params.MinPost;
    gmmWeightPrior  = gmm.params.WeightPrior;
    gmmMinGamma     = gmm.params.MinGamma; 
    gmmVarFloor     = gmm.params.VarFloor;
    NrX             = size(X,2);
        
    
    S0              = sum(P,2)';        
    P(P<gmmMinGamma)= 0;            
    S1              = X  * P';
    S2              = Xs * P';
                         
    M               = bsxfun(@times,S1,1./S0);    
    C               = bsxfun(@times,S2,1./S0) - M.^2;                    
    C               = bsxfun(@max,C,gmmVarFloor);
        
    msk             = S0 > gmmMinPost * NrX;                    % Check for a minimum of posterior            
    gmm.mean(:,msk) = M(:,msk);
    gmm.var(:,msk)  = C(:,msk);            
    gmm.weight      = normalize(S0 + gmmWeightPrior*NrX);       % Add a dirichlet prior        
    gmm.det.msk     = msk;
    
    if ~all(msk),   fprintf('|Upd %d comp|',sum(msk));      end     
end
