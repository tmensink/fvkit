function st= touch(fn)
    if nargin < 1 || isempty(fn), error('%s requires a filename',mfilename);    end
    
    st = system(sprintf('touch %s',fn));
end