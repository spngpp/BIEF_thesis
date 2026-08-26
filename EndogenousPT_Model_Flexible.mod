% Fiscal Policy as a Stabilization Tool: An Exploration of a Quasi-Automatic VAT Stabilizer with Endogenous Pass-Through
% Author: Giuseppe Spina
% Supervisor: Prof. Tommaso Monacelli
% Bocconi University - BSc in International Economics and Finance
% September 2026

%%%%%%%%%%%% Model 2.3: flexible price benchmark %%%%%%%%%%%%%%%

%%%%%%
% Notes
%%%%%%
% This file implements the flexible-price limit of Model 2.3 for the
% benchmark deep-habit calibration vartheta = 0.6. The Rotemberg pricing
% equation is removed and replaced by the flexible-price optimality
% condition
%       v_t = y_t - ctilde_t,
% which is the first-order form of
%       C_t = epsilon*nu_t*(C_t-vartheta*C_{t-1}).
%
% This is the economically correct zeta -> 0 limit. We do NOT literally
% set zeta = 0 in the linearized Rotemberg Phillips curve because that
% equation contains Cbar/zeta and is therefore undefined at zeta = 0.

%%%%%%
% Endogenous Variables
%%%%%%

var
    y           % log output / consumption deviation
    x           % output gap
    yn          % natural output deviation
    ctilde      % habit-adjusted consumption deviation
    ctilden     % natural habit-adjusted consumption deviation
    v           % customer-value deviation: v_t-vbar
    vn          % natural customer-value deviation
    mc          % log real marginal-cost deviation
    mcn         % natural log real marginal-cost deviation
    mp          % producer SDF deviation from log(beta)
    mpn         % natural producer SDF deviation from log(beta)
    pi          % producer-price inflation
    pic         % consumer-price inflation
    i           % nominal interest-rate deviation
    varpi       % actual VAT-wedge deviation
    varpin      % natural VAT-wedge deviation
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
    phi_pi
    phi_x
    rho_z
    rho_a
    bartau
    chi
    eta_tau
    vartheta
    Cbar
    rhobar
    coef_mc;

beta     = 0.99;
sigma    = 1;
phi      = 5;
epsilon  = 9;
phi_pi   = 1.5;
phi_x    = 0.125;
rho_z    = 0.5;
rho_a    = 0.9;
bartau   = 0.19;
chi      = 0.1;
eta_tau  = 0;
vartheta = 0.6;

% Initial steady-state coefficients. They are overwritten inside the loop.
nubar_init  = 1/(epsilon*(1-vartheta));
MCbar_init  = 1-(1-beta*vartheta)/(epsilon*(1-vartheta));
ybar_init   = (log(MCbar_init)-log(1+bartau) ...
               -sigma*log(1-vartheta))/(sigma+phi);
Cbar        = exp(ybar_init);
rhobar      = (bartau/(1+bartau))*Cbar;
coef_mc     = MCbar_init/nubar_init;

%%%%%%
% Directly Linearized Flexible-Price Model
%%%%%%

