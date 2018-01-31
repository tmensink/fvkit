%% VOC2007 FVKit extraction and comparison
% Demo script to run experiments on Pascal VOC 2007
% It includes the required parameters for obtaining the results from the README
% Note that not all options available in FVKit are explored, only some common ones!
%
% See data/voc2007 to obtain required Pascal VOC data
%
% Part of FVKit - initial release
% copyright, 2014-2018
% Thomas Mensink, University of Amsterdam
% thomas.mensink@uva.nl

clear all; %#ok<CLALL>
fversion(.95);
init_getOptsSetPath;

%% DATASET: VOC2007
dataset = 'VOC2007';
% Download PASCAL VOC 2007 dataset, see
% ./data/voc2007/download_pascalVOC2007.m
% this demo will create a directory
% ./data/voc2007/results
% which might require quite some storage depending on your options below!

%% Fisher Vector
% Set some parameters for obtaining Fisher Vectors
F = {'dsift'};                                      %Local features
GB= {'gmm'};                                        %GMM Base
EM= {'splitem'};                                    %EM algorithms
FV= {[0 1 1]};                                      %Fisher vectors [W M V]
N = {[1 1 0]};                                      %Normalisations


% Set parameters for different experiments
fprintf('Experiment : Demo Pascal VOC 2007\n');
doExperiment = 1;
switch doExperiment
    case 1
        fprintf('\t Experiment 1: PCA Dimensions\n');
        T = {'I'};P = [32 64 128];K = 256;SP={'F'};
    case 2
        fprintf('\t Experiment 2: Color SIFTs\n');
        T = {'O','H','I'};P = 64;K = 256;SP={'F'};
    case 3 
        fprintf('\t Experiment 3: Pooling\n');
        T = {'I'};P = 64; K=256;SP={'F','FH','FHQ'};
    case 4 
        fprintf('\t Experiment 4: Mixture Compnents\n');
        T = {'I'};P = 64;K = [16 32 64 128 256];SP={'F'};
    otherwise % Simple setting
        T = {'I'};P = 64;K = 16;SP={'F'};
end

% Options for training classifiers
enc0 = struct;
enc0.svm.kernel = 1;
enc0.svm.train  = 1;
enc0.svm.test   = 1;
enc0.svm.C      = logspace(-2,2,5);

%% Run FV extraction + classification
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
