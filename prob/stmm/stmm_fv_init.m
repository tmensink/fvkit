function fv_init = stmm_fv_init(gmm,fvopts,Xdesc)
    
    Xs      = Xdesc.^2;
    
    %Rather ugly, but for now ok:
    if isfield(gmm,'trans'),
        gmm.weight  = gmm.prior';
        tau         = smm_expectation( gmm, Xdesc, Xs);
        [alpha, beta, gamma, current_loglik, xi_summed] = fwdback(gmm.prior, gmm.trans, tau);        
        R           = gamma;        
    else        
        R               = smm_expectation(gmm,Xdesc, Xs);
    end
    
    if fvopts.sparse > 0,
        [~,inx]     = sort(R,1,'descend');
        nrK         = gmm.k;
        inx         = bsxfun(@plus,inx(fvopts.sparse+1:end,:),0:nrK:(nrK*nrX - 1));        
        R(inx)      = 0;        
    else
        thr = 1e-4;
        R(R < thr)  = 0;
    end    
        
    fv_init.R       = R;    
    
    %% Some variables
    fv_init.sW      = sqrt(gmm.weight);
    fv_init.sC      = sqrt(gmm.var);    
end
