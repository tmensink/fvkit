function [P, logl] = mixgauss_prob2(data, model)
%MIXGAUSS_PROB2 Summary of this function goes here
%   Detailed explanation goes here

if ~isfield(model, 'var')
    k   = size(model.sigma,3);
    model.var = zeros(size(model.mean));
    for i=1:k
        model.var(:,i)    = diag(model.sigma(:,:,i));
    end
end

if ~isfield(model, 'kConst') || ~isfield(model, 'iC') || ~isfield(model, 'MinvC')
    d               = size(model.mean,1);
    dConst          = .5*d*log(2*pi);               % scalar    normalisation by dimensions

    logDetC         = .5 * sum(log(model.var),1);     % 1 x k     log of determinant of C    
    model.iC        = 1./model.var;                   % d x k     inverse covariance

    model.MinvC     = model.mean .* model.iC;               % d x k     mean weighted with covariance
    MuDst           = .5 * sum(model.mean .* model.MinvC,1);% 1 x k     norm of means (with covariance)

                                            % 1 x k     Constant value per component
    %kConst  = LogW - dConst - logDetC - MuDst;
    model.kConst    = - dConst - logDetC - MuDst;
end
    

Xs      = data.^2;

%% Compute the distance in the exponents:
P       = model.MinvC' * data - .5 * model.iC' * Xs;
S       = bsxfun(@plus,P,model.kConst');
[P, logl] = softmax(S,1);

end

