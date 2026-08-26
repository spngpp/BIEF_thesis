% Fiscal Policy as a Stabilization Tool: An Exploration of a Quasi-Automatic VAT Stabilizer with Endogenous Pass-Through
% Author: Giuseppe Spina
% Supervisor: Prof. Tommaso Monacelli
% Bocconi University - BSc in International Economics and Finance
% September 2026

%%%%%%%%%%%%%%%%%%%%%%%% Model 2.2 %%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%
% Notes
%%%%%%
% The model is entered directly in first-order form.
% All endogenous variables are deviations from the deterministic steady state.

%%%%%%
% Endogenous Variables
%%%%%%

var
    y           % log output deviation
    x           % output gap
    yn          % natural output deviation
    pi          % producer-price inflation
    pic         % consumer-price inflation
    i           % nominal interest-rate deviation
    varpi       % VAT-wedge deviation: log(1+tau)-log(1+tau_bar)
    tau         % first-order VAT-rate deviation
    d           % real stabilizer-debt deviation
    a           % technology state
    z;          % preference state

%%%%%%
% Exogenous Variables
%%%%%%

varexo
    eps_z       % preference shock
    eps_a;      % technology shock

%%%%%%
% Parameters
%%%%%%

parameters
    beta
    sigma
    phi
    epsilon
    theta
    phi_pi
    phi_x
    rho_z
    rho_a
    bartau
    chi
    eta_tau
    lambda_calvo
    Cbar
    rhobar;

beta    = 0.99;
sigma   = 1;
phi     = 5;
epsilon = 9;
theta   = 0.75;
phi_pi  = 1.5;
phi_x   = 0.125;
rho_z   = 0.5;
rho_a   = 0.9;
bartau  = 0.19;
chi     = 0.1;
eta_tau = 0;

% Calvo slope on the real marginal-cost gap
lambda_calvo = ((1-theta)*(1-beta*theta))/theta;

% Common deterministic steady state of Model 2.2. The VAT-rule intercept
% is re-anchored for every eta_tau, so Cbar does not change with eta_tau.
MCbar_standard = (epsilon-1)/epsilon;
ybar_standard  = (log(MCbar_standard)-log(1+bartau))/(sigma+phi);
Cbar           = exp(ybar_standard);
rhobar         = (bartau/(1+bartau))*Cbar;

%%%%%%
% Linearized Model
%%%%%%

model(linear);

    % (1) Dynamic IS equation, equation (2.2.23)
    y = y(+1) - (1/(sigma+eta_tau))*(i - pi(+1) + z(+1) - z);

    % (2) Fixed-point natural output, equation (2.2.18), in deviations
    yn = ((1+phi)/(sigma+phi+eta_tau))*a;

    % (3) Output gap
    x = y - yn;

    % (4) New Keynesian Phillips Curve, equations (2.2.20)-(2.2.21)
    pi = beta*pi(+1) + lambda_calvo*(sigma+phi+eta_tau)*x;

    % (5) Monetary-policy rule, equation (2.1.34), in deviations
    i = phi_pi*pi + phi_x*x;

    % (6) VAT feedback rule, equation (2.2.11), in deviations
    varpi = eta_tau*y;

    % (7) First-order mapping from the VAT wedge to the VAT rate
    tau = (1+bartau)*varpi;

    % (8) Consumer-price inflation identity, equation (2.2.14)
    pic = pi + varpi - varpi(-1);

    % (9) Linearized debt accumulation around dbar = 0 and PiCbar = 1
    %     beta*d_t = (1-chi)d_{t-1} - (rho_t^tau-rhobar)
    % with d rho_t^tau = rhobar*y_t + Cbar/(1+bartau)*varpi_t.
    beta*d = (1-chi)*d(-1) - rhobar*y - (Cbar/(1+bartau))*varpi;

    % (10) Technology process
    a = rho_a*a(-1) - eps_a;

    % (11) Preference process
    z = rho_z*z(-1) - eps_z;

end;

%%%%%%
% Zero steady state of the directly linearized system
%%%%%%

initval;
    y = 0;
    x = 0;
    yn = 0;
    pi = 0;
    pic = 0;
    i = 0;
    varpi = 0;
    tau = 0;
    d = 0;
    a = 0;
    z = 0;
