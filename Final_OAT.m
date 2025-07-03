% OAT Sensitivity Analysis for Geothermal Power Plant Estimation
% This script performs sensitivity analysis and visualizes the results.

% Parameters for sensitivity analysis
factors = {'Area', 'Thickness', 'Reservoir Temp', 'Rock Density', 'Porosity', 'Recovery Factor', 'Capacity Factor'};
base_values = [225, 2.5, 200, 2700, 0.05, 11, 92.7]; % Baseline values for parameters
perturbation = 0.1; % 10% perturbation for sensitivity analysis

% Number of simulations
num_simulations = 100000;

% Fixed parameters
plant_life_years = 25; % Plant life (years)
plant_life_seconds = plant_life_years * 365 * 24 * 3600; % Plant life (seconds)
Cw = 4.18 * 1000; % Fluid specific heat (J/kg°C)
rho_f = 1000; % Fixed fluid density (kg/m³)

% Preallocate arrays for results
absolute_changes = zeros(length(factors), 1); % Store absolute changes
relative_changes = zeros(length(factors), 1); % Store relative changes

% Loop over each factor
for f = 1:length(factors)
    % Perturb base values
    perturbed_values = base_values;
    perturbed_values(f) = base_values(f) * (1 + perturbation);

    % Calculate baseline power capacity
    baseline_power = calculate_power_capacity(base_values, num_simulations, plant_life_seconds, Cw, rho_f);

    % Calculate perturbed power capacity
    perturbed_power = calculate_power_capacity(perturbed_values, num_simulations, plant_life_seconds, Cw, rho_f);

    % Calculate sensitivity indices (absolute and relative changes)
    absolute_changes(f) = abs(perturbed_power - baseline_power);
    relative_changes(f) = absolute_changes(f) / baseline_power;
end

% Plot results
figure;

% Plot absolute changes
subplot(2, 1, 1);
bar(absolute_changes, 'FaceColor', [0.2, 0.6, 0.8]);
title('Absolute Change in Power Capacity');
xlabel('Factors');
ylabel('Absolute Change (GWe)');
set(gca, 'XTickLabel', factors, 'XTick', 1:length(factors), 'XTickLabelRotation', 45);
grid on;

% Plot relative changes
subplot(2, 1, 2);
bar(relative_changes * 100, 'FaceColor', [0.8, 0.4, 0.4]);
title('Relative Change in Power Capacity');
xlabel('Factors');
ylabel('Relative Change (%)');
set(gca, 'XTickLabel', factors, 'XTick', 1:length(factors), 'XTickLabelRotation', 45);
grid on;

% Display results in the command window
fprintf('OAT Sensitivity Analysis Results:\n');
fprintf('----------------------------------\n');
fprintf('%-20s | Absolute Change | Relative Change\n', 'Factor');
fprintf('------------------------------------------\n');
for f = 1:length(factors)
    fprintf('%-20s | %.2e | %.2f %%\n', factors{f}, absolute_changes(f), relative_changes(f) * 100);
end

% Function to calculate power capacity
function power_capacity = calculate_power_capacity(values, num_simulations, plant_life_seconds, Cw, rho_f)
    % Extract parameter values
    area = values(1) * 1e6; % Convert from km^2 to m^2
    thickness = values(2) * 1e3; % Convert from km to m
    TR = values(3); % Reservoir temperature (°C)
    rho_r = values(4); % Rock density (kg/m^3)
    phi = values(5); % Porosity (fraction)
    Rf = values(6) / 100; % Recovery factor (fraction)
    F = values(7) / 100; % Capacity factor (fraction)
    Tref = 15; % Reference temperature (°C)

    % Calculate rock specific heat (J/kg°C)
    Cr = (-4.418e-7 * TR^3 - 0.0008209 * TR^2 + 1.352 * TR + 994.2); % Convert from kJ/kg°C to J/kg°C

    % Calculate reservoir volume (m^3)
    V = area * thickness; % Volume = Area x Thickness

    % Calculate thermal energy stored in the rock and geofluid (J)
    qR = rho_r * Cr * V * (1 - phi) * (TR - Tref); % Energy stored in rock
    qF = rho_f * Cw * V * phi * (TR - Tref); % Energy stored in geofluid
    qT = qR + qF; % Total thermal energy

    % Calculate conversion efficiency (dependent on TR)
    eta_c = 0.0935 * TR - 2.3266; % Conversion efficiency in %
    eta_c = eta_c / 100; % Convert to fraction

    % Calculate electrical power harvested (MWe)
    power_capacity = (qT * Rf * eta_c) / (F * plant_life_seconds);
    power_capacity = power_capacity / 1e9; % Convert to GWe
end