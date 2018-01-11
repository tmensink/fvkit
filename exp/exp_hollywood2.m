    clear all
    fversion(.1);
    %% Options to consider
    dataset     = 'Hollywood2';
    
    F = {'dt'}; 
    P = [96 128 160];                                   %PCA dimensions
    EM= {'splitem'};                                    %EM algorithms
    K = [128 256 512];                                  %NrGaussians    
    SP= {'F'};                                          %Spatial Pyramids
    FV= {[0 1 1]};                                      %Fisher vectors [W M V]
    N = {[1 1 0]};                                      %Normalisations
    C = logspace(-4,4,9);
    
    enc0.llf.max_feat = 350;         
    %% Experiment 1: Test on all Variations
    fprintf('Experiment : Test\n');
    R   = exp_run_feat(dataset,F,P,EM,K,SP,FV,N,C,enc0);    
        
    for i=1:numel(R),        
        enc = R{i}.enc;
        fprintf('%5d | ',i);
        fprintf('LLF type %3s | pca %3d |',enc.llf.feat,enc.pca.pdim);
        fprintf('GMM %8s %3dk |',enc.gmm.method,enc.gmm.k);
        fprintf('FV pool %3s WMV [%d %d %d] |',enc.fv.opts.pool,enc.fv.opts.gWeight,enc.fv.opts.gMean,enc.fv.opts.gVar);
        fprintf('Norm sqrt %d l2sub %d l2fin %d |',enc.fv.norm.sqrt,enc.fv.norm.l2sub,enc.fv.norm.l2fin);
        fprintf('SVM %5.0e C |',enc.svm.C);
        if isfield(R{i},'R') && isfield(R{i}.R,'tst'),
            fprintf('Perf mAP %7.2f %7.2f|\n',R{i}.R.tst.P(1:2)*100);
        else
            fprintf('Not finished yet\n');
        end
    end
    fname = ['res_pascal_' datestr(now,30)];    
    save(fname,'R*');
    fprintf('Saved in %s\n',fname);
