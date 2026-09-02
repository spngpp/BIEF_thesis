% Fiscal Policy as a Stabilization Tool: An Exploration of a Quasi-Automatic VAT Stabilizer with Endogenous Pass-Through
% Author: Giuseppe Spina
% Supervisor: Prof. Tommaso Monacelli
% Bocconi University - BSc in International Economics and Finance
% September 2026

%%%%%%%%%%%%%%%%%%%%%%%% Model 2.3 %%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%
% Notes
%%%%%%
% The model is entered directly in first-order form. All endogenous
% variables are deviations from the deterministic steady state associated
% with the current value of vartheta.
%
% With vartheta = 0, after Calvo-Rotemberg slope matching, Model 2.3 nests
% Model 2.2 to first order for every common value of eta_tau.
%
% The Rotemberg parameter zeta is calibrated once in the no-deep-habit
% benchmark and is then held fixed when vartheta changes.

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
    zeta
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
vartheta = 0;

%%%%%%
% Calvo-Rotemberg slope matching
%%%%%%

theta_match        = 0.75;
lambda_calvo_match = ((1-theta_match)*(1-beta*theta_match))/theta_match;
MCbar_nohabit      = (epsilon-1)/epsilon;
ybar_nohabit       = (log(MCbar_nohabit)-log(1+bartau))/(sigma+phi);
Cbar_nohabit       = exp(ybar_nohabit);
zeta               = ((epsilon-1)*Cbar_nohabit)/lambda_calvo_match;

% Initial steady-state coefficients.
nubar_init  = 1/(epsilon*(1-vartheta));
MCbar_init  = 1-(1-beta*vartheta)/(epsilon*(1-vartheta));
ybar_init   = (log(MCbar_init)-log(1+bartau) ...
               -sigma*log(1-vartheta))/(sigma+phi);
Cbar        = exp(ybar_init);
rhobar      = (bartau/(1+bartau))*Cbar;
coef_mc     = MCbar_init/nubar_init;

%%%%%%
% Linearized Model
%%%%%%

model(linear);

    % (1) Habit-adjusted consumption, in deviations
    ctilde = (1/(1-vartheta))*y - (vartheta/(1-vartheta))*y(-1);

    % (2) Producer-good SDF, net of log(beta)
    mp = z(+1)-z - sigma*(ctilde(+1)-ctilde) - (varpi(+1)-varpi);

    % (3) Real marginal cost, in deviations
    mc = varpi + sigma*ctilde + phi*y - (1+phi)*a;

    % (4) Customer-value recursion
    v = vartheta*beta*(v(+1)+mp) - coef_mc*mc;

    % (5) Rotemberg pricing equation.
    pi = beta*pi(+1)
         - (Cbar/zeta)*(v + (vartheta/(1-vartheta))*(y-y(-1)));

    % (6) Actual VAT feedback rule
    varpi = eta_tau*y;

    % (7) First-order mapping from VAT wedge to VAT rate
    tau = (1+bartau)*varpi;

    % (8) Consumer-price inflation identity
    pic = pi + varpi - varpi(-1);

    % (9) Household Euler equation, using c_t = y_t
    y = (vartheta/(1+vartheta))*y(-1)
        + (1/(1+vartheta))*y(+1)
        - ((1-vartheta)/(sigma*(1+vartheta)))
          *(i - pic(+1) + z(+1)-z);

    % (10) Natural habit-adjusted consumption
    ctilden = (1/(1-vartheta))*yn
              - (vartheta/(1-vartheta))*yn(-1);

    % (11) VAT rule in the flexible-price counterfactual
    varpin = eta_tau*yn;

    % (12) Natural producer-good SDF, net of log(beta)
    mpn = z(+1)-z - sigma*(ctilden(+1)-ctilden)
          - (varpin(+1)-varpin);

    % (13) Natural real marginal cost
    mcn = varpin + sigma*ctilden + phi*yn - (1+phi)*a;

    % (14) Natural customer-value recursion
    vn = vartheta*beta*(vn(+1)+mpn) - coef_mc*mcn;

    % (15) Flexible-price condition, in deviations
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
% Six parameter combinations used in the quantitative illustration
%%%%%%
% By construction, columns with vartheta=0 should reproduce Model 2.2
% to first-order numerical precision.

vartheta_grid_23 = [0, 0, 0, 0.6, 0.6, 0.6];
eta_grid_23      = [0, 1/1.19, 2/1.19, 0, 1/1.19, 2/1.19];
irf_horizon_23   = 40;

