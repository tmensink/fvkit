function [clac, clai, det] = eval_classacc(Pred, GT)
    % Computes the average class accuracy of prediction and groundtruth
    %
    % Input
    %   Pred    [N x Q]     Predictions for N documents for Q queries
    %   Gt      [N x Q]     Binary GT indicating relevance (1) or non-relevance (0)
    %
    % Output
    %   clac    scalar      Class accuracy averaged per class
    %   clai    scalar      Class accuracy averaged over all images
    %   det     struct      Detailed results
                   
    NrN = size(Pred,1);
    NrQ = size(Pred,2);
    assert(NrQ == size(GT,2));
    
    [Pval, Pinx]    = max(Pred,[],2);
    [I,L]           = find(GT > 0);   %Assumes a single label
        
    if numel(I) ~= NrN || ~all(I == (1:NrN)'),
        [msk,inx]   = ismember(1:NrN,I);
        if all(msk),
          L           = L(inx);               %Selects a single label
        else,
          clac = 0; clai = 0; det = struct();
          return
        end
    end
    
    GG      = Pinx == L;
    Gclass  = accumarray(L,GG);
    Nclass  = histc(L,unique(L));
    
    clai    = mean(GG);
    clac    = mean( Gclass ./ Nclass );
    
    det.Pval= Pval;
    det.Pinx= Pinx;
    det.I   = I;
    det.L   = L;
    det.GG  = GG;
    det.Gcl = Gclass;
    det.Ncl = Nclass;       
end
