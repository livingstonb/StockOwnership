clear

addpath('../EconTools')

params.nx = 50;
params.xmax = 100;
params.xcurv = 0.1;
params.bbeta = 0.98;
params.r = 0.005;

r_e_dist = [0.1; 0.2; 0.4; 0.2; 0.1];
r_e_grid = linspace(

rgrid = [0.05 0.02 -0.02];


xgrid = EconToolsML.GridConstruction.create_positive_asset_grid(params.xmax, params.xcurv, params.nx);
ygrid = [1];
ytrans = [1];

util = @(x) log(x);
util1 = @(x) 1 / x;

% sguess = repmat(xgrid, 1, 2) + 0.1;
% sav = sguess;
% 
% sshare = 0.5 * ones(params.nx, 2);

cguess = 0.5 * ygrid + params.r * xgrid;
V = util(cguess);

iter = 1;
dtol = 1e5;
maxiters = 1e5;

while (dtol > 1e-8) && (iter <= maxiters)
    

    
    con = xgrid + ygrid - sav;
    R_p = 1 + (1 - sshare) .* params.r + sshare .* rbeliefs_bc;
    xprime = R_p .* sav + ygrid;

    conprime = zeros(params.nx, 2, 3);
    for iz = 1:2
        cinterp = griddedInterpolant(xgrid, con(:,2), 'linear');
        ctemp = cinterp(reshape(xprime(:,iz,:), [], 1));
        conprime(:,iz,:) = reshape(ctemp, [params.nx 1 3]);
    end
    
    u1prime = util1(conprime);
    rhs = params.bbeta * R_p .* u1prime .* rbeliefs_bc;
    rhs = sum(rhs, 3);
    
    dv = zeros(params.nx, 2, 2);

    dv1 = zeros(params.nx, 2);
    valid = u1prime >= rhs;
    dv1(valid) = 0;
    dv1(~valid) = rhs - u1prime;
    dv(:,:,1) = dv1;
    
    constrained = u1prime > rhs;
    rhs = params.bbeta * (R_p - 1) .* u1prime .* rbeliefs_bc;
    rhs = sum(rhs, 3);
    dv(:,:,2) = abs(rhs);
    
    iter = iter + 1;
end
