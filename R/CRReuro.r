#' \code{CRReuro}
#' @description
#' European option binomial model on a stock without dividends.For academic purpose only.
#' Use fOptions::CRRBinomialTreeOptions for real-life usage.
#' @param S Stock price.
#' @param X Strike price.
#' @param sigma Implied volatility e.g. 0.20
#' @param r Risk-free rate.
#' @param T Time to maturity in years
#' @param N Number of time steps. Internally dt = T/N.
#' @param type "call" or "put"
#' @return List of asset price tree, option value tree and option price.
#' @export CRReuro
#' @author Philippe Cote
#' @examples
#' CRReuro(S=100,X=100,sigma=0.2,r=0.1,T=1,N=5,type="call")

CRReuro = function(S,X,sigma,r,T,N,type) {
  dt=T/N
  # Define u, d, and risk-neutral probability
  u = exp(sigma*sqrt(dt))
  d = exp(-sigma*sqrt(dt))
  q = (exp(r*dt) - d)/(u-d)
  # Define our asset tree prices
  asset = matrix(0, nrow=N+1, ncol=N+1)
  for (i in 1:(N+1)) {
    for (j in 1:i) {asset[i,j] = S * u^(j-1) * d^((i-1)-(j-1))}
  }
  # create a matrix of the same dimensions as asset price tree
  option = matrix(0, nrow=nrow(asset), ncol=ncol(asset))
  # replace last row with maturity payoffs
  if(type == "call") {option[nrow(option),] = pmax(asset[nrow(asset),] - X, 0)}
  if(type == "put") {option[nrow(option),] = pmax(X - asset[nrow(asset),], 0)}
  if (!type %in% c("call","put")) stop("define option type: call or put")

  # we discount recursively starting from final payoff (last row of tree)
  # starting at the second last period based on final payoffs
  for (i in (nrow(option)-1):1) {
    for(j in 1:i) {
      option[i, j] = ((1-q) * option[i+1,j] + q * option[i+1,j+1]) / exp(r*dt)
    }
  }

  # indicator if model can be used sigma > rsqrt(dt)
  note <- if (sigma > sqrt(dt)*r) {"ok"} else {"sigma < rsqrt(dt) do not use"}

  return(list(asset=asset, option=option, price=option[1,1],note=note))
}
