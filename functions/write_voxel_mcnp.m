function [  ] = write_voxel_mcnp(path_mcnp,MATDS,xcord,ycord,zcord,MATDATA)
%WRITE_VOXEL_MCNP This function writes an mcnp input file containing a 
%voxel phantom described in the MATDS matrix. Takes as input 1)File path
%2) MATDS, 3D matrix containing the material labels.3)The coordinates of 
%voxels centers, in cm.4) MATDATA a matrix containing the materials
%data



nummat= length(unique(MATDS));
volumes=zeros(1,nummat);
lx=(xcord(numel(xcord))-xcord(1))/(numel(xcord)-1);
ly=(ycord(numel(ycord))-ycord(1))/(numel(ycord)-1);
lz=(zcord(numel(zcord))-zcord(1))/(numel(zcord)-1);
for i=1:nummat
    volumes(i)=(nnz(MATDS==i))*(lx)*(ly)*(lz);
end

fileID = fopen(path_mcnp,'w');
fprintf(fileID,'Title INPUTMCNP_Voxel\n c     \n');
fprintf(fileID,'  998 0 -2 1  -4 3  -6  5             fill=999 (%4.4f %4.4f %4.4f)\n',(xcord(1)-lx/2),(ycord(1)-ly/2),(zcord(1)-lz/2));
fprintf(fileID,'999 0 -8 7 -10 9 -12 11 u=999 lat=1 fill=0:%d 0:%d 0:%d ',(numel(xcord)-1),(numel(ycord)-1),(numel(zcord)-1));
fprintf(fileID,'\n');

for k=1:numel(zcord)
    for j=1:numel(ycord)
        for i=1:numel(xcord)
           if i==1 && k==1 && j==1
               newline = cat(2,'     ',int2str(MATDS(1,j,1)));
               rep=0;
           end
           if i==1 && (k~=1 || j~=1) 
             newel=cat(2,' ',int2str(MATDS(i,j,k)));
             if length(cat(2,newline,newel)) <= 80
                newline = cat(2,newline,newel);
              else
                fprintf(fileID,newline);
                newline =  cat(2,'\n     ',newel);
              end
             rep=0;
           end
           
           if (i>1) 
               if MATDS(i,j,k)== MATDS(i-1,j,k)
                   rep=rep+1;
                   if i==numel(xcord)
                      newel=cat(2,' ',int2str(rep),'r');
                      if length(cat(2,newline,newel)) <= 80
                            newline = cat(2,newline,newel);
                        else
                            fprintf(fileID,newline);
                            newline =  cat(2,'\n     ',newel);
                      end
                   end
               else
                   if rep ~= 0
                        newel=cat(2,' ',int2str(rep),'r');
                        rep=0;
                        if length(cat(2,newline,newel)) <= 80
                            newline = cat(2,newline,newel);
                        else
                            fprintf(fileID,newline);
                            newline =  cat(2,'\n     ',newel);
                        end
                        newel=cat(2,' ',int2str(MATDS(i,j,k)));
                        if length(cat(2,newline,newel)) <= 80
                            newline = cat(2,newline,newel);
                        else
                            fprintf(fileID,newline);
                            newline =  cat(2,'\n     ',newel);
                        end
                   else
                        newel=cat(2,' ',int2str(MATDS(i,j,k)));
                        if length(cat(2,newline,newel)) <= 80
                            newline = cat(2,newline,newel);
                        else
                            fprintf(fileID,newline);
                            newline =  cat(2,'\n     ',newel);
                        end
                   end
               end
               
           end
        end
    end
end

fprintf(fileID,newline);

fprintf(fileID,'\n   1  1 -%3.6f -8 7 -10 9 -12 11    vol=%5.4f  u=1',MATDATA{1,4},volumes(1));
for i=2:nummat
   fprintf(fileID,'\n   %d like 1 but mat=%d  rho=-%3.4f  vol=%5.4f  u=%d',i,i,MATDATA{i,4},volumes(i),i);
end

