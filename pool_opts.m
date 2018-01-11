function po = pool_opts(po,enc)
    
    if ~isfield(po,'pool'),     po.pool         = 'F';              end
    if ~isfield(po,'pfunc'),    po.pfunc        = @pool_img;        end
    
    if strcmp(func2str(po.pfunc),'pool_img'),
        po.pyr.doFull   = ~isempty(strfind(po.pool,'F'));
        po.pyr.doHorz   = ~isempty(strfind(po.pool,'H'));
        po.pyr.doQuad   = ~isempty(strfind(po.pool,'Q'));        
        po.NrFV         =  po.pyr.doFull + 3 * po.pyr.doHorz + 4 * po.pyr.doQuad;
        assert(po.NrFV >= 1,'At least F, H, or Q should be switched on');        
    end    

    
    if ~isfield(po,'norm'),         po.norm             = struct;          end
    if ~isfield(po.norm,'pown'),    po.norm.pown        = 0.5;             end
    if ~isfield(po.norm,'l2sub'),   po.norm.l2sub       = true;            end
    if ~isfield(po.norm,'l2fin'),   po.norm.l2fin       = true;            end
    
    
    % Name
    bname   = sprintf('%s_%s_%03d_%1d%1d',func2str(po.pfunc),po.pool,po.norm.pown*100,po.norm.l2sub,po.norm.l2fin);
    if enc.llf.max_feat_fin > 0,
        bname = sprintf('%s_%dN',bname,enc.llf.max_feat_fin);
    end
    
    po.path = sprintf('%s/%s',enc.fv.path,bname);        
    po.name = 'feat';    
end