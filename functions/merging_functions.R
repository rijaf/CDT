
outputADTest <- function(X, months = 1:12, distr = "berngamma"){
	H0.test <- vector(mode = 'list', length = 12)
	H0.test[months] <- lapply(X[months], function(mon){
		sapply(mon, function(stn) if(!is.null(stn)) stn[[distr]]$h0 else 'null')
	})
	return(H0.test)
}

##############################
### Extract parameters
extractDistrParams <- function(X, months = 1:12, distr = "berngamma"){
	pars <- vector(mode = 'list', length = 12)
	pars[months] <- lapply(X[months], function(mon){
		parstn <- lapply(mon, function(stn){
			if(!is.null(stn)){
				fitdist <- stn[[distr]]$fitted.distr
				if(!is.null(fitdist)) fitdist$estimate else NA
			}else NA
		})
		nom <- na.omit(do.call('rbind', lapply(parstn, function(x) if(length(x) > 1) names(x) else NA)))[1, ]
		parstn <- do.call('rbind', parstn)
		dimnames(parstn)[[2]] <- nom
		parstn
	})
	pars[months] <- rapply(pars[months], f = function(x) ifelse(is.nan(x) | is.infinite(x), NA, x), how = "replace")
	return(pars)
}

##############################
### Quantile mapping
quantile.mapping.BGamma <- function(x, pars.stn, pars.rfe, rfe.zero){
	res <- x
	p.rfe <- 1-pars.rfe$prob
	ix <- !is.na(x) & (x > 0)
	p.rfe[ix] <- p.rfe[ix] + pars.rfe$prob[ix]*pgamma(x[ix], scale = pars.rfe$scale[ix], shape = pars.rfe$shape[ix])
	p.rfe[p.rfe > 0.999] <- 0.99
	ip <- p.rfe > (1-pars.stn$prob)
	pp <- (pars.stn$prob[ip]+p.rfe[ip]-1)/pars.stn$prob[ip]
	pp[pp > 0.999] <- 0.99
	res[ip] <- qgamma(pp, scale = pars.stn$scale[ip], shape = pars.stn$shape[ip])
	miss <- is.na(res) | is.nan(res) | is.infinite(res)
	res[miss] <- x[miss]
	res[is.na(x)] <- NA
	if(rfe.zero) res[x == 0] <- 0
	moy <- pars.rfe$shape*pars.rfe$scale
	ssd <- sqrt(pars.rfe$shape*pars.rfe$scale^2)
	ix <- (res-moy)/ssd > 3
	ix[is.na(ix)] <- FALSE
	res[ix] <- x[ix]
	return(res)
}

##############################
## Fit linear model
## See http://rsnippets.blogspot.com/2013/12/speeding-up-model-bootstrapping-in-gnu-r.html

fitLM.fun.RR <- function(df, min.len){
	# df <- na.omit(df)
	df <- df[!is.na(df$stn) & !is.na(df$rfe), , drop = FALSE]
	if(nrow(df) >= min.len) lm(stn~rfe, data = df)
	else return(NULL)
}

fitLM.month.RR <- function(df, min.len) by(df, df$month, fitLM.fun.RR, min.len)

#################################################################################################

outputSWNTest <- function(X, months = 1:12){
	H0.test <- vector(mode = 'list', length = 12)
	H0.test[months] <- lapply(X[months], function(mon){
		sapply(mon, function(stn) if(!is.null(stn)) stn$h0 else 'null')
	})
	return(H0.test)
}

##############################
### Extract parameters
extractNormDistrParams <- function(X, months = 1:12){
	pars <- vector(mode = 'list', length = 12)
	pars[months] <- lapply(X[months], function(mon){
		parstn <- lapply(mon, function(stn){
			if(!is.null(stn)){
				fitdist <- stn$fitted.distr
				if(!is.null(fitdist)) fitdist$estimate else NA
			}else NA
		})
		nom <- na.omit(do.call('rbind', lapply(parstn, function(x) if(length(x) > 1) names(x) else NA)))[1, ]
		parstn <- do.call('rbind', parstn)
		dimnames(parstn)[[2]] <- nom
		parstn
	})
	pars[months] <- rapply(pars[months], f = function(x) ifelse(is.nan(x) | is.infinite(x), NA, x), how = "replace")
	return(pars)
}

##############################
### Quantile mapping
quantile.mapping.Gau <- function(x, pars.stn, pars.reanal){
	p.reanal <- x
	ix <- !is.na(x)
	p.reanal[ix] <- pnorm(x[ix], mean = pars.reanal$mean[ix], sd = pars.reanal$sd[ix])
	p.reanal[ix][p.reanal[ix] < 0.001] <- 0.01
	p.reanal[ix][p.reanal[ix] > 0.999] <- 0.99
	res <- qnorm(p.reanal, mean = pars.stn$mean, sd = pars.stn$sd)
	miss <- is.na(res) | is.nan(res) | is.infinite(res)
	res[miss] <- x[miss]
	ix <- (res-pars.reanal$mean)/pars.reanal$sd > 3
	ix[is.na(ix)] <- FALSE
	res[ix] <- x[ix]	
    return(res)
}

##############################
## Fit linear model
fitLM.fun.TT <- function(df, min.len){
	df <- na.omit(df)
	if(nrow(df) >= min.len) lm(stn~tt, data = df)
	else return(NULL)
}

fitLM.month.TT <- function(df, min.len) by(df, df$month, fitLM.fun.TT, min.len)


