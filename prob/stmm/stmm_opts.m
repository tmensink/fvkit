function gopts = stmm_opts(gopts,enc)
    % Sets default parameters used in STMM
    
    if nargin < 1 || isempty(gopts),      gopts = struct;                       end
    
    if ~isfield(gopts,'Name'),        gopts.Name            = [];               end
    if ~isfield(gopts,'k'),           gopts.k               = 128;              end
    if ~isfield(gopts,'seed'),        gopts.seed            = 9835;             end
    if ~isfield(gopts,'iter'),        gopts.iter            = 100;              end
    if ~isfield(gopts,'method'),      gopts.method          = 'splitem';        end     %Or devilsem or yaelem
    
    switch gopts.method
        case {'splitem'}
            
            if ~isfield(gopts,'splitem'),     gopts.splitem         = struct;           end
            if ~isfield(gopts.splitem,'rpl'), gopts.splitem.rpl     = 0;                end
            bname = sprintf('stmm_%s',gopts.method);
            if gopts.splitem.rpl > 0,
                bname = sprintf('%s_rpl',bname);
            end
            
        case {'hmm'}
            if ~isfield(gopts,'hmm'),     gopts.hmm             = struct;           end
            if ~isfield(gopts.hmm,'init'),gopts.init            = 'splitem';        end            
            bname = sprintf('stmm_hmm_%s',gopts.init);
    end
    
    if ~isfield(gopts,'opts'),            gopts.opts            = struct;   end
    if ~isfield(gopts.opts,'MinPost'),         gopts.opts.MinPost         = 1e-4;     end
    if ~isfield(gopts.opts,'WeightPrior'),     gopts.opts.WeightPrior     =  100;     end
    if ~isfield(gopts.opts,'MinGamma'),        gopts.opts.MinGamma        = 1e-4;     end
    if ~isfield(gopts.opts,'MaxIter'),         gopts.opts.MaxIter         = 100;      end
    if ~isfield(gopts.opts,'VarFloor'),        gopts.opts.VarFloor        = 1e-9;     end
    if ~isfield(gopts.opts,'VarFloorFactor'),  gopts.opts.VarFloorFactor  = .01;      end
    if ~isfield(gopts.opts,'LlhDiffThr'),      gopts.opts.LlhDiffThr      = 0.001;    end
    
    if ~isfield(gopts.opts,'updateNu'),        gopts.opts.updateNu        = 0;         end
    if ~isfield(gopts.opts,'nu'),              gopts.opts.nu              = 10;        end
    if ~isfield(gopts.opts,'diagCov'),         gopts.opts.diagCov         = 1;         end
    
    
    
    gopts.path  = sprintf('%s/%s',enc.pca.path,enc.pca.name);
    
    if gopts.iter ~= 100,  bname = sprintf('%s_%di',bname,gopts.iter);   end
    if gopts.seed ~= 9835, bname = sprintf('%s_%ds',bname,gopts.seed);   end
    
    gopts.bname = sprintf('%s_N%5.0e',bname,gopts.opts.nu);
    
    gopts.name  = sprintf('%s_K%04d',gopts.bname,gopts.k);
    gopts.file  = sprintf('%s/%s.mat',gopts.path,gopts.name);
end