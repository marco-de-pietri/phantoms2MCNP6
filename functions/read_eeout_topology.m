function [tets,x,y,z,connections,eltypes,elmat,density,volumes]...
     = read_eeout_topology( folder,nome_eeout)
%READ_EEOUT_TOPOLOGY 
%   This function reads the eeout output file created by MCNP6 and it
%   return the description of the unstructured mesh.ATM works only with
%   linear thetrahedral mesh


fid=fopen([folder '/' nome_eeout]);
tline=fgetl(fid);

while strcmp(tline,' NODES X (cm)') < 1
   
    if contains(tline,'NUMBER OF NODES')
        nodes =sscanf(tline,'%*s %*s %*s %*s %d');
    end
     if contains(tline,'NUMBER OF 1st TETS :')
        tets=sscanf(tline,'%*s %*s %*s %*s %*s %d');
     end
    tline=fgetl(fid);
end

i=1;
while i <= nodes
    
    [temp, count]=sscanf(tline,'%e');
    x(i:(i+count-1))=temp;
    tline=fgetl(fid);
    i=i+count;
end

while strcmp(tline,' NODES Y (cm)') < 1

    tline=fgetl(fid);
end

 i=1;
while i <= nodes

    [temp, count]=sscanf(tline,'%e');
    y(i:(i+count-1))=temp;
    tline=fgetl(fid);
    i=i+count;
end

while strcmp(tline,' NODES Z (cm)') < 1

    tline=fgetl(fid);
end

 i=1;
while i <= nodes

    [temp, count]=sscanf(tline,'%e');
    z(i:(i+count-1))=temp;
    tline=fgetl(fid);
    i=i+count;
end

while strcmp(tline,' ELEMENT TYPE') < 1

    tline=fgetl(fid);
end

 i=1;
while i <= tets

    [temp, count]=sscanf(tline,'%d');
    eltypes(i:(i+count-1))=temp;
    tline=fgetl(fid);
    i=i+count;
end

while strcmp(tline,' ELEMENT MATERIAL') < 1

    tline=fgetl(fid);
end

 i=1;
while i <= tets

    [temp, count]=sscanf(tline,'%d');
    elmat(i:(i+count-1))=temp;
    tline=fgetl(fid);
    i=i+count;
end

while strcmp(tline,' CONNECTIVITY DATA 1ST ORDER TETS ELEMENT ORDERED') < 1

    tline=fgetl(fid);
end


 i=1;
while i <= (tets*4)

    [temp, count]=sscanf(tline,'%d');
    connections(i:(i+count-1))=temp;
    tline=fgetl(fid);
    i=i+count;
end

while strcmp(tline,' DENSITY (gm/cm^3)') < 1

    tline=fgetl(fid);
end

 i=1;
while i <= (tets)

    [temp, count]=sscanf(tline,'%e');
    density(i:(i+count-1))=temp;
    tline=fgetl(fid);
    i=i+count;
end


while strcmp(tline,' VOLUMES (cm^3)') < 1

    tline=fgetl(fid);
end

 i=1;
while i <= (tets)

    [temp, count]=sscanf(tline,'%e');
    volumes(i:(i+count-1))=temp;
    tline=fgetl(fid);
    i=i+count;
end

fclose(fid);


end