end;

%%%%%%
% Shock sizes
%%%%%%

shocks;
    var eps_z = 0.01^2;     % 1% contractionary preference shock
    var eps_a = 0.01^2;     % 1% contractionary technology shock
end;

%%%%%%
% Values of eta_tau to iterate over
%%%%%%

eta_grid_22 = [0, 1/1.19, 2/1.19];
irf_horizon_22 = 40; 

% Preallocate IRF containers: preference shock
m22_y_z     = nan(irf_horizon_22,length(eta_grid_22));
m22_x_z     = nan(irf_horizon_22,length(eta_grid_22));
m22_yn_z    = nan(irf_horizon_22,length(eta_grid_22));
m22_pi_z    = nan(irf_horizon_22,length(eta_grid_22));
m22_pic_z   = nan(irf_horizon_22,length(eta_grid_22));
m22_i_z     = nan(irf_horizon_22,length(eta_grid_22));
m22_varpi_z = nan(irf_horizon_22,length(eta_grid_22));
m22_tau_z   = nan(irf_horizon_22,length(eta_grid_22));
m22_d_z     = nan(irf_horizon_22,length(eta_grid_22));

% Preallocate IRF containers: technology shock
m22_y_a     = nan(irf_horizon_22,length(eta_grid_22));
m22_x_a     = nan(irf_horizon_22,length(eta_grid_22));
m22_yn_a    = nan(irf_horizon_22,length(eta_grid_22));
m22_pi_a    = nan(irf_horizon_22,length(eta_grid_22));
m22_pic_a   = nan(irf_horizon_22,length(eta_grid_22));
m22_i_a     = nan(irf_horizon_22,length(eta_grid_22));
m22_varpi_a = nan(irf_horizon_22,length(eta_grid_22));
m22_tau_a   = nan(irf_horizon_22,length(eta_grid_22));
m22_d_a     = nan(irf_horizon_22,length(eta_grid_22));

%%%%%%
% Loop over eta_tau values
%%%%%%

for eta_idx = 1:length(eta_grid_22)

    set_param_value('eta_tau',eta_grid_22(eta_idx));

    steady;
    check;

    stoch_simul(order=1,ar=0,irf=40,nograph);

    if info(1) ~= 0
        error('Model 2.2: Dynare failed for eta_tau index %d.',eta_idx);
    end

    % Preference-shock IRFs
    m22_y_z(:,eta_idx)     = oo_.irfs.y_eps_z(:);
    m22_x_z(:,eta_idx)     = oo_.irfs.x_eps_z(:);
    m22_yn_z(:,eta_idx)    = oo_.irfs.yn_eps_z(:);
    m22_pi_z(:,eta_idx)    = oo_.irfs.pi_eps_z(:);
    m22_pic_z(:,eta_idx)   = oo_.irfs.pic_eps_z(:);
    m22_i_z(:,eta_idx)     = oo_.irfs.i_eps_z(:);
    m22_varpi_z(:,eta_idx) = oo_.irfs.varpi_eps_z(:);
    m22_tau_z(:,eta_idx)   = oo_.irfs.tau_eps_z(:);
    m22_d_z(:,eta_idx)     = oo_.irfs.d_eps_z(:);

    % Technology-shock IRFs
    m22_y_a(:,eta_idx)     = oo_.irfs.y_eps_a(:);
    m22_x_a(:,eta_idx)     = oo_.irfs.x_eps_a(:);
    m22_yn_a(:,eta_idx)    = oo_.irfs.yn_eps_a(:);
    m22_pi_a(:,eta_idx)    = oo_.irfs.pi_eps_a(:);
    m22_pic_a(:,eta_idx)   = oo_.irfs.pic_eps_a(:);
    m22_i_a(:,eta_idx)     = oo_.irfs.i_eps_a(:);
    m22_varpi_a(:,eta_idx) = oo_.irfs.varpi_eps_a(:);
    m22_tau_a(:,eta_idx)   = oo_.irfs.tau_eps_a(:);
    m22_d_a(:,eta_idx)     = oo_.irfs.d_eps_a(:);

end;

% Objects used by the MATLAB execution/plotting file
m22_eta_grid = eta_grid_22;
m22_Cbar = Cbar;
m22_bartau = bartau;