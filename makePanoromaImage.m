function panorama = makePanoromaImage(imageNumber, t)
    % Load images.
    imagesDir = fullfile("imageSets/imageSet" + imageNumber);
    imagesScene = imageDatastore(imagesDir);
    
    % Read the first image from the image set.
    I = readimage(imagesScene,1);
    
    % convert to double
    I = im2double(I);
    % resize images
    rsize = 750;
    csize = rsize;
    
    % Convert to grayscale 
    grayImage = im2gray(I);
    
    % find corners using FAST
    [fast_corner_rows, fast_corner_cols] = my_fast_detector(grayImage, t);
    % save the result for the report
    fast = figure(1);
    imshow(grayImage); 
    hold on;
    plot(fast_corner_cols, fast_corner_rows, 'g+', 'markersize', 5)
    hold off;
    filename = "assets/S" + imageNumber + "-fast.png";
    saveas(fast,filename)
    
    % find corners using FASTR
    % This Threshhold is going to be the same for all the images
    thresh = 0.00001;
    x = detectHarrisCorners(grayImage);
    faster_rows = [];
    faster_cols = [];
    for i = 1:length(fast_corner_rows)
        if x(fast_corner_rows(i), fast_corner_cols(i)) > thresh
            faster_rows = [faster_rows fast_corner_rows(i)];
            faster_cols = [faster_cols fast_corner_cols(i)];
        end
    end
    % save the result for the report
    fastr = figure(2);
    imshow(grayImage);
    hold on;
    plot(faster_cols, faster_rows, "g.", 'markersize', 5)
    hold off;
    filename = "assets/S" + imageNumber + "-fastR.png";
    saveas(fastr,filename)
    
    % Initialize features for I(1) Using FAST
    points_FAST = SURFPoints([fast_corner_cols, fast_corner_rows]);
    [features_FAST, points_FAST] = extractFeatures(grayImage,points_FAST);

    % Initialize features for I(1) Using FASTER
    points = SURFPoints([faster_cols', faster_rows']);
    [features, points] = extractFeatures(grayImage,points);
    
    % Initialize all the transforms to the identity matrix. Note that the
    % projective transform is used here because the building images are fairly
    % close to the camera. Had the scene been captured from a further distance,
    % an affine transform would suffice.
    numImages = numel(imagesScene.Files);
    tforms(numImages) = projective2d(eye(3));
    
    % Initialize variable to hold image sizes.
    imageSize = zeros(numImages,2);
    
    % Iterate over remaining image pairs
    for n = 2:numImages
        
        % Store points and features for I(n-1).
        pointsPrevious = points;
        featuresPrevious = features;
        
        pointsPrevious_FAST = points_FAST;
        featuresPrevious_FAST = features_FAST;

        % save the last image for saving the result later on
        oldImage = I;
        % Read I(n).
        I = readimage(imagesScene, n);
        
        % convert to double
        I = im2double(I);
        % Convert image to grayscale.
        grayImage2 = im2gray(I);    
        
        % Save image size.
        imageSize(n,:) = size(grayImage2);
        
        % Find corners for the nth image
        [fast_corner_rows, fast_corner_cols] = my_fast_detector(grayImage2, t);
        x = detectHarrisCorners(grayImage2);
        faster_rows = [];
        faster_cols = [];
        for i = 1:length(fast_corner_rows)
            if x(fast_corner_rows(i), fast_corner_cols(i)) > thresh
                faster_rows = [faster_rows fast_corner_rows(i)];
                faster_cols = [faster_cols fast_corner_cols(i)];
            end
        end
        % Detect and extract SURF features for I(n) using FAST
        points_FAST = SURFPoints([fast_corner_cols, fast_corner_rows]);
        [features_FAST, points_FAST] = extractFeatures(grayImage,points_FAST);

        % Detect and extract SURF features for I(n) using FASTER
        points = SURFPoints([faster_cols', faster_rows']);
        [features, points] = extractFeatures(grayImage2,points);
        
        % Find correspondences between I(n) and I(n-1) using FAST
        indexPairs_FAST = matchFeatures(features_FAST, featuresPrevious_FAST, 'Unique', true);
           
        matchedPoints_FAST = points_FAST(indexPairs_FAST(:,1), :);
        matchedPointsPrev_FAST = pointsPrevious_FAST(indexPairs_FAST(:,2), :);    

        % save the mached result Fast
        match_FASTER_fig = figure(2);
        showMatchedFeatures(oldImage, I, matchedPointsPrev_FAST, matchedPoints_FAST, "montage")
        filename = "assets/S" + imageNumber + "-fastMatch.png";
        saveas(match_FASTER_fig,filename)

        % Find correspondences between I(n) and I(n-1) using FASTER
        indexPairs = matchFeatures(features, featuresPrevious, 'Unique', true);
           
        matchedPoints = points(indexPairs(:,1), :);
        matchedPointsPrev = pointsPrevious(indexPairs(:,2), :);     
        
        % save the mached result Faster
        match_fig = figure(3);
        showMatchedFeatures(oldImage, I, matchedPointsPrev, matchedPoints, "montage")
        filename = "assets/S" + imageNumber + "-fastRMatch.png";
        saveas(match_fig,filename)

        % Estimate the transformation between I(n) and I(n-1) using FASTR
        % points
        tforms(n) = estimateGeometricTransform2D(matchedPoints, matchedPointsPrev,...
            'projective', 'Confidence', 90, 'MaxNumTrials', 2000);
        
        % Compute T(n) * T(n-1) * ... * T(1)
        tforms(n).T = tforms(n).T * tforms(n-1).T; 
    end
    
    for i = 1:numel(tforms)           
        [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(i,2)], [1 imageSize(i,1)]);
    end
    
    maxImageSize = max(imageSize);
    
    % Find the minimum and maximum output limits. 
    xMin = min([1; xlim(:)]);
    xMax = max([maxImageSize(2); xlim(:)]);
    
    yMin = min([1; ylim(:)]);
    yMax = max([maxImageSize(1); ylim(:)]);
    
    % Width and height of panorama.
    width  = round(xMax - xMin);
    height = round(yMax - yMin);
    
    % Initialize the "empty" panorama.
    panorama = zeros([height width 3], 'like', I);
    
    blender = vision.AlphaBlender('Operation', 'Binary mask', ...
        'MaskSource', 'Input port');  
    
    % Create a 2-D spatial reference object defining the size of the panorama.
    xLimits = [xMin xMax];
    yLimits = [yMin yMax];
    panoramaView = imref2d([height width], xLimits, yLimits);
    
    % Create the panorama.
    for i = 1:numImages
        
        I = readimage(imagesScene, i);   
        I = im2double(I);
        % Transform I into the panorama.
        warpedImage = imwarp(I, tforms(i), 'OutputView', panoramaView);
                      
        % Generate a binary mask.    
        mask = imwarp(true(size(I,1),size(I,2)), tforms(i), 'OutputView', panoramaView);
        
        % Overlay the warpedImage onto the panorama.
        panorama = step(blender, panorama, warpedImage, mask);
    end
    
    pano_fig = figure(4)
    imshow(panorama)
    filename = "assets/S" + imageNumber + "-panorama.png";
    saveas(pano_fig, filename)

end