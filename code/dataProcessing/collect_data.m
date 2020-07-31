% This function will load data and make a big table for each subjects ectracting the relevant information;
function dataALL = collect_data()

fileList = dir('data/analytics');
fileList = fileList(3:length(fileList),:);

% measures to be extracted;
whatMeasures = {'SessionNumber', 'Block', 'Trial', 'Trial_Type', ...
    'Stop_Signal_Left', 'Stop_Signal_Right', 'Cue_Type', 'Safe_Response_Range', ...
    'Cue_Accuracy', 'Adaptive_Stop_Signal_Offset', 'Stop_Signal_Delay',	...
    'responseTimeLeft', 'responseTimeRight', 'Avg_RespTime', 'L_R_Synchrony'};

%Loop over all of the files in the "data" folder:
dataSubject = cell(length(fileList),1); 
for s = 1:length(fileList)
    
    fname = fileList(s).name;
    if contains(fname, '.analytics')
        
        % Get the data out of the .analytics file
        alfi_sess = convert_timeStamps(fname);
        numBlocks = length(alfi_sess.GameAnalytics.DragonSST.Blocks);
        
        dataSession = cell(numBlocks,1); 
        for b = 1:numBlocks
            
            numTrials = size(alfi_sess.GameAnalytics.DragonSST.Blocks(b).Trials,1);
            data = table;
            % loop oerl selected measures and do something for each
            % add a variable for subject
            [subName{1:numTrials}] = deal(fname);
            data.File = subName'; 
            
            for m=1:length(whatMeasures)
                
                switch whatMeasures{m}
                    case 'SessionNumber'
                        data.(whatMeasures{m}) = repmat(alfi_sess.SessionNumber, numTrials,1);
                        
                    case 'Block'
                        data.(whatMeasures{m}) = repmat(b, numTrials,1);
                        
                    case 'Trial'
                        data.(whatMeasures{m}) = linspace(1,numTrials, numTrials)';
                        
                    case {'Trial_Type', 'Stop_Signal_Left', 'Stop_Signal_Right', 'Cue_Type'}
                        % these are all strings and will remain strings
                        % loop over trials and extract information
                        selectData = strings(numTrials,1);
                        for t=1:numTrials
                            if ~isempty(alfi_sess.GameAnalytics.DragonSST.Blocks(b).Trials(t).(whatMeasures{m}))
                                selectData(t) = alfi_sess.GameAnalytics.DragonSST.Blocks(b).Trials(t).(whatMeasures{m});
                            end
                        end
                        data.(whatMeasures{m}) = selectData;
                        
                    case 'Stop_Signal_Delay'
                        % convert time stamp to number in ms
                        selectData = nan(numTrials,1);
                        for t=1:numTrials
                            if ~isempty(alfi_sess.GameAnalytics.DragonSST.Blocks(b).Trials(t).(whatMeasures{m}))
                                
                                timeStamp = alfi_sess.GameAnalytics.DragonSST.Blocks(b).Trials(t).(whatMeasures{m});
                                % select elements and convert to ms
                                STAMP_temp = split(timeStamp, ':');
                                selectData(t) = str2double(STAMP_temp{1})*3600+str2double(STAMP_temp{2})*60+str2double(STAMP_temp{3})*1000;
                                
                            end
                        end
                        data.(whatMeasures{m}) = selectData;
                    case {'Avg_RespTime', 'L_R_Synchrony'}
                        selectData = nan(numTrials,1);

                        for t=1:numTrials
                            % if both responses exist
                            if ~isempty(alfi_sess.GameAnalytics.DragonSST.Blocks(b).Trials(t).responseTimeRight) && ...
                                    ~isempty(alfi_sess.GameAnalytics.DragonSST.Blocks(b).Trials(t).responseTimeLeft)
                                % take the mean of L and R
                                if strcmp(whatMeasures{m}, 'Avg_RespTime')
                                    selectData(t) = mean([alfi_sess.GameAnalytics.DragonSST.Blocks(b).Trials(t).responseTimeRight,...
                                        alfi_sess.GameAnalytics.DragonSST.Blocks(b).Trials(t).responseTimeLeft]);
                                elseif strcmp(whatMeasures{m}, 'L_R_Synchrony')
                                    selectData(t) = alfi_sess.GameAnalytics.DragonSST.Blocks(b).Trials(t).responseTimeRight - ...
                                        alfi_sess.GameAnalytics.DragonSST.Blocks(b).Trials(t).responseTimeLeft;
                                end
                                
                            end
                        end
                        data.(whatMeasures{m}) = selectData;
                        
                    otherwise
                        % for all others, keep them as number
                        selectData = nan(numTrials,1);
                        for t=1:numTrials
                            if ~isempty(alfi_sess.GameAnalytics.DragonSST.Blocks(b).Trials(t).(whatMeasures{m}))
                                
                                selectData(t) = alfi_sess.GameAnalytics.DragonSST.Blocks(b).Trials(t).(whatMeasures{m});
                                
                            end
                        end
                        data.(whatMeasures{m}) = selectData;
                end
                
            end
            
            dataSession{b} = data; 
            % here add each table for a block at the end of existing big table
        end
        % for each subject add table into cell
        dataSubject{s} = vertcat(dataSession{:}); 
    end
end
% combine subject data into one big table
dataALL = vertcat(dataSubject{:}); 
end

