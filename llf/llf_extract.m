function [Xdesc, Xloc, Xnum, Xsize] = llf_extract(imglist,llfOpts,path)
    %Encoder function -- extract low level features (default SIFT)
    %
    % Part of FVKit - initial release
    % Copyright, 2013-2018
    % Thomas Mensink, University of Amsterdam
    % thomas.mensink@uva.nl
    
    if nargin < 3 || isempty(path), path = [];  end
    
    if ~iscell(imglist),     % We extract features from a single image
        [Xdesc, Xloc, Xnum, Xsize] = llf_extractlowlevelfeatures(fullfile(path,imglist),llfOpts);
    else                     % We extract features from a list of images
        nrImg   = numel(imglist);
        Xdesc   = cell(1,nrImg);
        Xloc    = cell(1,nrImg);
        Xnum    = zeros(3,nrImg,'int32');
        Xsize   = zeros(2,nrImg,'int16');
        
        fprintf('Extract features from %d img: %6d',nrImg,0);
        for ii=1:nrImg,
            fprintf('\b\b\b\b\b\b%6d',ii);
            [Xdesc{ii}, Xloc{ii}, Xnum(:,ii), Xsize(:,ii)] = llf_extractlowlevelfeatures(fullfile(path,imglist{ii}),llfOpts);
        end
        fprintf('--> Done!\n');
        
        Xdesc   = cat(2, Xdesc{:});
        Xloc    = cat(2, Xloc{:});
    end
    
    
    function [Idesc, Iloc, Inum, Isize] = llf_extractlowlevelfeatures(jpgfile,llfOpts)
        switch llfOpts.feat
            case 'dsift'
                [Iloc,Idesc,Isize] = llf_dsift(jpgfile,llfOpts.dsift);
        end
        
        Iloc            = single(Iloc);
        Idesc           = single(Idesc);
        msk             = sum(Idesc,1) == 0;
        Inum            = [0; sum(msk); numel(msk)];
        
        if size(Idesc,2) == 0,      Inum(1) = 0;        return;             end
        
        if llfOpts.max_feat > 0,
            if llfOpts.max_feat < 1,    %Assume it is a fraction of the number of features
                num     = max(round(size(Idesc,2) * llfOpts.max_feat),1);
            else                            %Absolute number
                num     = llfOpts.max_feat;
            end
            
            if num < size(Idesc,2),
                perm    = randperm(llfOpts.max_feat_rs,size(Idesc,2));
                perm    = sort(perm(1:num));
                Idesc   = Idesc(:,perm);
                Iloc    = Iloc( :,perm);
            end
        end
        Inum(1)         = int32(size(Iloc,2));
    end
    
end
