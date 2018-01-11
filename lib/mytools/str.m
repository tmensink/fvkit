function S = str(S,L,flag)
    %Creates a fixed length string
    %
    %Input:
    %   S   String to display
    %   L   Length of string (default 25 characters)
    %   flag 1 = left, 2 = right, 3 = centered
    
    % Thomas Mensink, 2009
    if nargin < 2 || isempty(L), L = 25; end
    if nargin < 3 || isempty(flag), flag = 1; end
    
    if ~ischar(S),
        S = char(S);
    end
    Sl = length(S);
    if Sl > L,
        S = S(1:L);
    elseif Sl < L,
        switch flag
            case 1
                S = [S,blanks(L-Sl)];
            case 2
                S = [blanks(L-Sl),S];
            case 3
                nrb1 = floor((L-Sl)/2);
                nrb2 = L - Sl - nrb1;
                S = [blanks(nrb1),S,blanks(nrb2)];
        end
    end