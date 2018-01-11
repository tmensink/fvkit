function [LL, prior, transmat, mu, Sigma, mixmat] = ...
     shmm_em(data, prior, transmat, mu, Sigma, mixmat, p_prior, p_trans, nu, varargin);
% LEARN_MHMM Compute the ML parameters of an HMM with (mixtures of) Gaussians output using EM.
% [ll_trace, prior, transmat, mu, sigma, mixmat] = learn_mhmm(data, ...
%   prior0, transmat0, mu0, sigma0, mixmat0, ...) 
%
% Notation: Q(t) = hidden state, Y(t) = observation, M(t) = mixture variable
%
% INPUTS:
% data{ex}(:,t) or data(:,t,ex) if all sequences have the same length
% prior(i) = Pr(Q(1) = i), 
% transmat(i,j) = Pr(Q(t+1)=j | Q(t)=i)
% mu(:,j,k) = E[Y(t) | Q(t)=j, M(t)=k ]
% Sigma(:,:,j,k) = Cov[Y(t) | Q(t)=j, M(t)=k]
% mixmat(j,k) = Pr(M(t)=k | Q(t)=j) : set to [] or ones(Q,1) if only one mixture component
%
% Optional parameters may be passed as 'param_name', param_value pairs.
% Parameter names are shown below; default values in [] - if none, argument is mandatory.
%
% 'max_iter' - max number of EM iterations [10]
% 'thresh' - convergence threshold [1e-4]
% 'verbose' - if 1, print out loglik at every iteration [1]
% 'cov_type' - 'full', 'diag' or 'spherical' ['full']
%
% To clamp some of the parameters, so learning does not change them:
% 'adj_prior' - if 0, do not change prior [1]
% 'adj_trans' - if 0, do not change transmat [1]
% 'adj_mix' - if 0, do not change mixmat [1]
% 'adj_mu' - if 0, do not change mu [1]
% 'adj_Sigma' - if 0, do not change Sigma [1]
%
% If the number of mixture components differs depending on Q, just set  the trailing
% entries of mixmat to 0, e.g., 2 components if Q=1, 3 components if Q=2,
% then set mixmat(1,3)=0. In this case, B2(1,3,:)=1.0.

if ~isempty(varargin) & ~isstr(varargin{1}) % catch old syntax
  error('optional arguments should be passed as string/value pairs')
end

[max_iter, thresh, verbose, cov_type,  adj_prior, adj_trans, adj_mix, adj_mu, adj_Sigma] = ...
    process_options(varargin, 'max_iter', 10, 'thresh', 1e-4, 'verbose', 1, ...
		    'cov_type', 'full', 'adj_prior', 1, 'adj_trans', 1, 'adj_mix', 1, ...
		    'adj_mu', 1, 'adj_Sigma', 1);
  
previous_loglik = -inf;
loglik = 0;
converged = 0;
num_iter = 1;
LL = [];

if ~iscell(data)
  data = num2cell(data, [1 2]); % each elt of the 3rd dim gets its own cell
end
numex = length(data);


O = size(data{1},1);
Q = length(prior);
if isempty(mixmat)
  mixmat = ones(Q,1);
end
M = size(mixmat,2);
if M == 1
  adj_mix = 0;
end

nFrame  = sum(cellfun(@(x) size(x,2),data));
nSeq    = size(data,1);
nStates = size(mu,2);

while (num_iter <= max_iter) & ~converged
  % E step
  if adj_mu | adj_Sigma
      [loglik, exp_num_trans, exp_num_visits1, postmix, m, ip, op] = ...
          ess_mhmm(prior, transmat, mixmat, mu, Sigma, nu, data, cov_type);
  else
      [loglik, exp_num_trans, exp_num_visits1, postmix] = ...
          ess_mhmm(prior, transmat, mixmat, mu, Sigma, nu, data, cov_type);
  end
  
  % M step
  if adj_prior
    prior = normalise(exp_num_visits1 + p_prior * nSeq/nStates);
  end
  if adj_trans 
    transmat = mk_stochastic(exp_num_trans + max(diag(repmat(p_trans * (nFrame-nSeq)/nStates,1,nStates)), 0.000001));
  end
  if adj_mix
    mixmat = mk_stochastic(postmix);
  end
  if adj_mu | adj_Sigma
    %TODO implement?
      %[mu2, Sigma2] = mixgauss_Mstep(postmix, m, op, ip, 'cov_type', cov_type, 'cov_prior', 0.0001); %TODO set prior to 0!
    if adj_mu
      mu = reshape(mu2, [O Q M]);
    end
    if adj_Sigma
      Sigma = reshape(Sigma2, [O O Q M]); 
    end
  end
  
  if verbose, fprintf(1, 'iteration %d, loglik = %f\n', num_iter, loglik); end
  num_iter =  num_iter + 1;
  converged = em_converged(loglik, previous_loglik, thresh);
  previous_loglik = loglik;
  LL = [LL loglik];
