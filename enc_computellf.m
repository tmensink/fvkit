function [Xdesc, Xloc, Xnum, Xsize] = enc_computellf(encOpts)
    %Compute a sample of the descriptors for training PCA and GMM etc
    
    llff                    = encOpts.llf.file;
    if exist(llff,'file') ~= 2,
        fversion(.21);
        fprintf('Compute llf \t%s\n',llff);
        
        % Set mask for train and validation set
        if isfield(encOpts.imdb.sets,'VAL'),
            msk               = encOpts.imdb.images.set == encOpts.imdb.sets.('TRAIN') | encOpts.imdb.images.set == encOpts.imdb.sets.('VAL');
        else
            msk               = encOpts.imdb.images.set == encOpts.imdb.sets.('TRAIN');
        end
        imglist             = encOpts.imdb.images.name(msk);
        
        [Xdesc, Xloc, Xnum, Xsize] = llf_extract(imglist,encOpts.llf,encOpts.path.dataset);
        d = whos('Xdesc');
        fprintf('Xdesc = [%8d x %8d] | type %10s | size %10dGB\n',d.size,d.class,d.bytes/1024^3);
        fprintf('Xnum  = [%8d x %8d] | min / max / mean 1 %d / %d / %f | min / max / mean 2 %d / %d / %f',size(Xnum),min(Xnum(1,:)),max(Xnum(1,:)),mean(Xnum(1,:)),min(Xnum(2,:)),max(Xnum(2,:)),mean(Xnum(2,:)));
        fprintf('Xloc  = [%8d x %8d]\n',size(Xloc));
        fprintf('Xsize = [%8d x %8d]\n',size(Xsize));
        
        assert(isnumeric(Xdesc),'%s -- Xdesc is not numeric',mfilename);
        assert(ismatrix(Xdesc),'%s -- Xdesc is not a matrix',mfilename);
        
        save(llff,'X*','encOpts','-v7.3');
    elseif nargout >= 1,
        load(llff);
    end
end