%% Rijksmuseum FV Extraction
% Demo script to extract features for Rijks Museum Challenge (RMC)
% Rijksmuseum challenge base code see:
%   https://github.com/tmensink/rijkschallenge
% For dataset see:
%   https://figshare.com/articles/Rijksmuseum_Challenge_2014/5660617
%
% Part of FVKit - initial release
% copyright, 2014-2018
% Thomas Mensink, University of Amsterdam
% thomas.mensink@uva.nl

clear all; %#ok<CLALL>
fversion(.95);
init_getOptsSetPath;

%% DATASET: VOC2007
dataset = 'RMC';

%% Fisher Vector
% Below some parameters for obtaining Fisher Vectors
F = {'dsift'};                                      %Local features
T = {'I'};                                          %Type of local features (I,O,H for dsift)
P = 96;                                             %PCA dimensions
GB= {'gmm'};                                        %GMM Base
EM= {'splitem'};                                    %EM algorithms
K = 16;                                             %NrGaussians
SP= {'F'};                                          %Spatial Pyramids
FV= {[0 1 1]};                                      %Fisher vectors [W M V]
N = {[1 1 0]};                                      %Normalisations

enc0 = struct;

fprintf('Experiment : Extract Features RMC\n');
R   = exp_run_feat(dataset,F,T,P,GB,EM,K,SP,FV,N,enc0);

%% Print an overview of the current set of experiments
for i=1:numel(R),
    fprintf('%5d |',i);
    RR = R{i}.R;
    if isfield(RR,'sum');
        fprintf('%100s | %s',RR.sum,RR.status);
    end
    fprintf('\n');
end

doCreatorChallenge = 1;
if doCreatorChallenge,
    %% This part of the demo requires the RijksChallenge repository:
    % https://github.com/tmensink/rijkschallenge
    addpath('../rijkschallenge/');
    %% Start RMC experiment (eg for Creator)
    % see exp_rijks_creator.m (from Rijkschallenge package) for more details
    
    n = 'FVKit: RMC Creator  options';
    expOpts                 = struct();
    expOpts.name            = 'creator';
    
    %% Difference with RMC14 file:
    %The (only difference with respect to the experiment files in RMC are
    % the data.file (directory with features) and rdir (a subdirectory
    % there):
    fvEnc = init_getOpts(R{1}.enc,dataset);
    expOpts.data.file       = [fvEnc.pool.path '/'];
    expOpts.data.gtfile     = '../rijkschallenge/data/rijksgt.mat';
    expOpts.rdir            = [expOpts.data.file '/results/'];
    
    expOpts.data.gtfield    = 'C';                  % Get creator field from GT
    expOpts.data.minTstOcc  = 10;
    
    expOpts.svm.run         = 1;                    % Set to 1 to run, 0 to evaluate existing classifiers!
    expOpts.svm.C           = logspace(-2,2,5);     % Set SVM options (hyper-parameter C)
    expOpts.svm.method      = '1vR';                % Set SVM method
    expOpts.svm.algo        = 1;                    % Option of LibLinear Train
    
    expOpts.eval.func       = 'mca';                % Set evaluation measure (MCA)
    
    exp_rijks_run                                   % Run experiment
    
    %% Results from this run will/should be:
    % Cross Validate using mca
    %         C 1e-02 P    0.025 (mca)
    %         C 1e-01 P    0.201 (mca)
    %         C 1e+00 P    0.449 (mca)
    %         C 1e+01 P    0.538 (mca)
    %         C 1e+02 P    0.528 (mca)
    % Evaluate using C 1e+01 |
    % creator
    %            0 | TRN | ii  375 ( all )| MCA:   97.67   99.99  100.00  100.00  100.00
    %            0 | VAL | ii  375 ( all )| MCA:   53.77   70.50   77.01   80.37   82.83
    %            0 | TST | ii  375 ( all )| MCA:   55.62   71.98   78.00   81.43   83.21
    %            1 | TST | ii  374 ( 59.1)| MCA:   69.30   77.37   81.18   83.12   84.34
    %            2 | TST | ii  300 ( 55.5)| MCA:   71.47   79.11   82.41   84.31   85.68
    %            3 | TST | ii  250 ( 52.5)| MCA:   73.30   80.82   83.90   85.80   86.85
    %            4 | TST | ii  200 ( 48.7)| MCA:   75.37   82.42   85.51   87.25   88.32
    %            5 | TST | ii  150 ( 43.6)| MCA:   77.00   84.10   87.09   88.91   90.04
    %            6 | TST | ii  100 ( 36.8)| MCA:   79.82   86.82   89.59   91.37   92.50
    %            7 | TST | ii   50 ( 26.4)| MCA:   81.68   89.34   92.27   93.90   94.90
    %            8 | TST | ii   25 ( 18.7)| MCA:   85.20   91.35   94.28   95.82   96.71
    
    %% Comparison to RMC files:
    % These results are higher than the reported results using the FVs
    % from RMC14 (55.6 vs 51.0 for all). This difference is likely due to the
    % square-rooting of the SIFT features before computing FVs (which was not
    % applied when the FV for RMC'14 was created)
end