end


%%%%%%%%%

function [loglik, exp_num_trans, exp_num_visits1, postmix, m, ip, op] = ...
    ess_mhmm(prior, transmat, mixmat, mu, Sigma, nu, data, cov_type)
% ESS_MHMM Compute the Expected Sufficient Statistics for a MOG Hidden Markov Model.
%
% Outputs:
% exp_num_trans(i,j)   = sum_l sum_{t=2}^T Pr(Q(t-1) = i, Q(t) = j| Obs(l))
% exp_num_visits1(i)   = sum_l Pr(Q(1)=i | Obs(l))
%
% Let w(i,k,t,l) = P(Q(t)=i, M(t)=k | Obs(l))
% where Obs(l) = Obs(:,:,l) = O_1 .. O_T for sequence l
% Then 
% postmix(i,k) = sum_l sum_t w(i,k,t,l) (posterior mixing weights/ responsibilities)
% m(:,i,k)   = sum_l sum_t w(i,k,t,l) * Obs(:,t,l)
% ip(i,k) = sum_l sum_t w(i,k,t,l) * Obs(:,t,l)' * Obs(:,t,l)
% op(:,:,i,k) = sum_l sum_t w(i,k,t,l) * Obs(:,t,l) * Obs(:,t,l)'

% precompute some constants to speed it up the mixgauss prob calculation
% (is without 95% of the time)
if strcmp(cov_type, 'diag')
    model.mean  = mu;
    k           = size(Sigma,3);
    model.var   = zeros(size(mu));
    for i=1:k
        model.var(:,i)    = diag(Sigma(:,:,i));
    end
    model.nu     = nu;
    model.weight = ones(size(nu)); % give a weight of one, then we can use smm_expectation
    model.params.diagCov = 1;
    model.k      = k;
end

verbose = 0;

%[O T numex] = size(data);
numex = length(data);
O = size(data{1},1);
Q = length(prior);
M = size(mixmat,2);
exp_num_trans = zeros(Q,Q);
exp_num_visits1 = zeros(Q,1);
postmix = zeros(Q,M);
m = zeros(O,Q,M);
op = zeros(O,O,Q,M);
ip = zeros(Q,M);

mix = (M>1);

loglik = 0;
if verbose, fprintf(1, 'forwards-backwards example # '); end


for ex=1:numex
  if verbose, fprintf(1, '%d ', ex); end
  %obs = data(:,:,ex);
  obs = data{ex};
  T = size(obs,2);
  if mix
    [B, B2] = mixgauss_prob(obs, mu, Sigma, mixmat);
    [alpha, beta, gamma,  current_loglik, xi_summed, gamma2] = ...
	fwdback(prior, transmat, B, 'obslik2', B2, 'mixmat', mixmat);
  else
    %B = mixgauss_prob(obs, mu, Sigma);
    %[alpha, beta, gamma,  current_loglik, xi_summed] = fwdback(prior, transmat, B);
    
    if strcmp(cov_type, 'diag')
        [tau,~,~, logl] = smm_expectation( model, obs);
        [alpha, beta, gamma,  current_loglik1, xi_summed] = fwdback(prior, transmat, tau);
        current_loglik     = current_loglik1 + sum(double(logl));
        if isnan(current_loglik)
            current_loglik1
            hmm.mu
            hmm.var
        end
    else
        % TODO
        x=errorNotImpl;
    end
  end    
  loglik = loglik +  current_loglik; 
  if verbose, fprintf(1, 'll at ex %d = %f\n', ex, loglik); end


  exp_num_trans = exp_num_trans + xi_summed; % sum(xi,3);
  exp_num_visits1 = exp_num_visits1 + gamma(:,1);
  
  if mix
    postmix = postmix + sum(gamma2,3);
  else
    postmix = postmix + sum(gamma,2); 
    gamma2 = reshape(gamma, [Q 1 T]); % gamma2(i,m,t) = gamma(i,t)
  end
  if nargout > 4
      % only calculate that if mu or sigma gets updated (because it is expensive)
      for i=1:Q
        for k=1:M
          w = reshape(gamma2(i,k,:), [1 T]); % w(t) = w(i,k,t,l)
          wobs = obs .* repmat(w, [O 1]); % wobs(:,t) = w(t) * obs(:,t)
          m(:,i,k) = m(:,i,k) + sum(wobs, 2); % m(:) = sum_t w(t) obs(:,t)
          op(:,:,i,k) = op(:,:,i,k) + wobs * obs'; % op(:,:) = sum_t w(t) * obs(:,t) * obs(:,t)'
          ip(i,k) = ip(i,k) + sum(sum(wobs .* obs, 2)); % ip = sum_t w(t) * obs(:,t)' * obs(:,t)
        end
      end
  end
end
if verbose, fprintf(1, '\n'); end
