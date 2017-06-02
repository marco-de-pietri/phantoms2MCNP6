function [ ] = write_vtk_voxel( path3,DSxcord,DSycord,DSzcord,mctal_tallies,tallies_errors,tallies_names,MATDS,MATDATA)
%WRITE_VTK_VOXEL This function writes a vtk file containing the tallies
%read by read_mctal_tallies function. It writes also the relative errors,
%the material labels and densities

lx=(DSxcord(numel(DSxcord))-DSxcord(1))/(numel(DSxcord)-1);
ly=(DSycord(numel(DSycord))-DSycord(1))/(numel(DSycord)-1);
lz=(DSzcord(numel(DSzcord))-DSzcord(1))/(numel(DSzcord)-1);

xnodes=(DSxcord(1)-lx/2):lx:DSxcord(numel(DSxcord))+lx/2;
ynodes=(DSycord(1)-ly/2):ly:DSycord(numel(DSycord))+ly/2;
znodes=(DSzcord(1)-lz/2):lz:DSzcord(numel(DSzcord))+lz/2;

fileID = fopen(path3,'w');
fprintf(fileID,'# vtk DataFile Version 2.1 DEPPO EDITION\n');
fprintf(fileID,'Original file: mctal\n');

fprintf(fileID,'ASCII\n\n');
fprintf(fileID,'DATASET RECTILINEAR_GRID\n');
fprintf(fileID,'DIMENSIONS %d %d %d \n',numel(xnodes),numel(ynodes), numel(znodes));

fprintf(fileID,'X_COORDINATES  %d  float\n',numel(xnodes));
for i=1:numel(xnodes)
fprintf(fileID,' %12.6f\n',xnodes(i));
end

fprintf(fileID,'Y_COORDINATES  %d  float\n',numel(ynodes));
for i=1:numel(ynodes)
fprintf(fileID,' %12.6f\n',ynodes(i));
end

fprintf(fileID,'Z_COORDINATES  %d  float\n',numel(znodes));
for i=1:numel(znodes)
fprintf(fileID,' %12.6f\n',znodes(i));
end

fprintf(fileID,'\nCELL_DATA              %d\n',numel(DSxcord)*numel(DSycord)*numel(DSzcord));

for m=1:numel(tallies_names)
    
    fprintf(fileID,'\nSCALARS  %s  float         1\n',tallies_names(m));
    fprintf(fileID,'LOOKUP_TABLE default\n');
    for k=1:numel(DSzcord)
        for j=1:numel(DSycord)
            for i=1:numel(DSxcord)
                fprintf(fileID,' %.5E\n',mctal_tallies(i,j,k,m));
            end
        end
    end
    
    fprintf(fileID,'\nSCALARS  %s_errors  float         1\n',tallies_names(m));
    fprintf(fileID,'LOOKUP_TABLE default\n');
    for k=1:numel(DSzcord)
        for j=1:numel(DSycord)
            for i=1:numel(DSxcord)
                fprintf(fileID,' %.5E\n',tallies_errors(i,j,k,m));
            end
        end
    end
end

fprintf(fileID,'\nSCALARS  density  float         1\n');
    fprintf(fileID,'LOOKUP_TABLE default\n');
    for k=1:numel(DSzcord)
        for j=1:numel(DSycord)
            for i=1:numel(DSxcord)
                fprintf(fileID,' %.5E\n',MATDATA{(MATDS(i,j,k)),4});
            end
        end
    end

fprintf(fileID,'\nFIELD FieldData       1\n');
fprintf(fileID,'material 1               %d float\n',numel(DSxcord)*numel(DSycord)*numel(DSzcord));
for k=1:numel(DSzcord)
    for j=1:numel(DSycord)
        for i=1:numel(DSxcord)
            fprintf(fileID,'     %d\n',MATDS(i,j,k));
        end
    end
end

fclose(fileID);
end

