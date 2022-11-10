% =========================================================================
% LogLikeARpNorm.m
% =========================================================================

function loglik=LogLikeARpNorm(x,y,p,const)
% =========================================================================
% Computes the conditional log likelihood function of Gaussian AR(p) model:
% y_t = c + d*t + theta_1*y_{t-1} + ... + theta_p*y_{t-p} + u_t
% with u_t ~ N(0,sig_u)
% =========================================================================
% loglik=LogLikeARpNorm(x,y,p,const)
% -------------------------------------------------------------------------
% INPUT
%   - x      [(const+p+1)x1]  vector of coefficients, i.e. [c,d,theta_1,...,theta_p,sig_u]'
%   - y      [Tx1]            data vector of dimension T
%   - p      [scalar]         number of lags
%   - const  [scalar]         1 constant; 2 constant and linear trend in model
% -------------------------------------------------------------------------
% OUTPUT
%	- loglik [double]         value of Gaussian log-likelihood
% -------------------------------------------------------------------------
% Calls
%   - lagmatrix.m (requires Econometrics Toolbox)
% =========================================================================
% Willi Mutschler, November 9, 2022
% willi@mutschler.eu
% =========================================================================

theta = x(1:(const+p)); % AR coefficients
sig_u = x(const+p+1);   % standard deviation of error term

T = size(y,1);          % sample size
Y = lagmatrix(y,1:p);   % create matrix with lagged variables
if const == 1           % add constant
    Y = [ones(T,1) Y];
elseif const == 2       % add constant and time trend
    Y = [ones(T,1) transpose(1:T) Y];
end
Y = Y((p+1):end,:);     % get rid of initial observations
y = y(p+1:end);         % get rid of initial observations

uhat = y - Y*theta;     % ML residuals
utu = uhat'*uhat;       % ML sum of residuals

% compute the conditional log likelihood
loglik = -log(2*pi)*(T-p)/2 - log(sig_u^2)*(T-p)/2 -utu/(2*sig_u^2);

if isnan(loglik) || isinf(loglik) || ~isreal(loglik)
    loglik = -1e10;     % if anything goes wrong set value very small, can also use -Inf
end

end % function end