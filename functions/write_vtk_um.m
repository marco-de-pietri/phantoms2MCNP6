function [] = write_vtk_um( path_vtk,num_tets,xnodes,ynodes,znodes,connections,eeout_energy,energy_error,eeout_flux,flux_error,density,eeout_materials)
%WRITE_VTK_UM This funvtion write a vtk file containing the flux and
%delivered energy reported in the eeout file. ATM it works only with linear
%tetrahedral meshes
fileID = fopen(path_vtk,'w');
fprintf(fileID,'# vtk DataFile Version 2.1 DEPPO EDITION\n');
fprintf(fileID,'Original file: eeout\n');
fprintf(fileID,'ASCII\n\n');
fprintf(fileID,'DATASET UNSTRUCTURED_GRID\n');

fprintf(fileID,'POINTS                %d float\n',numel(xnodes));
for i=1:numel(xnodes)
fprintf(fileID,' %12.6f %12.6f %12.6f\n',xnodes(i),ynodes(i),znodes(i));
end

fprintf(fileID,'\nCELLS   %d  %d\n',num_tets, num_tets*5);
for i=1:num_tets
fprintf(fileID,'4 %11d %11d %11d %11d\n',connections((i-1)*4+1)-1,connections((i-1)*4+2)-1,connections((i-1)*4+3)-1,connections((i-1)*4+4)-1);
end

fprintf(fileID,'\nCELL_TYPES       %d\n',num_tets);
for i=1:num_tets
fprintf(fileID,'  10\n');
end

fprintf(fileID,'\nCELL_DATA              %d\n',num_tets);
fprintf(fileID,'\nSCALARS ENERGY  float         1\n');
fprintf(fileID,'LOOKUP_TABLE default\n');
for i=1:num_tets
fprintf(fileID,' %.5E\n',eeout_energy(i));
end


fprintf(fileID,'\nSCALARS ENERGY_REL_ERROR  float         1\n');
fprintf(fileID,'LOOKUP_TABLE default\n');
for i=1:num_tets
fprintf(fileID,' %.5E\n',energy_error(i));
end


fprintf(fileID,'\nSCALARS FLUX  float         1\n');
fprintf(fileID,'LOOKUP_TABLE default\n');
for i=1:num_tets
fprintf(fileID,' %.5E\n',eeout_flux(i));
end


fprintf(fileID,'\nSCALARS FLUX_REL_ERROR  float         1\n');
fprintf(fileID,'LOOKUP_TABLE default\n');
for i=1:num_tets
fprintf(fileID,' %.5E\n',flux_error(i));
end

fprintf(fileID,'\nFIELD FieldData       1\n');
fprintf(fileID,'density 1               %d float\n',num_tets);
for i=1:num_tets
fprintf(fileID,' %.5E\n',density(i));
end

fprintf(fileID,'\nFIELD FieldData       1\n');
fprintf(fileID,'material 1               %d float\n',num_tets);
for i=1:num_tets
fprintf(fileID,'     %d\n',eeout_materials(i));
end


end

