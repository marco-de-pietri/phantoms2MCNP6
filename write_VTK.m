%this script write the vtk file of simulation involving unstructured mesh
%phantoms or voxel models from the abaqus phantoms. Voxel models obtained
%by voxelise_writeMCNP.m

clc
clear

mevtocgy=1.602176565E-8;
target=0;
disp('write VTK from unstructured mesh simulation [um], or voxel[voxel]');

prompt=input('[um/voxel]\n','s');
if strcmp(prompt,'um')
    target=1;
end
if strcmp(prompt,'voxel')
     target=2;
end


if target==1
   cartella_eeout=input('insert eeout path folder\n','s');
   nome_eeout=input('insert eeout file name\n','s');

   [num_tets,xnodes,ynodes,znodes,connections,eltypes,eeout_materials,density,...
    volumes]=read_eeout_topology(cartella_eeout,nome_eeout);

   [eeout_energy,energy_error,eeout_flux,flux_error]=read_eeout_tallies(num_tets,cartella_eeout,...
     nome_eeout);
 
   prompt=input('convert MeV/g to cGy?[yes/no]\n','s');
   if strcmp(prompt,'yes')
       eeout_energy=eeout_energy*mevtocgy;
   end
     
   
   prompt=input('scale the results? [yes/no]\n','s');
   if strcmp(prompt,'yes')
       norm=input('insert scale factor\n');
       eeout_energy=eeout_energy*norm;
       eeout_flux=eeout_flux*norm;
       
   end
 
    nome_vtk=input('insert vtk file name\n','s');
    path3=fullfile(cartella_eeout,nome_vtk);
    write_vtk_um(path3,num_tets,xnodes,ynodes,znodes,connections,eeout_energy,energy_error,eeout_flux,flux_error,density,eeout_materials);

end

%This will be changed in the c++ version


if target==2
    cartella_geometry=input('insert path of folder containing voxel_geometry.mat\n','s');
    path1=fullfile(cartella_geometry,'voxel_geometry.mat');
    load (path1);
    
    cartella_mctal=input('insert path folder containing mctal file\n','s');
    path2=fullfile(cartella_mctal,'mctal');
    
    [mctal_tallies,tallies_errors,tallies_names,energy_tally] = read_mctal_tallies(path2,MATDS,MATDATA);
    
    prompt=input('convert MeV/g to cGy?[yes/no]\n','s');
    if strcmp(prompt,'yes')
       mctal_tallies(:,:,:,logical(energy_tally))=mctal_tallies(:,:,:,logical(energy_tally))*mevtocgy;
    end
    
    prompt=input('scale the results?[yes/no]\n','s');
   if strcmp(prompt,'yes')
       norm=input('insert a scale factor\n');
       mctal_tallies=mctal_tallies*norm;
       
       
   end
    
    nome_vtk=input('insert a vtk file name\n','s');
    path3=fullfile(cartella_mctal,nome_vtk);
    
    write_vtk_voxel(path3,DSxcord,DSycord,DSzcord,mctal_tallies,tallies_errors,tallies_names,MATDS,MATDATA);
end

    
    
