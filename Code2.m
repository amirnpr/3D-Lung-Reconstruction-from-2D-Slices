% read and convert to 3D

dir_name = uigetdir('"C:\Users\Lenovo\Dropbox\My PC (DESKTOP-BHVANOA)\Desktop\data_2');
files=dir(dir_name);
endInstanceNumber=numel(files)-2;
startInstanceNumber=1;
inputSize=endInstanceNumber-startInstanceNumber+1;
sliceCounts=inputSize;

for i=3:numel(files)
    file_name=fullfile(dir_name,files(i).name);
    info=dicominfo(file_name);
    
    if((info.InstanceNumber>=startInstanceNumber) && (info.InstanceNumber<=endInstanceNumber))
    slicearray=dicomread(info);
    inputSlices(:,:,info.InstanceNumber-startInstanceNumber+1)= slicearray(:,:);
    end
end
[FileName,PathName]=uiputfile({'*.mat'},'Save Dicom Source','C:\Users\Lenovo\Dropbox\My PC (DESKTOP-BHVANOA)\Desktop\New folder');
fullFileName=fullfile(PathName,FileName);
save(fullFileName,'inputSlices');
load('C:\Users\Lenovo\Dropbox\My PC (DESKTOP-BHVANOA)\Desktop\New folder\R_Data2','inputSlices');

T=inputSlices;
T = im2single(T);
XY = T(:,:,86); % center slice in xy (172/2)
XZ = squeeze(T(256,:,:)); %center slice in xz (512/2)
% for xy
BW = XY > 5.098000e-01;
BW = imcomplement(BW);
BW = imclearborder(BW);
BW = imfill(BW, 'holes');
radius = 3;
decomposition = 0;
se = strel('disk', radius, decomposition);
BW = imerode(BW, se);
maskedImageXY = XY;
maskedImageXY(~BW) = 0;
% for xz
BT = XZ > 5.098000e-01;
BT = imcomplement(BT);
BT = imfill(BT, 'holes');
radiust = 3;
decompositiont = 0;
set = strel('disk', radiust, decompositiont);
BT = imerode(BT, set);
maskedImageXZ = XZ;
maskedImageXZ(~BT) = 0;
% imshow(maskedImageXY),title('maskedImageXY'),figure,imshow(maskedImageXZ),title('maskedImageXZ')
% Seed Mask
mask = false(size(T));
mask(:,:,86) = maskedImageXY;
mask(256,:,:) = mask(256,:,:)|reshape(maskedImageXZ,[1,512,172]);
T = histeq(T);
BW = activecontour(T,mask,100,'Chan-Vese');
X = T.*single(BW);
volumeViewer(X)

