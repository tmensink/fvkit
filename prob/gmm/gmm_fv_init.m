function fv_init = gmm_fv_init(gmm,fvopts,Xdesc)
    % FV initialisations
    %
    % Part of FVKit - initial release
    % Copyright, 2013-2018
    % Thomas Mensink, University of Amsterdam
    % thomas.mensink@uva.nl
    
    Xs              = Xdesc.^2;
    R               = gmm_expectation(gmm,Xdesc,Xs);
    
    if fvopts.sparse > 0,
        [~,inx]     = sort(R,1,'descend');
        nrK         = gmm.k;
        inx         = bsxfun(@plus,inx(fvopts.sparse+1:end,:),0:nrK:(nrK*nrX - 1));
        R(inx)      = 0;
    else
        thr = 1e-4;
        R(R < thr)  = 0;
    end
    
    fv_init.Xs      = Xs;
    fv_init.R       = R;
    
    %% Some variables
    fv_init.sW      = sqrt(gmm.weight);
    fv_init.sC      = sqrt(gmm.var);
    fv_init.sqM     = gmm.mean.^2;
end
