function R = exp_run_feat(dataset,F,T,P,GB,EM,K,SP,FV,N,enc0)
    % Run a series of experiments defined by the input options:
    %
    % Input
    % dataset   = 'VOC2007';                                        %Dataset
    % F         = {'dsft','dt'};                                    %Local feature
    % T         = {'I','O','H'};                                    %Feature type
    % P         = 32:16:128;                                        %PCA dimensions
    % EM        = {'splitem'};                                      %EM algorithms
    % K         = [16 32 64 128 256];                               %NrGaussians
    % SP        = {'F','FH','FHQ'};                                 %Spatial Pyramids
    % FV        = {[0 1 1],[1 0 0],[0 1 0],[0 0 1],[1 1 1]};        %Fisher vectors [W M V]
    % N         = {[0 0 0],[1 0 0],[0 1 0],[1 1 0]};                %Normalisations
    % enc0      = enc options for all experiments                   (optional)
    %
    % Note: not all available options are set with this function
    %
    % Part of FVKit - initial release
    % Copyright, 2013-2018
    % Thomas Mensink, University of Amsterdam
    % thomas.mensink@uva.nl
    
    
    assert(nargin >= 10,'%s requires 10 or 11 inputs see help',mfilename);
    if nargin < 11, enc0 = struct;       end
    
    NrExp   = prod([numel(F),numel(T),numel(P),numel(GB),numel(K),numel(EM),numel(SP),numel(FV),numel(N)]);
    fprintf('%s | %s | Run %d experiments\n',mfilename,datestr(now,31),NrExp);
    if NrExp > 100, fprintf('\t-->Are you sure to run %d experiments?\n',NrExp);keyboard; end
    
    fprintf('\t--> Dataset %s\n',dataset);
    R       = cell(1,NrExp);
    
    cnt     = 0;
    for f=1:numel(F),
        for t=1:numel(T)
            for p=1:numel(P),
                for g=1:numel(GB),
                    for em=1:numel(EM),
                        for k=1:numel(K),
                            for sp=1:numel(SP),
                                for fv=1:numel(FV),
                                    for n=1:numel(N),
                                        cnt = cnt+1;
                                        enc = enc0;
                                        
                                        enc.llf.feat       = F{f};
                                        if ~isempty(T{t}),
                                            enc.llf.(enc.llf.feat) = struct;
                                            enc.llf.(enc.llf.feat).type = T{t};
                                        end
                                        enc.pca.pdim        = P(p);
                                        enc.prob.base       = GB{g};
                                        enc.prob.method     = EM{em};
                                        enc.prob.k          = K(k);
                                        enc.fv.opts.gWeight = FV{fv}(1);
                                        enc.fv.opts.gMean   = FV{fv}(2);
                                        enc.fv.opts.gVar    = FV{fv}(3);
                                        enc.pool.pool       = SP{sp};
                                        enc.pool.norm.sqrt  = N{n}(1);
                                        enc.pool.norm.l2sub = N{n}(2);
                                        enc.pool.norm.l2fin = N{n}(3);
                                        r.enc               = enc;
                                        
                                        [~, r.R] = enc_pipeline_feat(enc,dataset);
                                        R{cnt} = r;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end