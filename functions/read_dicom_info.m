function [Info,xcord,ycord,zcord ] = read_dicom_info( dicom_folder)
%READ_DICOM_INFO This function takes as input the folder adress containing
%the DICOM files. It reads the files and return the pixel coordinates. It
%is important that in the folder there shoud be only the DICOM files and
%only one series of it

i=1;
dicomlist=dir(dicom_folder);
for n = 1 : numel(dicomlist) 
    if startsWith(dicomlist(n).name,'.')
        removelist(i)=n;
        i=i+1;
    end
end
dicomlist(removelist)=[];

for n = 1 : numel(dicomlist) 
    Info{n} = dicominfo(fullfile(dicom_folder,dicomlist(n).name));
    if n==1
        srID=Info{n}.SeriesInstanceUID;
        InitialX = (Info{1}.ImagePositionPatient(1));
        XSpacing=(Info{1}.PixelSpacing(1));
        Columns=double(Info{1}.Columns);
        FinalX=InitialX+XSpacing*(Columns-1);
        Rows=double(Info{1}.Rows);
        InitialY=double((Info{1}.ImagePositionPatient(2)));
        YSpacing=(Info{1}.PixelSpacing(2));
        FinalY=(InitialY+YSpacing*(Rows-1));
        InitialZ = (Info{1}.ImagePositionPatient(3));
        Z=zeros(1,numel(dicomlist));
                
    end
   
 if srID==Info{n}.SeriesInstanceUID
        srID=Info{n}.SeriesInstanceUID;
        Z(n)=single((Info{n}.ImagePositionPatient(3)));
 end
    
    if n==numel(dicomlist)
        FinalZ=(Info{numel(dicomlist)}.ImagePositionPatient(3));
        ZSpacing=abs((FinalZ-InitialZ)/(n-1));
    end
end

if (InitialX < FinalX)
    xcord=(InitialX:XSpacing:FinalX)/10;
else
    xcord=(Finalx:XSpacing:InitialX)/10;
end

if (InitialY < FinalY)
    ycord=(InitialY:YSpacing:FinalY)/10;
else
    ycord=(FinalY:YSpacing:InitialY)/10;
end

if (InitialZ < FinalZ)
    zcord=(InitialZ:ZSpacing:FinalZ)/10;
else
    zcord=(FinalZ:ZSpacing:InitialZ)/10;
end

end

