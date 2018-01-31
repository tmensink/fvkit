function pcode = pool_img(Xdesc,Xloc,Xsize,gmm,encOpts)
    % Fisher Vector function -- computes Fisher Vectors on [1x1,3x1] and normalizations
    %
    % This function computes the Fisher Vector image representation
    % It makes use of spatial pooling, and computes a FV for the whole
    % image (F), for three horizontal stripes (H), and/or for the four quadrants (Q).
    % This options is set in enc.fv.opts.pool = 'FHQ';
    %
    % Afterwards it applies the generalized squareroot normalisation and
    % the l2 normalisation, see [1] for details.
    %
    % Inputs
    %   Xdesc   [d x t]     local features, projected if necessary
    %   Xloc    [4 x t]     location of the features
    %   Xsize   [2 x 1]     image width and height
    %   gmm     struct      Structure
    %   encOpts struct      Options for the Fisher Vector extraction
    %
    % Output
    %   pcode   [cD x 1]    Fisher Vectors for the different regions, each a D dimensional vector
    %                       (see enc.fv.opts.nrDim). Returns and empty vector if Xdesc is empty
    %                       c depends on enc.fv.opts.pool, eg FH => c=4, or FHQ => c=8.
    %
    % References
    % [1]   Large-Scale Image Classification with Compressed Fisher Vectors
    %       Jorge Sanchez - Florent Perronnin - Thomas Mensink - Jakob Verbeek
    %       IJCV, 2013
    %
    % Part of FVKit - initial release
    % Copyright, 2013-2018
    % Thomas Mensink, University of Amsterdam
    % thomas.mensink@uva.nl
    
    if isempty(Xdesc),  pcode = []; return;     end
    
    if nargin < 5 || isempty(Xsize) || isempty(gmm) || isempty(encOpts)
        error('%s requires 5 inputs -- see help',mfilename);
    end
    
    fvo         =   encOpts.fv.opts;
    fvi         =   fvo.pfuncinit(gmm,fvo,Xdesc);
    
    
    %% Compute the FVs
    pcode           = cell(1,encOpts.pool.NrFV);
    bcount          = 0;
    
    if encOpts.pool.pyr.doQuad,
        %% Extract 4 Fisher Vectors for each of the quadrants
        hMsk        = Xloc(2,:) > .5;
        vMsk        = Xloc(1,:) > .5;
        nrQbin      = zeros(1,4);
        for q=1:4,
            if q == 1,      msk = hMsk == 0 & vMsk == 0;
            elseif q == 2,  msk = hMsk == 0 & vMsk == 1;
            elseif q == 3,  msk = hMsk == 1 & vMsk == 0;
            else            msk = hMsk == 1 & vMsk == 1;
            end
            
            nrQbin(q)           = sum(msk);
            pcode{q+bcount}     = fvo.pfunc(gmm,fvo,fvi,Xdesc,msk);
        end
        bcount = 4;
    end
    
    if encOpts.pool.pyr.doHorz,
        %% Extract 3 Fisher Vectors for each of the three stripes
        hStripes    = 3;
        hUnit       = 1/hStripes;
        hYbin       = ceil(Xloc(2,:) / hUnit);
        nrYbin      = zeros(1,hStripes);
        
        for h = 1:hStripes,
            msk                 = hYbin == h;
            
            nrYbin(h)           = sum(msk);
            pcode{h+bcount}     = fvo.pfunc(gmm,fvo,fvi,Xdesc,msk);
        end
    end
    
    if encOpts.pool.pyr.doFull,
        %% Compute the image signature for the whole image
        pcode{end}      = fvo.pfunc(gmm,fvo,fvi,Xdesc,[]);
    end
    
    pcode               = single(cat(2,pcode{:}));
    
    %% Do hellinger embedding / generalized square root
    if encOpts.pool.norm.pown > 0,
        pcode           = sign(pcode) .* ( abs(pcode).^encOpts.pool.norm.pown);
    end
    
    %% l2 normalize each subvector
    if encOpts.pool.norm.l2sub,
        pcode_norm      = sqrt(sum(pcode .^ 2, 1));
        pcode_norm      = max(pcode_norm, eps);
        pcode           = bsxfun(@times, pcode, 1 ./ pcode_norm);
    end
    
    %% create a single vector
    pcode           = pcode(:);
    
    %% l2 normalize the final vector
    if encOpts.pool.norm.l2fin,
        l2norm          = 1./sqrt(sum(pcode.^2));
        pcode           = l2norm * pcode;
    end
end
