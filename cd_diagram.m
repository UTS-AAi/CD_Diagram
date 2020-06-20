function cd = cd_diagram(avranks, N, labels, alpha, no_decimal, met)
%
% cd_diagram - plot a critical difference diagram
%
%    cd_diagram(avranks, N, labels, alpha, no_decimal, met) produces a critical difference diagram [1]
%    displaying the statistical significance (or otherwise) of a matrix of
%    scores, S, achieved by a set of machine learning algorithms.  Here
%    LABELS is a cell array of strings giving the name of each algorithm.
%  
%    avranks: average ranks for classifiers
%    labels: a list of cell containing names of classifiers
%    alpha: significant level
%    N: Number of datasets
%    no_decimal: Number of digits in the decimal part to round the cd value
%    met: Post-host test method: Nemenyi or Bonferroni-Dunn 
%    
%    References
%    
%    [1] Demsar, J., "Statistical comparisons of classifiers over multiple
%        datasets", Journal of Machine Learning Research, vol. 7, pp. 1-30,
%        2006.
%

%
% File        : criticaldifference.m
%
%
% Author      : Thanh Tung Khuat
%
% Copyright   : (c) Thanh Tung Khuat, June 2020.
%
%    This program is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 2 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program; if not, write to the Free Software
%    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
%

if nargin < 6
    met = "nemenyi";
end

if nargin < 5
    no_decimal = 3;
end

if nargin < 4

   alpha = 0.05;

end

k = size(avranks, 2);
% compute critical difference

if alpha == 0.01
        qalpha = [0.000 2.576 2.913 3.113 3.255 3.364 3.452 3.526 3.590 3.646 ...
             3.696 3.741 3.781 3.818 3.853 3.884 3.914 3.941 3.967 3.992 ...
             4.015 4.037 4.057 4.077 4.096 4.114 4.132 4.148 4.164 4.179 ...
             4.194 4.208 4.222 4.236 4.249 4.261 4.273 4.285 4.296 4.307 ...
             4.318 4.329 4.339 4.349 4.359 4.368 4.378 4.387 4.395 4.404 ...
             4.412 4.420 4.428 4.435 4.442 4.449 4.456 ];

elseif alpha == 0.05
    if met=="nemenyi"
        qalpha = [0.000 1.959964 2.343701 2.569032 2.727774 2.849705 2.94832 ...
                  3.030879 3.101730 3.163684 3.218654 3.268004 3.312739 3.353618 ...
                  3.39123 3.426041 3.458425 3.488685 3.517073 3.543799 ...
                  3.569 3.593 3.616 3.637 3.658 3.678 3.696 3.714 3.732 3.749 ...
                  3.765 3.780 3.795 3.810 3.824 3.837 3.850 3.863 3.876 3.888 ...
                  3.899 3.911 3.922 3.933 3.943 3.954 3.964 3.973 3.983 3.992 ...
                  4.001 4.009 4.017 4.025 4.032 4.040 4.046]; 
    else
        qalpha = [0 1.960 2.241 2.394 2.498 2.576 2.638 2.690 2.724 2.773];
    end

elseif alpha == 0.1
    if met=="nemenyi"
        qalpha = [0.000 1.645 2.052 2.291 2.460 2.589 2.693 2.780 2.855 2.920 ...
             2.978 3.030 3.077 3.120 3.159 3.196 3.230 3.261 3.291 3.319 ...
             3.346 3.371 3.394 3.417 3.439 3.459 3.479 3.498 3.516 3.533 ...
             3.550 3.567 3.582 3.597 3.612 3.626 3.640 3.653 3.666 3.679 ...
             3.691 3.703 3.714 3.726 3.737 3.747 3.758 3.768 3.778 3.788 ...
             3.797 3.806 3.814 3.823 3.831 3.838 3.846];
    else
        qalpha = [0 1.645 1.960 2.128 2.241 2.326 2.394 2.450 2.498 2.539];
    end

else

   error('alpha must be 0.01, 0.05 or 0.1');

end

cd = qalpha(k)*sqrt(k*(k+1)/(6*N));

figure(1);
clf
axis off
axis([-0.5 1.5 0 140]);
axis xy 
tics = repmat((0:(k-1))/(k-1), 3, 1);
line(tics(:), repmat([100, 105, 100], 1, k), 'LineWidth', 2, 'Color', 'k');
tics = repmat(((0:(k-2))/(k-1)) + 0.5/(k-1), 3, 1);
line(tics(:), repmat([100, 102.5, 100], 1, k-1), 'LineWidth', 1, 'Color', 'k');
line([0 0 0 cd/(k-1) cd/(k-1) cd/(k-1)], [127 123 125 125 123 127], 'LineWidth', 1, 'Color', 'k');
cd_text = sprintf("CD = %%.%df", no_decimal);
h = text(0.5*cd/(k-1), 130, sprintf(cd_text, cd), 'FontSize', 11, 'HorizontalAlignment', 'center');

for i=1:k

   text((i-1)/(k-1), 110, num2str(k-i+1), 'FontSize', 12, 'HorizontalAlignment', 'center');

end

% compute average ranks

r       = round(avranks, no_decimal);
[r,idx] = sort(r);

% compute statistically similar cliques

clique           = repmat(r,k,1) - repmat(r',1,k);
clique(clique<0) = realmax; 
clique           = clique < cd;

for i=k:-1:2

   if all(clique(i-1,clique(i,:))==clique(i,clique(i,:)))

      clique(i,:) = 0;

   end

end

n                = sum(clique,2);
clique           = clique(n>1,:);
n                = size(clique,1);

% labels displayed on the right
font_size_method = 11;
font_size_rank = 10;
for i=1:ceil(k/2)

   line([(k-r(i))/(k-1) (k-r(i))/(k-1) 1.1], [100 100-5*(n+1)-10*i 100-5*(n+1)-10*i], 'Color', 'k');
   h = text(1.1, 101 - 5*(n+1)- 10*i + 2, num2str(r(i)), 'FontSize', font_size_rank, 'HorizontalAlignment', 'right');

   text(1.13, 101 - 5*(n+1) - 10*i, labels{idx(i)}, 'FontSize', font_size_method, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');

end

% labels displayed on the left

for i=ceil(k/2)+1:k

   line([(k-r(i))/(k-1) (k-r(i))/(k-1) -0.1], [100 100-5*(n+1)-10*(k-i+1) 100-5*(n+1)-10*(k-i+1)], 'Color', 'k');

   text(-0.1, 101 - 5*(n+1) -10*(k-i+1)+2, num2str(r(i)), 'FontSize', font_size_rank, 'HorizontalAlignment', 'left');

   text(-0.13, 101 - 5*(n+1) -10*(k-i+1), labels{idx(i)}, 'FontSize', font_size_method, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'right');

end

% group cliques of statistically similar classifiers

for i=1:size(clique,1)

   R = r(clique(i,:));

   line([((k-min(R))/(k-1)) + 0.015 ((k - max(R))/(k-1)) - 0.015], [100-5*i 100-5*i], 'LineWidth', 3, 'Color', 'k');

end