model(linear);

    % (1) Habit-adjusted consumption
    ctilde = (1/(1-vartheta))*y - (vartheta/(1-vartheta))*y(-1);

    % (2) Producer-good SDF, net of log(beta)
    mp = z(+1)-z - sigma*(ctilde(+1)-ctilde) - (varpi(+1)-varpi);

    % (3) Real marginal cost
    mc = varpi + sigma*ctilde + phi*y - (1+phi)*a;

    % (4) Customer-value recursion
    v = vartheta*beta*(v(+1)+mp) - coef_mc*mc;

    % (5) FLEXIBLE-PRICE optimality condition
    v = y - ctilde;

    % (6) Actual VAT feedback rule
    varpi = eta_tau*y;

    % (7) First-order mapping from VAT wedge to VAT rate
    tau = (1+bartau)*varpi;

    % (8) Consumer-price inflation identity
    pic = pi + varpi - varpi(-1);

    % (9) Household Euler equation
    y = (vartheta/(1+vartheta))*y(-1)
        + (1/(1+vartheta))*y(+1)
        - ((1-vartheta)/(sigma*(1+vartheta)))
          *(i - pic(+1) + z(+1)-z);

    % (10) Natural habit-adjusted consumption
    ctilden = (1/(1-vartheta))*yn
              - (vartheta/(1-vartheta))*yn(-1);

    % (11) VAT rule in the natural flexible-price allocation
    varpin = eta_tau*yn;

    % (12) Natural producer-good SDF, net of log(beta)
    mpn = z(+1)-z - sigma*(ctilden(+1)-ctilden)
          - (varpin(+1)-varpin);

    % (13) Natural real marginal cost
    mcn = varpin + sigma*ctilden + phi*yn - (1+phi)*a;

    % (14) Natural customer-value recursion
    vn = vartheta*beta*(vn(+1)+mpn) - coef_mc*mcn;

    % (15) Natural flexible-price condition
    vn = yn - ctilden;

    % (16) Output gap
    x = y - yn;

    % (17) Monetary-policy rule: producer-price inflation target
    i = phi_pi*pi + phi_x*x;

    % (18) Linearized stabilizer-debt accumulation
    beta*d = (1-chi)*d(-1)
             - rhobar*y
             - (Cbar/(1+bartau))*varpi;

    % (19) Technology process
    a = rho_a*a(-1) - eps_a;

    % (20) Preference process
    z = rho_z*z(-1) - eps_z;

end;

%%%%%%
% Zero steady state of the directly linearized system
%%%%%%

initval;
    y = 0;
    x = 0;
    yn = 0;
    ctilde = 0;
    ctilden = 0;
    v = 0;
    vn = 0;
    mc = 0;
    mcn = 0;
    mp = 0;
    mpn = 0;
    pi = 0;
    pic = 0;
    i = 0;
    varpi = 0;
    varpin = 0;
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
% Three flexible-price parameter combinations, all with vartheta = 0.6
%%%%%%

eta_grid_23f    = [0, 1/1.19, 2/1.19];
irf_horizon_23f = 40;

% Preference shock
m23f_y_z      = nan(irf_horizon_23f,length(eta_grid_23f));
m23f_x_z      = nan(irf_horizon_23f,length(eta_grid_23f));
m23f_yn_z     = nan(irf_horizon_23f,length(eta_grid_23f));
m23f_pi_z     = nan(irf_horizon_23f,length(eta_grid_23f));
m23f_pic_z    = nan(irf_horizon_23f,length(eta_grid_23f));
m23f_i_z      = nan(irf_horizon_23f,length(eta_grid_23f));
m23f_varpi_z  = nan(irf_horizon_23f,length(eta_grid_23f));
m23f_tau_z    = nan(irf_horizon_23f,length(eta_grid_23f));
m23f_d_z      = nan(irf_horizon_23f,length(eta_grid_23f));
m23f_mc_z     = nan(irf_horizon_23f,length(eta_grid_23f));
m23f_v_z      = nan(irf_horizon_23f,length(eta_grid_23f));
m23f_ctilde_z = nan(irf_horizon_23f,length(eta_grid_23f));

% Technology shock
m23f_y_a      = nan(irf_horizon_23f,length(eta_grid_23f));
m23f_x_a      = nan(irf_horizon_23f,length(eta_grid_23f));
m23f_yn_a     = nan(irf_horizon_23f,length(eta_grid_23f));
m23f_pi_a     = nan(irf_horizon_23f,length(eta_grid_23f));
m23f_pic_a    = nan(irf_horizon_23f,length(eta_grid_23f));
m23f_i_a      = nan(irf_horizon_23f,length(eta_grid_23f));
m23f_varpi_a  = nan(irf_horizon_23f,length(eta_grid_23f));
m23f_tau_a    = nan(irf_horizon_23f,length(eta_grid_23f));
m23f_d_a      = nan(irf_horizon_23f,length(eta_grid_23f));
m23f_mc_a     = nan(irf_horizon_23f,length(eta_grid_23f));
m23f_v_a      = nan(irf_horizon_23f,length(eta_grid_23f));
m23f_ctilde_a = nan(irf_horizon_23f,length(eta_grid_23f));

