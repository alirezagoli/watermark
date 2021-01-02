% Alireza Goli
function NC=NC_project(S, W1D)

% Calculating NC
NC= sum(S==W1D)/ size(S,1);

end