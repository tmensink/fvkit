function s = fversion(v)
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
