%This script writes the mcnp input file containing the voxel phantom 
%obtained from the voxelization of the abaqus phantom obtained from 
%voxelise_eeout.m  It is possible to provide a material library with the 
%appropriate characteristics. If it is not, these are defined by defaul as 
%air and water.

clear

cartella_eeout=input('insert the folder with eeout_geometry.mat file\n','s');
path1=fullfile(cartella_eeout,'eeout_geometry.mat');
load (path1);
voxel_mat=single(voxel_mat)+1;
mat_number=length(unique(voxel_mat));
MATDATA=cell(mat_number,5);
MATDATA{1,1}='air';
     MATDATA{1,2}=[7014,8016,18040];
     MATDATA{1,3}=[0.7550,0.2320,0.0130];
     MATDATA{1,4}=0.001225;
     MATDATA{1,5}=[0000];
for i=2:mat_number
     MATDATA{i,1}='water';
     MATDATA{i,2}=[1001,8016];
     MATDATA{i,3}=[0.111,0.889];
     MATDATA{i,4}=1.0;
     MATDATA{i,5}=[0000];
end;
     

database=0;
prompt=input('load a material database [yes/no]\n','s');
if strcmp(prompt,'yes')
    database=1;
end

if database==1
    cartella_materials=input('insert folder path of the material database\n','s');
    nome_materials=input('insert material database name\n','s');

    path2=fullfile(cartella_materials,nome_materials);
    [a, b, c]=xlsread(path2);
    [d, e, f]=xlsread(path2,'Sheet2');
    [g, h, i]=xlsread(path2,'Sheet3');
    MATDATA(:,1)=c(:,3);
    MATDATA(:,4)=c(:,4);
    for i=1:mat_number
        MATDATA{i,5}(1,1)=a(i,1);
        MATDATA{i,5}(1,2)=a(i,2);
        MATDATA{i,2}=d(i,:);
        MATDATA{i,2}=MATDATA{i,2}(~isnan(MATDATA{i,2}));
        MATDATA{i,3}=g(i,:);
        MATDATA{i,3}=MATDATA{i,3}(~isnan(MATDATA{i,3}));
    end
end

prompt = 'downscaling by resolution [resolution] or by voxel dimension [dimension] ? \n';
method=input(prompt,'s');

if strcmp(method,'resolution')
    prompt = 'insert desired resolution [X] \n';
    rx = input(prompt);
    lx=(xcord(numel(xcord))-xcord(1))/(rx-1);
    prompt = 'insert desired resolution [Y] \n';
    ry = input(prompt);
    ly=(ycord(numel(ycord))-ycord(1))/(ry-1);
    prompt = 'insert desired resolution [Z] \n';
    rz = input(prompt);
    lz=(zcord(numel(zcord))-zcord(1))/(rz-1);
    DSxcord=single(xcord(1):lx:xcord(1)+lx*(rx-1));
    DSycord=single(ycord(1):ly:ycord(1)+ly*(ry-1));
    DSzcord=single(zcord(1):lz:zcord(1)+lz*(rz-1));
    MATDS=zeros(numel(DSxcord),numel(DSycord),numel(DSzcord),'int16');
    G = griddedInterpolant({xcord,ycord,zcord},voxel_mat,'nearest');
    MATDS=G({DSxcord,DSycord,DSzcord});
    
end

if strcmp(method,'dimension')
    prompt = 'insert voxel dimension (mm) [x] \n';
    lx= input(prompt);
    lx=lx/10;
    prompt = 'insert voxel dimension(mm) [y] \n';
    ly= input(prompt);
    ly=ly/10;
    prompt = 'insert voxel dimension(mm) [z] \n';
    lz= input(prompt);
    lz=lz/10;
    rx=fix((xcord(numel(xcord))-xcord(1))/lx)+1;
    ry=fix((ycord(numel(ycord))-ycord(1))/ly)+1;
    rz=fix((zcord(numel(zcord))-zcord(1))/lz)+1;
    DSxcord=single(xcord(1):lx:xcord(1)+lx*(rx-1));
    DSycord=single(ycord(1):ly:ycord(1)+ly*(ry-1));
    DSzcord=single(zcord(1):lz:zcord(1)+lz*(rz-1));
    MATDS=zeros(numel(DSxcord),numel(DSycord),numel(DSzcord),'int16');
    G = griddedInterpolant({xcord,ycord,zcord},voxel_mat,'nearest');
    MATDS=G({DSxcord,DSycord,DSzcord});

end


nome_input=input('insert MCNP input file name\n','s');
path3=fullfile(cartella_eeout,nome_input);

write_voxel_mcnp(path3,MATDS,DSxcord,DSycord,DSzcord,MATDATA);

path4=fullfile(cartella_eeout,'voxel_geometry.mat');
save(path4,'MATDS','DSxcord','DSycord','DSzcord','MATDATA');


