function enc = enc_getOptsDataset(enc,dataset)
    if nargin < 2 || isempty(dataset),  dataset = 'VOC2007';            end
    
    if ismac,
        bdir                    = '/Users/tmensink/Documents/research/data/';
    else
        bdir                    = '/datastore/tmensink/data/';
    end
    
    switch dataset
        case 'Hollywood2'
            enc.name            = dataset;
            bpath               = [bdir 'hollywood2/'];
            
            
            %enc.path.dataset    = [bpath 'DT/'];
            enc.path.dataset    = [bpath];
            enc.path.results    = [bpath 'results/'];
            
            enc.imdb            = load(fullfile(bpath,'imdb-hollywood2.mat'));              % IMDB file
        case 'CCV'
            enc.name            = dataset;
            bpath               = [bdir 'ccv/'];
                        
            
            enc.path.dataset    = [bpath 'fc2/'];
            enc.path.results    = [bpath 'results/'];
            
            enc.imdb            = load(fullfile(bpath,'/org_data/imdb.mat'));              % IMDB file
            enc.imdb.images     = enc.imdb.users;
            enc.imdb.images.name= enc.imdb.images.vidId;
            enc.imdb.classes.imageIds = enc.imdb.classes.vidId;
        case 'VOC2007'
            enc.name            = dataset;
            bpath               = [bdir 'voc2007/'];
            
            enc.path.dataset    = [bpath 'VOCdevkit/'];
            enc.path.results    = [bpath 'results/'];
            
            enc.imdb            = load(fullfile(enc.path.dataset,'imdb-VOC2007.mat'));              % IMDB file
        otherwise
            error('%s -- Dataset (%s) unknown',mfilename,dataset);
    end
    
end