% Preallocate IRF containers: preference shock
m23_y_z      = nan(irf_horizon_23,length(eta_grid_23));
m23_x_z      = nan(irf_horizon_23,length(eta_grid_23));
m23_yn_z     = nan(irf_horizon_23,length(eta_grid_23));
m23_pi_z     = nan(irf_horizon_23,length(eta_grid_23));
m23_pic_z    = nan(irf_horizon_23,length(eta_grid_23));
m23_i_z      = nan(irf_horizon_23,length(eta_grid_23));
m23_varpi_z  = nan(irf_horizon_23,length(eta_grid_23));
m23_tau_z    = nan(irf_horizon_23,length(eta_grid_23));
m23_d_z      = nan(irf_horizon_23,length(eta_grid_23));
m23_mc_z     = nan(irf_horizon_23,length(eta_grid_23));
m23_v_z      = nan(irf_horizon_23,length(eta_grid_23));
m23_ctilde_z = nan(irf_horizon_23,length(eta_grid_23));

% Preallocate IRF containers: technology shock
m23_y_a      = nan(irf_horizon_23,length(eta_grid_23));
m23_x_a      = nan(irf_horizon_23,length(eta_grid_23));
m23_yn_a     = nan(irf_horizon_23,length(eta_grid_23));
m23_pi_a     = nan(irf_horizon_23,length(eta_grid_23));
m23_pic_a    = nan(irf_horizon_23,length(eta_grid_23));
m23_i_a      = nan(irf_horizon_23,length(eta_grid_23));
m23_varpi_a  = nan(irf_horizon_23,length(eta_grid_23));
m23_tau_a    = nan(irf_horizon_23,length(eta_grid_23));
m23_d_a      = nan(irf_horizon_23,length(eta_grid_23));
m23_mc_a     = nan(irf_horizon_23,length(eta_grid_23));
m23_v_a      = nan(irf_horizon_23,length(eta_grid_23));
m23_ctilde_a = nan(irf_horizon_23,length(eta_grid_23));

% Store steady-state consumption for each parameter combination.
m23_Cbar = nan(1,length(eta_grid_23));

%%%%%%
% Loop over the six parameter combinations
%%%%%%

for combo_idx = 1:length(eta_grid_23)

    vartheta_current = vartheta_grid_23(combo_idx);
    eta_current      = eta_grid_23(combo_idx);

    % Steady-state coefficients implied by the current vartheta.
    nubar_current = 1/(epsilon*(1-vartheta_current));
    MCbar_current = 1-(1-beta*vartheta_current) ...
                    /(epsilon*(1-vartheta_current));

    if MCbar_current <= 0
        error('Model 2.3: non-positive steady-state marginal cost.');
    end

    ybar_current = (log(MCbar_current)-log(1+bartau) ...
                    -sigma*log(1-vartheta_current))/(sigma+phi);
    Cbar_current = exp(ybar_current);
    rhobar_current = (bartau/(1+bartau))*Cbar_current;
    coef_mc_current = MCbar_current/nubar_current;

    set_param_value('vartheta',vartheta_current);
    set_param_value('eta_tau',eta_current);
    set_param_value('Cbar',Cbar_current);
    set_param_value('rhobar',rhobar_current);
    set_param_value('coef_mc',coef_mc_current);

    m23_Cbar(combo_idx) = Cbar_current;

    steady(noprint);
    check;

    stoch_simul(order=1,ar=0,irf=40,nograph,noprint,nomoments,nocorr,nodecomposition,nofunctions,nomodelsummary);

    if info(1) ~= 0
        error(['Model 2.3: Dynare failed for parameter combination %d ', ...
               '(vartheta = %.3f, eta_tau = %.6f).'], ...
              combo_idx,vartheta_current,eta_current);
    end

    % Preference-shock IRFs
    m23_y_z(:,combo_idx)      = oo_.irfs.y_eps_z(:);
    m23_x_z(:,combo_idx)      = oo_.irfs.x_eps_z(:);
    m23_yn_z(:,combo_idx)     = oo_.irfs.yn_eps_z(:);
    m23_pi_z(:,combo_idx)     = oo_.irfs.pi_eps_z(:);
    m23_pic_z(:,combo_idx)    = oo_.irfs.pic_eps_z(:);
    m23_i_z(:,combo_idx)      = oo_.irfs.i_eps_z(:);
    m23_varpi_z(:,combo_idx)  = oo_.irfs.varpi_eps_z(:);
    m23_tau_z(:,combo_idx)    = oo_.irfs.tau_eps_z(:);
    m23_d_z(:,combo_idx)      = oo_.irfs.d_eps_z(:);
    m23_mc_z(:,combo_idx)     = oo_.irfs.mc_eps_z(:);
    m23_v_z(:,combo_idx)      = oo_.irfs.v_eps_z(:);
    m23_ctilde_z(:,combo_idx) = oo_.irfs.ctilde_eps_z(:);

    % Technology-shock IRFs
    m23_y_a(:,combo_idx)      = oo_.irfs.y_eps_a(:);
    m23_x_a(:,combo_idx)      = oo_.irfs.x_eps_a(:);
    m23_yn_a(:,combo_idx)     = oo_.irfs.yn_eps_a(:);
    m23_pi_a(:,combo_idx)     = oo_.irfs.pi_eps_a(:);
    m23_pic_a(:,combo_idx)    = oo_.irfs.pic_eps_a(:);
    m23_i_a(:,combo_idx)      = oo_.irfs.i_eps_a(:);
    m23_varpi_a(:,combo_idx)  = oo_.irfs.varpi_eps_a(:);
    m23_tau_a(:,combo_idx)    = oo_.irfs.tau_eps_a(:);
    m23_d_a(:,combo_idx)      = oo_.irfs.d_eps_a(:);
    m23_mc_a(:,combo_idx)     = oo_.irfs.mc_eps_a(:);
    m23_v_a(:,combo_idx)      = oo_.irfs.v_eps_a(:);
    m23_ctilde_a(:,combo_idx) = oo_.irfs.ctilde_eps_a(:);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%
