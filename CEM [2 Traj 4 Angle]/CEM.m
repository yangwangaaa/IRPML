clc
clear all
close all

%%%%%%%%%%%%%%%%%%%%
% Tuning Params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nbr_RBS=80;        % Radial basis functions
%RL_q_ref=4;       % Reference Joint Number
nbr_iter=30;     % Algorithm iterations count
Ke=10;             % Elitness parameter
K=20;             % Smaples count
alpha=0.0001;          % RBF coefficient 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%filename='Convergence.gif';

%% Reference Traj BiPed
Tref=Trefs();
s=size(Tref);

for RL_q_ref=1:s(1)
%% Initial Trajectories Sampling  Params
qu=num2str(RL_q_ref);
filename=strcat('Convergence_q_',qu,'.gif');  
mu= zeros(nbr_RBS,1);
V= rand (1,nbr_RBS);  
Sigma=diag(V);

%% CEM Iterations

for iter=1:nbr_iter
    if iter~=1
        mu=mu_new;
        Sigma=sigma_new;
    end
    teta=zeros(K,nbr_RBS);
    T=zeros(K,s(2));
     
for k=1:K 
   
    teta(k,:)=mvnrnd(mu,Sigma);
    T(k,:)=exepolicy_RBF(teta(k,:),Tref(RL_q_ref,:,:),s(2),alpha);
end
%% Plotting sampled tajectories

t=1:s(2);
figure(2)
hold off
for i=1:20
    plot(t,T(i,:)); 
    hold on;
end
idx=iter;
frame = getframe(gcf);
im{idx} = frame2im(frame);

%% Iterations 
cost=zeros(K,1);
for k=1:K
    cost(k)=J(Tref(RL_q_ref,:,:),T(k,:),1);
end

%% sorting and weighing 
p=zeros(K,1);
thresh_hold=1/Ke;
[B,I] = sort(cost);
for i=1:Ke
    p(I(i,1))=thresh_hold;
end

%% Updating mu
mu_new=zeros(nbr_RBS,1);
for i=1:K
    for m=1:nbr_RBS
        mu_new(m)=mu_new(m)+p(i)*teta(i,m);
    end
end

%% Updating Sigma
sigma_new=zeros(nbr_RBS);
for k=1:K
    sigma_new=sigma_new + (p(k).*(teta(k,:)'-mu(:)))*... %TOASK
           (teta(k,:)'-mu(:))';
end
end

%% Generating the animated gif of the converging trajectories
for idx=1:nbr_iter
    [A,map] = rgb2ind(im{idx},256);
if idx == 1
    imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',1);
else
    imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',1);
end
end

%% Learned distribution
figure
qu=num2str(RL_q_ref);
teta_RL = mvnrnd(mu_new,sigma_new); 
T_RL=exepolicy_RBF(teta_RL,Tref(RL_q_ref,:,:),s(2),alpha);
plot(T_RL,'+')
hold on
plot(1:s(2),Tref(RL_q_ref,:,1),'-') %% TOCHECK 
hold on
plot(1:s(2),Tref(RL_q_ref,:,2),'-')
legend('Learned','Reference')
title (strcat('Reference vs Learned',qu))
end