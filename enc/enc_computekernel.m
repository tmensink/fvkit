function enc_computekernel(encOpts)
    % Function to (pre) compute kernel matrices
    %
    % Part of FVKit - initial release
    % Copyright, 2013-2018
    % Thomas Mensink, University of Amsterdam
    % thomas.mensink@uva.nl
    
    % SVM Function: Pre-compute kernel matrices
    fversion(.15);
    
    fnames                  = fieldnames(encOpts.imdb.sets);
    msk = false(size(fnames));
    for f=1:numel(fnames), msk(f) = encOpts.imdb.sets.(fnames{f}) <= 0; end;
    fnames(msk) = [];
    kBase   = sprintf('%s/kernel_',encOpts.pool.path);
    fBase   = sprintf('%s/%s_',encOpts.pool.path,encOpts.pool.name);
    
    %% Compute the train x train kernel
    kName    = [kBase 'TRN2TRN' '.mat'];
    if exist(kName,'file') ~= 2,
        fprintf('Compute the train x train kernel\n');
        setname     = 'TRAIN';
        setfile     = [fBase setname '.mat'];
        
        assert(ismember('TRAIN',fnames));
        assert(exist(setfile,'file')==2);
        
        fprintf('\t-->Load features %s\n',setfile);
        ftrain      = load(setfile,'X','Xn');
        fprintf('\t-->X [%d x %d]\n',size(ftrain.X));
        
        K           = ftrain.X'*ftrain.X;
        save(kName,'K');
        fprintf('\t-->Saved! K = [%d x %d]\n',size(K));
        fprintf('\t-->File %s\n',kName);
    end
    
    %% Compute the train x val kernel
    msk    = ismember('VAL',fnames);
    if msk,
        kName    = [kBase 'VAL2TRN' '.mat'];
        if exist(kName,'file') ~= 2,
            fprintf('Compute the train x val kernel\n');
            %% Load the train features
            if exist('ftrain','var') ~= 1,
                setname     = 'TRAIN';
                setfile     = [fBase setname '.mat'];
                
                fprintf('\t-->Load features %s\n',setfile);
                ftrain      = load(setfile,'X','Xn');
                fprintf('\t-->X [%d x %d]\n',size(ftrain.X));
            end
            
            %% Load the val features
            if exist('fval','var') ~= 1,
                setname     = 'VAL';
                setfile     = [fBase setname '.mat'];
                
                fprintf('\t-->Load features %s\n',setfile);
                fval        = load(setfile,'X','Xn');
                fprintf('\t-->X [%d x %d]\n',size(fval.X));
            end
            
            K    = fval.X'*ftrain.X;
            save(kName,'K');
            fprintf('\t-->Saved! K = [%d x %d]\n',size(K));
            fprintf('\t-->File %s\n',kName);
        end
    end
    
    %% Compute the trainval x trainval kernel
    msk     = ismember('VAL',fnames);
    if msk,
        kName    = [kBase 'TRV2TRV' '.mat'];
        if exist(kName,'file') ~= 2,
            fprintf('Compute the trainval x trainval kernel\n');
            %% Load the train features
            if exist('ftrain','var') ~= 1,
                setname     = 'TRAIN';
                setfile     = [fBase setname '.mat'];
                
                fprintf('\t-->Load features %s\n',setfile);
                ftrain      = load(setfile,'X','Xn');
                fprintf('\t-->X [%d x %d]\n',size(ftrain.X));
            end
            
            %% Load the val features
            if exist('fval','var') ~= 1,
                setname     = 'VAL';
                setfile     = [fBase setname '.mat'];
                
                fprintf('\t-->Load features %s\n',setfile);
                fval        = load(setfile,'X','Xn');
                fprintf('\t-->X [%d x %d]\n',size(fval.X));
            end
            X = [ftrain.X fval.X];
            K = X'*X;
            clear X;
            save(kName,'K');
            fprintf('\t-->Saved! K = [%d x %d]\n',size(K));
            fprintf('\t-->File %s\n',kName);
        end
    end
    
    %% Compute the trainval x test kernel
    msk     = ismember('VAL',fnames);
    if msk,
        kName    = [kBase 'TST2TRV' '.mat'];
        if exist(kName,'file') ~= 2,
            fprintf('Compute the trainval x test kernel\n');
            %% Load the train features
            if exist('ftrain','var') ~= 1,
                setname     = 'TRAIN';
                setfile     = [fBase setname '.mat'];
                
                fprintf('\t-->Load features %s\n',setfile);
                ftrain      = load(setfile,'X','Xn');
                fprintf('\t-->X [%d x %d]\n',size(ftrain.X));
            end
            
            %% Load the val features
            if exist('fval','var') ~= 1,
                setname     = 'VAL';
                setfile     = [fBase setname '.mat'];
                
                fprintf('\t-->Load features %s\n',setfile);
                fval        = load(setfile,'X','Xn');
                fprintf('\t-->X [%d x %d]\n',size(fval.X));
            end
            X = [ftrain.X fval.X];
            
            %% Load the test features
            if exist('ftest','var') ~= 1,
                setname     = 'TEST';
                setfile     = [fBase setname '.mat'];
                
                fprintf('\t-->Load features %s\n',setfile);
                ftest        = load(setfile,'X','Xn');
                fprintf('\t-->X [%d x %d]\n',size(ftest.X));
            end
            
            K = ftest.X'*X;
            clear X;
            save(kName,'K');
            fprintf('\t-->Saved! K = [%d x %d]\n',size(K));
            fprintf('\t-->File %s\n',kName);
        end
    else
        %% In case there is no validation set, compute the train x test kernel
        kName    = [kBase 'TST2TRN' '.mat'];
        if exist(kName,'file') ~= 2,
            fprintf('Compute the train x test kernel\n');
            %% Load the train features
            if exist('ftrain','var') ~= 1,
                setname     = 'TRAIN';
                setfile     = [fBase setname '.mat'];
                
                fprintf('\t-->Load features %s\n',setfile);
                ftrain      = load(setfile,'X','Xn');
                fprintf('\t-->X [%d x %d]\n',size(ftrain.X));
            end
            
            %% Load the test features
            if exist('ftest','var') ~= 1,
                setname     = 'TEST';
                setfile     = [fBase setname '.mat'];
                
                fprintf('\t-->Load features %s\n',setfile);
                ftest        = load(setfile,'X','Xn');
                fprintf('\t-->X [%d x %d]\n',size(ftest.X));
            end
            K = ftest.X'*ftrain.X;
            save(kName,'K');
            fprintf('\t-->Saved! K = [%d x %d]\n',size(K));
            fprintf('\t-->File %s\n',kName);
        end
    end
end
