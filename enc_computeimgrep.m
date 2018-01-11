function enc_computeimgrep(encOpts)
    if encOpts.fv.extract == 1,                
        fnames                  = fieldnames(encOpts.imdb.sets);
        
        msk = false(size(fnames));
        for f=1:numel(fnames), msk(f) = encOpts.imdb.sets.(fnames{f}) <= 0; end;
        fnames(msk) = [];    

        for i=1:numel(fnames),
            setname     = fnames{i};
            setval      = encOpts.imdb.sets.(setname);
            setfile     = sprintf('%s/%s_%s.mat',encOpts.pool.path,encOpts.pool.name,setname);            
            setfileLock = [setfile '.lock'];
            fprintf('\t --> enco \t%s\n',setfile);
            if exist(setfile,'file') ~= 2 && exist(setfileLock,'file') ~= 2,
                touch(setfileLock);
                msk     = encOpts.imdb.images.set == setval;
                imglist = encOpts.imdb.images.name(msk);                                
                
                [X, Xn] = enc_fvextract_imglist(imglist,encOpts);
                
                fprintf('\t --> X   [%8d x %8d]\n',size(X));
                fprintf('\t --> Xn  [%8d x %8d]\n',size(Xn));
                save(setfile,'-v7.3','X','Xn');
                fprintf('\t --> saved!\n');
                delete(setfileLock);
            end
        end
    end
    
    
    function [X, Xn] = enc_fvextract_imglist(imglist,encOpts)
        if ~iscell(imglist), tmp=imglist; imglist = cell(1); imglist{1} = tmp;  end
        
        % Set the correct max number of features
        encOpts.llf.max_feat = encOpts.llf.max_feat_fin;
        
        nrI     = numel(imglist);        
        X       = cell(1,nrI);
        Xn      = zeros(3,nrI,'int32');
        
        % Get PCA and GMM
        pca     = enc_computepca(encOpts);
        gmm     = enc_computegmm(encOpts);
        
        
        fprintf('\t--> %10d | FV for img %10d',nrI,0);
        for j=1:numel(imglist)
            fprintf('\b\b\b\b\b\b\b\b\b\b%10d',j);
            % Extrac Low level features
            
            [Xdesc, Xloc, Xnum, Xsize] = llf_extract(imglist{j},encOpts.llf,encOpts.path.dataset);
            feat    = pca_addLocScale(encOpts,Xdesc,Xloc);
            feat    = pca_proj(encOpts,pca,feat);
            X{j}    = encOpts.pool.pfunc(feat,Xloc,Xsize,gmm,encOpts);
            Xn(:,j) = Xnum;
        end
        fprintf('| DONE!!!\n');
        X   = cat(2,X{:});
    end
end
