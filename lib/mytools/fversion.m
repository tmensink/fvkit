function s = fversion(v)
    % Prints version of file
    %
    % Part of FVKit - initial release
    % Copyright, 2013-2018
    % Thomas Mensink, University of Amsterdam
    % thomas.mensink@uva.nl

    if nargin < 1 || ~isnumeric(v), v = .01;        end

    dbs = dbstack(1);
    if isempty(dbs),
        cfname = 'Matlab Command Window';
    else
        cfname = dbs.name;
    end
    
    s = sprintf('%s | v %7.4f | start %s at %s\n',str(cfname),v,datestr(now,31),hostname);
    if nargout < 1,
        fprintf('%s',s);clear(s);
    end
end
