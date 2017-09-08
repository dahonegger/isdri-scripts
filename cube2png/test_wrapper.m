close all; clear all;

addpath(genpath('C:\Users\user\Desktop\isdri-scripts')) %github path
addpath(genpath('E:\SupportData')) %support data on CTR HUB

cubeFile='E:\purisima\processed\2017-09-08\Purisima_20172510000_pol.mat'; 

pngFile= 'E:\purisima\processed\PNGs\Purisima_20172510000_pol.png';

cube2png(cubeFile,pngFile)

