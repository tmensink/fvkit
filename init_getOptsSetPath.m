function init_getOptsSetPath
    % Set the correct paths for FVKit
    %
    % Part of FVKit - initial release
    % copyright, 2014-2018
    % Thomas Mensink, University of Amsterdam
    % thomas.mensink@uva.nl
    
    % A simplisitc way to overcome adding too often usesless paths
    if exist('llf_opts','file') ~= 2,
        LIBROOT='lib/';
        fprintf('setpaths\nlib: ');
        fprintf('mytools|');addpath([LIBROOT 'mytools']);
        fprintf('libsvm|');addpath([LIBROOT  'libsvm/']);
        fprintf('vlfeat|');addpath([LIBROOT  'vlfeat/']);
        fprintf('\n');
        fprintf('fv-kit:');
        fprintf('enc|');addpath('enc/');
        fprintf('eval|');addpath('eval/');
        fprintf('exp|');addpath('exp/');
        fprintf('llf|');addpath('llf/');
        fprintf('pca|');addpath('pca/');
        fprintf('pool|');addpath('pool/');
        fprintf('svm|');addpath('svm/');
        fprintf('\n');
        clear LIBROOT;
    end
end
