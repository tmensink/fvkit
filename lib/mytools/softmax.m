function  [p, z] = softmax(p,d)
    % SoftMax function 
    %    
    % computes the softmax p = exp(e)/sum(exp(e))
    % sums are taken over dimension d (which defaults to 1)
    % avoiding numerical underflow
    %
    % Input 
    %  e    matrix of values
    %  d    dimensionality to take sums (default = 1)
    % 
    % Output
    %  p    softmaxed matrix
    %  z    log sum exp of p
    %
    % J.J. Verbeek, 2006, 2011
    % Thomas Mensink, 2013
    
    if nargin<2; d=1;end

    m = max(p,[],d);
    p = bsxfun(@minus,p,m);
    p = exp(p);
    z = sum(p,d);
    
    p = bsxfun(@times,p,z.^-1);
    z = m + log(z);
end