fprintf(fileID,'\n c outside voxel region');
fprintf(fileID,'\n 997  1 -%3.4f  (2:-1: 4: -3 : 6 : -5) -92 -94 -96 91 93 95',MATDATA{1,4});
fprintf(fileID,'\n c resto del mondo');
fprintf(fileID,'\n 996  0  92 : 94 : 96 : -91 : -93 : -95');
fprintf(fileID,'\n');
fprintf(fileID,'\n 1 px  %3.4f',(xcord(1)-lx/2));
fprintf(fileID,'\n 2 px  %3.4f',((xcord(numel(xcord)))+lx/2));
fprintf(fileID,'\n 3 py  %3.4f',(ycord(1)-ly/2));
fprintf(fileID,'\n 4 py  %3.4f',((ycord(numel(ycord)))+ly/2));
fprintf(fileID,'\n 5 pz  %3.4f',(zcord(1)-lz/2));
fprintf(fileID,'\n 6 pz  %3.4f',((zcord(numel(zcord)))+lz/2));
fprintf(fileID,'\n 7 px   0');
fprintf(fileID,'\n 8 px  %3.4f',lx);
fprintf(fileID,'\n 9 py   0');
fprintf(fileID,'\n 10 py %3.4f',ly);
fprintf(fileID,'\n 11 pz   0');
fprintf(fileID,'\n 12 pz %3.4f',lz);
fprintf(fileID,'\n c superfici resto del mondo');
fprintf(fileID,'\n 91 px  %3.4f',(xcord(1)-(xcord(numel(xcord))-xcord(1))*5));
fprintf(fileID,'\n 92 px  %3.4f',((xcord(numel(xcord)))+(xcord(numel(xcord))-xcord(1))*5));
fprintf(fileID,'\n 93 py  %3.4f',(ycord(1)-(ycord(numel(ycord))-ycord(1))*5));
fprintf(fileID,'\n 94 py  %3.4f',((ycord(numel(ycord)))+(ycord(numel(ycord))-ycord(1))*5));
fprintf(fileID,'\n 95 pz  %3.4f',(zcord(1)-(zcord(numel(zcord))-zcord(1))*5));
fprintf(fileID,'\n 96 pz  %3.4f',((zcord(numel(zcord)))+(zcord(numel(zcord))-zcord(1))*5));
fprintf(fileID,'\n');

fprintf(fileID,'\n mode p e');
fprintf(fileID,'\n imp:p 1 %dr 0',nummat+2);
fprintf(fileID,'\n imp:e 1 %dr 0',nummat+2);

for i=1:nummat
   fprintf(fileID,'\n c   %s',MATDATA{i,1});
   for j=1:length(MATDATA{i,3})
       if j==1
           newline = cat(2,'\n m',int2str(i));
       end
       newel=cat(2,'  ',int2str(MATDATA{i,2}(1,j)),'  -',num2str(MATDATA{i,3}(1,j)));
       if length(cat(2,newline,newel)) <= 80
                newline = cat(2,newline,newel);
              else
                fprintf(fileID,newline);
                newline =  cat(2,'\n     ',newel);
       end
       if j==length(MATDATA{i,3})
           fprintf(fileID,newline);
       end
   end
              
end


fprintf(fileID,'\nsdef \n');

fprintf(fileID,'nps  \n');
fprintf(fileID,'prdmp j j 1 1 j \n');
fprintf(fileID,'tmesh\n');
fprintf(fileID,'rmesh993 \n');
fprintf(fileID,'cora993 %3.4f %di %3.4f \n',(xcord(1)-lx/2),(numel(xcord)-1),(xcord(numel(xcord))+lx/2));
fprintf(fileID,'corb993 %3.4f %di %3.4f \n',(ycord(1)-ly/2),(numel(ycord)-1),(ycord(numel(ycord))+ly/2));
fprintf(fileID,'corc993 %3.4f %di %3.4f \n',(zcord(1)-lz/2),(numel(zcord)-1),(zcord(numel(zcord))+lz/2));

fprintf(fileID,'rmesh991:p flux pedep \n');
fprintf(fileID,'cora991 %3.4f %di %3.4f \n',(xcord(1)-lx/2),(numel(xcord)-1),(xcord(numel(xcord))+lx/2));
fprintf(fileID,'corb991 %3.4f %di %3.4f \n',(ycord(1)-ly/2),(numel(ycord)-1),(ycord(numel(ycord))+ly/2));
fprintf(fileID,'corc991 %3.4f %di %3.4f \n',(zcord(1)-lz/2),(numel(zcord)-1),(zcord(numel(zcord))+lz/2));

fprintf(fileID,'rmesh881:e flux pedep \n');
fprintf(fileID,'cora881 %3.4f %di %3.4f \n',(xcord(1)-lx/2),(numel(xcord)-1),(xcord(numel(xcord))+lx/2));
fprintf(fileID,'corb881 %3.4f %di %3.4f \n',(ycord(1)-ly/2),(numel(ycord)-1),(ycord(numel(ycord))+ly/2));
fprintf(fileID,'corc881 %3.4f %di %3.4f \n',(zcord(1)-lz/2),(numel(zcord)-1),(zcord(numel(zcord))+lz/2));
fprintf(fileID,'endmd \n');

fclose(fileID);
end

