function [M, z] = normalize(A, dim)
    % NORMALISE Make the entries of a (multidimensional) array sum to 1
    % [M, c] = normalise(A)
    % c is the normalizing constant
    %
    % [M, c] = normalise(A, dim)
    % If dim is specified, we normalise the specified dimension only,
    % otherwise we normalise the whole array.
    
    % (c) 2011, Jakob Verbeek
    
    if nargin<2;
        dim=0;
    end
    
    if dim==0
        z = sum(A(:));
        if z == 0,  M = A;
        else        M = (1/z) * A;        end
    else
        z = sum(A,dim);
        s = z + (z==0);     % Set any zeros to one before dividing
                            % This is valid, since c=0 => all i. A(i)=0 => the answer should be 0/1=0        
        M = bsxfun(@times, A, s.^-1); % JJV 2011
    end
end