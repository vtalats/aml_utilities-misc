function [ x, e_conn, u, v, w, timesteps ] = import_big_fluent( data_prefix, mesh_file, get_mesh, loglevel )
%IMPORT_BIG_FLUENT Imports mesh and velocity data from multiple tecplot360 files.
%                  where the mesh and data files are separate
%              These tecplot360 files contain data generated from fluent.
%
%                 Assumes ONE ZONE and finite element data types:
%                    FETriangle, FETetrahedron
%                    FEQuadrilateral
%                    
%  Usage:  [ x, e_conn, u, v, w, timesteps ] = import_fluent( data_prefix, loglevel )
%
%  Variables:
%     Input
%                data_prefix  file name prefix for data files being
%                             imported - e.g. data_name_ would import the
%                             files data_name_*.dat
%                mesh_file    file name for the data file containing the mesh
%                get_mesh     flag to indicate whether to import mesh data:
%                               0 - data only
%                               1 - mesh only
%                               2 - mesh and data (default)
%                loglevel     default is 2, set to 99 for everything
%     Output
%                x            node points
%                e_conn       node connection matrix
%                u,v,w        velocity
%                timesteps    array containing solution times
%
%  Version: 1.0
%
%  Author: Alan Lattimer, 2015
%
%-------------------------------------------------------------------------------
  
  % Setup logging
  logName = [datestr(now,'mmddyyyy') '.ifl'];
  if nargin < 4
    loglevel = 2;
  end
  if nargin < 3
    get_mesh = 0;
  end
  
  lf = Msgcl(loglevel,logName);

  lf.pmsg(lf.ALL,'**********************************************');
  lf.pmsg(lf.ALL,'* import_big_fluent');
  lf.pmsg(lf.ALL,'*   Version 1.0, Author: Alan Lattimer, 2015');
  lf.pmsg(lf.ALL,'*');
  lf.pmsg(lf.ALL,'* Current loglevel: %d',loglevel);
  lf.pmsg(lf.ALL,'*');
  if get_mesh 
    lf.pmsg(lf.WARN,'*   Mesh file  : %s',mesh_file);
  end
  if get_mesh == 0 || get_mesh == 2
    lf.pmsg(lf.WARN,'*   Data files : %s*.dat',data_prefix);
  end
  lf.pmsg(lf.WARN,'*');
  lf.pmsg(lf.ERR,'* NOTE: This function assumes that the state');
  lf.pmsg(lf.ERR,'*       space is the same for all data files.');
  lf.pmsg(lf.ERR,'**********************************************');

  if get_mesh
    lf.pmsg(lf.ERR,'Loading the mesh file %s.',mesh_file);
    [x,e_conn] = read_tecplot360mesh(mesh_file,lf);
    [n_nodes, state_dim] = size(x);
    lf.pmsg(lf.PED,'     MESH SUMMARY')
    lf.pmsg(lf.PED,'       Number of nodes:          %d',n_nodes)
    lf.pmsg(lf.PED,'       Number of elements:       %d',size(e_conn,1))
    lf.pmsg(lf.PED,'       State dimension:          %d',state_dim)
  else
    lf.pmsg(lf.ERR,'Mesh not imported.');
    x = [];
    e_conn = [];
  end
  
  if get_mesh == 0 || get_mesh == 2 
    srch_files = sprintf('%s*.dat',data_prefix);
    data_files = ls(srch_files);
    data_files = textscan(data_files,'%s');
    data_files = sort(data_files{1});
    lf.pmsg(lf.WARN,'%d matching files found.',length(data_files));

    timesteps = [];

    lf.pmsg(lf.ERR,'Loading data files.');
    for j = 1:length(data_files)

      lf.pmsg(lf.WARN,' + Reading data from %s.',data_files{j})
      tic
      [data,variables,soln_time] = read_tecplot360data(data_files{j},lf);
      read_time = toc;
      lf.pmsg(lf.WARN,'   - Completed in %f seconds.',read_time); 

      timesteps = [timesteps soln_time];

      % Assign helper variables to extract individual data fields
      n_var = size(variables,2);
      n_data_var = n_var;
      n_data_cols = size(data,2);
      n_ts = length(soln_time);
      if j > 1
        start_idx = size(u,2)+1;
        end_idx = size(u,2)+(n_ts);
      else
        start_idx = 1;
        end_idx = n_ts;
      end

      lf.pmsg(lf.PED,'     DATA SUMMARY')
      lf.pmsg(lf.PED,'       Number of data variables: %d',n_data_cols)
      lf.pmsg(lf.PED,'       Number of curr snapshots: %d',n_ts)
      lf.pmsg(lf.PED,'       Total snapshots accum:    %d',end_idx)

      lf.pmsg(lf.WARN,' + Appending %d new snapshots to the data.',n_ts);
      tic
      for k = 1:n_data_var
        switch variables{k}
          case 'X Velocity'
            data_name = 'u';
          case 'Y Velocity'
            data_name = 'v';
          case 'Z Velocity'
            data_name = 'w';
          case 'TurbulentViscosity'
            data_name = 'cell_AV';
          otherwise
            tmp = variables{k};
            data_name = lower(tmp(1));
        end

        setdata = sprintf('%s(:,%d:%d)=data(:,%d:%d:%d);',data_name,start_idx,end_idx,k,n_data_var,n_data_cols);

        eval(setdata);
      end
      append_time = toc;
    end
        
    lf.pmsg(lf.WARN,'   - Completed in %f seconds.',append_time); 

  else
    lf.pmsg(lf.ERR,'Data not imported.');
    u = [];
    v = [];
    w = [];
    timesteps = [];
  end

  if get_mesh
    lf.pmsg(lf.ERR,'Completed loading mesh file.');
  end    
  if get_mesh == 0 || get_mesh == 2
    lf.pmsg(lf.ERR,'Completed loading %d files.',length(data_files));
  end
  lf.pmsg(lf.ERR,'**********************************************');
  
end

