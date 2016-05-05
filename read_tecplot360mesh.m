function [x,e_conn] = read_tecplot360mesh(tecplot_file,lf) 
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
  
  lf.pmsg(lf.ALL,'==> Enter read_tecplot360mesh.m');
  lf.pmsg(lf.ALL,'    Opening the mesh file.'); 
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
    if strcmp(token,'Z')
      threed = 1;
    end
    tline = fgetl(fid);
    token = strtok(tline,'"');
  end
    
    
  %  Get element information
  %-----------------------------------------------------------------------------
  lf.pmsg(lf.ALL,'    Getting the mesh information.');
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

  lf.pmsg(lf.ALL,'    Setting the element information.');
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
 
  
  n_data_var = n_var-2-threed;
  
  lf.pmsg(lf.ALL,'    Reading in the nodes.');
  if ( strcmp(file_type,'POINT') )
    lf.pmsg(lf.PED,'    ==> Data in POINT format.');
    columns = n_var;
    s_format = [];
    for i=1:columns
      s_format = [ s_format ' %f64' ];
    end

    lf.pmsg(lf.PED,'    ==> Reading node data from file.');
    C = textscan(fid, s_format, n_node);
    lf.pmsg(lf.PED,'        ==> Node data read');
    lf.pmsg(lf.PED,'        ==> Storing nodes to ''x'''); 
    if ( threed )
      x(:,1) = C{1};  x(:,2) = C{2};  x(:,3) = C{3};
    else
      x(:,1) = C{1};  x(:,2) = C{2};
    end
    lf.pmsg(lf.PED,'    ==> Completed reading node data.')
  elseif ( strcmp(file_type,'BLOCK') )
    lf.pmsg(lf.PED,'    ==> Data in BLOCK format.');
    n_lines = ceil(n_node/5);
    s_format = ' %f64 %f64 %f64 %f64 %f64 ';

    lf.pmsg(lf.PED,'    ==> Reading in and storing nodes.')

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
    lf.pmsg(lf.PED,'        ==> Completed.');

    lf.pmsg(lf.PED,'    ==> Skipping over the variable data.');
    textscan(fid, s_format, n_lines*n_data_var, 'HeaderLines', 1);
    lf.pmsg(lf.PED,'        ==> Completed.');


  end

  %   now read connectivity
  %-----------------------------------------------------------------------------
  s_format = [];
  for i=1:n_dof
    s_format = [ s_format ' %d' ];
  end

  lf.pmsg(lf.PED,'    ==> Reading connectivity data from file.');  
  C = textscan(fid, s_format, n_elem, 'HeaderLines', 0);
  lf.pmsg(lf.PED,'    ==> Storing the connectivity data.');
  for n=1:n_dof
    e_conn(:,n) = C{n};
  end
  lf.pmsg(lf.PED,'        ==> Completed.');


  x = x(1:n_node,:);

 
  fclose(fid);
 
  lf.pmsg(lf.ALL,'<== Exiting read_tecplot360mesh.m');
end
