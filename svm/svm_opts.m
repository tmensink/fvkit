function so = svm_opts(so,enc)
    % Set SVM options
    %
    % Part of FVKit - initial release
    % Copyright, 2013-2018
    % Thomas Mensink, University of Amsterdam
    % thomas.mensink@uva.nl
    
    if ~isfield(so,'kernel'),     so.kernel         = 0;              end
    if ~isfield(so,'trainOnly'),  so.trainOnly      = 0;              end
    if ~isfield(so,'train'),      so.train          = 0;              end
    if ~isfield(so,'test'),       so.test           = 0;              end
    if ~isfield(so,'C'),          so.C              = 1;              end
    if ~isfield(so,'eval'),       so.eval           = 'nap';          end
    if ~isfield(so,'evalS'),      so.evalS          = 'Non-Interpolated mAP';end
        
    so.path   = enc.pool.path;
end