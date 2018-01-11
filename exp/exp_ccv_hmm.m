clear all
fversion(.31);

%New version takes into account encKit options and structure

dataset = 'CCV';
enc0.llf.feat = 'fc2';
enc0.fv.opts.FIM = 'ID';
enc0.pool.norm.pown = 0;enc0.pool.l2sub = 0; enc0.pool.l2fin = 0;
enc0.svm.kernel = 1;

F = {'fc2'}; 
P = [64 128 256];                                   %PCA dimensions
GB= {'gmm','stmm'};                                 %GMM Base
EM= {'hmm'};                                        %EM algorithms
K = [2 4 8 16 32];                                           %NrGaussians
SP= {'F'};                                          %Spatial Pyramids
FV= {[0 1 0]};                                      %Fisher vectors [W M V]
N = {[0 0 0]};                                      %Normalisations

%% Experiment 1: Test on all Variations
fprintf('Experiment : Test\n');
R   = exp_run_feat(dataset,F,P,GB,EM,K,SP,FV,N,enc0);

for i=1:numel(R),    
    enc     = enc_getOpts(R{i}.enc);
    fprintf('%5d | %100s | %s\n',i,enc.sum,R.status);
end
