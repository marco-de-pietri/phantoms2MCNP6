function [energycell,energyerror, fluxcell,fluxerror] ...
          =read_eeout_tallies(tets,folder,nome_eeout)
%READ_EEOUT_TALLIES Questa funzione legge i tallies di energia e flusso a
%patto che nella simulazione UM sia presente solo un tally di flusso e solo
%uno di energia e che per entrambi sia attivata l'opzione error



energycell_temp=zeros(tets+1,1);
energyerror_temp=zeros(tets+1,1);
energycell=zeros(tets,1);
energyerror=zeros(tets,1);
fluxcell_temp=zeros(tets+1,1);
fluxerror_temp=zeros(tets+1,1);
fluxcell=zeros(tets,1);
fluxerror=zeros(tets,1);


fid=fopen([folder '/' nome_eeout]);
tline=fgetl(fid);

while (contains(tline,'TYPE : ENERGY_')==0)
        tline=fgetl(fid);
     
end

tline=fgetl(fid);
tline=fgetl(fid);
tline=fgetl(fid);
 
 i=1;
while i <= (tets+1)

    [temp, count]=sscanf(tline,'%e');
    energycell_temp(i:(i+count-1))=temp;
    tline=fgetl(fid);
    i=i+count;
end

while (contains(tline,'DATA SETS REL ERROR')==0)
        tline=fgetl(fid);
     
end

i=1;
while i <= (tets+1)

    [temp, count]=sscanf(tline,'%e');
    energyerror_temp(i:(i+count-1))=temp;
    tline=fgetl(fid);
    i=i+count;
end

fclose(fid);

fid=fopen([folder '/' nome_eeout]);
tline=fgetl(fid);


while (contains(tline,'TYPE : FLUX_')==0)
        tline=fgetl(fid);
     
end

tline=fgetl(fid);
tline=fgetl(fid);
tline=fgetl(fid);

i=1;
while i <= (tets+1)

    [temp, count]=sscanf(tline,'%e');
    fluxcell_temp(i:(i+count-1))=temp;
    tline=fgetl(fid);
    i=i+count;
end

while (contains(tline,'DATA SETS REL ERROR')==0)
        tline=fgetl(fid);
     
end


i=1;
while i <= (tets+1)

    [temp, count]=sscanf(tline,'%e');
    fluxerror_temp(i:(i+count-1))=temp;
    tline=fgetl(fid);
    i=i+count;
end

fclose(fid);


energycell(1:tets)=energycell_temp(2:tets+1);
energyerror(1:tets)=energyerror_temp(2:tets+1);
fluxcell(1:tets)=fluxcell_temp(2:tets+1);
fluxerror(1:tets)=fluxerror_temp(2:tets+1);

end

