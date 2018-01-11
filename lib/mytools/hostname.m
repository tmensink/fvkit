function hn = hostname
    [st hn] = system('hostname');
    if ~isletter(hn(end)),
        hn = hn(1:end-1);
    end
    
    if nargout < 1,
        fprintf('Hostname %s\n',hn);
        clear hn
    end
end