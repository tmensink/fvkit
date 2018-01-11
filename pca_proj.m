function pcafeat = pca_proj(encOpts,pca,feat)
    %Compute PCA projection of features

    if ~encOpts.pca.doPca,pcafeat = feat;return;                        end    
    if nargin < 2 || isempty(pca),pca     = enc_computepca(encOpts);    end
    
    pcafeat = pca.V * feat;    
end