%This script can compare two tallies. Both can be a lattice tally, a mesh
%tally or a voxelized unstructured mesh tally. The first one is used as
%reference in the percentage difference calculation. The macro structures
%material lists can be provided in order to simplify the plots in the
%second part of the script.

clc
clear

disp('insert tally 1');
disp('tally 1 from mctal or voxelized um?');
prompt=input('[mctal/um]','s');

origin=0;
if strcmp(prompt,'mctal')
    origin=1;
end

if strcmp(prompt,'um')
    origin=2;
end

if origin==1
    cartella_geometry=input('insert path of folder with voxel_geometry.mat\n','s');
    path1=fullfile(cartella_geometry,'voxel_geometry.mat');
    load (path1);
    
    tally1_xcord=DSxcord;
    tally1_ycord=DSycord;
    tally1_zcord=DSzcord;
    
    cartella_mctal=input('insert path of folder with mctal file\n','s');
    path2=fullfile(cartella_mctal,'mctal');
    
    [mctal_tallies,tallies_errors,tallies_names,energy_tally] = read_mctal_tallies(path2,MATDS,MATDATA);
    
    for i=1:numel(tallies_names)
    
        fprintf('tally numeber %u extracted from mctal: %s \n',i,tallies_names(i) );
    end
    
    prompt2=input('\ninsert tally number to use for the comparison\n');
    
    tally1=mctal_tallies(:,:,:,prompt2);
    tally1_errors=tallies_errors(:,:,:,prompt2);
    tally1_name=tallies_names(prompt2);
    
    tally1_mat=MATDS;
    tally1(logical(MATDS==1))=0;
    tally1_errors(logical(MATDS==1))=0;
      
end

if origin==2
    
    
    cartella_eeout_tallies=input('insert path of folder with eeout_tallies.mat\n','s');
    path1=fullfile(cartella_eeout_tallies,'eeout_tallies.mat');
    load (path1);
    tally1=voxel_energy;
    tally1_errors=voxel_energy_error;
    tally1_name='voxelized_energy';
    
    tally1_xcord=xcord;
    tally1_ycord=ycord;
    tally1_zcord=zcord;
    
    tally1_mat=voxel_mat+1;
end

disp('insert tally 2');
disp('tally 2 from mctal or voxelized um?');
prompt=input('[mctal/um]','s');

origin=0;
if strcmp(prompt,'mctal')
    origin=1;
end

if strcmp(prompt,'um')
    origin=2;
end

if origin==1
    cartella_geometry=input('insert path of folder with voxel_geometry.mat\n','s');
    path1=fullfile(cartella_geometry,'voxel_geometry.mat');
    load (path1);
    
    tally2_xcord=DSxcord;
    tally2_ycord=DSycord;
    tally2_zcord=DSzcord;
    
    cartella_mctal=input('insert path of folder with mctal file\n','s');
    path2=fullfile(cartella_mctal,'mctal');
    
    [mctal_tallies,tallies_errors,tallies_names,energy_tally] = read_mctal_tallies(path2,MATDS,MATDATA);
    
    for i=1:numel(tallies_names)
    
        fprintf('tally number %u extracted by mctal: %s \n',i,tallies_names(i) );
    end
    
    prompt2=input('\ninsert tally number to use for the comparison\n');
    
    tally2=mctal_tallies(:,:,:,prompt2);
    tally2_errors=tallies_errors(:,:,:,prompt2);
    tally2_name=tallies_names(prompt2);
    
    tally2(logical(MATDS==1))=0;
    tally2_errors(logical(MATDS==1))=0;
    tally2_mat=MATDS;
    
      
end

if origin==2
    
    
    cartella_eeout_tallies=input('insert path of folder with eeout_tallies.mat\n','s');
    path1=fullfile(cartella_eeout_tallies,'eeout_tallies.mat');
    load (path1);
    tally2=voxel_energy;
    tally2_errors=voxel_energy_error;
    tally2_name='voxelized_energy';
    
    tally2_xcord=xcord;
    tally2_ycord=ycord;
    tally2_zcord=zcord;
    tally2_mat=voxel_mat+1;
end

grid=0;
disp('use comparison grid from DICOM[dicom] or custom[user]?');
prompt=input('[dicom,user]\n','s');
if strcmp(prompt,'dicom')
    grid=1;
