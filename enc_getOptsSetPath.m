    if exist('llf_opts','file') ~= 2,
        LIBROOT='lib/';
        fprintf('setpaths LIB: ');
        fprintf('lib|');addpath(LIBROOT);
        fprintf('mytools|');addpath([LIBROOT 'mytools']);
        fprintf('libsvm|');addpath([LIBROOT  'libsvm-3.14/matlab/']);
        fprintf('vlfeat|');addpath([LIBROOT  'vlfeat/']);
        fprintf('HMM|');addpath([LIBROOT  'hmm/']);
        fprintf('||');
        fprintf('fv-kit:');
        fprintf('exp|');addpath('exp/');
        fprintf('llf|');addpath('llf/');
        fprintf('\n');
        clear LIBROOT;
    end
