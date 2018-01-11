function [Iloc,Idesc,Isize] = llf_dsift(jpgfile,dsOpts)
    im              = imread(jpgfile);
    im              = llf_standardizeImage(im,dsOpts.max_pix);
    [Iloc, Idesc]   = llf_dsift_raw(im,dsOpts);
    Isize           = [size(im,2); size(im,1)];


    function im = llf_standardizeImage(im,maxPix)
        % Standardize each image to have a maximum number of pixels
        % Largely copied from the provided code of Chatfield et al.
        
        numPix  = size(im,1)*size(im,2);
        
        if numPix > maxPix,
            im = imresize(im, sqrt(maxPix./numPix));
        end
        if size(im,3) == 1, im = repmat(im,[1 1 3]);    end
        
        im = im2single(im);
    end
    
    function [Iloc, Idesc] = llf_dsift_raw(im,dsOpts)
        switch dsOpts.type
            %case 'RGB'
            %im      = im;
            case 'I'
                im      = rgb2gray(im);
            case 'O'
                % This is an opponent SIFT
                mu      = 0.3*im(:,:,1) + 0.59*im(:,:,2) + 0.11*im(:,:,3) ;
                alpha   = 0.01;
                im      = cat(3, mu, (im(:,:,1) - im(:,:,2))/sqrt(2) + alpha*mu, (im(:,:,1) + im(:,:,2) - 2*im(:,:,3))/sqrt(6) + alpha*mu);
            case 'H'
                % This is a Hue-SIFT variant using only color information
                im = rgb2hsv(im);
                im = im(:,:,[3 1]);         % Use im = im(:,:,[3 1]) to include the intensity channel
        end        
        nChan   = size(im,3);
        
        NrScale = dsOpts.scales;
        
        if dsOpts.upscale,
           NrScale  =  NrScale + 1;
           imO      = im;
           im       = imresize(im,sqrt(2),dsOpts.rszm); 
        end
         
        F       = cell(1,NrScale);
        D       = cell(1,NrScale);               
        
        for s = 1:NrScale,
            if s > 1,
                if s == 1 && dsOpts.upscale,
                    im = imO;
                else
                    im      = imresize(im, sqrt(.5), dsOpts.rszm);   
                end
            end
                        
            for c = 1 : nChan,
                [F_,D_] = vl_dsift(im(:,:,c),'size',dsOpts.bin,'step',dsOpts.step,'fast','floatdescriptors','norm');
                if c == 1,
                    [dDim, nDesc] = size(D_);
                    
                    D{s}        = zeros(nChan*dDim,nDesc);
                    F{s}        = F_;
                                        
                    F{s}(1,:)   = F{s}(1,:) ./ size(im,2);
                    F{s}(2,:)   = F{s}(2,:) ./ size(im,2);                    
                    F{s}(4,:)   = s;
                end
                
                D{s}((c-1)*dDim + (1:dDim),:)   = D_;               
            end
        end                    
        Idesc   = cat(2,D{:});
        Iloc    = cat(2,F{:});
        
        if dsOpts.root,
            Idesc = sqrt(Idesc);
        end
    end
end
