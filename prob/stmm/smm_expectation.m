function [ tau, u, f, logl, mDist ] = smm_expectation( smm, X, Xs)
    % SMM EM - computes the expectation step
    % assumes diagona covariance matrix
    %
    % Input
    %   X           [d x n]     feature matrix
    %   smm         struct
    %       params  struct
    %       mean    [d x k]     component means
    %       var     [d x k]     diagonal variances
    %       weight  [1 x k]     weight vectors
    %       nu      [1 x k]     nu vectors
    %
    % Output
    %   tau         [k x n]     responsibility values
    %   u           [k x n]     expectation of the prior
    %   f           [k x n]     The likelyhood of a datapoint under each
    %                           Student-t component.
    %   logl        scalar      Loglikelyhood of the data under the SMM
    %   mDist       [k x n]     Distance of all datapoints to means
    %                           of all components (scalled with variance)
    %
    %
    % Written by Markus Nagel
    % March 2015, University of Amsterdam
    % (c) 2015
    keyboard
    d       = size(X,1);
    constLn   = gammaln( (smm.nu + d) ./ 2 ) - .5*log(pi .* smm.nu) - gammaln(smm.nu/2);
    
    detSigLn  = sum(log(smm.var),1);
    
    iC      = double(1./ smm.var);

    MinvC   = double(smm.mean .* iC);
    MuDst   = double(sum(smm.mean .* MinvC,1));    
    mDist   = bsxfun(@plus,double(iC'* Xs) - double(2* MinvC') * X, MuDst');
    
%     % NOTE: this is slower, but numerical more stable!
%     mDist   = zeros(smm.k, size(X,2));
%     for i=1:smm.k
%         Xzero           = bsxfun(@minus,X ,smm.mean(:,i));
%         mDist(i,:)      = iC(:,i)' * (Xzero.^2);
%     end
%     
    weightedDistLn    = bsxfun(@times, log(1 + bsxfun(@times,mDist,1./smm.nu')), .5*(smm.nu' + d));
    
    termLn  = constLn - .5 * detSigLn;
    fLn     = bsxfun(@minus, termLn', weightedDistLn);
    f       = exp(fLn);
    % weight according to mixture model
    Pln       = bsxfun(@plus, fLn, log(smm.weight'));
    
    % prior from temporal model
    if isfield(smm,'lnprior')
        Pln     = Pln + smm.lnprior;
    end
    
    % Do softmax
    [tau, logl] = softmax(Pln,1);
    logl        = mean(double(logl));
    
    % calculate u_ij = (nu + d) / (nu + mDist)
    u       = bsxfun(@times, (smm.nu' + d), 1./ bsxfun(@plus, smm.nu', mDist));
    
end

