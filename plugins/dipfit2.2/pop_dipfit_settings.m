% pop_dipfit_settings() - interactively change the global settings for dipole fitting
%
% Usage:
%   >> OUTEEG = pop_dipfit_settings ( INEEG ); % pop up window
%   >> OUTEEG = pop_dipfit_settings ( INEEG, 'key1', 'val1', 'key2', 'val2' ... )
%
% Inputs:
%   INEEG	input dataset
%
% Optional inputs:
%   'model'    - [string] file containing model compatible with
%                Fieldtrip dipolefitting() function ("vol" entry)
%   'chanfile' - [string] template channel location file

%   'electrodes'   - [integer array] indices of electrode to include
%                    in model. Default: all.
%
% Outputs:
%   OUTEEG	output dataset
%
% Author: Robert Oostenveld, SMI/FCDC, Nijmegen 2003
%         Arnaud Delorme, SCCN, La Jolla 2003

%   'gradfile' - [string] file containing gradiometer locations
%                ("gradfile" parameter in Fieldtrip dipolefitting() function)

% SMI, University Aalborg, Denmark http://www.smi.auc.dk/
% FC Donders Centre, University Nijmegen, the Netherlands http://www.fcdonders.kun.nl

% Copyright (C) 2003 Robert Oostenveld, SMI/FCDC roberto@smi.auc.dk
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Log: not supported by cvs2svn $
% Revision 1.1  2005/03/10 18:04:39  arno
% Initial revision
%
% Revision 1.27  2004/01/07 17:02:48  scott
% See List -> List
%
% Revision 1.26  2004/01/07 17:01:32  scott
% ... -> See List
%
% Revision 1.25  2004/01/07 17:00:21  scott
% added to Note
%
% Revision 1.24  2003/12/04 18:25:43  arno
% shell conductance unit
%
% Revision 1.23  2003/10/31 18:06:07  arno
% more edits
%
% Revision 1.22  2003/10/31 17:54:00  arno
% select channels -> omit channels
%
% Revision 1.21  2003/10/30 02:14:51  arno
% gui typo
%
% Revision 1.20  2003/10/29 22:43:37  arno
% wording
%
% Revision 1.19  2003/10/29 02:36:38  arno
% removing 2 lines of GUI
%
% Revision 1.18  2003/10/15 14:47:34  roberto
% removed urchanlocs from electrode projection part
%
% Revision 1.17  2003/10/14 15:56:38  roberto
% before projecting electrodes towards the skin, store the original in urchanlocs
%
% Revision 1.16  2003/08/08 16:57:10  arno
% removing normsphere
%
% Revision 1.15  2003/08/04 22:10:13  arno
% adding warning backtrace
%
% Revision 1.14  2003/08/04 22:03:32  arno
% adding normsphere option
%
% Revision 1.13  2003/08/01 13:50:51  roberto
% changed the gui, implemented fit-electrodes-to-sphere, modifications in vol.r/c/o are accepter
%
% Revision 1.12  2003/07/01 22:11:59  arno
% removing debug message
%
% Revision 1.11  2003/06/30 02:11:37  arno
% debug argument check
%
% Revision 1.10  2003/06/30 01:20:58  arno
% 4sphere -> 4spheres
%
% Revision 1.9  2003/06/30 01:18:46  arno
% copying new version
%
% Revision 1.5  2003/06/16 15:32:51  arno
% reprograming interface, programing history
%
% Revision 1.4  2003/03/12 10:32:50  roberto
% added 4-sphere volume model similar to BESA
%
% Revision 1.3  2003/03/06 15:58:28  roberto
% *** empty log message ***
%
% Revision 1.1  2003/02/24 10:06:08  roberto
% Initial revision
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [OUTEEG, com] = pop_dipfit_settings ( EEG, varargin )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 1
   help pop_dipfit_settings;
   return;
end;

OUTEEG = EEG;
com = '';

% get the default values and filenames
dipfitdefs;

