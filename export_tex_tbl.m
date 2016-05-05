function [ ] = export_tex_tbl( data, data_fmt, tex_file, hdr_labels, caption, tbl_name, tstyle )
%EXPORT_TEX_TBL Exports matrix data to a LaTex table
%   This function takes a matrix and outputs the data into a tex file that
%   can be imported or sourced into another Latex file.
%
%   Inputs
%     data       : data to be output to a table
%     data_fmt   : Cell array of data formats or a string to use for all the data
%                  (defualt => '%f')
%     tex_file   : file name of where to store data (default => 'data.tex')
%     hdr_labels : Cell array of column header labels (defualt => no labels)
%     caption    : Table caption (default => 'Matlab Data')
%     tbl_name   : Table label (default => 'data').  Labels are formed as
%                  'tab:tbl_name'
%     tstyle     : Use 'std' or 'booktab' style (default => 'std')
%
% Example usage:
%   Let A be a 3x20 matrix of floats where the first 2 columns are output
%   data and the third column is the error.  Suppose we would like to
%   output the first 2 columns as decimals and the last column in an
%   exponential notation.  Next we want the headers to be 'Output 1',
%   'Output 2' and 'Rel Error'.  We would like to save this to the file
%   'outdata.tex' in the subdirectory 'tex_files'. (This directory needs to
%   exist prior to calling this function.)  
%
%   >> data_fmt = {'%6.2f', '%6.2f', '%5.3e'};
%   >> tex_file_name = './tex_files/outdata.tex';
%   >> hdr_labels = {'Output 1', 'Output 2', 'Rel Error'};
%   >> tbl_caption = 'This is a table that was created in Matlab.'
%   >> tbl_name = 'out_mat'
%   >> export_tex_tbl(A, data_fmt, tex_file_name, hdr_labels, tbl_caption, tbl_name, 'std' )
%
% Alan Lattimer, Virginia Tech, April 2015
%
%--------------------------------------------------------------------------------

% Set default input values

if nargin < 6
  tbl_name = 'data';
  if nargin < 5
    caption = 'Matlab Data';
    if nargin < 4
      hdr_labels = '';
      if nargin < 3
        tex_file = 'data.tex';
        if nargin < 2
          data_fmt = '%f';
        end
      end
    end
  end
end

if nargin < 7
  std_style = 1;
elseif strcmpi(tstyle,'std')
  std_style = 1;
else
  std_style = 0;
end

    
fid = fopen(tex_file,'w+');

[n,m] = size(data);

spacer = '    ';

cfmt_str = repmat('c',1,m);
if iscell(data_fmt)
  if length(data_fmt) ~= m
    data_fmt = repmat(data_fmt(1),1,m);
    warning('Format cell length is different than the number of columns. Using %s for all columns',data_fmt{1});
  end
else
  data_fmt = repmat({data_fmt},1,m);
end
dfmt_str  = sprintf('%s & ',data_fmt{1:m-1});
dfmt_str = [spacer dfmt_str data_fmt{m} ' \\\\\n'];

fprintf(fid,'\\begin{table}[h]\n');
fprintf(fid,'  \\centering\n');
fprintf(fid,'  \\begin{tabular}{%s}\n',cfmt_str);
if std_style
  fprintf(fid,'    \\hline\n');
else
  fprintf(fid,'    \\toprule\n');
end
if iscell(hdr_labels)  && (length(hdr_labels) == m)
  fprintf(fid,spacer);
  for k = 1:m-1
    fprintf(fid,'%s & ',hdr_labels{k});
  end
  fprintf(fid,'%s \\\\\n',hdr_labels{end});
  if std_style
    fprintf(fid,'    \\hline\\hline\n');
  else
    fprintf(fid,'    \\midrule\n');
  end
end
for j = 1:n
  fprintf(fid,dfmt_str,data(j,:));
end
if std_style
  fprintf(fid,'    \\hline\n');
else
  fprintf(fid,'    \\bottomrule\n');
end
fprintf(fid,'  \\end{tabular}\n');
fprintf(fid,'  \\caption{%s}\n',caption);
fprintf(fid,'  \\label{tab:%s}\n',tbl_name);
fprintf(fid,'\\end{table}\n\n');



fclose(fid);

end