end
if strcmp(prompt,'user')
    grid=2;
end


if grid==1
    
    cartella_dicom=input('insert DICOM folder path\n','s');
    [dicominfo,xcomp,ycomp,zcomp]=read_dicom_info(cartella_dicom);

end

if grid==2
    
    fprintf('original resolution tally1: %u x %u x %u \n',numel(tally1_xcord),numel(tally1_ycord),numel(tally1_zcord));
    
    prompt = 'insert resolution [X] \n';
    rx = input(prompt);
    lx=(tally1_xcord(numel(tally1_xcord))-tally1_xcord(1))/(rx-1);
    prompt = 'insert resolution  [Y] \n';
    ry = input(prompt);
    ly=(tally1_ycord(numel(tally1_ycord))-tally1_ycord(1))/(ry-1);
    prompt = 'insert resolution  [Z] \n';
    rz = input(prompt);
    lz=(tally1_zcord(numel(tally1_zcord))-tally1_zcord(1))/(rz-1);
    
    xcomp=tally1_xcord(1):(lx):tally1_xcord(1)+(lx)*(rx-1);
    ycomp=tally1_ycord(1):(ly):tally1_ycord(1)+(ly)*(ry-1);
    zcomp=tally1_zcord(1):(lz):tally1_zcord(1)+(lz)*(rz-1);
    
end

mat_number=length(unique(tally1_mat));
struct_query=0;
disp('insert macrostructure groups?');
prompt=input('[yes/no]\n','s');
if strcmp(prompt,'yes')
    struct_query=1;
end
if strcmp(prompt,'no')
    struct_query=2;
end

if struct_query==1
    struct_list=zeros(mat_number,1);
    struct_list(1)=1;
    for i=2:mat_number
        fprintf('insert group number of material %u \n',i);
        struct_list(i)=input('');
    end
    tally1_struct=zeros(size(tally1_mat));
    
    for i=1:mat_number
        tally1_struct(tally1_mat==i)=struct_list(i);
    end
    tally1_struct_interp = griddedInterpolant({tally1_xcord,tally1_ycord,tally1_zcord},tally1_struct,'nearest');
    tally1_mat_interp = griddedInterpolant({tally1_xcord,tally1_ycord,tally1_zcord},tally1_mat,'nearest');
    tally2_mat_interp = griddedInterpolant({tally2_xcord,tally2_ycord,tally2_zcord},tally2_mat,'nearest');
    tally1_mat_ups=tally1_mat_interp({xcomp,ycomp,zcomp});
    tally2_mat_ups=tally2_mat_interp({xcomp,ycomp,zcomp});
    tally1_struct_ups=tally1_struct_interp({xcomp,ycomp,zcomp});
    
end

if struct_query==2

    tally1_mat_interp = griddedInterpolant({tally1_xcord,tally1_ycord,tally1_zcord},tally1_mat,'nearest');
    tally2_mat_interp = griddedInterpolant({tally2_xcord,tally2_ycord,tally2_zcord},tally2_mat,'nearest');
    tally1_mat_ups=tally1_mat_interp({xcomp,ycomp,zcomp});
    tally2_mat_ups=tally2_mat_interp({xcomp,ycomp,zcomp}); 
    tally1_struct_ups=tally1_mat_ups;
    tally2_struct_ups=tally2_mat_ups;

end

struct_number=length(unique(tally1_struct_ups));


tally1_interp = griddedInterpolant({tally1_xcord,tally1_ycord,tally1_zcord},tally1,'nearest');
tally2_interp = griddedInterpolant({tally2_xcord,tally2_ycord,tally2_zcord},tally2,'nearest');
tally1_ups=tally1_interp({xcomp,ycomp,zcomp});
tally2_ups=tally2_interp({xcomp,ycomp,zcomp});

deltap=zeros(numel(xcomp),numel(ycomp),numel(zcomp));


for k=1:numel(zcomp)
    for j=1:numel(ycomp)
        for i=1:numel(xcomp)
            if (tally1_ups(i,j,k) ~= 0) && (tally2_ups(i,j,k) ~= 0)
                deltap(i,j,k)=100*(abs(tally2_ups(i,j,k)-tally1_ups(i,j,k)))/tally1_ups(i,j,k);
            end
        end
    end