if nargin < 2
    % define the callbacks for the buttons
    cb_selectelectrodes = 'tmp = select_channel_list({EEG.chanlocs.label}, eval(get(findobj(gcbf, ''tag'', ''elec''), ''string''))); set(findobj(gcbf, ''tag'', ''elec''), ''string'',[''[''  num2str(tmp) '']''])'; % did not work
    cb_selectelectrodes = 'set(findobj(gcbf, ''tag'', ''elec''), ''string'', int2str(pop_chansel({EEG.chanlocs.labels})));';
    % cb_selectvolume     = '[fname, pname] = uigetfile(''*.*'', ''Load volume conductor''); fname = fullfile(pname, fname); tmp = strvcat(get(findobj(gcbf, ''tag'', ''vol''), ''string''), fname); set(findobj(gcbf, ''tag'', ''vol''), ''string'', tmp); set(findobj(gcbf, ''tag'', ''vol''), ''value'', size(tmp,1)); set(gcbf, ''userdata'', tmp)';
    cb_volmodel = [ 'tmpdat = get(gcbf, ''userdata'');' ... 
                    'tmpind = get(gcbo, ''value'');' ... 
                    'set(findobj(gcbf, ''tag'', ''radii''),   ''string'', num2str(tmpdat{tmpind}.r,3));' ...
                    'set(findobj(gcbf, ''tag'', ''conduct''), ''string'', num2str(tmpdat{tmpind}.c,3));' ...
                    'clear tmpdat tmpind;' ];
    cb_changeradii = [  'tmpdat = get(gcbf, ''userdata'');' ...
                       'tmpdat.vol.r = str2num(get(gcbo, ''string''));' ...
                       'set(gcf, ''userdata'', tmpdat)' ];
    cb_changeconduct = [  'tmpdat = get(gcbf, ''userdata'');' ...
                       'tmpdat.vol.c = str2num(get(gcbo, ''string''));' ...
                       'set(gcf, ''userdata'', tmpdat)' ];
    cb_changeorigin = [  'tmpdat = get(gcbf, ''userdata'');' ...
                       'tmpdat.vol.o = str2num(get(gcbo, ''string''));' ...
                       'set(gcf, ''userdata'', tmpdat)' ];
    % cb_fitelec = [ 'if get(gcbo, ''value''),' ...
    %                '  set(findobj(gcbf, ''tag'', ''origin''), ''enable'', ''off'');' ...
    %                'else' ...
    %                '  set(findobj(gcbf, ''tag'', ''origin''), ''enable'', ''on'');' ...
    %                'end;' ];
    
    userdata    = [];
    
    geomvert = [1 1 1 1 1 1 1 1 1];
    
    geomhorz = {
        [1 2] 
        [1]
        [1 1.3 0.5 0.5 ]
        [1 1.3 0.5 0.5 ]
        [1 1.3 0.5 0.5 ]
        [1.28 1 0.6]
        [1]
        [1]
        [1] };
    
    % define each individual graphical user element
    comhelp1 = [ 'warndlg2(strvcat(''Other models can be found in the'',' ...
                 '''"model" folder of the DIPFIT2 plugin folder''), ''Model type'');' ];
    comhelp2 = [ 'warndlg2(strvcat(''You need to enter the location file for the'',' ...
                 '''Gradiometers as EEGLAB does not store yet this type of information''), ''MEG gradiometers'');' ];
    commandload1 = [ '[filename, filepath] = uigetfile(''*'', ''Select a text file'');' ...
                    'if filename ~=0,' ...
                    '   set(findobj(''parent'', gcbf, ''tag'', ''model''), ''string'', [ filepath filename ]);' ...
                    'end;' ...
                    'clear filename filepath tagtest;' ];    
    commandload2 = [ '[filename, filepath] = uigetfile(''*'', ''Select a text file'');' ...
                    'if filename ~=0,' ...
                    '   set(findobj(''parent'', gcbf, ''tag'', ''meg''), ''string'', [ filepath filename ]);' ...
                    'end;' ...
                    'clear filename filepath tagtest;' ];    
    commandload3 = [ '[filename, filepath] = uigetfile(''*'', ''Select a text file'');' ...
                    'if filename ~=0,' ...
                    '   set(findobj(''parent'', gcbf, ''tag'', ''mri''), ''string'', [ filepath filename ]);' ...
                    'end;' ...
                    'clear filename filepath tagtest;' ];    
    folder = which('pop_dipfit_settings');
    folder = folder(1:end-21);
    delim  = folder(end);
    
    userdata = { { [ folder 'standard_BESA' delim 'standard_BESA.mat' ] ...
                   [ folder 'standard_BESA' delim 'avg152T1.mat' ] ...
                   [ folder 'standard_BESA' delim 'Standard-10-5-Cap385.sfp' ] } ...
                 { [ folder 'standard_BEM' delim 'standard_vol.mat' ] ...
                   [ folder 'standard_BEM' delim 'standard_mri.mat' ] ...
                   [ folder 'standard_BEM' delim 'elec' delim 'standard_1005.elc' ] } { [] [] [] } { [] [] [] } };
    setmodel = [ 'tmpdat = get(gcbf, ''userdata'');' ...
                 'tmpval = get(gcbo, ''value'');' ...
                 'set(findobj(gcbf, ''tag'', ''model''), ''string'', tmpdat{tmpval}{1});' ...
                 'set(findobj(gcbf, ''tag'', ''mri''  ), ''string'', tmpdat{tmpval}{2});' ...
                 'set(findobj(gcbf, ''tag'', ''meg''), ''string'', tmpdat{tmpval}{3});' ];
        
    elements  = { ...
        { 'style' 'text'        'string'  'Model' } ...
        { 'style' 'listbox'     'string'  'Spherical 4 shell (BESA)|Boundary Element Model|Spherical MEG|Custom' ... 
                                'callback' setmodel } { } ...
        { 'style' 'text'        'string' 'Model file' } ...
        { 'style' 'edit'        'string' ''          'tag'      'model' } ...
        { 'style' 'pushbutton'  'string' 'Browse'    'callback' commandload1 } ...
        { 'style' 'pushbutton'  'string' 'Help'      'callback' comhelp1 } ...
        { 'style' 'text'        'string' 'MRI' } ...
        { 'style' 'edit'        'string' ''          'tag'      'mri' } ...
        { 'style' 'pushbutton'  'string' 'Browse'    'callback' commandload3 } ...
        { 'style' 'pushbutton'  'string' 'Help'      'callback' comhelp1 } ...
        { 'style' 'text'        'string' 'Template channel loc. file' } ...
        { 'style' 'edit'        'string' ''          'tag'      'meg' } ...
        { 'style' 'pushbutton'  'string' 'Browse'    'callback' commandload2 } ...
        { 'style' 'pushbutton'  'string' 'Help'      'callback' comhelp2 } ...
        { 'style' 'text'        'string' 'Omit channels for dipole fit' } ...
        { 'style' 'edit'        'string' ''          'tag' 'elec' } ...
        { 'style' 'pushbutton'  'string' 'List' 'callback' cb_selectelectrodes } ... 
        { } ...
        { 'style' 'text'        'string' 'Note: check that the channels lie on the surface of the head model' } ...
        { 'style' 'text'        'string' '(e.g., in the channel editor ''Set head radius'' to usually 85).' } ...
                };
    
    result = inputgui( geomhorz, elements, 'pophelp(''pop_dipfit_settings'')', ...
                                     'Dipole fit settings - pop_dipfit_settings()', userdata, 'normal', geomvert );
    
    if isempty(result), return; end
    options = {};
    options = { options{:} 'hdmfile'      result{2} };
    options = { options{:} 'mrifile'      result{3} };
    options = { options{:} 'chanfile'     result{4} };
    options = { options{:} 'chansel'      setdiff(1:EEG.nbchan, str2num(result{5})) };

