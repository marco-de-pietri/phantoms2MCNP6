% This script voxelises the structure and the tallies results obtained in a
% MCNP6 simulation containing an unstructured mesh in abaqus format. ATM it
% works only with linear tethraedral meshes containing only one energy
% and/or flux tally which encompass the whole phantom. The voxelization
% grid can be extracted from dicom files or inserted by the user

clear
clc
cartella_eeout=input('insert eeout folder\n','s');
nome_eeout=input('insert eeout file name\n','s');

[num_tets,xnodes,ynodes,znodes,connections,eltypes,eeout_materials,density,...
    volumes]=read_eeout_topology(cartella_eeout,nome_eeout);

tallies=0;
prompt=input('voxellize the tallies? [yes/no]\n','s');
if strcmp(prompt,'yes')
    tallies=1;
end

if (tallies == 1)
  [eeout_energy,energy_error,eeout_flux,flux_error]=read_eeout_tallies(num_tets,cartella_eeout,...
     nome_eeout);
end




grid=0;
disp('voxel grid from DICOM[dicom] o custom[user]?');
prompt=input('[dicom,user]\n','s');
if strcmp(prompt,'dicom')
    grid=1;
end
if strcmp(prompt,'user')
    grid=2;
end


if grid==1
    
    cartella_dicom=input('insert dicom folder\n','s');
    [dicominfo,xcord,ycord,zcord]=read_dicom_info(cartella_dicom);

end

if grid==2
 
    disp(['x nodes range : ',num2str(min(xnodes)),' ',num2str(max(xnodes))]);
    disp(['y nodes range : ',num2str(min(ynodes)),' ',num2str(max(ynodes))]);
    disp(['z nodes range : ',num2str(min(znodes)),' ',num2str(max(znodes))]);
    
    prompt = 'insert voxel dimension 1 (mm) [ x ] \n';
    lx= input(prompt);
    prompt = 'insert voxel dimension 2 (mm) [ y ] \n';
    ly= input(prompt);
    prompt = 'insert voxel dimension 3 (mm) [ z ] \n';
    lz= input(prompt);
    rx=fix((max(xnodes)-min(xnodes))/(lx/10))+1;
    ry=fix((max(ynodes)-min(ynodes))/(ly/10))+1;
    rz=fix((max(znodes)-min(znodes))/(lz/10))+1;
    xcord=min(xnodes):(lx/10):min(xnodes)+(lx/10)*(rx-1);
    ycord=min(ynodes):(ly/10):min(ynodes)+(ly/10)*(ry-1);
    zcord=min(znodes):(lz/10):min(znodes)+(lz/10)*(rz-1);
end



    
disp(['range coord x : ',num2str(xcord(1)),' ',num2str(xcord(numel(xcord))),' num pixel: ',num2str(numel(xcord))]);
disp(['range coord y : ',num2str(ycord(1)),' ',num2str(ycord(numel(ycord))),' num pixel: ',num2str(numel(ycord))]);
disp(['range coord z : ',num2str(zcord(1)),' ',num2str(zcord(numel(zcord))),' num pixel: ',num2str(numel(zcord))]);

voxel_mat=zeros(numel(xcord),numel(ycord),numel(zcord),'single');
if (tallies == 1)
    voxel_energy=zeros(numel(xcord),numel(ycord),numel(zcord),'single');
    voxel_energy_error=zeros(numel(xcord),numel(ycord),numel(zcord),'single');
    voxel_flux=zeros(numel(xcord),numel(ycord),numel(zcord),'single');
    voxel_flux_error=zeros(numel(xcord),numel(ycord),numel(zcord),'single');
end


disp('starting unstructured mesh voxelization');

CONNECTIONTABLE=zeros(num_tets,4,'double');
for i=1:num_tets
    CONNECTIONTABLE(i,:)=connections(((i-1)*4+1):((i-1)*4+4));
end

TR=triangulation(CONNECTIONTABLE,[xnodes' ynodes' znodes']);
for k=1:numel(zcord)
    for j=1:numel(ycord)
        for i=1:numel(xcord)
            found=0;
            found=pointLocation(TR, [xcord(i) ycord(j) zcord(k)]);
                if isnan(found) == 0
                    voxel_mat(i,j,k)=eeout_materials(found);
                    if (tallies == 1)
                        voxel_energy(i,j,k)=eeout_energy(found);
                        voxel_energy_error(i,j,k)=energy_error(found);
                        voxel_flux(i,j,k)=eeout_flux(found);
                        voxel_flux_error(i,j,k)=flux_error(found);
                    end
                    
                end
                if isnan(found) == 1
                    voxel_mat(i,j,k)=0;
                    if (tallies == 1)
                        voxel_energy(i,j,k)=0;
                        voxel_energy_error(i,j,k)=0;
                        voxel_flux(i,j,k)=0;
                        voxel_flux_error(i,j,k)=0;
                    end
                end
            
        end
    end
    fprintf('layer %d completed\n',k);
end


path1=fullfile(cartella_eeout,'eeout_geometry.mat');
save(path1,'voxel_mat','xcord','ycord','zcord');
if (tallies == 1)
    path2=fullfile(cartella_eeout,'eeout_tallies.mat');
    save(path2,'voxel_mat','xcord','ycord','zcord','voxel_energy','voxel_energy_error','voxel_flux','voxel_flux_error');
end
disp('done'); 
