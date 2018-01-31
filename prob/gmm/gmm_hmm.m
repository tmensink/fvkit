function hmm = gmm_hmm(Xdesc,Xloc,hopts)
    % Hidden Markov GMM
    %
    % Part of FVKit - initial release
    % Copyright, 2013-2018
    % Thomas Mensink, University of Amsterdam
    % thomas.mensink@uva.nl
    
    NrD     = size(Xdesc,1);
    NrK     = hopts.k;
    seqId   = cumsum([1 Xloc(2,1:end-1)-Xloc(2,2:end)>0]);
    NrS     = max(seqId);
    
    rs      = RandStream.create('mt19937ar','seed',hopts.seed);
    if strcmp(hopts.init,'splitem'),
        f = hopts.file;
        a = strfind(f,'_hmm');
        f(a:a+3) = [];
        tmp = load(f);
        hmm.mean    = tmp.gmm.mean;
        hmm.var     = tmp.gmm.var;
        hmm.prior   = tmp.gmm.weight;        
        hmm.k       = NrK;
        hmm.trans   = normalize(rand(rs,NrK) + eye(NrK),2);
    elseif strcmp(hopts.init,'rnd'),
        hmm.mean    = randn(rs,NrD,NrK) * .01;
        hmm.var     = rand(rs,NrD,NrK) * .1;
        hmm.prior   = ones(1,NrK)/NrK;        
        hmm.trans   = normalize(rand(rs,NrK) + eye(NrK),2);
        hmm.k       = NrK;
    end
    
    % Get Video Sequences
    seqFeat = cell(1,NrS);
    for i=1:NrS,
        seqFeat{i} = Xdesc(:,seqId==i);
    end
            
    Sigma0  = zeros(NrD, NrD, NrK);
    for i=1:NrK
        Sigma0(:,:,i)   = diag(hmm.var(:,i));
    end
    
    cov_type    = 'diag';
    p_prior     = 0;
    p_trans     = 0;
    adj_mu      = 0;
    adj_sigma   = 0;
    adj_prior   = 1;
    
    fprintf('\t--> Train HMM\n');     
    [LL, prior1, transmat1, mu1, Sigma1, ~] = mhmm_em(seqFeat, hmm.prior, hmm.trans, hmm.mean, Sigma0, [], p_prior, p_trans, 'max_iter',hopts.opts.MaxIter, 'cov_type', cov_type, 'adj_mu',adj_mu,'adj_Sigma', adj_sigma,  'adj_prior', adj_prior);

        
    hmm.LL      = LL;
    hmm.prior   = prior1;
    hmm.trans   = transmat1;
    hmm.mean    = mu1;    
    hmm.covType = cov_type;
    
    % get the diagonals of the cov matrix
    hmm.var     = zeros(NrD,NrK);
    for i=1:NrK
        hmm.var(:,i)    = diag(Sigma1(:,:,i));
    end
end
