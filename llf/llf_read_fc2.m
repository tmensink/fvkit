function [Iloc,Idesc,Isize] = llf_read_fc2(fname,dtOpts)
    %help!
    
    q = load([fname '.mat']);
    tmp = q.im';

    NrD = size(q.im,1);
    Iloc  = [ones(1,NrD); 1:NrD];
    Idesc = tmp;
    Isize = size(tmp);
end
