clc
clear
close all

tic

fileID = fopen('map2.osm','r','n','UTF-8');
A = textscan(fileID,'%s', 'delimiter', '\n'); % , 'whitespace', '');
fclose(fileID);

R = length(A{1}); % number of rows in the file

nodes = zeros(R,3);
% nodes(1) = id
% nodes(2) = longitude
% nodes(3) = latitute

n = 0;
first_way = 1;
% condition = zeros(1,R);
% ci = 10; % condition intervals
% for c = 1:ci-1
%     condition(ceil(R*c/ci)) = 1;
% end

% Build node repository
fprintf('Building node repository...')
for r = 1:R
    
    temp = cell2mat(A{1}(r));
    %     disp(temp)
    
    if contains(temp,'<node')
        n = n+1;
        quot = strfind(temp,'"');
        
        nodes(n,1) = extract_value(temp, 'id', quot);
        nodes(n,2) = extract_value(temp, 'lon', quot);
        nodes(n,3) = extract_value(temp, 'lat', quot);
        
        last_node_row = r;
    end
    
    if first_way
        if contains(temp,'<way')
            first_way_row = r;
            first_way = 0;
        end
    end
    
    %     if condition(r)
    %         fprintf('.')
    %     end
    
end
fprintf(' %f\n', toc)
fprintf('There are %d nodes\n\n', n)
% fprintf('Last node: %d, first way: %d\n', last_node_row, first_way_row)
nodes = nodes(1:n,:);
% plot(nodes(:,2), nodes(:,3), '.b')




ways = zeros(R,4);
% ways(1) = code (0 unknown, 1 highway)
% ways(2) = start row
% ways(3) = end row
% ways(4) = number of ref elements

w = 0;
inside_way = 0;
structure_found = 0;
highways = 0;
refs = 0;

% Search for components
fprintf('Search for components...')
for r = first_way_row:R
    
    temp = cell2mat(A{1}(r));
    
    if ~inside_way
        if contains(temp,'<way')
            w = w+1;
            ways(w,2) = r;
            inside_way = 1;
        end
    end
    
    if inside_way
        if contains(temp,'ref=')
            refs = refs+1;
        end
        
        if ~structure_found
            if contains(temp,'<tag k="highway"')
                ways(w,1) = 1;
                highways = highways+1;
                structure_found = 1;
            end
        end
        
        if contains(temp,'</way>')
            ways(w,3) = r;
            ways(w,4) = refs;
            refs = 0;
            inside_way = 0;
            if structure_found
                structure_found = 0;
                %         else
                %             cprintf('*cyan', 'Structure not found.\n')
            end
        end
        
    end
    
    %     if condition(r)
    %         fprintf('.')
    %     end
    
end
fprintf(' %f\n', toc)
fprintf('There are %d components\n', w)
fprintf('There are %d streets\n\n', highways)

ways = ways(1:w,:);



W = w;
P = 0;
figure
hold on

% Plot streets
fprintf('Plotting streets...')
for w = 1:W
    
    if ways(w,1) == 1
        ref = zeros(1,ways(w,4));
        for scan = ways(w,2)+1:ways(w,3)-1
            temp = cell2mat(A{1}(scan));
            if contains(temp,'ref=')
                P = P+1;
                quot = strfind(temp,'"');
                ref(P) = extract_value(temp, 'ref', quot);
            end
        end
        street_lon = zeros(P,1);
        street_lat = zeros(P,1);
        for p = 1:P
            r = find(ref(p) == nodes(:,1),1);
            street_lon(p) = nodes(r,2);
            street_lat(p) = nodes(r,3);
        end
        P = 0;
        plot(street_lon, street_lat, 'b')
        pause(0)
    end
    
end
fprintf(' %f\n', toc)




% Functions

function value = extract_value(search_string, value_name, quot, varargin)

pos = strfind(search_string, [' ', value_name, '=']);
if ~isempty(pos)
    varquot = quot(find(quot>pos,2));
    value = str2double(search_string(varquot(1)+1:varquot(2)-1));
else
    cprintf('*cyan', 'No %s value found.\n', value_name)
    value = 0;
end

end

