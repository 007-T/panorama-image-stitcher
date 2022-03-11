%CMPT361 Spring 2022
%Ali Tohidi, 301355519
function [corner_rows, corner_cols] = my_fast_detector(image, threshold)

%   Filter for shifting the image 3 pixels down
    top_filter = zeros(7); 
    top_filter(1, 4) = 1;
%   Filter for shifting the image 3 pixels up
    bottom_filter = zeros(7); 
    bottom_filter(7, 4) = 1;
%   Filter for shifting the image 3 pixels right
    left_filter = zeros(7); 
    left_filter(4, 1) = 1;
%   Filter for shifting the image 3 pixels left
    right_filter = zeros(7); 
    right_filter(4, 7) = 1;
%   Shifted images
    top_high_speed_filtered_image = imfilter(image, top_filter);
    bottom_high_speed_filtered_image = imfilter(image, bottom_filter);
    left_high_speed_filtered_image = imfilter(image, left_filter);
    right_high_speed_filtered_image = imfilter(image, right_filter);
    
%   Find the dark candidates
    top_candidates_dark = find(top_high_speed_filtered_image - image < -threshold); 
    bottom_candidates_dark = find(bottom_high_speed_filtered_image - image < -threshold); 
    left_candidates_dark = find(left_high_speed_filtered_image - image < -threshold); 
    right_candidates_dark = find(right_high_speed_filtered_image - image < -threshold); 

%   Create a map of all pixels of the image and add 1 to the value of that
%   cell -> If a pixel passes the high_speed_dark test then it would have a
%   value of 3 or 4
    high_speed_dark_candidates = zeros(size(image));
    
    high_speed_dark_candidates(top_candidates_dark) = high_speed_dark_candidates(top_candidates_dark)+1;
    high_speed_dark_candidates(bottom_candidates_dark) = high_speed_dark_candidates(bottom_candidates_dark)+1;
    high_speed_dark_candidates(left_candidates_dark) = high_speed_dark_candidates(left_candidates_dark)+1;
    high_speed_dark_candidates(right_candidates_dark) = high_speed_dark_candidates(right_candidates_dark)+1;
    
    [high_speed_dark_row, high_speed_dark_col] = find(high_speed_dark_candidates >= 3);
    
%     Find the light candidates
    top_candidates_light = find(top_high_speed_filtered_image - image > threshold); 
    bottom_candidates_light = find(bottom_high_speed_filtered_image - image > threshold); 
    left_candidates_light = find(left_high_speed_filtered_image - image > threshold); 
    right_candidates_light = find(right_high_speed_filtered_image - image > threshold); 
    
    high_speed_light_candidates = zeros(size(image));
    
    high_speed_light_candidates(top_candidates_light) = high_speed_light_candidates(top_candidates_light)+1;
    high_speed_light_candidates(bottom_candidates_light) = high_speed_light_candidates(bottom_candidates_light)+1;
    high_speed_light_candidates(left_candidates_light) = high_speed_light_candidates(left_candidates_light)+1;
    high_speed_light_candidates(right_candidates_light) = high_speed_light_candidates(right_candidates_light)+1;
    
    [high_speed_light_row, high_speed_light_col] = find(high_speed_light_candidates >= 3);

%     corner_cols = [high_speed_dark_row' high_speed_light_row'];
%     corner_rows = [high_speed_dark_col' high_speed_light_col'];

 %   Filters for the shifts to 16 different pixels around the main pixel
    p = zeros(7);
    p(1, 4) = 1;
    p(4, 4) = -1;

    for i = 2:16 
        p(:, :, i) = zeros(7);
        p(4, 4, i) = -1;
    end
    
    p(1, 5, 2) = 1;
    p(2, 6, 3) = 1;
    p(3, 7, 4) = 1;
    p(4, 7, 5) = 1;
    p(5, 7, 6) = 1;
    p(6, 6, 7) = 1;
    p(7, 5, 8) = 1;
    p(7, 4, 9) = 1;
    p(7, 3, 10) = 1;
    p(6, 2, 11) = 1;
    p(5, 1, 12) = 1;
    p(4, 1, 13) = 1;
    p(3, 1, 14) = 1;
    p(2, 2, 15) = 1;
    p(1, 3, 16) = 1;

    pf = imfilter(image, p(:,:,1));
    for i = 2:16
        pf(:,:,i) = imfilter(image, p(:,:,i));
    end

    corners = zeros(size(image));

    for i = 1:length(high_speed_dark_row)
        count = 0;
        for j = 1:32
            k = j;
            if k > 16
                k = k-16;
            end
            if pf(high_speed_dark_row(i), high_speed_dark_col(i), k) < -threshold
                count = count+1;
            else
                count = 0;
            end
            if count >= 12
                v_score = sum(pf(high_speed_dark_row(i), high_speed_dark_col(i), :));
                corners(high_speed_dark_row(i), high_speed_dark_col(i)) = v_score;
                break;
            end
        end
    end

    for i = 1:length(high_speed_light_row)
        count = 0;
        for j = 1:32
            k = j;
            if k > 16
                k = k-16;
            end
            if pf(high_speed_light_row(i), high_speed_light_col(i), k) < -threshold
                count = count+1;
            else
                count = 0;
            end
            if count >= 12
                v_score = sum(pf(high_speed_light_row(i), high_speed_light_col(i), :));
                corners(high_speed_light_row(i), high_speed_light_col(i)) = v_score;
                break;
            end
        end
    end
    corners = abs(corners);
    corners = imdilate(corners, ones(3));
    [corner_rows, corner_cols] = find(corners ~= 0);
end