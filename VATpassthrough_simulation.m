% Fiscal Policy as a Stabilization Tool: An Exploration of a Quasi-Automatic VAT Stabilizer with Endogenous Pass-Through
% Author: Giuseppe Spina
% Supervisor: Prof. Tommaso Monacelli
% Bocconi University - BSc in International Economics and Finance
% September 2026

clear
close all
clc

if isempty(which('dynare'))
    error(['Dynare is not on the MATLAB path. Open MATLAB, add the Dynare ', ...
           'matlab folder to the path, and run this file again.']);
end

if ~isfile('ExogenousPT_Model.mod') || ~isfile('EndogenousPT_Model.mod') || ...
        ~isfile('EndogenousPT_Model_Flexible.mod')
    error(['ExogenousPT_Model.mod, EndogenousPT_Model.mod, EndogenousPT_Model_Flexible.mod ', ...
           'and VAT_simulation.m must be in the same MATLAB working folder.']);
end

%%%%%%
% Graph defaults
%%%%%%

graph_font = 'Helvetica Neue';
title_word_font = 'URW Classico';

set(groot,'defaultFigureColor','w')
set(groot,'defaultAxesColor','w')
set(groot,'defaultAxesXColor','k')
set(groot,'defaultAxesYColor','k')
set(groot,'defaultAxesFontName',graph_font)
set(groot,'defaultAxesFontSize',11)
set(groot,'defaultAxesFontWeight','normal')
set(groot,'defaultAxesTickLabelInterpreter','tex')
set(groot,'defaultAxesLineWidth',0.75)
set(groot,'defaultAxesBox','on')
set(groot,'defaultAxesTickDir','in')
set(groot,'defaultTextColor','k')
set(groot,'defaultTextFontName',graph_font)
set(groot,'defaultTextFontWeight','normal')
set(groot,'defaultLegendFontName',graph_font)
set(groot,'defaultLegendFontSize',12)
set(groot,'defaultLegendFontWeight','normal')

%%%%%%
% Running the three models
%%%%%%

clear global M_ oo_ options_
dynare ExogenousPT_Model noclearall nolog
dynare EndogenousPT_Model noclearall nolog
dynare EndogenousPT_Model_Flexible noclearall nolog

%%%%%%
% Setting the path to save the graphs
%%%%%%

folder = fullfile(pwd,'Figures');

if ~exist(folder,'dir')
    mkdir(folder)
end

% Scaling conventions used in the figures:
% 100*y      = percent deviation of a log variable
% 100*tau    = percentage-point VAT-rate deviation
% 400*pi     = annualized percentage-point inflation deviation
% 400*i      = annualized percentage-point nominal-rate deviation
% 100*d/Y_t  = stabilizer debt as percentage points of same-period output

%%%%%%
% Nesting check: Model 2.3 with vartheta = 0 must reproduce Model 2.2
%%%%%%

nesting_tol = 1e-8;

m23_y_nohabit   = m23_y_z(:,1:3);
m23_x_nohabit   = m23_x_z(:,1:3);
m23_pi_nohabit  = m23_pi_z(:,1:3);
m23_pic_nohabit = m23_pic_z(:,1:3);
m23_i_nohabit   = m23_i_z(:,1:3);

nesting_y   = max(abs(m22_y_z(:)   - m23_y_nohabit(:)));
nesting_x   = max(abs(m22_x_z(:)   - m23_x_nohabit(:)));
nesting_pi  = max(abs(m22_pi_z(:)  - m23_pi_nohabit(:)));
nesting_pic = max(abs(m22_pic_z(:) - m23_pic_nohabit(:)));
nesting_i   = max(abs(m22_i_z(:)   - m23_i_nohabit(:)));

nesting_error = max([nesting_y nesting_x nesting_pi nesting_pic nesting_i]);

fprintf('\nNo-deep-habit nesting check, preference shock:\n')
fprintf('  max |Model 2.2 - Model 2.3| = %.3e\n',nesting_error)

if nesting_error > nesting_tol
    warning(['The no-deep-habit Model 2.3 preference-shock IRFs do not ', ...
             'reproduce Model 2.2 within the chosen numerical tolerance. ', ...
             'Check the model files before interpreting the quantitative results.']);
end

m23_y_nohabit_a   = m23_y_a(:,1:3);
m23_x_nohabit_a   = m23_x_a(:,1:3);
m23_pi_nohabit_a  = m23_pi_a(:,1:3);
m23_pic_nohabit_a = m23_pic_a(:,1:3);
m23_i_nohabit_a   = m23_i_a(:,1:3);

nesting_y_a   = max(abs(m22_y_a(:)   - m23_y_nohabit_a(:)));
nesting_x_a   = max(abs(m22_x_a(:)   - m23_x_nohabit_a(:)));
nesting_pi_a  = max(abs(m22_pi_a(:)  - m23_pi_nohabit_a(:)));
nesting_pic_a = max(abs(m22_pic_a(:) - m23_pic_nohabit_a(:)));
nesting_i_a   = max(abs(m22_i_a(:)   - m23_i_nohabit_a(:)));

nesting_error_a = max([nesting_y_a nesting_x_a nesting_pi_a nesting_pic_a nesting_i_a]);

fprintf('No-deep-habit nesting check, productivity shock:\n')
fprintf('  max |Model 2.2 - Model 2.3| = %.3e\n',nesting_error_a)

if nesting_error_a > nesting_tol
    warning(['The no-deep-habit Model 2.3 productivity-shock IRFs do not ', ...
             'reproduce Model 2.2 within the chosen numerical tolerance. ', ...
             'Check the model files before interpreting the quantitative results.']);
end

%%%%%%
% Flexible-price diagnostic
%%%%%%
% With the same fiscal regime used to define natural output, flexible prices
% should imply an output gap numerically equal to zero up to solver tolerance.

flex_gap_z = max(abs(m23f_x_z(:)));
flex_gap_a = max(abs(m23f_x_a(:)));
fprintf('Flexible-price Model 2.3 output-gap check:\n')
fprintf('  preference shock: max |x_t| = %.3e\n',flex_gap_z)
fprintf('  productivity shock: max |x_t| = %.3e\n',flex_gap_a)

%%%%%%
% Plotting horizon for the preference shock
%%%%%%

pref_horizon = 10;

m22_y_z     = m22_y_z(1:pref_horizon,:);
m22_x_z     = m22_x_z(1:pref_horizon,:);
m22_yn_z    = m22_yn_z(1:pref_horizon,:);
m22_pi_z    = m22_pi_z(1:pref_horizon,:);
m22_pic_z   = m22_pic_z(1:pref_horizon,:);
m22_i_z     = m22_i_z(1:pref_horizon,:);
m22_varpi_z = m22_varpi_z(1:pref_horizon,:);
m22_tau_z   = m22_tau_z(1:pref_horizon,:);
m22_d_z     = m22_d_z(1:pref_horizon,:);

m23_y_z      = m23_y_z(1:pref_horizon,:);
m23_x_z      = m23_x_z(1:pref_horizon,:);
m23_yn_z     = m23_yn_z(1:pref_horizon,:);
m23_pi_z     = m23_pi_z(1:pref_horizon,:);
m23_pic_z    = m23_pic_z(1:pref_horizon,:);
m23_i_z      = m23_i_z(1:pref_horizon,:);
m23_varpi_z  = m23_varpi_z(1:pref_horizon,:);
m23_tau_z    = m23_tau_z(1:pref_horizon,:);
m23_d_z      = m23_d_z(1:pref_horizon,:);
m23_mc_z     = m23_mc_z(1:pref_horizon,:);
m23_v_z      = m23_v_z(1:pref_horizon,:);
m23_ctilde_z = m23_ctilde_z(1:pref_horizon,:);

