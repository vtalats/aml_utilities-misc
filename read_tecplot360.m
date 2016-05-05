function [x,e_conn,data,variables,soln_time] = read_tecplot360(tecplot_file) 
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
    error('teplot filename must be provided');
  end
  
  fid = fopen(tecplot_file);
  if (fid==-1)
    error('teplot file %s cannot be opened',tecplot_file);
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
  while ~strncmp(token,'ZONE',4)
    if ~strncmp(token,'DATASET',7)
      n_var = n_var + 1;
      variables{n_var} = token;
    end
    if strcmp(token,'Z')
      threed = 1;
    end
    tline = fgetl(fid);
    token = strtok(tline,'"');
  end
    
    
  %  Get element information
  %-----------------------------------------------------------------------------
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
      end

      if ( strcmp(keyword,'E') || strcmp(keyword,'Elements') )
        n_elem = eval(value);
      end

      if ( strcmp(keyword,'ET') || strcmp(keyword,'ZONETYPE') )
        element_type = value;
      end

      if ( strcmp(keyword,'F') || strcmp(keyword,'DATAPACKING') )
        file_type = value;
      end

      if ( strcmp(keyword,'SOLUTIONTIME') )
        soln_time = str2double(value);
      end
    end
  end

  if ( strcmp(element_type,'FETriangle') )
    e_conn = zeros(n_elem,3);
    n_dof  = 3;
  elseif ( strcmp(element_type,'FETetrahedron') )
    e_conn = zeros(n_elem,4);
    n_dof  = 4;
  elseif ( strcmp(element_type,'FEQuadrilateral') )
    e_conn = zeros(n_elem,8);
    n_dof  = 8;
  end
%   
%   % test for a blank line
%   [tline] = fgetl(fid);
%   if (isempty(tline))
%     header = 4;
%   else
%     header = 3;
%   end
%  
  %fclose(fid);
 
%   %***********************************************************************
%   % The following is just hard-coded to test the data import below.  This
%   % code should be deleted prior to real usage.
%   variables = {'X','Y','Z','C','U','V','W'};
%   n_var = 7;
%   n_dof = 4;
%   n_elem = 20;
%   n_node = 13;
%   e_conn = zeros(n_elem,4);
%   file_type = 'BLOCK';
%   header = 16;
%   threed = 1;
%   % End of code to be deleted.
%   %***********************************************************************
  
  n_data_var = n_var-2-threed;
  
  %  Re-open file and read in data
  %-----------------------------------------------------------------------------
  %fid = fopen(tecplot_file);
  ts = 1;
  while ~feof(fid)
    
    if ( strcmp(file_type,'POINT') )
      columns = n_var;
      s_format = [];
      for i=1:columns
        s_format = [ s_format ' %f64' ];
      end

      C = textscan(fid, s_format, n_node);
  %     C = textscan(fid, s_format, n_node, 'HeaderLines', header);

      if ( threed )
        x(:,1) = C{1};  x(:,2) = C{2};  x(:,3) = C{3};
        for n=4:n_var
          data(:,n-3) = C{n};
        end
      else
        x(:,1) = C{1};  x(:,2) = C{2};
        for n=3:n_var
          data(:,n-2) = C{n};
        end
      end

    elseif ( strcmp(file_type,'BLOCK') )

      n_lines = ceil(n_node/5);
      s_format = ' %f64 %f64 %f64 %f64 %f64 ';

      if (ts == 1)
        C = textscan(fid, s_format, n_lines);

        T(:,1) = C{1};
        T(:,2) = C{2};
        T(:,3) = C{3};
        T(:,4) = C{4};
        T(:,5) = C{5};
        x(:,1) = reshape(T',5*n_lines,1);

        C = textscan(fid, s_format, n_lines, 'HeaderLines', 1);
        T(:,1) = C{1};
        T(:,2) = C{2};
        T(:,3) = C{3};
        T(:,4) = C{4};
        T(:,5) = C{5};
        x(:,2) = reshape(T',5*n_lines,1);

        if ( threed )
          C = textscan(fid, s_format, n_lines, 'HeaderLines', 1);
          T(:,1) = C{1};
          T(:,2) = C{2};
          T(:,3) = C{3};
          T(:,4) = C{4};
          T(:,5) = C{5};
          x(:,3) = reshape(T',5*n_lines,1);
        end
      else
        textscan(fid, s_format, n_lines*(2+threed));
      end


      for n=1:n_data_var
        C = textscan(fid, s_format, n_lines, 'HeaderLines', 1);
        T(:,1) = C{1};
        T(:,2) = C{2};
        T(:,3) = C{3};
        T(:,4) = C{4};
        T(:,5) = C{5};
        curr_col = ((ts-1)*n_data_var)+n;
        data(:,curr_col) = reshape(T',5*n_lines,1);
      end


    end

    %   now read connectivity
    %-----------------------------------------------------------------------------
    s_format = [];
    for i=1:n_dof
      s_format = [ s_format ' %d' ];
    end

    C = textscan(fid, s_format, n_elem, 'HeaderLines', 1);
    
    if (ts == 1)
      for n=1:n_dof
        e_conn(:,n) = C{n};
      end
    end

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
  
  x = x(1:n_node,:);

  if ( n_var-2-threed )
    data = data(1:n_node,:);
  end

 
  fclose(fid);
 
   
end
