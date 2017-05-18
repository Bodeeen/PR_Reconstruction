function [ z ] = testFun( x )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
z = (1-x(1)).^2 + 100*(x(2)-x(1).^2).^2;
end

