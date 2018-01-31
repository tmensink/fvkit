% Download script for PASCAL VOC 2007 train and test data
%
% Part of FVKit - initial release
% Copyright, 2013-2017
% Thomas Mensink, University of Amsterdam
% thomas.mensink@uva.nl

%% PASCAL VOC 2007
% Website http://host.robots.ox.ac.uk/pascal/VOC/voc2007/
if exist('./VOCdevkit/VOC2007/ImageSets/Main/train.txt','file')~=2,
    if exist('VOCtrainval_06-Nov-2007.tar','file') ~= 2,
        fprintf('Download VOCtrainval\n');
        if ismac,
            !curl -o VOCtrainval_06-Nov-2007.tar http://host.robots.ox.ac.uk/pascal/VOC/voc2007/VOCtrainval_06-Nov-2007.tar
        else
            !wget http://host.robots.ox.ac.uk/pascal/VOC/voc2007/VOCtrainval_06-Nov-2007.tar
        end
    end
    fprintf('Extract VOCtrainval\n');
    !tar -xf VOCtrainval_06-Nov-2007.tar
end

if exist('./VOCdevkit/VOC2007/ImageSets/Main/test.txt','file')~=2,
    if exist('VOCtest_06-Nov-2007.tar','file') ~= 2,
        fprintf('Download VOCtest\n');
        if ismac,
            !curl -o VOCtest_06-Nov-2007.tar http://host.robots.ox.ac.uk/pascal/VOC/voc2007/VOCtest_06-Nov-2007.tar
        else
            !wget http://host.robots.ox.ac.uk/pascal/VOC/voc2007/VOCtest_06-Nov-2007.tar
        end
    end
    fprintf('Extract VOCtest\n');
    !tar -xf VOCtest_06-Nov-2007.tar
end

fprintf('VOC2007 dataset is ready\n');

% IMDB file (in git repository) is obtained from:
%   Ken Chatfield (et al.) Project about Evaluation of Encoders
%   The Devil is in the details, BMVC 2011
%   Main: http://www.robots.ox.ac.uk/~vgg/research/encoding_eval/
%   Code: http://www.robots.ox.ac.uk/~vgg/software/enceval_toolkit/