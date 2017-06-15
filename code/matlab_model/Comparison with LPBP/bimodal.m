clear all
n = 100000;
[bimodal_dist, dist_function] = umgrn([ 0.9 0.9],[0.1 0.1 ],n, 'limit', [0 1], 'with_plot', 0);

x = bimodal_dist(randperm(numel(bimodal_dist)));
% plot the distribution
hist(bimodal_dist,100);
% create a title
title(sprintf('mean=%f, median=%f,variance=%f',mean(x),median(x),var(x)))