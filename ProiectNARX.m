clc; clear all; close all;

%%
load("iddata-12.mat");
u_id = id.InputData(:);   
y_id = id.OutputData(:);
u_val = val.InputData(:);
y_val = val.OutputData(:);

N_id = length(u_id);
N_val = length(u_val);

grad_polinom = 1;

MSE = [];

MSE_min       = 10e4;   
pred_id_min = [];  
pred_val_min   = [];
sim_val_min    = [];
na_nb_fin      = [0 0];
theta_fin      = [];

for na = 1:3
    nb = na;  
    
    %constructie phi predictie
    nr_term = 0;
    for a = 0:grad_polinom
        for b = 0:(grad_polinom - a)
            nr_term = nr_term + na * nb;
        end
    end
    N_phi = 1 + na + nb + nr_term;

    phi_id = zeros(N_id, N_phi);
    for k = 1:N_id
        phi_id(k,1) = 1;
        for i = 1:na
            coloana = 1 + i;
            if (k - i) > 0
                phi_id(k,coloana) = y_id(k - i);
            end
        end
        for j = 1:nb
            coloana = na + 1 + j;
            if (k - j) > 0
                phi_id(k,coloana) = u_id(k - j);
            end
        end
        z = na + nb + 2;
        for a = 0:grad_polinom
            for b = 0:(grad_polinom - a)
                for na1 = 1:na
                    for nb2 = 1:nb
                        if (k - na1 > 0) && (k - nb2 > 0)
                            phi_id(k,z) = (y_id(k - na1)^a) * (u_id(k - nb2)^b);
                        end
                        z = z + 1;
                    end
                end
            end
        end
    end
    
    theta = phi_id \ y_id;
    
    %predictie set id
    y_pred_id = phi_id * theta;
    mse_id   = mean((y_id - y_pred_id).^2);

    %predictie set val
    phi_val = zeros(N_val, N_phi);

    for k = 1:N_val
        phi_val(k,1) = 1;
        for i = 1:na
            coloana = 1 + i;
            if (k - i) > 0
                phi_val(k,coloana) = y_val(k - i);
            end
        end
        for j = 1:nb
            coloana = na + 1 + j;
            if (k - j) > 0
                phi_val(k,coloana) = u_val(k - j);
            end
        end
        z = na + nb + 2;
        for a = 0:grad_polinom
            for b = 0:(grad_polinom - a)
                for na1 = 1:na
                    for nb2 = 1:nb
                        if (k - na1 > 0) && (k - nb2 > 0)
                            phi_val(k,z) = (y_val(k - na1)^a) * (u_val(k - nb2)^b);
                        end
                        z = z + 1;
                    end
                end
            end
        end
    end

    y_pred_val = phi_val * theta;
    mse_val   = mean((y_val - y_pred_val).^2);

    %simulare set id
    y_sim_id = zeros(N_id, 1);
    y_sim_id(1:nb) = y_id(1:nb);

    for k = (nb+1) : N_id
        phi_sim = zeros(N_phi, 1);
        phi_sim(1) = 1;
        for i = 1:na
            phi_sim(1 + i) = y_sim_id(k - i);
        end
        for j = 1:nb
            phi_sim(na + 1 + j) = u_id(k - j);
        end
        z = na + nb + 2;
        for a = 0:grad_polinom
            for b = 0:(grad_polinom - a)
                for na1 = 1:na
                    for nb2 = 1:nb
                        phi_sim(z) = (y_sim_id(k - na1)^a) * (u_id(k - nb2)^b);
                        z = z + 1;
                    end
                end
            end
        end
        y_sim_id(k) = theta' * phi_sim;
    end
    mse_sim_id = mean((y_id - y_sim_id).^2);

    %simulate set val
    y_sim_val = zeros(N_val, 1);
    y_sim_val(1:nb) = y_val(1:nb);

    for k = (nb+1) : N_val
        phi_sim = zeros(N_phi, 1);
        phi_sim(1) = 1;
        for i = 1:na
            phi_sim(1 + i) = y_sim_val(k - i);
        end
        for j = 1:nb
            phi_sim(na + 1 + j) = u_val(k - j);
        end
        z = na + nb + 2;
        for a = 0:grad_polinom
            for b = 0:(grad_polinom - a)
                for na1 = 1:na
                    for nb2 = 1:nb
                        phi_sim(z) = (y_sim_val(k - na1)^a) * (u_val(k - nb2)^b);
                        z = z + 1;
                    end
                end
            end
        end
        y_sim_val(k) = theta' * phi_sim;
    end
    mse_sim_val = mean((y_val - y_sim_val).^2);

    %stocam toate mse-urile <3
    MSE = [MSE;na, nb, grad_polinom, mse_id, mse_val, mse_sim_id, mse_sim_val];

    if mse_val < MSE_min
        MSE_min        = mse_val;
        pred_id_min  = y_pred_id;
        pred_val_min    = y_pred_val;
        na_nb_fin       = [na nb];
        theta_fin       = theta;
        sim_val_min     = y_sim_val;
    end
