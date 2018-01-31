function pcafeat = pca_proj(encOpts,pca,feat,loc)
    %Compute PCA projection of features
    %
    % Part of FVKit - initial release
    % Copyright, 2013-2018
    % Thomas Mensink, University of Amsterdam
    % thomas.mensink@uva.nl
    
    if ~encOpts.pca.doPca,pcafeat = feat;return;                        end
    if nargin < 2 || isempty(pca),pca     = enc_computepca(encOpts);    end
    
    pcafeat = pca.V * feat;
    pcafeat = pca_addLocScale(encOpts,pcafeat,loc);
end