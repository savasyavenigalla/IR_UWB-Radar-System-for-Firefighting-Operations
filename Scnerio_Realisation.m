clc; clear; close all;

%% Floor dimensions
floor_width = 12;  
floor_height = 10;

figure;
hold on;
axis equal;
axis([0 floor_width 0 floor_height]);
xlabel('X (meters)');
ylabel('Y (meters)');
title('Firefighter Radar Navigation with Wall Penetration and Fire Scenario');
grid on;

%% Draw outer walls
rectangle('Position', [0, 0, floor_width, floor_height], 'EdgeColor', 'k', 'LineWidth', 3);

% Internal walls
rectangle('Position', [4, 0, 0.2, 6], 'FaceColor', [0.5 0.5 0.5]);
rectangle('Position', [0, 6, 6, 0.2], 'FaceColor', [0.5 0.5 0.5]);
rectangle('Position', [8, 4, 0.2, 6], 'FaceColor', [0.5 0.5 0.5]);
rectangle('Position', [6, 4, 2.2, 0.2], 'FaceColor', [0.5 0.5 0.5]);

%% Fire symbols (🔥)
fire_x = [2, 9, 5, 10,4];
fire_y = [2, 8, 5, 2,7];
for i = 1:length(fire_x)
    % text(fire_x(i), fire_y(i), '🔥', 'FontSize', 14);
    text(fire_x(i), fire_y(i), '🔥', 'FontSize', 14, 'Color', [1 0.4 0]); 

end

%% Targets
num_targets = 13;
target_x = [2, 5, 7, 10, 9, 1, 3, 6, 8, 1, 7, 5,1];
target_y = [2, 3, 5, 7, 8, 9, 8, 1, 2, 7, 6, 9,5];
target_detected = zeros(1, num_targets);
target_wall_detected = zeros(1, num_targets); % New: wall penetration detection
h_targets = scatter(target_x, target_y, 100, 'r', 'filled');

%% Radar parameters
fov_angle = 110;    
max_range = 25;     
scan_speed = 0.15;  
rotation_speed = 2; 
wall_loss_factor = 2;

%% Firefighter (Radar) movement path
x_path = [1:0.5:3, 3*ones(1,5), 3:0.5:9, 9*ones(1,6), 9:-0.5:6, 6*ones(1,6), 6:-0.5:1];
y_path = [ones(1,5)*1, 1:1:5, ones(1,13)*5, 5:1:9, ones(1,7)*9, 9:-1:4];

if length(x_path) ~= length(y_path)
    min_len = min(length(x_path), length(y_path));
    x_path = x_path(1:min_len);
    y_path = y_path(1:min_len);
end

rotation_angle = 1; 

%% Animation
for t = 1:length(x_path)
    radar_pos = [x_path(t), y_path(t)];
    
    % Clear previous FOV
    h_fov = findobj('Type', 'Patch');
    delete(h_fov);
    
    % Draw radar
    h_radar = plot(radar_pos(1), radar_pos(2), 'bo', 'MarkerSize', 10, 'MarkerFaceColor', 'b');
    
    % Calculate FOV points
    theta = linspace(rotation_angle - fov_angle/2, rotation_angle + fov_angle/2, 50);
    x_fov = radar_pos(1) + max_range * cosd(theta);
    y_fov = radar_pos(2) + max_range * sind(theta);

    % --- Wall attenuation visualization ---
    walls_crossed = 0;
    if radar_pos(1) < 4 && any(x_fov > 4) && any(x_fov < 4.2) && any(y_fov < 6)
        walls_crossed = walls_crossed + 1;
    end
    if radar_pos(2) < 6 && any(y_fov > 6) && any(x_fov < 6)
        walls_crossed = walls_crossed + 1;
    end
    if radar_pos(1) < 8 && any(x_fov > 8) && any(y_fov > 4)
        walls_crossed = walls_crossed + 1;
    end
    if radar_pos(2) < 4 && any(y_fov > 4) && any(x_fov >=6 & x_fov<=8)
        walls_crossed = walls_crossed + 1;
    end

    switch walls_crossed
        case 0
            fov_color = [0.2 0.6 1]; % Strong blue
            alpha_val = 0.9;
        case 1
            fov_color = [0.4 0.7 1]; % Lighter blue
            alpha_val = 0.6;
        otherwise
            fov_color = [0.7 0.8 1]; % Very faded blue
            alpha_val = 0.3;
    end
    
    fill([radar_pos(1) x_fov], [radar_pos(2) y_fov], fov_color, 'FaceAlpha', alpha_val, 'EdgeColor', 'none');
    
    % Check detections
    for i = 1:num_targets
        if ~target_detected(i)
            dx = target_x(i) - radar_pos(1);
            dy = target_y(i) - radar_pos(2);
            distance = sqrt(dx^2 + dy^2);
            angle = atan2d(dy, dx);
            if angle < 0
                angle = angle + 360;
            end
            
            rot_angle_norm = mod(rotation_angle, 360);
            
            % Wall crossing for each target
            num_walls = 0;
            if (target_x(i) > 4 && radar_pos(1) < 4)
                num_walls = num_walls + 1;
            end
            if (target_y(i) > 6 && radar_pos(2) < 6)
                num_walls = num_walls + 1;
            end
            if (target_x(i) > 8 && radar_pos(1) < 8)
                num_walls = num_walls + 1;
            end
            if (target_y(i) > 4 && radar_pos(2) < 4)
                num_walls = num_walls + 1;
            end
            
            effective_range = max_range / (wall_loss_factor ^ num_walls);
            
            if (distance <= effective_range) && ...
               (angle >= rot_angle_norm - fov_angle/2) && ...
               (angle <= rot_angle_norm + fov_angle/2)
                target_detected(i) = 1;
                if num_walls >= 1
                    target_wall_detected(i) = 1; % Detected through wall
                end
            end
        end
    end
    
    % Update target colors
    colors = repmat([1 0 0], num_targets, 1); % Default Red
    % Green: direct detection
    colors(logical(target_detected & ~target_wall_detected), :) = repmat([0 1 0], sum(target_detected & ~target_wall_detected), 1);
    % Orange: wall detection
    colors(logical(target_wall_detected), :) = repmat([2 0.5 1], sum(target_wall_detected), 1);
    
    set(h_targets, 'CData', colors);
    
    % Rotate FOV
    rotation_angle = rotation_angle + rotation_speed;
    if rotation_angle > 360
        rotation_angle = rotation_angle - 360;
    end
    
    pause(0.1);
    delete(h_radar);
end

hold off;
