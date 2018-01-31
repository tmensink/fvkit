function pca = enc_computepca(encOpts)
    % Compute PCA projection
    %
    % Part of FVKit - initial release
    % Copyright, 2013-2018
    % Thomas Mensink, University of Amsterdam
    % thomas.mensink@uva.nl
    
    
    if encOpts.pca.doPca    == 0,
        pca = [];
    else
        pcaf                    = encOpts.pca.file;
        if exist(pcaf,'file') ~=2,
            fversion(.21);
            fprintf('Compute pca \t%s\n',pcaf);
            
            pcaff   = encOpts.pca.mfile;
            if exist(pcaff,'file') == 2,
                load(pcaff)
            else
                
                [Xdesc, ~]  = enc_computellf(encOpts);
                feat = Xdesc;
                clear Xdesc
                
                %% Make the feature matrix double precision
                % This yields more stable results when using matlab functions like eigenvalue decomposition
                feat = double(feat);
                
                %% Do the actual PCA computation
                % We compute once the PCA off the full dimensionality
                % Taken in part from the mypca file from Jakob Verbeek
                [fDim, N] = size(feat);
                fprintf('Performing PCA in Full dimensions (%d dim)\n',fDim);
                
                %%% HERE
                M       = mean(feat,2);
                feat    = bsxfun(@minus,feat,M);      %Zero mean data
                
                %By design mDim = fDim, therefor this is the fastest:
                [V,D]   = eig(feat*feat');
                %Otherwise (ie if mDim<fDim), this would have been an option:
                %options.disp=0;[V,D]   =eigs(feat*feat',[],k,'lm',options);
                
                %Sort eigenvalues
                [D,I]       = sort(diag(D),'descend');
                V           = V(:,I);
                
                pca.M       = M;
                pca.V       = V';
                pca.D       = D/N;
                pca.dim     = fDim;
                
                save(pcaff,'pca');
            end
            
            %Just select the first pDim pca values
            k           = encOpts.pca.Pdim;
            pca.M       = pca.M(1:k);
            pca.V       = pca.V(1:k,:);
            pca.D       = pca.D(1:k);
            pca.dim     = k;
            save(pcaf,'pca');
        elseif nargout >= 1,
            load(pcaf)
        end
    end
end