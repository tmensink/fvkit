function pco = pca_opts(pco,enc)
    
    if ~isfield(pco,'doPca'),       pco.doPca           = 1;                end    
    if ~isfield(pco,'pdim'),        pco.pdim            = 64;               end
    if ~isfield(pco,'addLoc'),      pco.addLoc          = 1;                end
    if ~isfield(pco,'addNorm'),     pco.addNorm         = 1;                end
    if ~isfield(pco,'addScale'),    pco.addScale        = 1;                end
    
    pco.mdim    = enc.llf.(enc.llf.feat).out_dim + 2*pco.addLoc + pco.addNorm + pco.addScale;
        
    if pco.pdim == 0, pco.doPca = 0;            end
    if pco.doPca == 0, pco.pdim = pco.mdim;     end
    
    
    
    pco.path  = sprintf('%s/%s',enc.llf.path,enc.llf.name);
    
    if pco.doPca,
        str       = 'LNS';        
        pco.name  = sprintf('pca_D%04d%s',pco.pdim,['_' str([pco.addLoc pco.addNorm pco.addScale] == 1)]);
        pco.mname = sprintf('pca_D%04d%s',pco.mdim,['_' str([pco.addLoc pco.addNorm pco.addScale] == 1)]);
        pco.mfile = sprintf('%s/%s.mat',pco.path,pco.mname);
    else
        pco.name  = 'pca_no';
    end
    pco.file  = sprintf('%s/%s.mat',pco.path,pco.name);
