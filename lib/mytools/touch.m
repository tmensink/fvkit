function st= touch(fn)
    % Touch a file
    %
    % Part of FVKit - initial release
    % Copyright, 2013-2018
    % Thomas Mensink, University of Amsterdam
    % thomas.mensink@uva.nl
    
    if nargin < 1 || isempty(fn), error('%s requires a filename',mfilename);    end
    
    st = system(sprintf('touch %s',fn));
end