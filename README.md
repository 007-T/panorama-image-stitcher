# panorama-image-stitcher
### The following is a programing assignment for my intoduction to computer vision class at SFU where I got two stitch pairs of images that I took from the same scene but with a shift in angle or position together.
See the full results at: https://htmlpreview.github.io/?https://github.com/007-T/panorama-image-stitcher/blob/main/hw2template.html

Here is the assignment description for reference.


# CMPT 361 - Introduction to Computer Graphics (and Vision)

## Programming Assignment 2
In this assignment, you will implement the FAST interest point detector and use it to generate panoramas!
You can do this assignment in any language. However, as we cover all these topics with Matlab demonstrations in lectures, it will be easier in Matlab. If you use another language, you need to submit your code with a readme file with detailed explanations on how to run your code (the libraries you used etc.).
You need to submit your source code (e.g. ".m") and your report (e.g. ".html") through Coursys. Once run, your code should save each result image with the filenames defined below with a single click. Your report will be an html file together with your result images. The provided template uses these filenames to display your results.
The MATLAB Image Stitching tutorial we mentioned in the RANSAC lecture will be a helpful resource, although they implement some stuff that is not included in this assignment, even if you are not implementing this assignment in MATLAB.
## 1: Take 4 sets of 2 photographs to be stitched together to create a panorama

You need to take photograph pairs to be stitched together, similar to the pair we talked about in our transformations lecture. Take each pair of images from different scenes. I would recommend taking many pairs of images and determining which ones to use after some experimentation with your implementation and results. Make sure to resize your images to get the longer dimension of the image (height or width) to be 750.
If you’d like to implement Part 6 for bonus points, at least two of your 4 image sets should contain 4 images to be stitched together.
Submit your resized image pairs named as S1-im1.png, S1-im2.png, and so on.
## 2: FAST feature detector (3 pts.)

Features from accelerated segment test, or FAST, is an efficient interest point detection method proposed by Rosten and Drummond. It works by comparing the brightness of a pixel with a ring surrounding it. You can find more detailed description in the links below:
FAST Wikipedia page
OpenCV Tutorial
You need to implement FAST including the high-speed test and non-maximal suppression as a function named my_fast_detector. It’s on you to learn about how to define functions in MATLAB.
The FAST implementation should be your own original code, do not copy or reuse other open-source implementations (e.g. GitHub).
Hint: In MATLAB, using for loops is quite inefficient but using matrix operations are very efficient. You can do the pixel-wise comparisons by shifting the image for every pixel at once. For example, to check if a pixel is brighter than their neighbor 3 pixels to the left, shift the image to the right by 3 pixels and compare against the original image in a single line!
Save the visualization of the detected points in the first images of your 2 image sets as S1-fast.png and S2-fast.png
## 3: Robust FAST using Harris Cornerness metric (1 pts.)

Compute the Harris cornerness measure for each detected FAST feature. Eliminate weak FAST points by defining a threshold for the Harris metric. This threshold must be the same for every image you use. We will call these points FASTR points.
Comment on which points were discarded after this thresholded by comparing your FAST and FASTR visualizations. Save the visualization of the detected points in the first images of your 2 image sets as S1-fastR.png and S2-fastR.png. Note down the average computation time of FAST and FASTR features (average of all the images you have) and comment on the difference.
## 4: Point description and matching (2 pts.)

Use an existing implementation of one of ORB, SURF, or FREAK feature description methods to generate descriptors for your FAST and FASTR points. Note which descriptor you use in your report. Depending on the function you are using, you might need to put your keypoints in appropriate containers. Don’t forget to use MATLAB Help to get such definitions.
Match the features between the first two images in each photo set using existing implementation such as "matchFeatures" in MATLAB. Save the visualization of the matched points between the two images of your first 2 image sets, using FAST and FASTR points, as S1-fastMatch.png, S1-fastRMatch.png, S2-fastMatch.png, and S2-fastRMatch.png. Comment on the performance differences if any.
## 5: RANSAC and Panoramas (4 pts.)

To compute the homography between each pair, you will use RANSAC. You can use an existing implementation such as "estimateGeometricTransform2D" function in MATLAB, but you need to be able experiment with the RANSAC parameters for the optimum result.
Find the homography between two images in all your image sets and stitch them together.
Experiment with RANSAC parameters and find a setup where you use minimum number of trials while still getting a satisfactory result for all your image sets. You’ll find 2 different sets of RANSAC parameters, one for FAST and one for FASTR. The RANSAC parameters you decide should be the same for the 4 image sets.
Save the stitched images for all your image sets only using FASTR points, as S1-panorama.png, S2-panorama.png, S3-panorama.png, and S4-panorama.png Comment on the difference between optimal RANSAC parameters for FAST and FASTR.

**Source: http://yaksoy.github.io/introvc/assignment2/**
