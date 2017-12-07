close all; clear all;

addpath(genpath('C:\Data\isdri\isdri-scripts')) %github path
addpath(genpath('D:\SupportData')) %support data on CTR HUB

cubeFile='D:\guadalupe\processed\2017-09-20\Guadalupe_20172631930_pol.mat'; 

pngFile= 'D:\Purisima_20172510000_pol.png';

cube2png_guadalupe_enviro_bathy(cubeFile,pngFile)

