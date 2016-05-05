function [data,variables,soln_time] = read_tecplot360data(tecplot_file,lf) 
%-------------------------------------------------------------------------------
%  READ_TECPLOT360:  A MATLAB function that reads in a tecplot file and 
%                 extracts nodes, connectivity as well as other variables.
%
%                 Assumes ONE ZONE and finite element data types:
%                    FETriangle, FETetrahedron
%                    FEQuadrilateral
%                    
%  Usage:  [x,e_conn,data,variables,soln_time] = read_tecplot(tecplot_file)
%
%  Variables:
%                x
%                e_conn
%                data        a n_nodes x n_variables array containing
%                            the finite element data
%                variables   names of the variables
%                soln_time   array containing solution times
%
%  Version: 1.0
%
%  Author: Alan Lattimer, 2015
%    Based on read_tecplot.m v1.3 by Jeff Borggaard, 2013
%
%
%-------------------------------------------------------------------------------

  if (nargin==0)
    error('tecplot filename must be provided');
  end
  
  lf.pmsg(lf.ALL,'==> Enter read_tecplot360data.m');
  lf.pmsg(lf.ALL,'    Opening the data file.');
  fid = fopen(tecplot_file);
  if (fid==-1)
    error('tecplot file %s cannot be opened',tecplot_file);
  end

  %  Skip over the title
  %-----------------------------------------------------------------------------
  [~] = fgetl(fid);

  %  Get variable names (parse a comma-separated string)
  %-----------------------------------------------------------------------------
  tline = fgetl(fid);                      % read VARIABLES = ... string
%   tline = tline(strfind(tline,'=')+1:end); % remove "VARIABLES ="
  [~,remain] = strtok(tline,'"');
  token = strtok(remain,'"'); % remove "VARIABLES ="
  n_var = 0;
  threed = 0;
  
  lf.pmsg(lf.ALL,'    Reading in the variable header');
  while ~strncmp(token,'ZONE',4)
    if ~strncmp(token,'DATASET',7)
      n_var = n_var + 1;
      variables{n_var} = token;
    end
    if strncmp(token,'Z',1)
      threed = 1;
    end
    tline = fgetl(fid);
    token = strtok(tline,'"');
  end
    
    
  %  Get element information
  %-----------------------------------------------------------------------------
  lf.pmsg(lf.ALL,'    Getting the element information.');
  for k=1:4
    tline = fgetl(fid);

    % assume all keywords are separated by commas
    segments = [0 strfind(tline,',') length(tline)+1];
    for i=1:length(segments)-1
      substring = tline(segments(i)+1 : segments(i+1)-1);
      equal_position = strfind(substring,'=');
      keyword = strtok(substring(1:equal_position-1));
      value   = strtok(substring(equal_position+1:end));

      if ( strcmp(keyword,'N') || strcmp(keyword,'Nodes') )
        n_node = eval(value);
        lf.pmsg(lf.PED,'      - Number of nodes: %d',n_node);
      end

      if ( strcmp(keyword,'E') || strcmp(keyword,'Elements') )
        n_elem = eval(value);
        lf.pmsg(lf.PED,'      - Number of elements: %d',n_elem);
      end

      if ( strcmp(keyword,'ET') || strcmp(keyword,'ZONETYPE') )
        element_type = value;
        lf.pmsg(lf.PED,'      - Zone type: %s',element_type);
      end

      if ( strcmp(keyword,'F') || strcmp(keyword,'DATAPACKING') )
        file_type = value;
        lf.pmsg(lf.PED,'      - Data packing: %s',file_type);
      end

      if ( strcmp(keyword,'SOLUTIONTIME') )
        soln_time = str2double(value);
        lf.pmsg(lf.PED,'      - Solution time: %4.2f',soln_time);
      end
    end
  end

  lf.pmsg(lf.ALL,'    Setting the element information.');
  if ( strcmp(element_type,'FETriangle') )
    n_dof  = 3;
  elseif ( strcmp(element_type,'FETetrahedron') )
    n_dof  = 4;
  elseif ( strcmp(element_type,'FEQuadrilateral') )
    n_dof  = 8;
  end
 
  
  n_data_var = n_var;
  
  ts = 1;
  while ~feof(fid)
    
    if ( strcmp(file_type,'POINT') )
      s_format = [];
      for i=1:columns
        s_format = [ s_format ' %f64' ];
      end

      C = textscan(fid, s_format, n_node);
      lf.pmsg(lf.PED,'    Reading data.');
      for n=1:n_var
        data(:,n) = C{n};
      end
      
    elseif ( strcmp(file_type,'BLOCK') )

      n_lines = ceil(n_node/5);
      s_format = ' %f64 %f64 %f64 %f64 %f64 ';

%       lf.pmsg(lf.PED,'    Skipping over the node data.');
%       textscan(fid, s_format, n_lines*(2+threed));
      
      lf.pmsg(lf.PED,'    Reading data.');
      for n=1:n_data_var
        C = textscan(fid, s_format, n_lines, 'HeaderLines', 0);
        T(:,1) = C{1};
        T(:,2) = C{2};
        T(:,3) = C{3};
        T(:,4) = C{4};
        T(:,5) = C{5};
%         curr_col = ((ts-1)*n_data_var)+n;
        data(:,n) = reshape(T',5*n_lines,1);
      end


    end

    %   now read connectivity
    %-----------------------------------------------------------------------------
    lf.pmsg(lf.PED,'    Skipping over the element connectivity.');
    s_format = [];
    for i=1:n_dof
      s_format = [ s_format ' %d' ];
    end

    C = textscan(fid, s_format, n_elem, 'HeaderLines', 0);
    
    fgetl(fid); %move to the next line
    % If we have not reached the end of file, read next time step.
    if ~feof(fid)
      for k=1:5
        tline = fgetl(fid);
        segments = [0 strfind(tline,',') length(tline)+1];

        if length(segments)>2
          substring = tline(segments(end-1)+1 : segments(end)-1);
          equal_position = strfind(substring,'=');
          keyword = strtok(substring(1:equal_position-1));
          value   = strtok(substring(equal_position+1:end));
          if ( strcmp(keyword,'SOLUTIONTIME') )
            ts = ts + 1;
            soln_time(ts) = str2double(value);
          end
        end
      end
    end
    

    
  end %WHILE
  
  data = data(1:n_node,:);

 
  fclose(fid);
 
  lf.pmsg(lf.ALL,'<== Exiting read_tecplot360data.m');
  
end
