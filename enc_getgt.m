function gt = enc_getgt(encOpts)
    nrC= numel(encOpts.imdb.classes.imageIds);
    fn = fieldnames(encOpts.imdb.sets);
    
    for f = 1:numel(fn),
        setval = encOpts.imdb.sets.(fn{f});
        imgids = encOpts.imdb.images.id(encOpts.imdb.images.set == setval);
        
        gtf    = zeros(numel(imgids),nrC);
        for c=1:nrC;
            gtf(:,c) = ismember(imgids,encOpts.imdb.classes.imageIds{c});
        end
        
        gt.(fn{f}) = gtf;
    end
end