m23f_y_z      = m23f_y_z(1:pref_horizon,:);
m23f_x_z      = m23f_x_z(1:pref_horizon,:);
m23f_yn_z     = m23f_yn_z(1:pref_horizon,:);
m23f_pi_z     = m23f_pi_z(1:pref_horizon,:);
m23f_pic_z    = m23f_pic_z(1:pref_horizon,:);
m23f_i_z      = m23f_i_z(1:pref_horizon,:);
m23f_varpi_z  = m23f_varpi_z(1:pref_horizon,:);
m23f_tau_z    = m23f_tau_z(1:pref_horizon,:);
m23f_d_z      = m23f_d_z(1:pref_horizon,:);
m23f_mc_z     = m23f_mc_z(1:pref_horizon,:);
m23f_v_z      = m23f_v_z(1:pref_horizon,:);
m23f_ctilde_z = m23f_ctilde_z(1:pref_horizon,:);

quarters = (0:pref_horizon-1)';

%%%%%%
% Figure 3.1: Preference shock, Model 2.2
%%%%%%

figure('Color','w','Position',[100 40 1000 1180]);

subplot(4,2,1)
Y = 100*m22_y_z;
plot(quarters,Y(:,1),'-b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'-r','Linewidth',1.5)
plot(quarters,Y(:,3),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Output','y_t')
format_irf_axis(gca,quarters,Y)

subplot(4,2,2)
Y = 100*m22_x_z;
plot(quarters,Y(:,1),'-b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'-r','Linewidth',1.5)
plot(quarters,Y(:,3),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Output gap','x_t')
format_irf_axis(gca,quarters,Y)

subplot(4,2,3)
Y = 100*m22_tau_z;
plot(quarters,Y(:,1),'-b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'-r','Linewidth',1.5)
plot(quarters,Y(:,3),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'VAT rate deviation','\tau_t-\bar{\tau}')
format_irf_axis(gca,quarters,Y)

subplot(4,2,4)
Y = 400*m22_pi_z;
plot(quarters,Y(:,1),'-b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'-r','Linewidth',1.5)
plot(quarters,Y(:,3),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Producer inflation','\pi_t')
format_irf_axis(gca,quarters,Y)

subplot(4,2,5)
Y = 400*m22_pic_z;
plot(quarters,Y(:,1),'-b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'-r','Linewidth',1.5)
plot(quarters,Y(:,3),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Consumer inflation','\pi_t^C')
format_irf_axis(gca,quarters,Y)

subplot(4,2,6)
Y = 400*m22_i_z;
plot(quarters,Y(:,1),'-b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'-r','Linewidth',1.5)
plot(quarters,Y(:,3),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Nominal interest rate deviation','i_t-\bar{i}')
format_irf_axis(gca,quarters,Y)

subplot(4,2,7)
% Debt-to-output ratio using output in the same period as debt. Since y_t is
% a log deviation, the output level is reconstructed as Y_t = Ybar*exp(y_t).
Y_level = m22_Cbar*exp(m22_y_z);
Y = 100*(m22_d_z./Y_level);
plot(quarters,Y(:,1),'-b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'-r','Linewidth',1.5)
plot(quarters,Y(:,3),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Debt-to-output ratio','d_t/Y_t')
format_irf_axis(gca,quarters,Y)

ax_lgd = subplot(4,2,8);
h1 = plot(nan,nan,'-b','Linewidth',1.5);
hold on
h2 = plot(nan,nan,'-r','Linewidth',1.5);
h3 = plot(nan,nan,'-g','Linewidth',1.5);
hold off
axis(ax_lgd,'off')
lgd = legend([h1 h2 h3], ...
    {'\eta_\tau = 0', '\eta_\tau = 0.840', '\eta_\tau = 1.681'}, ...
    'Interpreter','tex','Location','best','FontSize',12.5);
format_legend(lgd,graph_font)
center_legend_in_axes(lgd,ax_lgd)

drawnow
exportgraphics(gcf,fullfile(folder,'IRF_PREF_FULL_PASSTHROUGH.png'),'Resolution',500,'BackgroundColor','white','Padding','tight')

%%%%%%
% Figure 3.4: Preference shock, Model 2.3
%%%%%%
% Color identifies eta_tau:
% blue  -> eta_tau = 0
% red   -> eta_tau = 0.840
% green -> eta_tau = 1.681
%
% Line style identifies vartheta:
% dashed -> vartheta = 0
% solid  -> vartheta = 0.6

figure('Color','w','Position',[100 40 1000 1180]);

subplot(4,2,1)
Y = 100*m23_y_z;
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Output','y_t')
format_irf_axis(gca,quarters,Y)

subplot(4,2,2)
Y = 100*m23_x_z;
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Output gap','x_t')
format_irf_axis(gca,quarters,Y)

subplot(4,2,3)
Y = 100*m23_tau_z;
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'VAT rate deviation','\tau_t-\bar{\tau}')
format_irf_axis(gca,quarters,Y)

subplot(4,2,4)
Y = 400*m23_pi_z;
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Producer inflation','\pi_t')
format_irf_axis(gca,quarters,Y)

subplot(4,2,5)
Y = 400*m23_pic_z;
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Consumer inflation','\pi_t^C')
format_irf_axis(gca,quarters,Y)

subplot(4,2,6)
Y = 400*m23_i_z;
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Nominal interest rate deviation','i_t-\bar{i}')
format_irf_axis(gca,quarters,Y)

subplot(4,2,7)
% Debt-to-output ratio using output in the same period as debt. At the
% zero-inflation steady state Ybar = Cbar in Model 2.3.
Ybar_matrix = repmat(m23_Cbar,size(m23_y_z,1),1);
Y_level = Ybar_matrix.*exp(m23_y_z);
Y = 100*(m23_d_z./Y_level);
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Debt-to-output ratio','d_t/Y_t')
format_irf_axis(gca,quarters,Y)

ax_lgd = subplot(4,2,8);
h1 = plot(nan,nan,'--b','Linewidth',1.5);
hold on
h2 = plot(nan,nan,'--r','Linewidth',1.5);
h3 = plot(nan,nan,'--g','Linewidth',1.5);
h4 = plot(nan,nan,'-b','Linewidth',1.5);
h5 = plot(nan,nan,'-r','Linewidth',1.5);
h6 = plot(nan,nan,'-g','Linewidth',1.5);
hold off
axis(ax_lgd,'off')
lgd = legend([h1 h2 h3 h4 h5 h6], ...
    {'\vartheta = 0, \eta_\tau = 0', ...
     '\vartheta = 0, \eta_\tau = 0.840', ...
     '\vartheta = 0, \eta_\tau = 1.681', ...
     '\vartheta = 0.6, \eta_\tau = 0', ...
     '\vartheta = 0.6, \eta_\tau = 0.840', ...
     '\vartheta = 0.6, \eta_\tau = 1.681'}, ...
    'Interpreter','tex','Location','best','FontSize',11.5);
format_legend(lgd,graph_font)
center_legend_in_axes(lgd,ax_lgd)

drawnow
exportgraphics(gcf,fullfile(folder,'IRF_PREF_ENDOGENOUS_PASSTHROUGH.png'),'Resolution',500,'BackgroundColor','white','Padding','tight')

%%%%%%
% Figure 3.5: Preference shock, pass-through mechanism in Model 2.3
%%%%%%
% Dashed red  : vartheta = 0,   eta_tau = 0.840 versus eta_tau = 0
% Dashed green: vartheta = 0,   eta_tau = 1.681 versus eta_tau = 0
% Solid red   : vartheta = 0.6, eta_tau = 0.840 versus eta_tau = 0
% Solid green : vartheta = 0.6, eta_tau = 1.681 versus eta_tau = 0

active_idx = [2,3,5,6];
base_idx   = [1,1,4,4];

n_pt = length(active_idx);
H = size(m23_y_z,1);

pt_eq   = nan(H,n_pt);
p_diff  = nan(H,n_pt);
mu_diff = nan(H,n_pt);

for k = 1:n_pt

    S = active_idx(k);
    B = base_idx(k);

    p_diff(:,k) = cumsum(m23_pi_z(:,S)-m23_pi_z(:,B));

    wedge_diff = m23_varpi_z(:,S)-m23_varpi_z(:,B);

    pc_diff = p_diff(:,k) + wedge_diff;

    impact_scale = max(abs(wedge_diff(1)),1e-12);
    valid = abs(wedge_diff) >= 0.05*impact_scale;
    pt_eq(valid,k) = pc_diff(valid)./wedge_diff(valid);

    mu_diff(:,k) = -(m23_mc_z(:,S)-m23_mc_z(:,B));

end

q_pt = quarters;

figure('Color','w','Position',[90 160 1320 520]);

ax_pt = axes('Position',[0.055 0.40 0.265 0.48]);
Y = pt_eq;
h1 = plot(ax_pt,q_pt,Y(:,1),'--r','Linewidth',1.5);
hold(ax_pt,'on')
h2 = plot(ax_pt,q_pt,Y(:,2),'--g','Linewidth',1.5);
h3 = plot(ax_pt,q_pt,Y(:,3),'-r','Linewidth',1.5);
h4 = plot(ax_pt,q_pt,Y(:,4),'-g','Linewidth',1.5);
hold(ax_pt,'off')
set_variable_title(ax_pt,'Equilibrium pass-through','PT_t^{eq}')
format_irf_axis(ax_pt,q_pt,Y)
xlim(ax_pt,[0 2])
ylim(ax_pt,[0 1.5])
xticks(ax_pt,[0 1 2])

ax_p = axes('Position',[0.365 0.16 0.275 0.72]);
Y = 100*p_diff;
plot(ax_p,q_pt,Y(:,1),'--r','Linewidth',1.5)
hold(ax_p,'on')
plot(ax_p,q_pt,Y(:,2),'--g','Linewidth',1.5)
plot(ax_p,q_pt,Y(:,3),'-r','Linewidth',1.5)
plot(ax_p,q_pt,Y(:,4),'-g','Linewidth',1.5)
hold(ax_p,'off')
set_variable_title(ax_p,'Producer price differential','p_t^S-p_t^0')
format_irf_axis(ax_p,q_pt,Y)

ax_mu = axes('Position',[0.685 0.16 0.275 0.72]);
Y = 100*mu_diff;
plot(ax_mu,q_pt,Y(:,1),'--r','Linewidth',1.5)
hold(ax_mu,'on')
plot(ax_mu,q_pt,Y(:,2),'--g','Linewidth',1.5)
plot(ax_mu,q_pt,Y(:,3),'-r','Linewidth',1.5)
plot(ax_mu,q_pt,Y(:,4),'-g','Linewidth',1.5)
hold(ax_mu,'off')
set_variable_title(ax_mu,'Markup differential','\mu_t^S-\mu_t^0')
format_irf_axis(ax_mu,q_pt,Y)

lgd = legend(ax_pt,[h1 h2 h3 h4], ...
    {'\vartheta = 0, \eta_\tau = 0.840', ...
     '\vartheta = 0, \eta_\tau = 1.681', ...
     '\vartheta = 0.6, \eta_\tau = 0.840', ...
     '\vartheta = 0.6, \eta_\tau = 1.681'}, ...
    'Interpreter','tex','FontSize',11.5);
format_legend(lgd,graph_font)
center_legend_below_pt(lgd,ax_pt)

drawnow
exportgraphics(gcf,fullfile(folder,'IRF_PREF_PASSTHROUGH_MECHANISM.png'),'Resolution',500,'BackgroundColor','white','Padding','tight')

%%%%%%
% Figure 3.2: Preference shock, rigid versus flexible prices in Model 2.3
%%%%%%
% All six lines use vartheta = 0.6. Color identifies eta_tau and line style
% identifies the price-setting regime:
% dashed -> flexible prices
% solid  -> rigid prices (benchmark Rotemberg calibration)

figure('Color','w','Position',[100 40 1000 1180]);

subplot(4,2,1)
Y = 100*[m23f_y_z, m23_y_z(:,4:6)];
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Output','y_t')
format_irf_axis(gca,quarters,Y)

subplot(4,2,2)
Y = 100*[m23f_x_z, m23_x_z(:,4:6)];
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Output gap','x_t')
format_irf_axis(gca,quarters,Y)

subplot(4,2,3)
Y = 100*[m23f_tau_z, m23_tau_z(:,4:6)];
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'VAT rate deviation','\tau_t-\bar{\tau}')
format_irf_axis(gca,quarters,Y)

subplot(4,2,4)
Y = 400*[m23f_pi_z, m23_pi_z(:,4:6)];
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Producer inflation','\pi_t')
format_irf_axis(gca,quarters,Y)

subplot(4,2,5)
Y = 400*[m23f_pic_z, m23_pic_z(:,4:6)];
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Consumer inflation','\pi_t^C')
format_irf_axis(gca,quarters,Y)

subplot(4,2,6)
Y = 400*[m23f_i_z, m23_i_z(:,4:6)];
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Nominal interest rate deviation','i_t-\bar{i}')
format_irf_axis(gca,quarters,Y)

subplot(4,2,7)
Ybar_flex = repmat(m23f_Cbar,size(m23f_y_z,1),1);
Ylevel_flex = Ybar_flex.*exp(m23f_y_z);
Ybar_rigid = repmat(m23_Cbar(4:6),size(m23_y_z,1),1);
Ylevel_rigid = Ybar_rigid.*exp(m23_y_z(:,4:6));
Y = 100*[(m23f_d_z./Ylevel_flex), (m23_d_z(:,4:6)./Ylevel_rigid)];
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Debt-to-output ratio','d_t/Y_t')
format_irf_axis(gca,quarters,Y)

ax_lgd = subplot(4,2,8);
h1 = plot(nan,nan,'--b','Linewidth',1.5);
hold on
h2 = plot(nan,nan,'--r','Linewidth',1.5);
h3 = plot(nan,nan,'--g','Linewidth',1.5);
h4 = plot(nan,nan,'-b','Linewidth',1.5);
h5 = plot(nan,nan,'-r','Linewidth',1.5);
h6 = plot(nan,nan,'-g','Linewidth',1.5);
hold off
axis(ax_lgd,'off')
lgd = legend([h1 h2 h3 h4 h5 h6], ...
    {'Flexible prices, \eta_\tau = 0', ...
     'Flexible prices, \eta_\tau = 0.840', ...
     'Flexible prices, \eta_\tau = 1.681', ...
     'Rigid prices, \eta_\tau = 0', ...
     'Rigid prices, \eta_\tau = 0.840', ...
     'Rigid prices, \eta_\tau = 1.681'}, ...
    'Interpreter','tex','Location','best','FontSize',11.5);
format_legend(lgd,graph_font)
center_legend_in_axes(lgd,ax_lgd)

drawnow
exportgraphics(gcf,fullfile(folder,'IRF_PREF_RIGID_VS_FLEXIBLE.png'),'Resolution',500,'BackgroundColor','white','Padding','tight')

%%%%%%
% Figure 3.3: Preference shock, pass-through under rigid versus flexible prices
%%%%%%

H = size(m23f_y_z,1);
pt_rf_z   = nan(H,4);
p_rf_z    = nan(H,4);
mu_rf_z   = nan(H,4);

for k = 1:2
    S = k+1;
    B = 1;
    p_rf_z(:,k) = cumsum(m23f_pi_z(:,S)-m23f_pi_z(:,B));
    wedge_diff = m23f_varpi_z(:,S)-m23f_varpi_z(:,B);
    pc_diff = p_rf_z(:,k) + wedge_diff;
    impact_scale = max(abs(wedge_diff(1)),1e-12);
    valid = abs(wedge_diff) >= 0.05*impact_scale;
    pt_rf_z(valid,k) = pc_diff(valid)./wedge_diff(valid);
    mu_rf_z(:,k) = -(m23f_mc_z(:,S)-m23f_mc_z(:,B));
end

for k = 1:2
    S = 4+k;
    B = 4;
    j = k+2;
    p_rf_z(:,j) = cumsum(m23_pi_z(:,S)-m23_pi_z(:,B));
    wedge_diff = m23_varpi_z(:,S)-m23_varpi_z(:,B);
    pc_diff = p_rf_z(:,j) + wedge_diff;
    impact_scale = max(abs(wedge_diff(1)),1e-12);
    valid = abs(wedge_diff) >= 0.05*impact_scale;
    pt_rf_z(valid,j) = pc_diff(valid)./wedge_diff(valid);
    mu_rf_z(:,j) = -(m23_mc_z(:,S)-m23_mc_z(:,B));
end

q_pt = quarters;
figure('Color','w','Position',[90 160 1320 520]);

ax_pt = axes('Position',[0.055 0.40 0.265 0.48]);
Y = pt_rf_z;
h1 = plot(ax_pt,q_pt,Y(:,1),'--r','Linewidth',1.5);
hold(ax_pt,'on')
h2 = plot(ax_pt,q_pt,Y(:,2),'--g','Linewidth',1.5);
h3 = plot(ax_pt,q_pt,Y(:,3),'-r','Linewidth',1.5);
h4 = plot(ax_pt,q_pt,Y(:,4),'-g','Linewidth',1.5);
hold(ax_pt,'off')
set_variable_title(ax_pt,'Equilibrium pass-through','PT_t^{eq}')
format_irf_axis(ax_pt,q_pt,Y)
xlim(ax_pt,[0 2])
ylim(ax_pt,[0 1.5])
xticks(ax_pt,[0 1 2])

ax_p = axes('Position',[0.365 0.16 0.275 0.72]);
Y = 100*p_rf_z;
plot(ax_p,q_pt,Y(:,1),'--r','Linewidth',1.5)
hold(ax_p,'on')
plot(ax_p,q_pt,Y(:,2),'--g','Linewidth',1.5)
plot(ax_p,q_pt,Y(:,3),'-r','Linewidth',1.5)
plot(ax_p,q_pt,Y(:,4),'-g','Linewidth',1.5)
hold(ax_p,'off')
set_variable_title(ax_p,'Producer price differential','p_t^S-p_t^0')
format_irf_axis(ax_p,q_pt,Y)

ax_mu = axes('Position',[0.685 0.16 0.275 0.72]);
Y = 100*mu_rf_z;
plot(ax_mu,q_pt,Y(:,1),'--r','Linewidth',1.5)
hold(ax_mu,'on')
plot(ax_mu,q_pt,Y(:,2),'--g','Linewidth',1.5)
plot(ax_mu,q_pt,Y(:,3),'-r','Linewidth',1.5)
plot(ax_mu,q_pt,Y(:,4),'-g','Linewidth',1.5)
hold(ax_mu,'off')
set_variable_title(ax_mu,'Markup differential','\mu_t^S-\mu_t^0')
format_irf_axis(ax_mu,q_pt,Y)

lgd = legend(ax_pt,[h1 h2 h3 h4], ...
    {'Flexible prices, \eta_\tau = 0.840', ...
     'Flexible prices, \eta_\tau = 1.681', ...
     'Rigid prices, \eta_\tau = 0.840', ...
     'Rigid prices, \eta_\tau = 1.681'}, ...
    'Interpreter','tex','FontSize',11.5);
format_legend(lgd,graph_font)
center_legend_below_pt(lgd,ax_pt)

drawnow
exportgraphics(gcf,fullfile(folder,'IRF_PREF_RIGID_VS_FLEXIBLE_PASSTHROUGH.png'),'Resolution',500,'BackgroundColor','white','Padding','tight')

% Plotting horizon for the productivity shock
quarters = (0:size(m22_y_a,1)-1)';

%%%%%%
% Figure 3.6: Productivity shock, Model 2.2
%%%%%%

figure('Color','w','Position',[100 40 1000 1180]);

subplot(4,2,1)
Y = 100*m22_y_a;
plot(quarters,Y(:,1),'-b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'-r','Linewidth',1.5)
plot(quarters,Y(:,3),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Output','y_t')
format_irf_axis(gca,quarters,Y)
xlim(gca,[0 40])

subplot(4,2,2)
Y = 100*m22_x_a;
plot(quarters,Y(:,1),'-b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'-r','Linewidth',1.5)
plot(quarters,Y(:,3),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Output gap','x_t')
format_irf_axis(gca,quarters,Y)
xlim(gca,[0 40])

subplot(4,2,3)
Y = 100*m22_tau_a;
plot(quarters,Y(:,1),'-b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'-r','Linewidth',1.5)
plot(quarters,Y(:,3),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'VAT rate deviation','\tau_t-\bar{\tau}')
format_irf_axis(gca,quarters,Y)
xlim(gca,[0 40])

subplot(4,2,4)
Y = 400*m22_pi_a;
plot(quarters,Y(:,1),'-b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'-r','Linewidth',1.5)
plot(quarters,Y(:,3),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Producer inflation','\pi_t')
format_irf_axis(gca,quarters,Y)
xlim(gca,[0 40])

subplot(4,2,5)
Y = 400*m22_pic_a;
plot(quarters,Y(:,1),'-b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'-r','Linewidth',1.5)
plot(quarters,Y(:,3),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Consumer inflation','\pi_t^C')
format_irf_axis(gca,quarters,Y)
xlim(gca,[0 40])

subplot(4,2,6)
Y = 400*m22_i_a;
plot(quarters,Y(:,1),'-b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'-r','Linewidth',1.5)
plot(quarters,Y(:,3),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Nominal interest rate deviation','i_t-\bar{i}')
format_irf_axis(gca,quarters,Y)
xlim(gca,[0 40])

subplot(4,2,7)
Y_level = m22_Cbar*exp(m22_y_a);
Y = 100*(m22_d_a./Y_level);
plot(quarters,Y(:,1),'-b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'-r','Linewidth',1.5)
plot(quarters,Y(:,3),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Debt-to-output ratio','d_t/Y_t')
format_irf_axis(gca,quarters,Y)
xlim(gca,[0 40])

ax_lgd = subplot(4,2,8);
h1 = plot(nan,nan,'-b','Linewidth',1.5);
hold on
h2 = plot(nan,nan,'-r','Linewidth',1.5);
h3 = plot(nan,nan,'-g','Linewidth',1.5);
hold off
axis(ax_lgd,'off')
lgd = legend([h1 h2 h3], ...
    {'\eta_\tau = 0', '\eta_\tau = 0.840', '\eta_\tau = 1.681'}, ...
    'Interpreter','tex','Location','best','FontSize',12.5);
format_legend(lgd,graph_font)
center_legend_in_axes(lgd,ax_lgd)

drawnow
exportgraphics(gcf,fullfile(folder,'IRF_PROD_FULL_PASSTHROUGH.png'),'Resolution',500,'BackgroundColor','white','Padding','tight')

%%%%%%
% Figure 3.9: Productivity shock, corrected Model 2.3
%%%%%%

figure('Color','w','Position',[100 40 1000 1180]);

subplot(4,2,1)
Y = 100*m23_y_a;
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Output','y_t')
format_irf_axis(gca,quarters,Y)
xlim(gca,[0 40])

subplot(4,2,2)
Y = 100*m23_x_a;
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Output gap','x_t')
format_irf_axis(gca,quarters,Y)
xlim(gca,[0 40])

subplot(4,2,3)
Y = 100*m23_tau_a;
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'VAT rate deviation','\tau_t-\bar{\tau}')
format_irf_axis(gca,quarters,Y)
xlim(gca,[0 40])

subplot(4,2,4)
Y = 400*m23_pi_a;
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Producer inflation','\pi_t')
format_irf_axis(gca,quarters,Y)
xlim(gca,[0 40])

subplot(4,2,5)
Y = 400*m23_pic_a;
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Consumer inflation','\pi_t^C')
format_irf_axis(gca,quarters,Y)
xlim(gca,[0 40])

subplot(4,2,6)
Y = 400*m23_i_a;
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Nominal interest rate deviation','i_t-\bar{i}')
format_irf_axis(gca,quarters,Y)
xlim(gca,[0 40])

subplot(4,2,7)
Ybar_matrix = repmat(m23_Cbar,size(m23_y_a,1),1);
Y_level = Ybar_matrix.*exp(m23_y_a);
Y = 100*(m23_d_a./Y_level);
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Debt-to-output ratio','d_t/Y_t')
format_irf_axis(gca,quarters,Y)
xlim(gca,[0 40])

ax_lgd = subplot(4,2,8);
h1 = plot(nan,nan,'--b','Linewidth',1.5);
hold on
h2 = plot(nan,nan,'--r','Linewidth',1.5);
h3 = plot(nan,nan,'--g','Linewidth',1.5);
h4 = plot(nan,nan,'-b','Linewidth',1.5);
h5 = plot(nan,nan,'-r','Linewidth',1.5);
h6 = plot(nan,nan,'-g','Linewidth',1.5);
hold off
axis(ax_lgd,'off')
lgd = legend([h1 h2 h3 h4 h5 h6], ...
    {'\vartheta = 0, \eta_\tau = 0', ...
     '\vartheta = 0, \eta_\tau = 0.840', ...
     '\vartheta = 0, \eta_\tau = 1.681', ...
     '\vartheta = 0.6, \eta_\tau = 0', ...
     '\vartheta = 0.6, \eta_\tau = 0.840', ...
     '\vartheta = 0.6, \eta_\tau = 1.681'}, ...
    'Interpreter','tex','Location','best','FontSize',11.5);
format_legend(lgd,graph_font)
center_legend_in_axes(lgd,ax_lgd)

drawnow
exportgraphics(gcf,fullfile(folder,'IRF_PROD_ENDOGENOUS_PASSTHROUGH.png'),'Resolution',500,'BackgroundColor','white','Padding','tight')

%%%%%%
% Figure 3.11: Productivity shock, pass-through mechanism in Model 2.3
%%%%%%

active_idx = [2,3,5,6];
base_idx   = [1,1,4,4];

n_pt = length(active_idx);
H = size(m23_y_a,1);

pt_eq_a   = nan(H,n_pt);
p_diff_a  = nan(H,n_pt);
mu_diff_a = nan(H,n_pt);

for k = 1:n_pt

    S = active_idx(k);
    B = base_idx(k);

    p_diff_a(:,k) = cumsum(m23_pi_a(:,S)-m23_pi_a(:,B));
    wedge_diff = m23_varpi_a(:,S)-m23_varpi_a(:,B);
    pc_diff = p_diff_a(:,k) + wedge_diff;

    impact_scale = max(abs(wedge_diff(1)),1e-12);
    valid = abs(wedge_diff) >= 0.05*impact_scale;
    pt_eq_a(valid,k) = pc_diff(valid)./wedge_diff(valid);

    mu_diff_a(:,k) = -(m23_mc_a(:,S)-m23_mc_a(:,B));

end

q_pt = quarters;

figure('Color','w','Position',[90 160 1320 520]);

ax_pt = axes('Position',[0.055 0.40 0.265 0.48]);
Y = pt_eq_a;
h1 = plot(ax_pt,q_pt,Y(:,1),'--r','Linewidth',1.5);
hold(ax_pt,'on')
h2 = plot(ax_pt,q_pt,Y(:,2),'--g','Linewidth',1.5);
h3 = plot(ax_pt,q_pt,Y(:,3),'-r','Linewidth',1.5);
h4 = plot(ax_pt,q_pt,Y(:,4),'-g','Linewidth',1.5);
hold(ax_pt,'off')
set_variable_title(ax_pt,'Equilibrium pass-through','PT_t^{eq}')
format_irf_axis(ax_pt,q_pt,Y)
xlim(ax_pt,[0 6])
ylim(ax_pt,[0 1.5])
xticks(ax_pt,[0 2 4 6])

ax_p = axes('Position',[0.365 0.16 0.275 0.72]);
Y = 100*p_diff_a;
plot(ax_p,q_pt,Y(:,1),'--r','Linewidth',1.5)
hold(ax_p,'on')
plot(ax_p,q_pt,Y(:,2),'--g','Linewidth',1.5)
plot(ax_p,q_pt,Y(:,3),'-r','Linewidth',1.5)
plot(ax_p,q_pt,Y(:,4),'-g','Linewidth',1.5)
hold(ax_p,'off')
set_variable_title(ax_p,'Producer price differential','p_t^S-p_t^0')
format_irf_axis(ax_p,q_pt,Y)
xlim(ax_p,[0 40])

ax_mu = axes('Position',[0.685 0.16 0.275 0.72]);
Y = 100*mu_diff_a;
plot(ax_mu,q_pt,Y(:,1),'--r','Linewidth',1.5)
hold(ax_mu,'on')
plot(ax_mu,q_pt,Y(:,2),'--g','Linewidth',1.5)
plot(ax_mu,q_pt,Y(:,3),'-r','Linewidth',1.5)
plot(ax_mu,q_pt,Y(:,4),'-g','Linewidth',1.5)
hold(ax_mu,'off')
set_variable_title(ax_mu,'Markup differential','\mu_t^S-\mu_t^0')
format_irf_axis(ax_mu,q_pt,Y)
xlim(ax_mu,[0 40])

lgd = legend(ax_pt,[h1 h2 h3 h4], ...
    {'\vartheta = 0, \eta_\tau = 0.840', ...
     '\vartheta = 0, \eta_\tau = 1.681', ...
     '\vartheta = 0.6, \eta_\tau = 0.840', ...
     '\vartheta = 0.6, \eta_\tau = 1.681'}, ...
    'Interpreter','tex','FontSize',11.5);
format_legend(lgd,graph_font)
center_legend_below_pt(lgd,ax_pt)

drawnow
exportgraphics(gcf,fullfile(folder,'IRF_PROD_PASSTHROUGH_MECHANISM.png'),'Resolution',500,'BackgroundColor','white','Padding','tight')

%%%%%%
% Figure 3.7: Productivity shock, rigid versus flexible prices in Model 2.3
%%%%%%

figure('Color','w','Position',[100 40 1000 1180]);

subplot(4,2,1)
Y = 100*[m23f_y_a, m23_y_a(:,4:6)];
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Output','y_t')
format_irf_axis(gca,quarters,Y)
xlim(gca,[0 40])

subplot(4,2,2)
Y = 100*[m23f_x_a, m23_x_a(:,4:6)];
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Output gap','x_t')
format_irf_axis(gca,quarters,Y)
xlim(gca,[0 40])

subplot(4,2,3)
Y = 100*[m23f_tau_a, m23_tau_a(:,4:6)];
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'VAT rate deviation','\tau_t-\bar{\tau}')
format_irf_axis(gca,quarters,Y)
xlim(gca,[0 40])

subplot(4,2,4)
Y = 400*[m23f_pi_a, m23_pi_a(:,4:6)];
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Producer inflation','\pi_t')
format_irf_axis(gca,quarters,Y)
xlim(gca,[0 40])

subplot(4,2,5)
Y = 400*[m23f_pic_a, m23_pic_a(:,4:6)];
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Consumer inflation','\pi_t^C')
format_irf_axis(gca,quarters,Y)
xlim(gca,[0 40])

subplot(4,2,6)
Y = 400*[m23f_i_a, m23_i_a(:,4:6)];
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Nominal interest rate deviation','i_t-\bar{i}')
format_irf_axis(gca,quarters,Y)
xlim(gca,[0 40])

subplot(4,2,7)
Ybar_flex = repmat(m23f_Cbar,size(m23f_y_a,1),1);
Ylevel_flex = Ybar_flex.*exp(m23f_y_a);
Ybar_rigid = repmat(m23_Cbar(4:6),size(m23_y_a,1),1);
Ylevel_rigid = Ybar_rigid.*exp(m23_y_a(:,4:6));
Y = 100*[(m23f_d_a./Ylevel_flex), (m23_d_a(:,4:6)./Ylevel_rigid)];
plot(quarters,Y(:,1),'--b','Linewidth',1.5)
hold on
plot(quarters,Y(:,2),'--r','Linewidth',1.5)
plot(quarters,Y(:,3),'--g','Linewidth',1.5)
plot(quarters,Y(:,4),'-b','Linewidth',1.5)
plot(quarters,Y(:,5),'-r','Linewidth',1.5)
plot(quarters,Y(:,6),'-g','Linewidth',1.5)
hold off
set_variable_title(gca,'Debt-to-output ratio','d_t/Y_t')
format_irf_axis(gca,quarters,Y)
xlim(gca,[0 40])

ax_lgd = subplot(4,2,8);
h1 = plot(nan,nan,'--b','Linewidth',1.5);
hold on
h2 = plot(nan,nan,'--r','Linewidth',1.5);
h3 = plot(nan,nan,'--g','Linewidth',1.5);
h4 = plot(nan,nan,'-b','Linewidth',1.5);
h5 = plot(nan,nan,'-r','Linewidth',1.5);
h6 = plot(nan,nan,'-g','Linewidth',1.5);
hold off
axis(ax_lgd,'off')
lgd = legend([h1 h2 h3 h4 h5 h6], ...
    {'Flexible prices, \eta_\tau = 0', ...
     'Flexible prices, \eta_\tau = 0.840', ...
     'Flexible prices, \eta_\tau = 1.681', ...
     'Rigid prices, \eta_\tau = 0', ...
     'Rigid prices, \eta_\tau = 0.840', ...
     'Rigid prices, \eta_\tau = 1.681'}, ...
    'Interpreter','tex','Location','best','FontSize',11.5);
format_legend(lgd,graph_font)
center_legend_in_axes(lgd,ax_lgd)

drawnow
exportgraphics(gcf,fullfile(folder,'IRF_PROD_RIGID_VS_FLEXIBLE.png'),'Resolution',500,'BackgroundColor','white','Padding','tight')

%%%%%%
% Figure 3.8: Productivity shock, pass-through under rigid versus flexible prices
%%%%%%

H = size(m23f_y_a,1);
pt_rf_a   = nan(H,4);
p_rf_a    = nan(H,4);
mu_rf_a   = nan(H,4);

for k = 1:2
    S = k+1;
    B = 1;
    p_rf_a(:,k) = cumsum(m23f_pi_a(:,S)-m23f_pi_a(:,B));
    wedge_diff = m23f_varpi_a(:,S)-m23f_varpi_a(:,B);
    pc_diff = p_rf_a(:,k) + wedge_diff;
    impact_scale = max(abs(wedge_diff(1)),1e-12);
    valid = abs(wedge_diff) >= 0.05*impact_scale;
    pt_rf_a(valid,k) = pc_diff(valid)./wedge_diff(valid);
    mu_rf_a(:,k) = -(m23f_mc_a(:,S)-m23f_mc_a(:,B));
end

for k = 1:2
    S = 4+k;
    B = 4;
    j = k+2;
    p_rf_a(:,j) = cumsum(m23_pi_a(:,S)-m23_pi_a(:,B));
    wedge_diff = m23_varpi_a(:,S)-m23_varpi_a(:,B);
    pc_diff = p_rf_a(:,j) + wedge_diff;
    impact_scale = max(abs(wedge_diff(1)),1e-12);
    valid = abs(wedge_diff) >= 0.05*impact_scale;
    pt_rf_a(valid,j) = pc_diff(valid)./wedge_diff(valid);
    mu_rf_a(:,j) = -(m23_mc_a(:,S)-m23_mc_a(:,B));
end

q_pt = quarters;
figure('Color','w','Position',[90 160 1320 520]);

ax_pt = axes('Position',[0.055 0.40 0.265 0.48]);
Y = pt_rf_a;
h1 = plot(ax_pt,q_pt,Y(:,1),'--r','Linewidth',1.5);
hold(ax_pt,'on')
h2 = plot(ax_pt,q_pt,Y(:,2),'--g','Linewidth',1.5);
h3 = plot(ax_pt,q_pt,Y(:,3),'-r','Linewidth',1.5);
h4 = plot(ax_pt,q_pt,Y(:,4),'-g','Linewidth',1.5);
hold(ax_pt,'off')
set_variable_title(ax_pt,'Equilibrium pass-through','PT_t^{eq}')
format_irf_axis(ax_pt,q_pt,Y)
xlim(ax_pt,[0 6])
ylim(ax_pt,[0 1.5])
xticks(ax_pt,[0 2 4 6])

ax_p = axes('Position',[0.365 0.16 0.275 0.72]);
Y = 100*p_rf_a;
plot(ax_p,q_pt,Y(:,1),'--r','Linewidth',1.5)
hold(ax_p,'on')
plot(ax_p,q_pt,Y(:,2),'--g','Linewidth',1.5)
plot(ax_p,q_pt,Y(:,3),'-r','Linewidth',1.5)
plot(ax_p,q_pt,Y(:,4),'-g','Linewidth',1.5)
hold(ax_p,'off')
set_variable_title(ax_p,'Producer price differential','p_t^S-p_t^0')
format_irf_axis(ax_p,q_pt,Y)
xlim(ax_p,[0 40])

ax_mu = axes('Position',[0.685 0.16 0.275 0.72]);
Y = 100*mu_rf_a;
plot(ax_mu,q_pt,Y(:,1),'--r','Linewidth',1.5)
hold(ax_mu,'on')
plot(ax_mu,q_pt,Y(:,2),'--g','Linewidth',1.5)
plot(ax_mu,q_pt,Y(:,3),'-r','Linewidth',1.5)
plot(ax_mu,q_pt,Y(:,4),'-g','Linewidth',1.5)
hold(ax_mu,'off')
set_variable_title(ax_mu,'Markup differential','\mu_t^S-\mu_t^0')
format_irf_axis(ax_mu,q_pt,Y)
xlim(ax_mu,[0 40])

lgd = legend(ax_pt,[h1 h2 h3 h4], ...
    {'Flexible prices, \eta_\tau = 0.840', ...
     'Flexible prices, \eta_\tau = 1.681', ...
     'Rigid prices, \eta_\tau = 0.840', ...
     'Rigid prices, \eta_\tau = 1.681'}, ...
    'Interpreter','tex','FontSize',11.5);
format_legend(lgd,graph_font)
center_legend_below_pt(lgd,ax_pt)

drawnow
exportgraphics(gcf,fullfile(folder,'IRF_PROD_RIGID_VS_FLEXIBLE_PASSTHROUGH.png'),'Resolution',500,'BackgroundColor','white','Padding','tight')

%%%%%%
% Figure 3.10: Productivity shock, comparison of output-gap definitions
%%%%%%
% Both panels show Model 2.3 under rigid prices.
% Dashed lines: no deep habits, vartheta = 0.
% Solid lines:  deep habits, vartheta = 0.6.
% Colors identify the VAT-rule coefficient eta_tau.
% Left panel: policy-consistent natural-output gap used in Model 2.3,
%             x_t = y_t^R(eta_tau,vartheta) - y_t^F(eta_tau,vartheta).
% Right panel: Blanchard-style diagnostic gap. For each value of vartheta,
%              natural output responds to the productivity shock but the
%              cyclical VAT stabilizer is excluded from the benchmark:
%              x_t^B = y_t^R(eta_tau,vartheta) - y_t^F(eta_tau=0,vartheta).

x_policy_consistent_a = m23_x_a(:,1:6);

yn_blanchard_nohabit_a = m23_y_a(:,1) - m23_x_a(:,1);
yn_blanchard_habit_a   = m23_y_a(:,4) - m23_x_a(:,4);

x_blanchard_a = zeros(size(m23_y_a(:,1:6)));
x_blanchard_a(:,1:3) = m23_y_a(:,1:3) - repmat(yn_blanchard_nohabit_a,1,3);
x_blanchard_a(:,4:6) = m23_y_a(:,4:6) - repmat(yn_blanchard_habit_a,1,3);

gap_definition_tol = 1e-8;
gap_definition_error_nohabit = max(abs(x_policy_consistent_a(:,1)-x_blanchard_a(:,1)));
gap_definition_error_habit   = max(abs(x_policy_consistent_a(:,4)-x_blanchard_a(:,4)));

fprintf('\nOutput-gap definition checks, productivity shock:\n')
fprintf('  vartheta=0:   max |policy-consistent - Blanchard| at eta_tau=0 = %.3e\n',gap_definition_error_nohabit)
fprintf('  vartheta=0.6: max |policy-consistent - Blanchard| at eta_tau=0 = %.3e\n',gap_definition_error_habit)

if gap_definition_error_nohabit > gap_definition_tol || gap_definition_error_habit > gap_definition_tol
    warning(['The two output-gap definitions do not coincide at eta_tau=0. ', ...
             'Check the flexible-price benchmark before interpreting Figure 11.']);
end

figure('Color','w','Position',[120 160 1120 520]);

ax_gap_pc = axes('Position',[0.075 0.16 0.39 0.72]);
Y = 100*x_policy_consistent_a;
h1 = plot(ax_gap_pc,quarters,Y(:,1),'--b','Linewidth',1.5);
hold(ax_gap_pc,'on')
h2 = plot(ax_gap_pc,quarters,Y(:,2),'--r','Linewidth',1.5);
h3 = plot(ax_gap_pc,quarters,Y(:,3),'--g','Linewidth',1.5);
h4 = plot(ax_gap_pc,quarters,Y(:,4),'-b','Linewidth',1.5);
h5 = plot(ax_gap_pc,quarters,Y(:,5),'-r','Linewidth',1.5);
h6 = plot(ax_gap_pc,quarters,Y(:,6),'-g','Linewidth',1.5);
hold(ax_gap_pc,'off')
set_variable_title(ax_gap_pc,'Policy-consistent output gap','')
format_irf_axis(ax_gap_pc,quarters,Y)
xlim(ax_gap_pc,[0 40])

ax_gap_b = axes('Position',[0.535 0.16 0.39 0.72]);
Y = 100*x_blanchard_a;
g1 = plot(ax_gap_b,quarters,Y(:,1),'--b','Linewidth',1.5);
hold(ax_gap_b,'on')
g2 = plot(ax_gap_b,quarters,Y(:,2),'--r','Linewidth',1.5);
g3 = plot(ax_gap_b,quarters,Y(:,3),'--g','Linewidth',1.5);
g4 = plot(ax_gap_b,quarters,Y(:,4),'-b','Linewidth',1.5);
g5 = plot(ax_gap_b,quarters,Y(:,5),'-r','Linewidth',1.5);
g6 = plot(ax_gap_b,quarters,Y(:,6),'-g','Linewidth',1.5);
hold(ax_gap_b,'off')
set_variable_title(ax_gap_b,'Blanchard-style output gap','')
format_irf_axis(ax_gap_b,quarters,Y)
xlim(ax_gap_b,[0 40])

lgd = legend(ax_gap_b,[g1 g2 g3 g4 g5 g6], ...
    {'\vartheta = 0, \eta_\tau = 0', ...
     '\vartheta = 0, \eta_\tau = 0.840', ...
     '\vartheta = 0, \eta_\tau = 1.681', ...
     '\vartheta = 0.6, \eta_\tau = 0', ...
     '\vartheta = 0.6, \eta_\tau = 0.840', ...
     '\vartheta = 0.6, \eta_\tau = 1.681'}, ...
    'Interpreter','tex','FontSize',11.5);
format_legend(lgd,graph_font)
drawnow
set(lgd,'Units','normalized')
lgd_pos = get(lgd,'Position');
lgd_pos(1) = 0.690;
lgd_pos(2) = 0.535;
set(lgd,'Position',lgd_pos)

drawnow
exportgraphics(gcf,fullfile(folder,'IRF_PROD_OUTPUT_GAP_DEFINITIONS.png'),'Resolution',500,'BackgroundColor','white','Padding','tight')

%%%%%%
% Figure A.1: Model 2.3 first-order solution region
%%%%%%
% Green: Dynare finds a valid first-order stochastic solution.
% Red:   no valid first-order solution on the scanned parameter grid.
%
% Vertical dashed lines identify eta_tau = 0.840 and 1.681.
% The horizontal dashed line identifies the benchmark vartheta = 0.6.

figure('Color','w','Position',[120 100 950 650]);

imagesc(m23_map_eta,m23_map_vartheta,m23_solution_map)
axis xy
hold on
xline(1/1.19,'--k','LineWidth',1.5)
xline(2/1.19,'--k','LineWidth',1.5)
yline(0.6,'--k','LineWidth',1.5)
hold off

xlabel('Strength of the VAT rule (\eta_\tau)','Interpreter','tex','FontName',title_word_font,'FontSize',13,'FontWeight','normal','Color','k')
ylabel('Deep habits parameter (\vartheta)','Interpreter','tex','FontName',title_word_font,'FontSize',13,'FontWeight','normal','Color','k')

xlim([m23_map_eta(1) m23_map_eta(end)])
ylim([0 0.99])

set(gca,'FontName',graph_font,'FontSize',11,'FontWeight','normal', ...
        'XColor','k','YColor','k','Color','w','Box','on','TickDir','in','TickLabelInterpreter','tex')

colormap([1 0 0; 0 1 0])
clim([0 1])

drawnow
exportgraphics(gcf,fullfile(folder,'MODEL23_SOLUTION_REGION.png'),'Resolution',500,'BackgroundColor','white','Padding','tight')

%%%%%%
% Ex-post validity checks for the preference-shock simulations
%%%%%%

barvarpi = log(1+0.19);

% Exact VAT-rate reconstruction from the simulated log VAT wedge.
min_tau_22  = min(exp(barvarpi + m22_varpi_z(:))-1);
min_tau_23  = min(exp(barvarpi + m23_varpi_z(:))-1);
min_tau_23f = min(exp(barvarpi + m23f_varpi_z(:))-1);

fprintf('\nMinimum VAT rate after the preference shock:\n')
fprintf('  Model 2.2: %.6f\n',min_tau_22)
fprintf('  Model 2.3 rigid: %.6f\n',min_tau_23)
fprintf('  Model 2.3 flexible: %.6f\n',min_tau_23f)

if min_tau_22 < 0 || min_tau_23 < 0 || min_tau_23f < 0
    warning('The VAT rate becomes negative in at least one preference-shock IRF.')
end

% Check C_t - vartheta*C_{t-1} > 0 in Model 2.3.
min_habit_surplus = inf;

for j = 1:size(m23_y_z,2)
    C_path = m23_Cbar(j)*exp(m23_y_z(:,j));
    C_lag = [m23_Cbar(j); C_path(1:end-1)];
    habit_surplus = C_path - m23_vartheta_grid(j)*C_lag;
    min_habit_surplus = min(min_habit_surplus,min(habit_surplus));
end

fprintf('Minimum C_t - vartheta*C_{t-1}: %.6f\n',min_habit_surplus)

if min_habit_surplus <= 0
    warning('Habit-adjusted consumption becomes non-positive after the preference shock in Model 2.3.')
end

min_habit_surplus_flex = inf;
for j = 1:size(m23f_y_z,2)
    C_path = m23f_Cbar(j)*exp(m23f_y_z(:,j));
    C_lag = [m23f_Cbar(j); C_path(1:end-1)];
    habit_surplus = C_path - m23f_vartheta*C_lag;
    min_habit_surplus_flex = min(min_habit_surplus_flex,min(habit_surplus));
end
fprintf('Minimum C_t - vartheta*C_{t-1}, flexible prices: %.6f\n', ...
        min_habit_surplus_flex)
if min_habit_surplus_flex <= 0
    warning('Habit-adjusted consumption becomes non-positive after the preference shock in the flexible-price benchmark.')
end

min_tau_22_a  = min(exp(barvarpi + m22_varpi_a(:))-1);
min_tau_23_a  = min(exp(barvarpi + m23_varpi_a(:))-1);
min_tau_23f_a = min(exp(barvarpi + m23f_varpi_a(:))-1);

fprintf('\nMinimum VAT rate after the productivity shock:\n')
fprintf('  Model 2.2: %.6f\n',min_tau_22_a)
fprintf('  Model 2.3 rigid: %.6f\n',min_tau_23_a)
fprintf('  Model 2.3 flexible: %.6f\n',min_tau_23f_a)

if min_tau_22_a < 0 || min_tau_23_a < 0 || min_tau_23f_a < 0
    warning('The VAT rate becomes negative in at least one productivity-shock IRF.')
end

min_habit_surplus_a = inf;

for j = 1:size(m23_y_a,2)
    C_path = m23_Cbar(j)*exp(m23_y_a(:,j));
    C_lag = [m23_Cbar(j); C_path(1:end-1)];
    habit_surplus = C_path - m23_vartheta_grid(j)*C_lag;
    min_habit_surplus_a = min(min_habit_surplus_a,min(habit_surplus));
end

fprintf('Minimum C_t - vartheta*C_{t-1} after productivity shock: %.6f\n', ...
        min_habit_surplus_a)

if min_habit_surplus_a <= 0
    warning('Habit-adjusted consumption becomes non-positive after the productivity shock in Model 2.3.')
end

min_habit_surplus_flex_a = inf;
for j = 1:size(m23f_y_a,2)
    C_path = m23f_Cbar(j)*exp(m23f_y_a(:,j));
    C_lag = [m23f_Cbar(j); C_path(1:end-1)];
    habit_surplus = C_path - m23f_vartheta*C_lag;
    min_habit_surplus_flex_a = min(min_habit_surplus_flex_a,min(habit_surplus));
end
fprintf('Minimum C_t - vartheta*C_{t-1} after productivity shock, flexible prices: %.6f\n', ...
        min_habit_surplus_flex_a)
if min_habit_surplus_flex_a <= 0
    warning('Habit-adjusted consumption becomes non-positive after the productivity shock in the flexible-price benchmark.')
end

fprintf('\nRotemberg coefficient held fixed across rigid-price Model 2.3: zeta = %.6f\n',m23_zeta)
fprintf('Figures saved in: %s\n\n',folder)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Local formatting functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function set_variable_title(ax,words,symbol)
    word_font = 'URW Classico';
    fs = 13;
    y_title = 1.04;
    if ~strcmp(words,'Producer price differential') && ...
            ~strcmp(words,'Markup differential')
        ax_pix = getpixelposition(ax,true);
        if ax_pix(4) > 0
            y_title = y_title + 4/ax_pix(4);
        end
    end
    title(ax,'')
    if isempty(symbol)
        text(ax,0.5,y_title,words, ...
            'Units','normalized','HorizontalAlignment','center', ...
            'VerticalAlignment','middle','Clipping','off', ...
            'Interpreter','none','FontName',word_font,'FontSize',fs, ...
            'FontWeight','normal','Color','k');
    else
        t_words = text(ax,0,y_title,[words ' '], ...
            'Units','normalized','HorizontalAlignment','left', ...
            'VerticalAlignment','middle','Clipping','off', ...
            'Interpreter','none','FontName',word_font,'FontSize',fs, ...
            'FontWeight','normal','Color','k');
        t_symbol = text(ax,0,y_title,['$(' symbol ')$'], ...
            'Units','normalized','HorizontalAlignment','left', ...
            'VerticalAlignment','middle','Clipping','off', ...
            'Interpreter','latex','FontSize',fs,'FontWeight','normal', ...
            'Color','k');

        drawnow
        ew = get(t_words,'Extent');
        es = get(t_symbol,'Extent');
        total_width = ew(3) + es(3);
        x_left = 0.5 - total_width/2;
        set(t_words,'Position',[x_left y_title 0])
        set(t_symbol,'Position',[x_left+ew(3) y_title 0])
    end
end

function center_legend_in_axes(lgd,ax)
    drawnow
    old_ax_units = get(ax,'Units');
    set(ax,'Units','normalized')
    ax_pos = get(ax,'Position');
    set(ax,'Units',old_ax_units)

    set(lgd,'Units','normalized')
    lgd_pos = get(lgd,'Position');
    lgd_pos(1) = ax_pos(1) + (ax_pos(3)-lgd_pos(3))/2;
    lgd_pos(2) = ax_pos(2) + (ax_pos(4)-lgd_pos(4))/2;
    set(lgd,'Position',lgd_pos)
end

function center_legend_below_pt(lgd,ax_pt)
    drawnow
    old_ax_units = get(ax_pt,'Units');
    set(ax_pt,'Units','normalized')
    pt_pos = get(ax_pt,'Position');
    set(ax_pt,'Units',old_ax_units)

    blank_rect = [pt_pos(1), 0.06, pt_pos(3), max(pt_pos(2)-0.14,0.20)];
    set(lgd,'Units','normalized')
    lgd_pos = get(lgd,'Position');
    lgd_pos(1) = blank_rect(1) + (blank_rect(3)-lgd_pos(3))/2;
    lgd_pos(2) = blank_rect(2) + (blank_rect(4)-lgd_pos(4))/2;
    set(lgd,'Position',lgd_pos)
end

function format_irf_axis(ax,x,Y)

    finite_values = Y(isfinite(Y));

    if isempty(finite_values)
        finite_values = 0;
    end

    ymin = min([finite_values(:); 0]);
    ymax = max([finite_values(:); 0]);
    yrange = ymax-ymin;

    if yrange < 1e-10
        yrange = max(abs([ymin ymax]));
        if yrange < 1e-10
            yrange = 1;
        end
    end

    pad = 0.08*yrange;

    xlim(ax,[x(1) x(end)])
    ylim(ax,[ymin-pad ymax+pad])
    box(ax,'on')
    set(ax,'Color','w','XColor','k','YColor','k', ...
           'FontName','Helvetica Neue','FontSize',11,'FontWeight','normal', ...
           'TickLabelInterpreter','tex','LineWidth',0.75,'TickDir','in')
end

function format_legend(lgd,graph_font)
    set(lgd,'Color','w','TextColor','k','EdgeColor','k', ...
            'FontName',graph_font,'FontWeight','normal','Box','on')
end