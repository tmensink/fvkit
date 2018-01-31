function delpath(CPath)
    %Removes these path without warning from existing path
    %
    % Part of FVKit - initial release
    % Copyright, 2013-2018
    % Thomas Mensink, University of Amsterdam
    % thomas.mensink@uva.nl
    
    ps      = pathsep;
    cmdirs  = regexp([matlabpath ps],['.[^' ps ']*' ps],'match')';
    
    if iscell(CPath);
        for i=1:numel(CPath),
            CPath{i} = [CPath{i} ':'];
        end
    else
        CPath = regexp([CPath ps],['.[^' ps ']*' ps],'match')';
    end
    [ism,inx] = ismember(CPath,cmdirs);
    
    if any(ism),
        cmdirs(inx(ism)) = [];
        matlabpath([cmdirs{:}])
    end
end