end

na       = na_nb_fin(1);
nb       = na_nb_fin(2);
N_phi  = length(theta_fin);
N_sim_val = length(y_val);

fprintf('\nCel mai bun MSE (pe validare - predictie) = %.6f ', MSE_min);
fprintf('a fost obtinut pentru na=%d si nb=%d\n', na, nb);

%sim finala pe id
N_sim__id = length(y_id);
y_sim__id = zeros(N_sim__id, 1);
y_sim__id(1:nb) = y_id(1:nb);

for k = (nb+1) : N_sim__id
    phi_sim = zeros(N_phi, 1);
    phi_sim(1) = 1;
    for i = 1:na
        phi_sim(1 + i) = y_sim__id(k - i);
    end
    for j = 1:nb
        phi_sim(na + 1 + j) = u_id(k - j);
    end
    z = na + nb + 2;
    for a = 0:grad_polinom
        for b = 0:(grad_polinom - a)
            for na1 = 1:na
                for nb2 = 1:nb
                    phi_sim(z) = (y_sim__id(k - na1)^a) * (u_id(k - nb2)^b);
                    z = z + 1;
                end
            end
        end
    end
    y_sim__id(k) = theta_fin' * phi_sim;
end

%sim finala pe val
N_sim = length(y_val);
y_sim_val = zeros(N_sim, 1);
y_sim_val(1:nb) = y_val(1:nb);

for k = (nb+1) : N_sim
    phi_sim = zeros(N_phi, 1);
    phi_sim(1) = 1;
    for i = 1:na
        phi_sim(1 + i) = y_sim_val(k - i);
    end
    for j = 1:nb
        phi_sim(na + 1 + j) = u_val(k - j);
    end
    z = na + nb + 2;
    for a = 0:grad_polinom
        for b = 0:(grad_polinom - a)
            for na1 = 1:na
                for nb2 = 1:nb
                    phi_sim(z) = (y_sim_val(k - na1)^a) * (u_val(k - nb2)^b);
                    z = z + 1;
                end
            end
        end
    end
    y_sim_val(k) = theta_fin' * phi_sim;
end

figure;
subplot(2,1,1);
plot(y_id, 'LineWidth', 1.5); hold on;
plot(pred_id_min, 'LineWidth', 1.5);
plot(y_sim__id, '--', 'LineWidth', 1.5);
legend('Iesire reala', 'Predictie', 'Simulare');
title('Set de identificare: Iesire reala vs Predictie vs Simulare');

subplot(2,1,2);
plot(y_val, 'LineWidth', 1.5); hold on;
plot(pred_val_min, 'LineWidth', 1.5);
plot(y_sim_val, '--', 'LineWidth', 1.5);
legend('Iesire reala', 'Predictie', 'Simulare');
title('Set de validare: Iesire reala vs Predictie vs Simulare');

%calcul mse
mse_pred__id = mean((y_id - pred_id_min).^2);
mse_pred_val   = mean((y_val - pred_val_min).^2);
mse_sim__id  = mean((y_id - y_sim__id).^2);
mse_sim_val    = mean((y_val - y_sim_val).^2);

figure;
plot(1:3, MSE(:,4), '-o', 'LineWidth', 1.5); hold on;
plot(1:3, MSE(:,5), '-o', 'LineWidth', 1.5);
xlabel('na = nb');
ylabel('MSE ');
legend('MSE id ', 'MSE val ');
title('MSE (predictie) in functie de na=nb');
grid on;

figure;
plot(1:3, MSE(:,6), '-s', 'LineWidth', 1.5); hold on;
plot(1:3, MSE(:,7), '-s', 'LineWidth', 1.5);
xlabel('na = nb');
ylabel('MSE (Simulare)');
legend('MSE id', 'MSE val ');
title('MSE (simulare) in functie de na=nb');
grid on;

fprintf('\nEroare medie patratica (MSE):\n');
fprintf('Set identificare:\n');
fprintf(' - Predictie: %.6f\n', mse_pred__id);
fprintf(' - Simulare: %.6f\n', mse_sim__id);
fprintf('Set de validare:\n');
fprintf(' - Predictie: %.6f\n', mse_pred_val);
fprintf(' - Simulare: %.6f\n', mse_sim_val);