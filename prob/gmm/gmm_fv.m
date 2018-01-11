function fv = gmm_fv(gmm,fvopts,fvinit,X,Msk)
    % Fisher Vector function - computes the FV of the set of samples X, given a gaussian mixture model (gmm) structure
    %
    % Input
    % X         [d x t]     matrix of t observations of dimension d
    % Xs        [d x t]     matrix of t observations of dimension d - squared!
    % gmm                   struct with the Mixture of Gaussians model
    %   .mean   [d x k]         mean matrix
    %   .var    [d x k]         variance matrix (diagonal variance is assumed)
    %   .weight [1 x k]         weight vector
    % fvopts                option structure
    %   .gWeight    {false} |  true
    %   .gMean       false  | {true}
    %   .gVar        false  | {true}
    %
    % References
    % [1]   Large-Scale Image Classification with Compressed Fisher Vectors
    %       Jorge Sanchez - Florent Perronnin - Thomas Mensink - Jakob Verbeek
    %       Submitted to IJCV, january 2013
    %
    % Written by Thomas Mensink
    % January 2013, University of Amsterdam
    % (c) 2013
    
    %% If X is empty, return zero vector
    if isempty(X),                      fv      = zeros(fvopts.nrDim,1);  return;           end
    
    if isempty(Msk),
        Xs      = fvinit.Xs;
        R       = fvinit.R;
    else
        X       = X(:,Msk);
        Xs      = fvinit.Xs(:,Msk);
        R       = fvinit.R(:,Msk);
    end
    
    sW          = fvinit.sW;
    sC          = fvinit.sC;
    sqM         = fvinit.sqM;
    
    %% Some sizes we need to now
    nrX = size(X,2);
    
    
    if strcmp(fvopts.FIM, 'CFA'),
        Nw      = 1./sW;
        Nm      = bsxfun(@rdivide, sC, sW);
        Nv      =  Nm / sqrt(2);
    elseif strcmp(fvopts.FIM,'ID'),
        Nw = 1; Nm=1; Nv=1;
    else error('Incorrect FIM approx');
    end
    
    %% Compute the sufficient statistics S0, S1 and S2.
    S0 = sum(R,2)';
    if fvopts.gMean || fvopts.gVar, S1 = X * R';        end
    if fvopts.gVar,                 S2 = Xs* R';        end
    
    %% Compute the Fisher Vectors and concatenate into a single vector
    fv = [];
    
    %With respect to the weight
    if fvopts.gWeight,
        FVw = (S0 - nrX*gmm.weight).*Nw;
        fv  = FVw(:);
    end
    
    %With respect to the mean
    if fvopts.gMean,
        M   = bsxfun(@times,gmm.mean,S0);
        FVm = ((S1 - M) ./ gmm.var) .*Nm;
        fv  = [fv; FVm(:)];
    end
    
    %With respect to the variance
    if fvopts.gVar,
        M   = S2 - 2 * gmm.mean .* S1 + bsxfun(@times, ( sqM - gmm.var ), S0);
        S   = bsxfun(@times,sC,gmm.var);
        FVv = (M ./ S) .*Nv;
        fv  = [fv; FVv(:)];
    end
        
    iNrX = 1/nrX;
    fv   = fv * iNrX;
end