function gmm = enc_computegmm(encOpts)
    % Encoder function -- Computes the Gaussian Mixture Model parameters from a set of features
    %
    % This function either uses the Split-EM (see gmm_splitem [1]), or it uses the EM implementation of
    % the gmm-fisher package provided in the software of Chatfield et al., see for more information [2].
    %
    % Input
    %  feat
    %  encOpts      struct                  contains the options, seen enc_encOpts;
    %
    %  Output
    %   gmm         struct
    %    .var       [d x k]     matrix      the diagonal variances of each component
    %    .mean      [d x k]     matrix      the component means
    %    .weight    [1 x k]     vector      the component weights
    %    .logl      [1 x iter]  vector      the history of the loglikelihood values
    %
    %
    % References
    % [1]   Large-Scale Image Classification with Compressed Fisher Vectors
    %       Jorge Sanchez - Florent Perronnin - Thomas Mensink - Jakob Verbeek
    %       Submitted to IJCV, january 2013
    %
    % [2]   The devil is in the details: an evaluation of recent feature encoding methods
    %       K. Chatfield, V. Lempitsky, A. Vedaldi, A. Zisserman
    %       British Machine Vision Conference, 2011
    %
    %
    % Part of FVKit - initial release
    % Copyright, 2013-2018
    % Thomas Mensink, University of Amsterdam
    % thomas.mensink@uva.nl
    mixfn           = encOpts.prob.file;
    
    if exist(mixfn,'file') ~= 2,
        fversion(.21);
        fprintf('\t--> Create file %s\n',mixfn);
        
        %% Load the input features
        
        [Xdesc,Xloc]= enc_computellf(encOpts);
        pca         = enc_computepca(encOpts);
        Xfeat       = pca_proj(encOpts,pca,Xdesc,Xloc);
        clear Xdesc
        
        %% Do the actual GMM computation
        fprintf('Select EM Method\n');
        emf         = str2func([encOpts.prob.base, '_', encOpts.prob.method]);
        gmm         = emf(Xfeat,Xloc,encOpts.prob);
        
        %Below are for legecy reasons, currently not in use
        %elseif strcmp(encOpts.gmm.method,'em'),
        %    emf                 = str2func([encOpts.gmm.base, '_', encOpts.gmm.method]);
        %    gmm                 = emf(feat,encOpts.gmm);
        %Below are for legecy reasons, currently not in use
        %         elseif strcmp(gmmOpts.method,'rndemi'),
        %             [f,n,~]             = fileparts(enc_getName('gmm-file',encOpts,struct('iter',-1)));
        %             gmm.params.MaxIter  = 50;
        %             gmm.params.Name     = [f '/' n '_%04di.mat'];
        %             gmm                 = gmm_em(gmm,feat);
        %         elseif strcmp(gmmOpts.method,'rndinit'),
        %             gmm.params.MaxIter  = 0;
        %             gmm                 = gmm_em(gmm,feat);
        %         elseif strcmp(gmmOpts.method,'yaelem'),
        %             addpath(gmmOpts.yaelem.path);   % Add the yael library
        %             fprintf('Applying Yaels GMM optimization with random initialization seed %d\n',gmmOpts.yaelem.seed);
        %             [gmm.weight, gmm.mean, gmm.var] = yael_gmm(feat, gmmOpts.k, 'niter', gmmOpts.iter, 'verbose', 0, 'seed', gmmOpts.yaelem.seed,'nt', 1);
        %             gmm.k               = gmmOpts.k;
        %             gmm.logl            = 0;
        %         elseif strcmp(gmmOpts.method,'devilem'),
        %             addpath(gmmOpts.devilem.path);  % add library path (see Devils in the Details Package)
        %             fprintf('Applying Devils GMM optimization with random initialization\n');
        %             gmm_params          = struct;
        %             gmm.k               = gmmOpts.k;
        %
        %             codebook            = mexGmmTrainSP(feat, gmm.k, gmm_params);
        %             gmm.var             = codebook.variance;
        %             gmm.mean            = codebook.mean;
        %             gmm.weight          = codebook.coef';
        %             gmm.logl            = codebook.log_likelihood;
        %             clear codebook
        %else
        %    error('%s - unknown gmm method %s',mfilename,encOpts.gmm.method);
        %end
        
        fprintf('Save gmm as %s\n',mixfn);
        save(mixfn,'gmm');
        
        
    elseif nargout >= 1,
        load(mixfn);
    end
end