else
    options = varargin;
end

% convert to structure
options = cell2struct(options(2:2:end), options(1:2:end),2);
% assign/update the EEG structure
OUTEEG.dipfit.hdmfile  = options.hdmfile;
OUTEEG.dipfit.mrifile  = options.mrifile;
OUTEEG.dipfit.chanfile = options.chanfile;
OUTEEG.dipfit.chansel  = options.chansel;

% checking electrode configuration
% --------------------------------
if 0
    disp('Checking electrode configuration');
    tmpchan          = readlocs(OUTEEG.dipfit.chanfile);
    [tmp1 ind1 ind2] = intersect( lower({ tmpchan.labels }), lower({ OUTEEG.chanlocs.labels }));
    if isempty(tmp1)
        disp('No common channel labels found between template and current channels');
        if ~isempty(findstr(OUTEEG.dipfit.hdmfile, 'BESA'))
            disp('Make sure you fit the best sphere to your current channels in the channel editor');
            disp('Check for inconsistency of dipole ');
        else
            disp('BEM MODEL IS IRRELEVANT IF CHANNEL ARE NOT ON THE HEAD SURFACE AND WILL RETURN INNACURATE RESULTS');
        end;
    else % common channels: performing best transformation
        TMP = OUTEEG;
        elec1 = eeglab2fieldtrip(TMP, 'elec');
        elec1 = elec1.elec;
        TMP.chanlocs = tmpchan;
        elec2 = eeglab2fieldtrip(TMP, 'elec');
        elec2 = elec2.elec;
        cfg.elec     = elec1;
        cfg.template = elec2;
        cfg.method   = 'warp';
        elec3 = electrodenormalize(cfg);
    
        % convert back to EEGLAB format
        OUTEEG.chanlocs = struct( 'labels', elec3.label, ...
                              'X'     , mat2cell(elec3.pnt(:,1)'), ...
                              'Y'     , mat2cell(elec3.pnt(:,2)'), ...
                              'Z'     , mat2cell(elec3.pnt(:,3)') );
        OUTEEG.chanlocs = convertlocs(OUTEEG.chanlocs, 'cart2all');
    end;
    
end;
%    allsph = [ OUTEEG.chanlocs.sph_radius ];
%    if length(unique(allsph)) ~= 1
%        disp('Warning: electrodes do not lie on a sphere');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXME commented out by Robert
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% g = finputcheck( options, { 'radii'        'float'     []             [defaultvolume.r];
%                             'conductances' 'float'     []             [defaultvolume.c];
%                             'origin'       'float'     []             [defaultvolume.o];
%                             'projectelectrodes' 'integer' [0 1]       [0];
%                             'electrodes'   'integer'   [1 Inf]        [1:EEG.nbchan]});
% if isstr(g), error(g); end;
% 
% % remember the volume conductor and electrode settings
% OUTEEG.dipfit.chansel = g.electrodes;
% OUTEEG.dipfit.vol.r   = g.radii;
% OUTEEG.dipfit.vol.c   = g.conductances;
% OUTEEG.dipfit.vol.o   = defaultvolume.o;
%
% if g.projectelectrodes & isfield(EEG, 'chanlocs')
%   if isfield(OUTEEG.chanlocs, 'X') & isfield(OUTEEG.chanlocs, 'Y') & isfield(OUTEEG.chanlocs, 'Z')
%     % here we have the option to remember the original channel locations
%     % but it is not decided yet upon where to put them
%     % OUTEEG.urchanlocs = OUTEEG.chanlocs;
% 
%     % project the electrodes towards the skin (not used by default)
%     for el = 1:length(EEG.chanlocs)
%       xyz(1) = OUTEEG.chanlocs(el).X;
%       xyz(2) = OUTEEG.chanlocs(el).Y;
%       xyz(3) = OUTEEG.chanlocs(el).Z;
%       xyz = xyz - g.origin;
%       xyz = max(g.radii) * xyz / norm(xyz);
%       xyz = xyz + g.origin;
%       OUTEEG.chanlocs(el).X = xyz(1);
%       OUTEEG.chanlocs(el).Y = xyz(2);
%       OUTEEG.chanlocs(el).Z = xyz(3);
%     end
%     OUTEEG.chanlocs = convertlocs(OUTEEG.chanlocs, 'cart2all');
%   else
%     error('could not project electrodes because carthesian coordinates are not available');
%   end
% else 
%     warning off backtrace; % avoid long error messages
% end

com = sprintf('%s = pop_dipfit_settings( %s, %s);', inputname(1), inputname(1), vararg2str(options));
