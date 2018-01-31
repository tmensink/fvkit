function gmm = gmm_splitem(X,~,gmmOpts)
    % GMM EM - Estimates GMM parameters using a EM based on splitting of the component means
    %
    % Input
    %   X           [d x n]     Matrix with n observations of d dimensions
    %   gmmOpts     struct      Structure with the GMM / EM options
    %                            see gmm_opts.m
    %
    % Output
    %   gmm         struct
    %    .var       [d x k]     Matrix with the diagonal variances of each component
    %    .mean      [d x k]     Matrix with the component means
    %    .weight    [1 x k]     Vector with the component weights
    %    .logl      [1 x iter]  Vector with the history of the loglikelihood values
    %
    % The idea of split EM is as follows
    %   Define component 1 as being the data mean vector,
    %   For split iteration 1...x do
    %     Split each component in two with small perturbation
    %       i.e. M + randn
    %     Use standard EM for a few iterations
    %   end for
    %
    % In [1] the idea is explained as follows:
    % "We estimate the GMM parameters on a large set of training local descriptors using the
    % Expectation-Maximization algorithm to optimize a Maximum Likelihood (ML) criterion. We use an
    % iterative process which consists in starting with a single Gaussian (for which a closed-form
    % formula exists), splitting all Gaussians by slightly perturbing the mean and then re-esti-
    % mating the GMM parameters with EM. This itrative splitting-training strategy ??? which was
    % inspired by the HMM Toolkit (HTK) (Young et al, 2002) and enables cross-validating and moni-
    % toring the influence of the number of Gaussians K"
    %
    % References
    % [1]   Image Classification with the Fisher Vector: Theory and Practice
    %       Jorge Sanchez - Florent Perronnin - Thomas Mensink - Jakob Verbeek
    %       IJCV, january 2013
    %
    % See also: gmm_em
    %
    % Part of FVKit - initial release
    % Copyright, 2013-2018
    % Thomas Mensink, University of Amsterdam
    % thomas.mensink@uva.nl
    
    kMax        = gmmOpts.k;
    kMaxLog     = log2(kMax);
    assert(ceil(kMaxLog) == kMaxLog,'%s - Assumes that gmm.k is an exponent of 2 i.e. [2 8 16 32 64 ... 1024]',mfilename);
    KK          = cumprod(2*ones(1,kMaxLog));
    
    kBase       = [gmmOpts.path '/' gmmOpts.bname '_K%04d.mat'];
    
    M = []; C = []; W = []; Xs = [];
    for ki = 1:numel(KK),
        k           = KK(ki);
        kName       = sprintf(kBase,k);
        
        fprintf('\t--> Mixture for %4d Gaussians\n',k);
        
        if exist(kName,'file'),
            fprintf('\t\t--> Skip | Exists in %s\n',kName);
        else
            fprintf('\t\t--> Learn |\n');
            
            %% Initilization of the different clusters
            if k == 2,
                fprintf('\t\t--> Initialize M by data mean + rand variation, C by data variance and W as uniform\n');
                rs          = RandStream.create('mt19937ar','seed',gmmOpts.seed);
                dataM       = mean(X,2);
                dataC       = var(X,[],2);
                
                M           = [dataM dataM];
                C           = [dataC dataC];
                W           = [.5 .5];
                clear dataM dataC
            else
                fprintf('\t\t--> Initialize by previous components\n');
                if isempty(M) || isempty(C) || isempty(W),
                    kk      = KK(ki-1);
                    ffn     = sprintf(kBase,kk);
                    fprintf('\t\t--> Start from %s\n',ffn);
                    
                    tmp     = load(ffn);
                    rs      = tmp.gmm.rs;
                    M       = tmp.gmm.mean;
                    C       = tmp.gmm.var;
                    W       = tmp.gmm.weight;
                    clear tmp;
                end
                
                kInx        = [1 1]' * (1:KK(ki-1));    kInx = kInx(:);     %Index vector to each of the components [1 1 2 2 3 3...]
                
                W           = normalize(W(:,kInx));                         %Set the mixing weights
                M           = M(:,kInx);                                    %Set the mean
                C           = C(:,kInx);                                    %Set the variance for each component
            end
            
            %% Set the random perturbation of the means
            % The goal is that the expected distance between <d> is 1
            % d = (m1-m2)'(m1-m2);
            % and it can be shown that <d> relates to the dimensionality D
            % and the chosen variance.
            %  For <d> = 1  --> sigma^2 = 1/sqrt(2*D)
            %  For <d> = .5 --> sigma^2 = 1/sqrt(4*D)
            d           = size(X,1);
            M           = M + ( randn(rs,d,k) * (1/sqrt(2*d) ) );
            
            %% Print information
            fprintf('\t\t--> Means [%d x %d] - after init:\n',size(M));
            for i=1:5,
                fprintf('\t\t\t');fprintf(' %7.2f ',M(i,1:min(size(M,2),10)));fprintf('\n');
            end
            
            %% EM optimization
            fprintf('\t\t--> Run EM  \n');
            if exist('Xs','var') == 0 || isempty(Xs),
                Xs = X.^2;
            end
            
            gmm         = struct;
            gmm.rs      = rs;
            gmm.params  = gmmOpts.opts;
            gmm.mean    = M;
            gmm.var     = C;
            gmm.weight  = W;
            gmm.k       = k;
            
            gmm         = gmm_em(X,gmm,Xs);
            
            %% Print information
            fprintf('\t\t--> Means - after EM:\n');
            for i=1:5,
                fprintf('\t\t\t');fprintf(' %7.2f ',gmm.mean(i,1:min(size(M,2),10)));fprintf('\n');
            end
            fprintf('\t\t --> Save as %s\n',kName);
            save(kName,'gmm');
            
            M = gmm.mean;
            C = gmm.var;
            W = gmm.weight;
        end
    end
end
