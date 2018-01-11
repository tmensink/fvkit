function smmParams = smm_opts(smmParams)
    % Sets default parameters used in EM
    
    if nargin < 1 || isempty(smmParams),      smmParams = struct;                   end
    
    if ~isfield(smmParams,'Seed'),            smmParams.Seed            = 42;       end
    if ~isfield(smmParams,'MaxIter'),         smmParams.MaxIter         = 100;      end
    if ~isfield(smmParams,'LlhDiffThr'),      smmParams.LlhDiffThr      = 0.001;    end
    
    if ~isfield(smmParams,'Name'),            smmParams.Name            = [];       end
    if ~isfield(smmParams,'k'),               smmParams.k               = 16;       end
    
    if ~isfield(smmParams,'updateNu'),        smmParams.updateNu        = 0;         end
    if ~isfield(smmParams,'nu'),              smmParams.nu              = 10;        end
    if ~isfield(smmParams,'diagCov'),         smmParams.diagCov         = 1;         end
    %if ~isfield(smmParams,'init'),           smmParams.init            = 'GMM';     end    
    
    %if ~isfield(smmParams,'MinPost'),         smmParams.MinPost         = 1e-4;     end
    %if ~isfield(smmParams,'WeightPrior'),     smmParams.WeightPrior     =  100;     end
    %if ~isfield(smmParams,'MinGamma'),        smmParams.MinGamma        = 1e-4;     end  
    %if ~isfield(smmParams,'VarFloor'),        smmParams.VarFloor        = 1e-9;     end
    %if ~isfield(smmParams,'VarFloorFactor'),  smmParams.VarFloorFactor  = .01;      end
     
