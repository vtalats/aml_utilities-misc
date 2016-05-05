function [ u, v, w, timesteps ] = import_big_fluent_data( data_prefix, loglevel )
%IMPORT_FLUENT Loads import velocity data from multiple tecplot360 files
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
  if nargin < 2
    loglevel = 2;
  end
  lf = Msgcl(loglevel,logName);

  lf.pmsg(lf.ERR,'**********************************************');
  lf.pmsg(lf.ERR,'* import_fluent');
  lf.pmsg(lf.ERR,'*   Version 1.0, Author: Alan Lattimer, 2015');
  lf.pmsg(lf.ERR,'*');
  lf.pmsg(lf.ERR,'* Current loglevel: %d',loglevel);
  lf.pmsg(lf.ERR,'*');
  lf.pmsg(lf.WARN,'*   Loading multiple fluent data files with');
  lf.pmsg(lf.WARN,'*   with the form %s*.dat',data_prefix);
  lf.pmsg(lf.WARN,'*');
  lf.pmsg(lf.ERR,'* NOTE: This function assumes that the state');
  lf.pmsg(lf.ERR,'*       space is the same for all data files.');
  lf.pmsg(lf.ERR,'**********************************************');

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
    [x,e_conn,data,variables,soln_time] = read_tecplot360(data_files{j});
    read_time = toc;
    lf.pmsg(lf.WARN,'   - Completed in %f seconds.',read_time); 
    
    timesteps = [timesteps soln_time];

    % Assign helper variables to extract individual data fields
    n_var = size(variables,2);
    state_dim = size(x,2);
    n_data_var = n_var-state_dim;
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
    lf.pmsg(lf.PED,'       Number of nodes:          %d',size(x,1))
    lf.pmsg(lf.PED,'       Number of elements:       %d',size(e_conn,1))
    lf.pmsg(lf.PED,'       State dimension:          %d',state_dim)
    lf.pmsg(lf.PED,'       Number of data variables: %d',n_data_cols)
    lf.pmsg(lf.PED,'       Number of curr snapshots: %d',n_ts)
    lf.pmsg(lf.PED,'       Total snapshots accum:    %d',end_idx)

    lf.pmsg(lf.WARN,' + Appending %d new snapshots to the data.',n_ts);
    tic
    for k = 1:n_data_var
      switch variables{k+state_dim}
        case 'X Velocity'
          data_name = 'u';
        case 'Y Velocity'
          data_name = 'v';
        case 'Z Velocity'
          data_name = 'w';
        case 'TurbulentViscosity'
          data_name = 'cell_AV';
        otherwise
          tmp = variables{k+state_dim};
          data_name = lower(tmp(1));
      end

      setdata = sprintf('%s(:,%d:%d)=data(:,%d:%d:%d);',data_name,start_idx,end_idx,k,n_data_var,n_data_cols);

      eval(setdata);
    end
    append_time = toc;
    
    if ~exist('cell_AV','var');
      cell_AV = cell(1);
    end
    
    lf.pmsg(lf.WARN,'   - Completed in %f seconds.',append_time); 

    
  end

  lf.pmsg(lf.ERR,'Completed loading %d files.',length(data_files))
  lf.pmsg(lf.ERR,'**********************************************');
  
end

