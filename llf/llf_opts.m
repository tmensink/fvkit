function lopts = llf_opts(lopts,enc)
    
    if ~isfield(lopts,'feat'),        lopts.feat            = 'dsift';          end
    if ~isfield(lopts,'max_feat'),    lopts.max_feat        = 250;              end
    if ~isfield(lopts,'max_feat_fin'),lopts.max_feat_fin    = 0;                end
    if ~isfield(lopts,'max_feat_seed'),lopts.max_feat_seed  = 5489;             end
    if ~isfield(lopts,'max_feat_rs'), lopts.max_feat_rs     = RandStream.create('mt19937ar','seed',lopts.max_feat_seed);   end
    
    
    switch lopts.feat
        case {'dsift'}
            if ~isfield(lopts,'dsift'),       lopts.dsift           = struct;           end
            if ~isfield(lopts.dsift,'max_pix'),lopts.dsift.max_pix  = 1e5;              end
            if ~isfield(lopts.dsift,'step'),  lopts.dsift.step      = 4;                end
            if ~isfield(lopts.dsift,'bin'),   lopts.dsift.bin       = 6;                end
            if ~isfield(lopts.dsift,'scales'),lopts.dsift.scales    = 5;                end                        
            if ~isfield(lopts.dsift,'upscale'),lopts.dsift.upscale  = 1;                end
            if ~isfield(lopts.dsift,'smooth'),lopts.dsift.smooth    = 0;                end
            if ~isfield(lopts.dsift,'rszm'),  lopts.dsift.rszm      = 'bicubic';        end
            if ~isfield(lopts.dsift,'type'),  lopts.dsift.type      = 'I';              end %Could be either I, H, O. intensity, hue or opponent sift
            
            switch lopts.dsift.type,
                case 'I'
                    lopts.dsift.out_dim  = 128;
                case 'H'
                    lopts.dsift.out_dim  = 128*2;
                case 'O'
                    lopts.dsift.out_dim  = 128*3;
            end
            
            if ~isfield(lopts.dsift,'root'),  lopts.dsift.root      = 1;                end
            if ~isfield(lopts.dsift,'out_dim'),lopts.dsift.out_dim  = 128;              end
                        
            % Define name, dir, and name
            name = sprintf('%s_%03dk_%ds%ds%db%du',lopts.dsift.type,ceil(lopts.dsift.max_pix/1000),lopts.dsift.scales,lopts.dsift.step,lopts.dsift.bin,lopts.dsift.upscale);
            
            if lopts.dsift.root == 1,               name  = sprintf('%sroot',name);                   end            
            if ~strcmp(lopts.dsift.rszm,'bicubic'), name  = sprintf('%s_%s',name,lopts.dsift.rszm);   end            
            lopts.dsift.name = name;
            
        case {'dt'},
            if ~isfield(lopts,'dt'),          lopts.dt              = struct;           end
            if ~isfield(lopts.dt,'dHog'),     lopts.dt.dHog         = 1;                end
            if ~isfield(lopts.dt,'dHof'),     lopts.dt.dHof         = 0;                end
            if ~isfield(lopts.dt,'dMBHx'),    lopts.dt.dMBHx        = 1;                end
            if ~isfield(lopts.dt,'dMBHy'),    lopts.dt.dMBHy        = 1;                end
            if ~isfield(lopts.dt,'out_dim'),  lopts.dt.out_dim      = 288;              end
            if ~isfield(lopts.dt,'C'),        lopts.dt.C            = enc.imdb.str2inx; end
            if ~isfield(lopts.dt,'mmap'),
                lopts.dt.mmap = memmapfile([enc.path.dataset 'DT.bin'],'Writable',false,'Format',{'single',[436 enc.imdb.NrFeat],'DTfeat';'int64',[numel(lopts.dt.C)+1,1],'DTinx'});
            end            
            lopts.dt.name = sprintf('dt_%d%d%d%d',lopts.dt.dHog,lopts.dt.dHof,lopts.dt.dMBHx,lopts.dt.dMBHy);
            
        case {'fc2'}
            
            if ~isfield(lopts,'fc2'),         lopts.fc2             = struct;            end
            if ~isfield(lopts.fc2,'out_dim'), lopts.fc2.out_dim     = 4096;                end
            if ~isfield(lopts.fc2,'C'),       lopts.fc2.C           = enc.imdb.images.vidId;   end            
            lopts.fc2.name = '';
            
        case {'mat'},
            if ~isfield(lopts,'mat'),         lopts.mat             = struct;               end
            if ~isfield(lopts.mat,'out_dim'), lopts.mat.out_dim     = 4096;                 end
            if ~isfield(lopts.mat,'files'),   lopts.mat.files       = {'train.mat','test.mat','val.mat'}; end
            if ~isfield(lopts.mat,'dir'),     lopts.mat.dir         = enc.path.dataset;     end
            lopts.mat.name = '';
    end
    
    lopts.path = [enc.path.results lopts.feat '/' lopts.(lopts.feat).name];
    name        = 'llf';
    
    if lopts.max_feat > 0,
        name        = sprintf('%s_%06dn',name,lopts.max_feat);
    end
    
    if lopts.max_feat_seed  ~= 5489,
        name    = sprintf('%s_rs%d',name,lopts.max_feat_seed);
    end
    
    lopts.name    = name;
    lopts.file    = sprintf('%s/%s.mat',lopts.path,name);
end
