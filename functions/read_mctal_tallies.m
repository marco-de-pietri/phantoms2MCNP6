function [mctal_tallies,tallies_errors,tallies_names,energy_tally ] = read_mctal_tallies( path_mctal,MATDS,MATDATA )
%READ_MCTAL_TALLIES This function takes as a input the complete address of
%the mctal file, it can reads both meshtallies and lattice tallies. The
%size of these must correspond to the MATDS size as this contain the
%material matrix, to convert the energy-to-volume to energy-to-mass (dose) 
%it can read only flux and delivered energy tallies, it requests which are
%energy tallies,in order to divide them for the density

tally_count=0;
dim_matrix=size(MATDS);
mctal_tallies=zeros(dim_matrix(1),dim_matrix(2),dim_matrix(3),20);
tallies_errors=zeros(dim_matrix(1),dim_matrix(2),dim_matrix(3),20);
tallies_names=strings(20,1);

num_voxel=dim_matrix(1)*dim_matrix(2)*dim_matrix(3);
fid=fopen(path_mctal);
tline=fgetl(fid);

while ischar(tline)
    
    while (strncmp(tline,'tally',5)==0)
        tline=fgetl(fid);
        if tline==-1
            break
        end
    end
    if (strncmp(tline,'tally',5)==1)
        
    temp_name=sscanf(tline,'%*s %u');
    tline=fgetl(fid);
    tline=fgetl(fid);
    temp_numb=sscanf(tline,'%*s %u');
    
   if temp_numb(1)==num_voxel
       
       while (contains(tline,'s')==0)
        tline=fgetl(fid);
       end
       
      num_mesh=sscanf(tline,'%*s %u');
      
      if (num_mesh(1)==0)
          num_mesh(1)=1;
      end
        num_read=num_voxel*num_mesh(1)*2;
        tempdata=zeros(num_read,1);
       
       while (contains(tline,'vals')==0)
        tline=fgetl(fid);
     
       end
       tline=fgetl(fid);
       i=1;
       while i<=num_read
           [temp, count]=sscanf(tline,'%13e %7e %13e %7e %13e %7e %13e %7e');
           tempdata(i:(i+count-1))=temp;
           i=i+count;
           tline=fgetl(fid);
       end
       
       if (length(tempdata)/num_voxel)==2
           
           tally_count=tally_count+1;
           tallies_names(tally_count)=['tally_' int2str(temp_name(1))];
           temp_values=tempdata(1:2:length(tempdata));
           temp_errors=tempdata(2:2:length(tempdata));
           temp_matrix_values=zeros(size(MATDS));
           temp_matrix_errors=zeros(size(MATDS));
           for k = 1: dim_matrix(3)
                for j = 1: dim_matrix(2)
                     for i = 1: dim_matrix(1)
                        temp_matrix_values(i,j,k) = temp_values(i+(j-1)*dim_matrix(1)+(k-1)*dim_matrix(2)*dim_matrix(1));
                        temp_matrix_errors(i,j,k) = temp_errors(i+(j-1)*dim_matrix(1)+(k-1)*dim_matrix(2)*dim_matrix(1));       
                     end
                end 
           end
           mctal_tallies(:,:,:,tally_count)=temp_matrix_values;
           tallies_errors(:,:,:,tally_count)=temp_matrix_errors;
       end
       
        if (length(tempdata)/num_voxel)==4
            
            tallies_names(tally_count+1)=['tally_' int2str(temp_name(1)) '_1'];
            tallies_names(tally_count+2)=['tally_' int2str(temp_name(1)) '_2'];
            temp_values_1=tempdata(1:4:length(tempdata));
            temp_errors_1=tempdata(2:4:length(tempdata));
            temp_values_2=tempdata(3:4:length(tempdata));
            temp_errors_2=tempdata(4:4:length(tempdata));
            temp_matrix_values_1=zeros(size(MATDS));
            temp_matrix_errors_1=zeros(size(MATDS));
            temp_matrix_values_2=zeros(size(MATDS));
            temp_matrix_errors_2=zeros(size(MATDS));
            
            for k = 1: dim_matrix(3)
                for j = 1: dim_matrix(2)
                     for i = 1: dim_matrix(1)
                        temp_matrix_values_1(i,j,k) = temp_values_1(i+(j-1)*dim_matrix(1)+(k-1)*dim_matrix(2)*dim_matrix(1));
                        temp_matrix_errors_1(i,j,k) = temp_errors_1(i+(j-1)*dim_matrix(1)+(k-1)*dim_matrix(2)*dim_matrix(1));
                        temp_matrix_values_2(i,j,k)= temp_values_2(i+(j-1)*dim_matrix(1)+(k-1)*dim_matrix(2)*dim_matrix(1));
                        temp_matrix_errors_2(i,j,k) = temp_errors_2(i+(j-1)*dim_matrix(1)+(k-1)*dim_matrix(2)*dim_matrix(1));
        
                     end
                end 
            end
           
            mctal_tallies(:,:,:,tally_count+1)=temp_matrix_values_1;
            tallies_errors(:,:,:,tally_count+1)=temp_matrix_errors_1;
            mctal_tallies(:,:,:,tally_count+2)=temp_matrix_values_2;
            tallies_errors(:,:,:,tally_count+2)=temp_matrix_errors_2;
            tally_count=tally_count+2;
        end
   end
   end
end

fprintf('mctal reading completed: %d tallies recorded\n',tally_count);
mctal_tallies=mctal_tallies(:,:,:,1:tally_count);
tallies_errors=tallies_errors(:,:,:,1:tally_count);
tallies_names=tallies_names(1:tally_count,1);
energy_tally=zeros(tally_count,1);

for m=1:tally_count
    fprintf('is tally %s a delivered energy tally?\n',tallies_names(m) );
    prompt=input('[yes/no]\n','s');
    if (prompt=='yes')
        
      for k = 1: dim_matrix(3)
                for j = 1: dim_matrix(2)
                     for i = 1: dim_matrix(1)
                        mctal_tallies(i,j,k,m) = mctal_tallies(i,j,k,m)/MATDATA{(MATDS(i,j,k)),4};
                        
        
                     end
                end 
      end 
            
      energy_tally(m)=1;
    end
end
    



