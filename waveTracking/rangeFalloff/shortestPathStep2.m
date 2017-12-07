function [Y,ind]=shortestPath(A,pathdirection);
%{
function ind=shortestPath(A,pathdirection);

Solve for the second pass of accumulated evidence across each "slice" A and 
find the lowest cost path through the resulting accumlated evidence (Y)
following Step 2 of the method of Sun, 2002, Fast Stereo Matching Using 
Rectangular Subregioning and 3D Maximum-Surface Techniques, International 
Journal of Computer Vision 47, 99-117.

Method was originally coded by L. Clarke.
M. Palmsten 11/2009

Inputs
A                   D x V evidence matrix from doEvidence.m
pathdirection = 0   for top to bottom path.
              = 1   for left to right path.

%}

if nargin < 2
  error('shortestPath requires 2 input arguments.');
  return;
end

% Check for NaN's
if sum(sum(isnan(A)))>0
  error('Graph must not have any NaN.');
  return;
end

% Transpose graph if path direction is left to right.
switch pathdirection
 case 0
  tG = A;
 case 1
  tG = A';
 otherwise
  error('Argument 2 for shortestPAth must be 0 or 1.');
  return;
end

% Pad sides of graph with inf to simplify neighbor search near
% graph boundaries.
G = ones(size(tG)+[0,2]).*inf;
G(:,2:end-1) = tG;

m = size(G,1); % number of rows in unpadded graph
n = size(G,2); % number of columns in unpadded graph

% Forward pass
% Y is length of shortest path from graph top to node G(i,j)
% Shortest path in first row is just itself.
Y = zeros(size(G));
Y(1,:) = G(1,:);
Y(:,1) = ones(size(Y(:,1))).*inf;
Y(:,end) = ones(size(Y(:,end))).*inf;
step = [0 -1 1];

for i=2:m
  for j=2:n-1
    % Sub array of upper nearest neighbors.
    prev = Y(i-1,j+step);
    % Find shortest path neighbor
    zmin = min(find(prev == min(prev)));
    Y(i,j) = G(i,j)+prev(zmin); % Shortest path length to this
                                % node.
    k(i,j) = step(zmin);  % Index to shortest path neighbor.
  end
end

% Array for indicies of shortest path.
t1 = [1:m]';
ind = [zeros(size(t1))];

% Backtracking
ind(m) = max(find(Y(end,:) == min(Y(end,:))));
for i=m-1:-1:1
  ind(i) = ind(i+1)+k(i+1,ind(i+1));
end

% Adjust shortest path indicies for padding and transposition.
Y = Y(:,2:end-1);
switch pathdirection
 case 0
  ind = [ind-1];
 case 1
  ind = [ind-1]';
  Y= Y';
end