end
                

disp('insert direction to evaluate dose difference');
direction=input('[x,y,z]','s');

if strcmp(direction,'z')

    disp('inserire la coordinata z del piano xy da analizzare le distribuzioni di dose');
    querycord=input('inserire valore in cm, solo invio per uscire\n');

    while (isempty(querycord))==0
    
        figure
        hold on
        [pos, zindex]=min(abs(zcomp-querycord));
        Rdeltap = imref2d(size(deltap(:,:,zindex(1))),[ycomp(1) ycomp(numel(ycomp))],[xcomp(1) xcomp(numel(xcomp))]);
        imshow(deltap(:,:,zindex(1)),Rdeltap,[],'InitialMagnification','fit','Colormap',parula);
        colorbar;
        xlabel('Y')
        ylabel('X')
        
        caxis([0, min([max(max(deltap(:,:,zindex(1)))), 150])]);
        
        contour(ycomp,xcomp,tally1_struct_ups(:,:,zindex(1)),struct_number-1,'k','LineWidth',1);
        hold off
        
        disp('inserire la coordinata z del piano da analizzare le distribuzioni di dose');
        querycord=input('inserire valore in cm, solo invio per uscire\n');

    end
end

if strcmp(direction,'y')

    disp('inserire la coordinata y del piano xz da analizzare le distribuzioni di dose');
    querycord=input('inserire valore in cm, solo invio per uscire\n');

    while (isempty(querycord))==0
    
        figure
        hold on
        [pos, yindex]=min(abs(ycomp-querycord));
        Rdeltap = imref2d(size(squeeze(deltap(:,yindex(1),:))),[zcomp(1) zcomp(numel(zcomp))],[xcomp(1) xcomp(numel(xcomp))]);
        imshow(squeeze(deltap(:,yindex(1),:)),Rdeltap,[],'InitialMagnification','fit','Colormap',parula);
        colorbar;
        xlabel('Z')
        ylabel('X')
        caxis([0, min([max(max(deltap(:,yindex(1),:))), 150])]);
        contour(zcomp,xcomp,squeeze(tally1_struct_ups(:,yindex(1),:)),struct_number-1,'k','LineWidth',1);
        disp('inserire la coordinata y del piano xz da analizzare le distribuzioni di dose');
        querycord=input('inserire valore in cm, solo invio per uscire\n');
        hold off
        
    end
end

if strcmp(direction,'x')

    disp('inserire la coordinata x del piano yz da analizzare le distribuzioni di dose');
    querycord=input('inserire valore in cm, solo invio per uscire\n');

    while (isempty(querycord))==0
    
        figure
        hold on
        [pos, xindex]=min(abs(xcomp-querycord));
        Rdeltap = imref2d(size(squeeze(deltap(xindex(1),:,:))),[zcomp(1) zcomp(numel(zcomp))],[ycomp(1) ycomp(numel(ycomp))]);
        imshow(squeeze(deltap(xindex(1),:,:)),Rdeltap,[],'InitialMagnification','fit','Colormap',parula);
        colorbar;
        xlabel('Z')
        ylabel('Y')
        caxis([0, min([max(max(deltap(xindex(1),:,:))), 150])]);
        contour(zcomp,ycomp,squeeze(tally1_struct_ups(xindex(1),:,:)),struct_number-1,'k','LineWidth',1);
        disp('inserire la coordinata x del piano yz da analizzare le distribuzioni di dose');
        querycord=input('inserire valore in cm, solo invio per uscire\n');
        hold off

    end
end

analysis=0;
failedmask=zeros(numel(xcomp),numel(ycomp),numel(zcomp));

disp('scegliere il tipo di analisi: differenza percentuale[diff], Distance to Agreement[dta]');
disp('o gamma analysis[gamma]?');
prompt=input('[diff/dta/gamma]','s');

if strcmp(prompt,'diff')
    analysis=1;
end
if strcmp(prompt,'dta')
    analysis=2;
end
if strcmp(prompt,'gamma')
    analysis=3;
end

