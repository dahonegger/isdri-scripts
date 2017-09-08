function [yTide,dnTide] = arguelloPointElevations

fname = 'Arguello_Point_elevations_2min.txt';

[yTide,dnTide] = loadXTide(fname);