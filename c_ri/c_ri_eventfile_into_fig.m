function h = c_ri_eventfile_into_fig(time_interval,path_events,panels,flag)
%function h = c_ri_eventfile_into_fig(time_interval,path_events,panels,flag)
%function h = c_ri_eventfile_into_fig(time_interval,path_events,panels)
%
%Input:
% time_interval - isdat_epoch [start_time end_time]
% path_events - path where event files are located, ex './'
% panels - structure with list of panels to plot, ex. {'Bx','By','B','B1','Ex','Vps'}
% flag - 'print' print the result to file
%
%Output:
%  h - handle to figures

global AV_DEBUG; if isempty(AV_DEBUG), debug=0;else, debug=AV_DEBUG;end

n_panels=size(panels,2);  if debug, disp(['Figure with ' num2str(n_panels) ' panels.']);end
i_fig=1;

plot_command=struct(...
  'Vps' ,'c_pl_tx(P1,P2,P3,P4,2);ylabel(''V_{ps} [V]'');', ...
  'Bx','c_pl_tx(B1,B2,B3,B4,2);ylabel(''B_X [nT] GSE'');', ...
  'By','c_pl_tx(B1,B2,B3,B4,3);ylabel(''B_Y [nT] GSE'');', ...
  'Bz','c_pl_tx(B1,B2,B3,B4,4);ylabel(''B_Z [nT] GSE'');', ...
  'B' ,'c_pl_tx(av_abs(B1),av_abs(B2),av_abs(B3),av_abs(B4),5);ylabel(''B [nT] GSE'');', ...
  'dE1' ,'av_tplot(dE1);ylabel(''E [mV/m] DS, sc1'');', ...
  'dE2' ,'av_tplot(dE2);ylabel(''E [mV/m] DS, sc2'');', ...
  'dE3' ,'av_tplot(dE3);ylabel(''E [mV/m] DS, sc3'');', ...
  'dE4' ,'av_tplot(dE4);ylabel(''E [mV/m] DS, sc4'');', ...
  'B1' ,'av_tplot(av_abs(B1));ylabel(''B [nT] GSE, sc1'');', ...
  'B2' ,'av_tplot(av_abs(B1));ylabel(''B [nT] GSE, sc2'');', ...
  'B3' ,'av_tplot(av_abs(B1));ylabel(''B [nT] GSE, sc3'');', ...
  'B4' ,'av_tplot(av_abs(B1));ylabel(''B [nT] GSE, sc4'');', ...
  'ExBx' ,'c_pl_tx(ExB1,ExB2,ExB3,ExB4,2);ylabel(''ExB_X [km/s] GSE'');', ...
  'ExBy' ,'c_pl_tx(ExB1,ExB2,ExB3,ExB4,3);ylabel(''ExB_Y [km/s] GSE'');', ...
  'ExBz' ,'c_pl_tx(ExB1,ExB2,ExB3,ExB4,4);ylabel(''ExB_Z [km/s] GSE'');', ...
  'ExB' ,'c_pl_tx(av_abs(ExB1),av_abs(ExB2),av_abs(ExB3),av_abs(ExB4),5);ylabel(''|ExB| [km/s]'');', ...
  'ExB1' ,'av_tplot(av_abs(ExB1));ylabel(''ExB [km/s] GSE, sc1'');', ...
  'ExB2' ,'av_tplot(av_abs(ExB2));ylabel(''ExB [km/s] GSE, sc2'');', ...
  'ExB3' ,'av_tplot(av_abs(ExB3));ylabel(''ExB [km/s] GSE, sc3'');', ...
  'ExB4' ,'av_tplot(av_abs(ExB4));ylabel(''ExB [km/s] GSE, sc4'');', ...
  'test','test' ...
);

file_list=dir([path_events '*F*t*T*t*.mat']);
for i_file=1:size(file_list,1),
  if c_ri_timestr_within_tint(file_list(i_file).name,time_interval),
     tint_plot=c_ri_timestr_within_tint(file_list(i_file).name);
     if debug, disp(['Using file: ' file_list(i_file).name]);end
     load([path_events file_list(i_file).name]);
     figure(i_fig);i_panel=1;
     for i_panel=1:n_panels,
        h(i_fig,i_panel)=av_subplot(n_panels,1,-i_panel);
        eval(eval(['plot_command.' panels{i_panel}]));
     end
     av_zoom(tint_plot,'x',h(i_fig,:));
     add_timeaxis(h(i_fig,:));
     i_fig=i_fig+1;
  end
end

if nargin == 4,
 switch flag,
 case 'print',
   for j=1:i_fig-1,
     figure(j);
     panel_str='';
     for jj=1:n_panels, panel_str=[panel_str '_' panels{jj}];end
     print_file_name=[file_list(i_file).name '_' panel_str '.ps'];
     orient tall;print('-dpsc2',print_file_name);
   end
 end
end
