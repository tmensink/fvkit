function enc = init_getOptsDataset(enc,dataset)
    % Sets dataset specicif options for FVKit
    %
    % Part of FVKit - initial release
    % copyright, 2014-2018
    % Thomas Mensink, University of Amsterdam
    % thomas.mensink@uva.nl
    
    if nargin < 2 || isempty(dataset),  dataset = 'VOC2007';            end
    
    bdir = './data/';
    switch dataset
        case 'VOC2007'
            enc.name            = dataset;
            bpath               = [bdir 'voc2007/'];
            
            enc.path.dataset    = [bpath 'VOCdevkit/'];
            enc.path.results    = [bpath 'results/'];
            
            enc.imdb            = load(fullfile(enc.path.dataset,'imdb-VOC2007.mat'));              % IMDB file
        case {'RMC', 'RMC14'}
            enc.name            = dataset;
            bpath               = [bdir 'rijks/'];
            
            enc.path.dataset    =  bpath;
            enc.path.results    = [bpath 'results/'];
            
            enc.imdb            = load(fullfile(enc.path.dataset,'imdb-rijks.mat'));              % IMDB file
            
        otherwise
            error('%s -- Dataset (%s) unknown',mfilename,dataset);
    end
    
end