m23f_Cbar = nan(1,length(eta_grid_23f));

for eta_idx = 1:length(eta_grid_23f)

    eta_current = eta_grid_23f(eta_idx);

    nubar_current = 1/(epsilon*(1-vartheta));
    MCbar_current = 1-(1-beta*vartheta)/(epsilon*(1-vartheta));

    if MCbar_current <= 0
        error('Flexible Model 2.3: non-positive steady-state marginal cost.');
    end

    ybar_current = (log(MCbar_current)-log(1+bartau) ...
                    -sigma*log(1-vartheta))/(sigma+phi);
    Cbar_current = exp(ybar_current);
    rhobar_current = (bartau/(1+bartau))*Cbar_current;
    coef_mc_current = MCbar_current/nubar_current;

    set_param_value('eta_tau',eta_current);
    set_param_value('Cbar',Cbar_current);
    set_param_value('rhobar',rhobar_current);
    set_param_value('coef_mc',coef_mc_current);

    m23f_Cbar(eta_idx) = Cbar_current;

    steady(noprint);
    check;

    stoch_simul(order=1,ar=0,irf=40,nograph,noprint,nomoments,nocorr,nodecomposition,nofunctions,nomodelsummary);

    if info(1) ~= 0
        error(['Flexible Model 2.3: Dynare failed for eta_tau = %.6f.'], ...
              eta_current);
    end

    % Preference shock
    m23f_y_z(:,eta_idx)      = oo_.irfs.y_eps_z(:);
    m23f_x_z(:,eta_idx)      = oo_.irfs.x_eps_z(:);
    m23f_yn_z(:,eta_idx)     = oo_.irfs.yn_eps_z(:);
    m23f_pi_z(:,eta_idx)     = oo_.irfs.pi_eps_z(:);
    m23f_pic_z(:,eta_idx)    = oo_.irfs.pic_eps_z(:);
    m23f_i_z(:,eta_idx)      = oo_.irfs.i_eps_z(:);
    m23f_varpi_z(:,eta_idx)  = oo_.irfs.varpi_eps_z(:);
    m23f_tau_z(:,eta_idx)    = oo_.irfs.tau_eps_z(:);
    m23f_d_z(:,eta_idx)      = oo_.irfs.d_eps_z(:);
    m23f_mc_z(:,eta_idx)     = oo_.irfs.mc_eps_z(:);
    m23f_v_z(:,eta_idx)      = oo_.irfs.v_eps_z(:);
    m23f_ctilde_z(:,eta_idx) = oo_.irfs.ctilde_eps_z(:);

    % Technology shock
    m23f_y_a(:,eta_idx)      = oo_.irfs.y_eps_a(:);
    m23f_x_a(:,eta_idx)      = oo_.irfs.x_eps_a(:);
    m23f_yn_a(:,eta_idx)     = oo_.irfs.yn_eps_a(:);
    m23f_pi_a(:,eta_idx)     = oo_.irfs.pi_eps_a(:);
    m23f_pic_a(:,eta_idx)    = oo_.irfs.pic_eps_a(:);
    m23f_i_a(:,eta_idx)      = oo_.irfs.i_eps_a(:);
    m23f_varpi_a(:,eta_idx)  = oo_.irfs.varpi_eps_a(:);
    m23f_tau_a(:,eta_idx)    = oo_.irfs.tau_eps_a(:);
    m23f_d_a(:,eta_idx)      = oo_.irfs.d_eps_a(:);
    m23f_mc_a(:,eta_idx)     = oo_.irfs.mc_eps_a(:);
    m23f_v_a(:,eta_idx)      = oo_.irfs.v_eps_a(:);
    m23f_ctilde_a(:,eta_idx) = oo_.irfs.ctilde_eps_a(:);

end

m23f_eta_grid      = eta_grid_23f;
m23f_vartheta      = vartheta;
m23f_bartau        = bartau;
m23f_epsilon       = epsilon;