% Figura A.1: first-order solution map
%%%%%%
% A grid point is classified as valid if:
% 1. the deep-habit steady state has positive real marginal cost; and
% 2. Dynare obtains a valid first-order stochastic solution (info(1)=0).

map_eta_grid_23      = 0:0.05:2.00;
map_vartheta_grid_23 = 0:0.025:1;
m23_solution_map     = zeros(length(map_vartheta_grid_23), ...
                             length(map_eta_grid_23));

fprintf('\nComputing Model 2.3 first-order solution map...\n');

for v_idx = 1:length(map_vartheta_grid_23)

    vartheta_map = map_vartheta_grid_23(v_idx);

    nubar_map = 1/(epsilon*(1-vartheta_map));
    MCbar_map = 1-(1-beta*vartheta_map) ...
                /(epsilon*(1-vartheta_map));

    if MCbar_map <= 0
        continue
    end

    ybar_map = (log(MCbar_map)-log(1+bartau) ...
                -sigma*log(1-vartheta_map))/(sigma+phi);
    Cbar_map = exp(ybar_map);
    rhobar_map = (bartau/(1+bartau))*Cbar_map;
    coef_mc_map = MCbar_map/nubar_map;

    set_param_value('vartheta',vartheta_map);
    set_param_value('Cbar',Cbar_map);
    set_param_value('rhobar',rhobar_map);
    set_param_value('coef_mc',coef_mc_map);

    for eta_idx = 1:length(map_eta_grid_23)

        eta_map = map_eta_grid_23(eta_idx);
        set_param_value('eta_tau',eta_map);

        map_valid = false;

        try
            stoch_simul(order=1,ar=0,irf=0,nograph,noprint,nomoments,nocorr,nodecomposition,nofunctions,nomodelsummary);
            map_valid = (info(1) == 0);
        catch
            map_valid = false;
        end

        m23_solution_map(v_idx,eta_idx) = double(map_valid);

    end

    if mod(v_idx,5) == 0 || v_idx == length(map_vartheta_grid_23)
        fprintf('  completed %d of %d vartheta rows\n', ...
                v_idx,length(map_vartheta_grid_23));
    end

end

%%%%%%
% Objects used by the MATLAB execution/plotting file
%%%%%%

m23_eta_grid       = eta_grid_23;
m23_vartheta_grid  = vartheta_grid_23;
m23_zeta           = zeta;
m23_bartau         = bartau;
m23_epsilon        = epsilon;
m23_map_eta        = map_eta_grid_23;
m23_map_vartheta   = map_vartheta_grid_23;

% Restore the main deep-habit calibration after the map scan.
set_param_value('vartheta',0.6);
set_param_value('eta_tau',1/1.19);
