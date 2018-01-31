function lopts = llf_opts(lopts,enc)
    % Set options for local features
    %
    % Part of FVKit - initial release
    % Copyright, 2013-2018
    % Thomas Mensink, University of Amsterdam
    % thomas.mensink@uva.nl
    
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
