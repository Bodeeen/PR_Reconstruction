points1 = [1 1; 2 2; 3 3; 5 5];
points2 = [2 2; 3 3; 4 4; 1 1];

plot(points1, '.', 'Color', 'green');
hold on;
plot(points2, '.', 'Color', 'red');

computeRigidTransformation(points1, points2)
[transformation, inliers] = estimateRigidTransformation(points1, points2, 100, 0.1);
transformation
inliers
% plot(points1(inliers, :), 'X', 'Color', 'green');
% plot(points2(inliers, :), 'X', 'Color', 'red');