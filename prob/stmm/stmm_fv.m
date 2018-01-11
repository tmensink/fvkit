function fv = stmm_fv(smm,fvopts,fvinit,X,Msk)    
    % Fisher Vector function - computes the FV of the set of samples X, given a gaussian mixture model (smm) structure
    %
    % Input
    % X         [d x t]     matrix of t observations of dimension d
    % Xs        [d x t]     matrix of t observations of dimension d - squared!
    % smm                   struct with the Mixture of Gaussians model
    %   .mean   [d x k]         mean matrix
    %   .var    [d x k]         variance matrix (diagonal variance is assumed)
    %   .weight [1 x k]         weight vector
    % fvopts                option structure
    %   .gWeight    {false} |  true
    %   .gMean       false  | {true}
    %   .gVar        false  | {true}
    % R         []          is a dummy to make it compatible with gmm interface
    %
    % Written by Markus Nagel
    % March 2015, University of Amsterdam
    % (c) 2015
    
    %% If X is empty, return zero vector
    if isempty(X),                      fv      = zeros(fvopts.nrDim,1);  return;           end
    
    if isempty(Msk),        
        R       = fvinit.R;
    else
        X       = X(:,Msk);        
        R       = fvinit.R(:,Msk);
    end
    
    sW          = fvinit.sW;
    sC          = fvinit.sC;
        
    %% Some sizes we need to now
    nrX = size(X,2);
    nrD = size(X,1);
    nrK = smm.k;
    
    %% Compute the sufficient statistics S0, S1 and S2.    
    S0      = sum(R,2)';
    S1      = zeros(nrD, nrK);
    S2      = zeros(nrD, nrK);
    iC      = double(1./ smm.var);
    for i=1:nrK
        Xzero           = bsxfun(@minus,X ,smm.mean(:,i));
        sqXzero         = (Xzero.^2);
        mDist           = iC(:,i)' * sqXzero;
        denom           = 1 + (mDist / smm.nu(i));
        S1(:,i)         = Xzero * (R(i,:) ./ denom)';
        S2(:,i)         = sqXzero * (R(i,:) ./ denom)';
    end
    
    %% Compute the Fisher Vectors and concatenate into a single vector
    fv = [];
    
    if strcmp(fvopts.FIM, 'CFA')
        Nw      = 1./sW;
        Nm      = bsxfun(@rdivide, sC, sW);
        Nv      =  Nm / sqrt(2);
    elseif strcmp(fvopts.FIM,'ID'),
        Nw = 1; Nm=1; Nv=1;
    else
        error('No exisiting FIM approximation selected');        
    end
    
    %With respect to the weight
    if fvopts.gWeight,
        FVw = (S0 - nrX*smm.weight) .*Nw;
        fv  = FVw(:);
    end
    
    %With respect to the mean
    if fvopts.gMean,        
        sc  = (smm.nu + nrD) ./ smm.nu;
        FVm = bsxfun(@times, sc, S1 ./ smm.var) .* Nm;
        fv  = [fv; FVm(:)];
    end
    
    %With respect to the variance
    if fvopts.gVar,
        sc  = (smm.nu + nrD) ./ smm.nu;
        FVv = bsxfun(@times, sc, S2 ./ smm.var);
        FVv = (bsxfun(@minus, FVv, S0) ./ sC) .* Nv;
        fv  = [fv; FVv(:)];
    end
            
    iNrX = 1/nrX;
    fv   = fv * iNrX;      
end
