function [Iloc,Idesc,Isize] = llf_read_dt(fname,dtOpts)
    %Read the DT files from Impala (UvA)
    
    % Impala Definition:
    % The features are computed one by one, and each one in a single line, with the following format:
    %
    % frameNum mean_x mean_y var_x var_y length scale x_pos y_pos t_pos Trajectory HOG HOF MBHx MBHy
    %
    % The first 10 elements are information about the trajectory:
    %
    % frameNum:     The trajectory ends on which frame
    % mean_x:       The mean value of the x coordinates of the trajectory
    % mean_y:       The mean value of the y coordinates of the trajectory
    % var_x:        The variance of the x coordinates of the trajectory
    % var_y:        The variance of the y coordinates of the trajectory
    % length:       The length of the trajectory
    % scale:        The trajectory is computed on which scale
    % x_pos:        The normalized x position w.r.t. the video (0~0.999), for spatio-temporal pyramid
    % y_pos:        The normalized y position w.r.t. the video (0~0.999), for spatio-temporal pyramid
    % t_pos:        The normalized t position w.r.t. the video (0~0.999), for spatio-temporal pyramid
    %
    % The following element are five descriptors concatenated one by one:
    %
    % Trajectory:    2x[trajectory length] (default 30 dimension)
    % HOG:           8x[spatial cells]x[spatial cells]x[temporal cells] (default 96 dimension)
    % HOF:           9x[spatial cells]x[spatial cells]x[temporal cells] (default 108 dimension)
    % MBHx:          8x[spatial cells]x[spatial cells]x[temporal cells] (default 96 dimension)
    % MBHy:          8x[spatial cells]x[spatial cells]x[temporal cells] (default 96 dimension)
    %
    % Standard classification: PCA -> 128, FV met 256, powernormalisatie met 0.25;
    if nargin < 1, fname = '/datastore/koelma/VisualSearch/hollywood2/DenseTrajectories/Resized_200W/actioncliptrain00823.avi.dt'; end
    
    [~,n1,~] = fileparts(fname);
    %[~,n1,d1] = fileparts(fname);
    %[~,~ ,e2] = fileparts(n1);
    %if strcmp(e1,'dt') == 0 && strcmp(e2,'avi') == 0,
    %    fname = [fname '.avi.dt'];
    %end
    %
    %tmp  = load(fname);
    [msk,inx] = ismember([n1 '.avi.dt'],dtOpts.C);
    assert(msk == 1,'%s not found',fname);
    imsk = (dtOpts.mmap.Data.DTinx(inx)+1):1:dtOpts.mmap.Data.DTinx(inx+1);

    %Iinf = 1:10;
    %Itra = 11:40;
    Ihog = 41:136;
    Ihof = 137:244;
    Imbhx= 245:340;
    Imbhy= 341:436;
    
    msk = [];
    if dtOpts.dHog,     msk = [msk Ihog];   end
    if dtOpts.dHof,     msk = [msk Ihof];   end
    if dtOpts.dMBHx,    msk = [msk Imbhx];   end
    if dtOpts.dMBHy,    msk = [msk Imbhy];   end
    
    if ~isempty(imsk), 
      tmp = dtOpts.mmap.Data.DTfeat(:,imsk);
    else
      tmp = zeros(size(dtOpts.mmap.Data.DTfeat,1),1);
    end
    Iloc  = tmp(2:3,:);
    Idesc = tmp(msk,:);
    Isize = [numel(msk), size(tmp,1)];
end