if analysis==1
    
    target=input('inserire il valore percentuale soglia per l''analisi\n');
    perc_passed=100-(100*sum(sum(sum(logical(deltap>=target))))/sum(sum(sum(logical(tally1_mat_ups~=1)))));
    fprintf('percentuale di punti con una differenza inferiore a %3.2f %% : %3.2f %%\n',target,perc_passed);
    failedmask(logical(deltap>=target))= 1;
end

disp('inserire la direzione lungo il quale valutare l''analisi');
direction=input('[x,y,z]','s');
    
if strcmp(direction,'z')

    disp('inserire la coordinata z del piano xy da analizzare ');
    querycord=input('inserire valore in cm, solo invio per uscire\n');

    while (isempty(querycord))==0
    
        figure
        hold on
        [pos, zindex]=min(abs(zcomp-querycord));
        
        Rdeltap = imref2d(size(deltap(:,:,zindex(1))),[ycomp(1) ycomp(numel(ycomp))],[xcomp(1) xcomp(numel(xcomp))]);
        
        red = cat(3, ones(size(deltap(:,:,zindex(1)))), zeros(size(deltap(:,:,zindex(1)))), zeros(size(deltap(:,:,zindex(1)))));
        
        contour(ycomp,xcomp,tally1_struct_ups(:,:,zindex(1)),struct_number-1,'k','LineWidth',1);
       
        xlabel('Y')
        ylabel('X')
        
        mask=imshow(red,Rdeltap,[],'InitialMagnification','fit');
        set(mask, 'AlphaData', failedmask(:,:,zindex(1)))
        
        hold off
        
        disp('inserire la coordinata z del piano da analizzare ');
        querycord=input('inserire valore in cm, solo invio per uscire\n');

    end
end

if strcmp(direction,'y')

    disp('inserire la coordinata y del piano xz da analizzare ');
    querycord=input('inserire valore in cm, solo invio per uscire\n');

    while (isempty(querycord))==0
    
        figure
        hold on
        [pos, yindex]=min(abs(ycomp-querycord));
        
        Rdeltap =  imref2d(size(squeeze(deltap(:,yindex(1),:))),[zcomp(1) zcomp(numel(zcomp))],[xcomp(1) xcomp(numel(xcomp))]);
        red = cat(3, ones(size(squeeze(deltap(:,yindex(1),:)))), zeros(size(squeeze(deltap(:,yindex(1),:)))), zeros(size(squeeze(deltap(:,yindex(1),:)))));
        
        contour(zcomp,xcomp,squeeze(tally1_struct_ups(:,yindex(1),:)),struct_number-1,'k','LineWidth',1);
        
        xlabel('Z')
        ylabel('X')
        
        mask=imshow(red,Rdeltap,[],'InitialMagnification','fit');
        set(mask, 'AlphaData', squeeze(failedmask(:,yindex(1),:)))
        
        hold off
        
        disp('inserire la coordinata y del piano da analizzare ');
        querycord=input('inserire valore in cm, solo invio per uscire\n');

    end
end

if strcmp(direction,'x')

    disp('inserire la coordinata x del piano yz da analizzare ');
    querycord=input('inserire valore in cm, solo invio per uscire\n');

    while (isempty(querycord))==0
    
        figure
        hold on
        [pos, xindex]=min(abs(xcomp-querycord));
        
        Rdeltap = imref2d(size(squeeze(deltap(xindex(1),:,:))),[zcomp(1) zcomp(numel(zcomp))],[ycomp(1) ycomp(numel(ycomp))]);
        red = cat(3, ones(size(squeeze(deltap(xindex(1),:,:)))), zeros(size(squeeze(deltap(xindex(1),:,:)))), zeros(size(squeeze(deltap(xindex(1),:,:)))));
        contour(zcomp,ycomp,squeeze(tally1_struct_ups(xindex(1),:,:)),struct_number-1,'k','LineWidth',1);
        
        xlabel('Z')
        ylabel('Y')
        
        mask=imshow(red,Rdeltap,[],'InitialMagnification','fit');
        set(mask, 'AlphaData', squeeze(failedmask(xindex(1),:,:)))
        
        hold off
        
        disp('inserire la coordinata x del piano da analizzare ');
        querycord=input('inserire valore in cm, solo invio per uscire\n');

    end
end





