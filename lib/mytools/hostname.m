function hn = hostname
    % Print hostname of computer
    %
    % Part of FVKit - initial release
    % Copyright, 2013-2018
    % Thomas Mensink, University of Amsterdam
    % thomas.mensink@uva.nl
    
    [~, hn] = system('hostname');
    if ~isletter(hn(end)),
        hn = hn(1:end-1);
    end
    
    if nargout < 1,
        fprintf('Hostname %s\n',hn);
        clear hn
    end
end