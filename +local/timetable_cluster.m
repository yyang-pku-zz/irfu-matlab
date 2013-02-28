function out=timetable_cluster(varargin)
% LOCAL.TIMETABLE_CLUSTER generate different Cluster time tables
%
% 	LOCAL.TIMETABLE_CLUSTER('tailbox')
%		generate time tables when Cluster is in tailbox
%

% $Id$

if nargin == 0,
	help local.timetable_cluster;
	return;
end

if ischar(varargin{1})
	timetableToGenerate = lower(varargin{1});
else
	irf_log('fcal','unknown input, see help')
	return;
end

switch timetableToGenerate
	case 'tailbox'
		%% find time intervals when Cluster is in tailbox
		Units=irf_units;
		clusterPositionFileGSE = '/data/caalocal/mR_1min.mat';
%		clusterPositionFileSM  = '/data/caalocal/mR_SM_1min.mat';
		workDir=tempname;
		mkdir(workDir);
		cd(workDir);
		irf_log('fcal',['Cluster position file: ' clusterPositionFileGSE]);
		if ~exist(clusterPositionFileGSE,'file')
			irf_log('fcal','Position file does not exist, log in to spis or brain!')
			return;
		end
		disp('Loading Cluster 1 min positions');
		load(clusterPositionFileGSE); % load Cluster positions 1min resolution
		
		disp('Preparing data');
		tStep=median(diff(R1(:,1))); % time step
		tailBoxX=-5; % tailbox is at X less than this value, in RE
		tailBoxDY=4; % tailbox distance halfwidth in Y at tailBoxX, in RE (tailbox gets wider with distance, y+|tailBoxX|/5)
		tailBoxDZ=5; % tailbox distance halfwidth in Z, in RE
		izero=find(R1(:,1)==0);
		sclist={'','1','2','3','4'}; % include also center of configuration
		c_eval('R?(izero,:)=[];',sclist);
		c_eval('R?=irf_abs(R?);',sclist);
		c_eval('R?=irf_gse2gsm(R?);',sclist); % TODO: needs to be substituted by onera conversion which is a bit more correct
		c_eval('RRE?=irf_tappl(R?,''*Units.km/Units.RE'');clear R?;',sclist);
		
		% tailbox definition
		conditionString = ['X<' num2str(tailBoxX) 'RE,|Z|<' num2str(tailBoxDZ) 'RE,|Y|<' num2str(tailBoxDY-abs(tailBoxX/5)) '+|X|/5 RE GSM'];
		disp(['Finding when Cluster is in tailbox, ' conditionString]);
		ttLabel='tailbox';
		ttTitle=['Cluster ? in tailbox, ' conditionString];
		% all indexes when Cluster in tailbox
		c_eval('itailbox?=(abs(RRE?(:,3))<tailBoxDY+abs(RRE?(:,2))/5 & abs(RRE?(:,4))<tailBoxDZ & RRE?(:,2)<tailBoxX);',sclist)
		% start indexes of time intervals
		c_eval('indstart?=find(diff([0 itailbox?(:)'']) == 1);',sclist);
		% stop indexes of time intervals
		c_eval('indend?=find(diff([itailbox?(:)'' 0]) == -1);',sclist);
		% put the interval start/end time half a step before/after start/end index times
		c_eval(['tt_C?_in_' ttLabel '=irf.TimeTable([RRE?(indstart?,1)-tStep/2 RRE?(indend?,1)+tStep/2]);'],sclist)
		c_eval(['tt_C?_in_' ttLabel '.Header=[''' ttTitle '''];'],sclist);
		% make it possible to access time tables from workspace
		c_eval('disp([''Access from workspace time table: tt_C?_in_'' ttLabel]);',sclist);
		c_eval(['assignin(''base'',''tt_C?_in_' ttLabel ''',tt_C?_in_' ttLabel ');'],sclist);
		
		% if satisfied with result should be possible to upload to IRF time
		% table repository
		answerToSave = irf_ask('Upload time tables to IRF disk? y/n [%]>','answerToSave','n');
		if strcmp(answerToSave,'y')
			c_eval(['irf_tt(tt_C?_in_' ttLabel ',''write_IRF'',''C?_in_' ttLabel ''');'],sclist)
		end
		% to download data, see aagetdata.m under spis:data/cluster/tailbox
		
	otherwise
		irf_log('fcal',['unknown timetable:' timetableToGenerate]);
end


