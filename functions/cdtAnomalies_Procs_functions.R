
anomaliesCalcProcs <- function(GeneralParameters){
	freqData <- GeneralParameters$intstep
	start.year <- GeneralParameters$Dates$start.year
	start.mon <- GeneralParameters$Dates$start.mon
	start.dek <- GeneralParameters$Dates$start.dek
	end.year <- GeneralParameters$Dates$end.year
	end.mon <- GeneralParameters$Dates$end.mon
	end.dek <- GeneralParameters$Dates$end.dek

	if(any(is.na(c(start.year, start.mon, start.dek, end.year, end.mon, end.dek)))){
		InsertMessagesTxt(main.txt.out, "Invalid anomalies date range", format = TRUE)
		return(NULL)
	}

	if(GeneralParameters$outdir$update){
		don.anom <- try(readRDS(GeneralParameters$outdir$dir), silent = TRUE)
		if(inherits(don.anom, "try-error")){
			InsertMessagesTxt(main.txt.out, paste("Unable to read", GeneralParameters$outdir$dir), format = TRUE)
			return(NULL)
		}
		if(freqData != don.anom$params$intstep){
			InsertMessagesTxt(main.txt.out, paste("Previous saved anomalies data are not a", freqData), format = TRUE)
			return(NULL)
		}

		if(GeneralParameters$data.type != don.anom$params$data.type){
			InsertMessagesTxt(main.txt.out, paste("Previous saved anomalies data are not a", GeneralParameters$data.type), format = TRUE)
			return(NULL)
		}
	}else{
		if(!dir.exists(GeneralParameters$outdir$dir)){
			InsertMessagesTxt(main.txt.out, paste(GeneralParameters$outdir$dir, "did not find"), format = TRUE)
			return(NULL)
		}

		if(GeneralParameters$climato$clim.exist){
			don.climato <- try(readRDS(GeneralParameters$climato$clim.file), silent = TRUE)
			if(inherits(don.climato, "try-error")){
				InsertMessagesTxt(main.txt.out, paste("Unable to read", GeneralParameters$climato$clim.file), format = TRUE)
				return(NULL)
			}

			if(freqData != don.climato$params$intstep){
				InsertMessagesTxt(main.txt.out, paste("The climatologies data are not a", freqData, "data"), format = TRUE)
				return(NULL)
			}

			if(GeneralParameters$data.type != don.climato$params$data.type){
				InsertMessagesTxt(main.txt.out, paste("Climatologies data are not a", GeneralParameters$data.type), format = TRUE)
				return(NULL)
			}
		}else{
			year1 <- GeneralParameters$climato$start
			year2 <- GeneralParameters$climato$end
			minyear <- GeneralParameters$climato$minyear
			xwin <- GeneralParameters$climato$window

			if(any(is.na(c(year1, year2, minyear)))){
				InsertMessagesTxt(main.txt.out, "Invalid base period", format = TRUE)
				return(NULL)
			}
		}
	}

	#####################################################

	if(GeneralParameters$data.type == "cdtstation"){
		don <- getStnOpenData(GeneralParameters$cdtstation$file)
		if(is.null(don)) return(NULL)
		don <- getCDTdataAndDisplayMsg(don, freqData)
		if(is.null(don)) return(NULL)

		daty <- don$dates
		year <- as.numeric(substr(daty, 1, 4))

		if(GeneralParameters$outdir$update){
			if(length(don$id) != length(don.anom$data$id)){
				InsertMessagesTxt(main.txt.out, "Number of stations from the input and the previous saved anomalies data do not match", format = TRUE)
				return(NULL)
			}
			
			if(any(don$id != don.anom$data$id)){
				InsertMessagesTxt(main.txt.out, "Order of stations from the input and the previous saved anomalies data do not match", format = TRUE)
				return(NULL)
			}

			dat.moy <- try(readRDS(don.anom$mean.file), silent = TRUE)
			if(inherits(dat.moy, "try-error")){
				InsertMessagesTxt(main.txt.out, paste("Unable to read", don.anom$mean.file), format = TRUE)
				return(NULL)
			}
			if(don.anom$params$anomaly == "Standardized"){
				dat.sds <- try(readRDS(don.anom$sds.file), silent = TRUE)
				if(inherits(dat.sds, "try-error")){
					InsertMessagesTxt(main.txt.out, paste("Unable to read", don.anom$sds.file), format = TRUE)
					return(NULL)
				}
			}

			clim.index.file <- file.path(dirname(dirname(don.anom$mean.file)), "Climatology.rds")
			don.climato <- try(readRDS(clim.index.file), silent = TRUE)
			if(inherits(don.climato, "try-error")){
				InsertMessagesTxt(main.txt.out, paste("Unable to read", clim.index.file), format = TRUE)
				return(NULL)
			}

			index0 <- NULL
			index0$id <- don.climato$index
			anomaly.fonct <- don.anom$params$anomaly
		}else{
			if(GeneralParameters$climato$clim.exist){
				if(length(don$id) != length(don.climato$data$id)){
					InsertMessagesTxt(main.txt.out, "Number of stations from data and the climatology do not match", format = TRUE)
					return(NULL)
				}
				
				if(any(don$id != don.climato$data$id)){
					InsertMessagesTxt(main.txt.out, "Order of stations from data and the climatology do not match", format = TRUE)
					return(NULL)
				}

				mean.file <- file.path(dirname(GeneralParameters$climato$clim.file), 'CDTMEAN', 'CDTMEAN.rds')
				sds.file <- file.path(dirname(GeneralParameters$climato$clim.file), 'CDTSTD', 'CDTSTD.rds')

				dat.moy <- try(readRDS(mean.file), silent = TRUE)
				if(inherits(dat.moy, "try-error")){
					InsertMessagesTxt(main.txt.out, paste("Unable to read", mean.file), format = TRUE)
					return(NULL)
				}
				if(GeneralParameters$anomaly == "Standardized"){
					dat.sds <- try(readRDS(sds.file), silent = TRUE)
					if(inherits(dat.sds, "try-error")){
						InsertMessagesTxt(main.txt.out, paste("Unable to read", sds.file), format = TRUE)
						return(NULL)
					}
				}
				index0 <- NULL
				index0$id <- don.climato$index
			}else{
				if(length(unique(year)) < minyear){
					InsertMessagesTxt(main.txt.out, "No enough data to calculate climatologies", format = TRUE)
					return(NULL)
				}

				iyear <- year >= year1 & year <= year2
				daty0 <- daty[iyear]
				don0 <- don$data[iyear, , drop = FALSE]
				index0 <- getClimatologiesIndex(daty0, freqData, xwin)

				div <- if(freqData == "daily") 2*xwin+1 else 1
				Tstep.miss <- (sapply(index0$index, length)/div) < minyear

				dat.clim <- lapply(seq_along(index0$id), function(jj){
					if(Tstep.miss[jj]){
						tmp <- rep(NA, ncol(don0))
						 return(list(moy = tmp, sds = tmp))
					}
					xx <- don0[index0$index[[jj]], , drop = FALSE]
					ina <- (colSums(!is.na(xx))/div) < minyear
					moy <- colMeans(xx, na.rm = TRUE)
					sds <- matrixStats::colSds(xx, na.rm = TRUE)
					moy[ina] <- NA
					sds[ina] <- NA
					rm(xx)
					list(moy = moy, sds = sds)
				})

				dat.moy <- do.call(rbind, lapply(dat.clim, "[[", "moy"))
				dat.sds <- do.call(rbind, lapply(dat.clim, "[[", "sds"))
				dat.moy <- round(dat.moy, 1)
				dat.sds <- round(dat.sds, 1)

				rm(dat.clim, don0, daty0)
			}
			anomaly.fonct <- GeneralParameters$anomaly
		}

		### anom
		daty0 <- if(freqData == "monthly") as.Date(paste0(daty, 15), "%Y%m%d") else as.Date(daty, "%Y%m%d")

		if(freqData == "daily"){
			start.daty <- as.Date(paste(start.year, start.mon, start.dek, sep = "-"))
			end.daty <- as.Date(paste(end.year, end.mon, end.dek, sep = "-"))
		}
		if(freqData == "pentad"){
			start.daty <- as.Date(paste(start.year, start.mon, start.dek, sep = "-"))
			end.daty <- as.Date(paste(end.year, end.mon, end.dek, sep = "-"))
		}
		if(freqData == "dekadal"){
			start.daty <- as.Date(paste(start.year, start.mon, start.dek, sep = "-"))
			end.daty <- as.Date(paste(end.year, end.mon, end.dek, sep = "-"))
		}
		if(freqData == "monthly"){
			start.daty <- as.Date(paste(start.year, start.mon, 15, sep = "-"))
			end.daty <- as.Date(paste(end.year, end.mon, 15, sep = "-"))
		}

		iyear <- daty0 >= start.daty & daty0 <= end.daty
		daty <- daty[iyear]
		if(length(daty) == 0){
			InsertMessagesTxt(main.txt.out, "No data to compute anomaly", format = TRUE)
			return(NULL)
		}
		don$data <- don$data[iyear, , drop = FALSE]
		rm(daty0)

		########
		index <- getClimatologiesIndex(daty, freqData, 0)
		ixx <- match(index0$id, index$id)
		ixx <- ixx[!is.na(ixx)]
		index$id <- index$id[ixx]
		index$index <- index$index[ixx]

		index1 <- lapply(seq_along(index$id), function(j){
			cbind(index$id[j], index$index[[j]])
		})

		index1 <- do.call(rbind, index1)
		index1 <- index1[order(index1[, 2]), ]
		daty <- daty[index1[, 2]]

		if(anomaly.fonct == "Difference"){
			anom <- don$data[index1[, 2], , drop = FALSE] - dat.moy[index1[, 1], , drop = FALSE]
		}

		if(anomaly.fonct == "Percentage"){
			anom <- 100 * (don$data[index1[, 2], , drop = FALSE] - dat.moy[index1[, 1], , drop = FALSE]) / (dat.moy[index1[, 1], , drop = FALSE]+0.001)
		}

		if(anomaly.fonct == "Standardized"){
			anom <- (don$data[index1[, 2], , drop = FALSE] - dat.moy[index1[, 1], , drop = FALSE]) / dat.sds[index1[, 1], , drop = FALSE]
		}

		#########################################

		if(GeneralParameters$outdir$update){
			anom.dir <- dirname(GeneralParameters$outdir$dir)
			anom.file.rds <- file.path(anom.dir, 'CDTANOM', 'CDTANOM.rds')
			anom.file.csv <- file.path(anom.dir, 'CDTSTATIONS', paste0(freqData, "_Anomaly.csv"))

			data.anom.rds <- readRDS(anom.file.rds)
			data.anom.csv <- read.table(anom.file.csv, sep = ",", colClasses = "character", stringsAsFactors = FALSE)
			infohead <- data.anom.csv[1:3, , drop = FALSE]
			data.anom.csv <- data.anom.csv[-(1:3), -1]

			ixold <- match(daty, don.anom$data$dates)
			ixold <- ixold[!is.na(ixold)]

			if(length(ixold) == 0){
				don.anom$data$dates <- c(don.anom$data$dates, daty)
				data.anom.rds <- rbind(data.anom.rds, anom)
				anom[is.na(anom)] <- -99
				anom <- as.data.frame(anom)
				names(anom) <- names(data.anom.csv)
				data.anom.csv <- rbind(data.anom.csv, anom)
			}else{
				don.anom$data$dates <- c(don.anom$data$dates[-ixold], daty)
				data.anom.rds <- rbind(data.anom.rds[-ixold, , drop = FALSE], anom)
				anom[is.na(anom)] <- -99
				anom <- as.data.frame(anom)
				names(anom) <- names(data.anom.csv)
				data.anom.csv <- rbind(data.anom.csv[-ixold, , drop = FALSE], anom)
			}

			saveRDS(data.anom.rds, anom.file.rds)

			tmp <- data.frame(cbind(don.anom$data$dates, data.anom.csv))
			names(tmp) <- names(infohead)
			data.anom.csv <- rbind(infohead, tmp)
			writeFiles(data.anom.csv, anom.file.csv)

			saveRDS(don.anom, GeneralParameters$outdir$dir)
			EnvAnomalyCalcPlot$output <- don.anom
			EnvAnomalyCalcPlot$PathAnom <- anom.dir

			rm(tmp, don, anom, data.anom.csv, data.anom.rds, don.anom, dat.moy, dat.sds)
		}else{
			outDIR <- file.path(GeneralParameters$outdir$dir, "ANOMALIES_data")
			dir.create(outDIR, showWarnings = FALSE, recursive = TRUE)
			out.dat.index <- gzfile(file.path(outDIR, "Anomaly.rds"), compression = 7)

			datadir <- file.path(outDIR, 'CDTSTATIONS')
			dir.create(datadir, showWarnings = FALSE, recursive = TRUE)
			out.cdt.anomal <- file.path(datadir, paste0(freqData, "_Anomaly.csv"))

			dataOUT3 <- file.path(outDIR, 'CDTANOM')
			dir.create(dataOUT3, showWarnings = FALSE, recursive = TRUE)
			out.cdt.anom <- gzfile(file.path(dataOUT3, 'CDTANOM.rds'), compression = 7)

			#############
			saveRDS(anom, out.cdt.anom)
			close(out.cdt.anom)

			#############
			xhead <- rbind(don$id, don$lon, don$lat)
			chead <- c('ID.STN', 'LON', paste0(toupper(freqData), "/LAT"))
			infohead <- cbind(chead, xhead)

			#############
			anom <- round(anom, 2)
			anom[is.na(anom)] <- -99
			anom <- rbind(infohead, cbind(daty, anom))
			writeFiles(anom, out.cdt.anomal)

			#############
			if(GeneralParameters$climato$clim.exist){
				output <- list(params = GeneralParameters,
							data = list(id = don$id, lon = don$lon, lat = don$lat, dates = daty),
							mean.file = mean.file, sds.file = sds.file)
				EnvAnomalyCalcPlot$output <- output
				EnvAnomalyCalcPlot$PathAnom <- outDIR

				saveRDS(output, out.dat.index)
				close(out.dat.index)
			}else{
				out.cdt.clim.moy <- file.path(datadir, paste0(freqData, "_Climatology_mean.csv"))
				out.cdt.clim.sds <- file.path(datadir, paste0(freqData, "_Climatology_std.csv"))

				out.climato.index <- gzfile(file.path(outDIR, "Climatology.rds"), compression = 7)

				dataOUT1 <- file.path(outDIR, 'CDTMEAN')
				dir.create(dataOUT1, showWarnings = FALSE, recursive = TRUE)
				index.file.moy <- file.path(dataOUT1, 'CDTMEAN.rds')
				out.cdt.moy <- gzfile(index.file.moy, compression = 7)

				dataOUT2 <- file.path(outDIR, 'CDTSTD')
				dir.create(dataOUT2, showWarnings = FALSE, recursive = TRUE)
				index.file.sds <- file.path(dataOUT2, 'CDTSTD.rds')
				out.cdt.sds <- gzfile(index.file.sds, compression = 7)

				output <- list(params = GeneralParameters,
							data = list(id = don$id, lon = don$lon, lat = don$lat, dates = daty),
							mean.file = index.file.moy, sds.file = index.file.sds)
				EnvAnomalyCalcPlot$output <- output
				EnvAnomalyCalcPlot$PathAnom <- outDIR

				params.clim <- c(GeneralParameters[c("intstep", "data.type", "cdtstation", "cdtdataset", "cdtnetcdf")],
								list(climato = GeneralParameters$climato[c("start", "end", "minyear", "window")],
									out.dir = GeneralParameters$outdir$dir))
				output.clim <- list(params = params.clim,
							data = list(id = don$id, lon = don$lon, lat = don$lat),
							index = index0$id)

				saveRDS(output.clim, out.climato.index)
				close(out.climato.index)
				saveRDS(output, out.dat.index)
				close(out.dat.index)
				saveRDS(dat.moy, out.cdt.moy)
				close(out.cdt.moy)
				saveRDS(dat.sds, out.cdt.sds)
				close(out.cdt.sds)

				##################
				infohead[3, 1] <- "INDEX/LAT"
				dat.moy[is.na(dat.moy)] <- -99
				dat.moy <- rbind(infohead, cbind(index0$id, dat.moy))
				writeFiles(dat.moy, out.cdt.clim.moy)

				dat.sds[is.na(dat.sds)] <- -99
				dat.sds <- rbind(infohead, cbind(index0$id, dat.sds))
				writeFiles(dat.sds, out.cdt.clim.sds)
			}
			rm(dat.moy, dat.sds, output, don, anom)
		}
	}

	#####################################################

	if(GeneralParameters$data.type == "cdtdataset"){
		don <- try(readRDS(GeneralParameters$cdtdataset$index), silent = TRUE)
		if(inherits(don, "try-error")){
			InsertMessagesTxt(main.txt.out, paste("Unable to read", GeneralParameters$cdtdataset$index), format = TRUE)
			return(NULL)
		}
		if(freqData != don$TimeStep){
			InsertMessagesTxt(main.txt.out, paste("The dataset is not a", freqData, "data"), format = TRUE)
			return(NULL)
		}

		daty <- don$dateInfo$date
		year <- as.numeric(substr(daty, 1, 4))

		if(GeneralParameters$outdir$update){
			outDIR <- dirname(GeneralParameters$outdir$dir)
			index.file.moy <- don.anom$mean.file
			index.file.sds <- don.anom$sds.file

			index.file.anomal <- file.path(outDIR, "CDTANOM", "CDTANOM.rds")
			index.out <- try(readRDS(index.file.anomal), silent = TRUE)
			if(inherits(index.out, "try-error")){
				InsertMessagesTxt(main.txt.out, paste("Unable to read", index.file.anomal), format = TRUE)
				return(NULL)
			}

			SP1 <- defSpatialPixels(list(lon = don$coords$mat$x, lat = don$coords$mat$y))
			SP2 <- defSpatialPixels(list(lon = index.out$coords$mat$x, lat = index.out$coords$mat$y))
			if(is.diffSpatialPixelsObj(SP1, SP2, tol = 1e-04)){
				InsertMessagesTxt(main.txt.out, "The dataset & anomaly data have different resolution or bbox", format = TRUE)
				return(NULL)
			}
			rm(SP1, SP2)

			clim.index.file <- file.path(dirname(dirname(index.file.moy)), "Climatology.rds")
			don.climato <- try(readRDS(clim.index.file), silent = TRUE)
			if(inherits(don.climato, "try-error")){
				InsertMessagesTxt(main.txt.out, paste("Unable to read", clim.index.file), format = TRUE)
				return(NULL)
			}

			index0 <- NULL
			index0$id <- don.climato$index
			rm(don.climato)
		}else{
			outDIR <- file.path(GeneralParameters$outdir$dir, "ANOMALIES_data")
			dir.create(outDIR, showWarnings = FALSE, recursive = TRUE)

			if(GeneralParameters$climato$clim.exist){
				index.file.moy <- file.path(dirname(GeneralParameters$climato$clim.file), 'CDTMEAN', 'CDTMEAN.rds')
				index.file.sds <- file.path(dirname(GeneralParameters$climato$clim.file), 'CDTSTD', 'CDTSTD.rds')

				index.data.climato <- try(readRDS(index.file.moy), silent = TRUE)
				if(inherits(index.data.climato, "try-error")){
					InsertMessagesTxt(main.txt.out, paste("Unable to read", index.file.moy), format = TRUE)
					return(NULL)
				}

				SP1 <- defSpatialPixels(list(lon = don$coords$mat$x, lat = don$coords$mat$y))
				SP2 <- defSpatialPixels(list(lon = index.data.climato$coords$mat$x, lat = index.data.climato$coords$mat$y))
				if(is.diffSpatialPixelsObj(SP1, SP2, tol = 1e-04)){
					InsertMessagesTxt(main.txt.out, "The dataset & climatology have different resolution or bbox", format = TRUE)
					return(NULL)
				}
				rm(SP1, SP2)

				index0 <- NULL
				index0$id <- don.climato$index
				rm(index.data.climato)
			}else{
				if(length(unique(year)) < minyear){
					InsertMessagesTxt(main.txt.out, "No enough data to calculate climatologies", format = TRUE)
					return(NULL)
				}

				iyear <- year >= year1 & year <= year2
				daty0 <- daty[iyear]
				index0 <- getClimatologiesIndex(daty0, freqData, xwin)

				div <- if(freqData == "daily") 2*xwin+1 else 1
				Tstep.miss <- (sapply(index0$index, length)/div) < minyear

				##################
				out.climato.index <- gzfile(file.path(outDIR, "Climatology.rds"), compression = 7)

				ncdfOUT1 <- file.path(outDIR, 'DATA_NetCDF', 'CDTMEAN')
				dir.create(ncdfOUT1, showWarnings = FALSE, recursive = TRUE)
				ncdfOUT2 <- file.path(outDIR, 'DATA_NetCDF', 'CDTSTD')
				dir.create(ncdfOUT2, showWarnings = FALSE, recursive = TRUE)

				datadir1 <- file.path(outDIR, 'CDTMEAN', 'DATA')
				dir.create(datadir1, showWarnings = FALSE, recursive = TRUE)
				index.file.moy <- file.path(outDIR, 'CDTMEAN', 'CDTMEAN.rds')
				datadir2 <- file.path(outDIR, 'CDTSTD', 'DATA')
				dir.create(datadir2, showWarnings = FALSE, recursive = TRUE)
				index.file.sds <- file.path(outDIR, 'CDTSTD', 'CDTSTD.rds')

				##################

				params.clim <- c(GeneralParameters[c("intstep", "data.type", "cdtstation", "cdtdataset", "cdtnetcdf")],
								list(climato = GeneralParameters$climato[c("start", "end", "minyear", "window")],
									out.dir = GeneralParameters$outdir$dir))
				output.clim <- list(params = params.clim, index = index0$id)

				saveRDS(output.clim, out.climato.index)
				close(out.climato.index)

				##################

				index.out.clim <- don
				index.out.clim$varInfo$longname <- paste(freqData, "climatology from:", don$varInfo$longname)

				index.out.clim$dateInfo$date <- index0$id
				index.out.clim$dateInfo$index <- seq_along(index0$id)

				index.file.moy.gz <- gzfile(index.file.moy, compression = 7)
				saveRDS(index.out.clim, index.file.moy.gz)
				close(index.file.moy.gz)

				index.file.sds.gz <- gzfile(index.file.sds, compression = 7)
				saveRDS(index.out.clim, index.file.sds.gz)
				close(index.file.sds.gz)

				#########################################

				chunkfile <- sort(unique(don$colInfo$index))
				chunkcalc <- split(chunkfile, ceiling(chunkfile/don$chunkfac))

				do.parChunk <- if(don$chunkfac > length(chunkcalc)) TRUE else FALSE
				do.parCALC <- if(do.parChunk) FALSE else TRUE

				toExports <- c("readCdtDatasetChunk.sequence", "writeCdtDatasetChunk.sequence", "doparallel")
				packages <- c("doParallel")

				is.parallel <- doparallel(do.parCALC & (length(chunkcalc) > 10))
				`%parLoop%` <- is.parallel$dofun
				ret <- foreach(jj = seq_along(chunkcalc), .export = toExports, .packages = packages) %parLoop% {
					don.data <- readCdtDatasetChunk.sequence(chunkcalc[[jj]], GeneralParameters$cdtdataset$index, do.par = do.parChunk)
					don.data <- don.data[don$dateInfo$index, , drop = FALSE]
					don.data <- don.data[iyear, , drop = FALSE]

					dat.clim <- lapply(seq_along(index0$id), function(j){
						if(Tstep.miss[jj]){
							tmp <- rep(NA, ncol(don.data))
							 return(list(moy = tmp, sds = tmp))
						}

						xx <- don.data[index0$index[[j]], , drop = FALSE]
						ina <- (colSums(!is.na(xx))/div) <  minyear
						moy <- colMeans(xx, na.rm = TRUE)
						sds <- matrixStats::colSds(xx, na.rm = TRUE)
						moy[ina] <- NA
						sds[ina] <- NA
						rm(xx)
						list(moy = moy, sds = sds)
					})

					dat.moy <- do.call(rbind, lapply(dat.clim, "[[", "moy"))
					dat.sds <- do.call(rbind, lapply(dat.clim, "[[", "sds"))

					writeCdtDatasetChunk.sequence(dat.moy, chunkcalc[[jj]], index.out.clim, datadir1, do.par = do.parChunk)
					writeCdtDatasetChunk.sequence(dat.sds, chunkcalc[[jj]], index.out.clim, datadir2, do.par = do.parChunk)
					rm(dat.clim, dat.moy, dat.sds, don.data); gc()
				}
				if(is.parallel$stop) stopCluster(is.parallel$cluster)

				##########################################

				x <- index.out.clim$coords$mat$x
				y <- index.out.clim$coords$mat$y
				dx <- ncdim_def("Lon", "degreeE", x)
				dy <- ncdim_def("Lat", "degreeN", y)
				xy.dim <- list(dx, dy)
				nc.grd <- ncvar_def(index.out.clim$varInfo$name, index.out.clim$varInfo$units, xy.dim, -99,
									index.out.clim$varInfo$longname, "float", compression = 9)

				######################
				ret <- lapply(index0$id, function(id){
					dat.moy <- readCdtDatasetChunk.multi.dates.order(index.file.moy, id, onedate = TRUE)
					dat.moy <- dat.moy$z
					dat.moy[is.na(dat.moy)] <- -99
					filenc <- file.path(ncdfOUT1, paste0("clim_", id, ".nc"))
					nc <- nc_create(filenc, nc.grd)
					ncvar_put(nc, nc.grd, dat.moy)
					nc_close(nc)

					dat.sds <- readCdtDatasetChunk.multi.dates.order(index.file.sds, id, onedate = TRUE)
					dat.sds <- dat.sds$z
					dat.sds[is.na(dat.sds)] <- -99
					filenc <- file.path(ncdfOUT2, paste0("clim_", id, ".nc"))
					nc <- nc_create(filenc, nc.grd)
					ncvar_put(nc, nc.grd, dat.sds)
					nc_close(nc)

					return(0)
				})
			}
		}

		### anom
		daty0 <- if(freqData == "monthly") as.Date(paste0(daty, 15), "%Y%m%d") else as.Date(daty, "%Y%m%d")

		if(freqData == "daily"){
			start.daty <- as.Date(paste(start.year, start.mon, start.dek, sep = "-"))
			end.daty <- as.Date(paste(end.year, end.mon, end.dek, sep = "-"))
		}

		if(freqData == "pentad"){
			start.daty <- as.Date(paste(start.year, start.mon, start.dek, sep = "-"))
			end.daty <- as.Date(paste(end.year, end.mon, end.dek, sep = "-"))
		}
		if(freqData == "dekadal"){
			start.daty <- as.Date(paste(start.year, start.mon, start.dek, sep = "-"))
			end.daty <- as.Date(paste(end.year, end.mon, end.dek, sep = "-"))
		}
		if(freqData == "monthly"){
			start.daty <- as.Date(paste(start.year, start.mon, 15, sep = "-"))
			end.daty <- as.Date(paste(end.year, end.mon, 15, sep = "-"))
		}

		iyear <- daty0 >= start.daty & daty0 <= end.daty
		daty <- daty[iyear]
		if(length(daty) == 0){
			InsertMessagesTxt(main.txt.out, "No data to compute anomaly", format = TRUE)
			return(NULL)
		}
		rm(daty0)

		########
		index <- getClimatologiesIndex(daty, freqData, 0)
		ixx <- match(index0$id, index$id)
		ixx <- ixx[!is.na(ixx)]
		index$id <- index$id[ixx]
		index$index <- index$index[ixx]

		index1 <- lapply(seq_along(index$id), function(j){
			cbind(index$id[j], index$index[[j]])
		})

		index1 <- do.call(rbind, index1)
		index1 <- index1[order(index1[, 2]), ]
		daty <- daty[index1[, 2]]

		##################

		ncdfOUT3 <- file.path(outDIR, 'DATA_NetCDF', 'CDTANOM')
		datadir3 <- file.path(outDIR, 'CDTANOM', 'DATA')
		index.file.anomal <- file.path(outDIR, 'CDTANOM', 'CDTANOM.rds')

		if(GeneralParameters$outdir$update){
			anomaly.fonct <- don.anom$params$anomaly
			out.anom.index <- gzfile(GeneralParameters$outdir$dir, compression = 7)

			ixold <- match(daty, don.anom$dates)
			ixold <- ixold[!is.na(ixold)]

			if(length(ixold) == 0){
				newdaty <- c(index.out$dateInfo$date, daty)
				newindex <- c(index.out$dateInfo$index, max(index.out$dateInfo$index) + seq_along(daty))
			}else{
				newdaty <- c(index.out$dateInfo$date[-ixold], daty)
				newindex <- c(index.out$dateInfo$index[-ixold], max(index.out$dateInfo$index[-ixold]) + seq_along(daty))
			}

			##########
			index.out$dateInfo$date <- newdaty
			index.out$dateInfo$index <- newindex
			saveRDS(index.out, index.file.anomal)

			don.anom$dates <- newdaty
			saveRDS(don.anom, out.anom.index)
			close(out.anom.index)

			EnvAnomalyCalcPlot$output <- don.anom
			EnvAnomalyCalcPlot$PathAnom <- outDIR
		}else{
			anomaly.fonct <- GeneralParameters$anomaly
			out.anom.index <- gzfile(file.path(outDIR, "Anomaly.rds"), compression = 7)

			dir.create(ncdfOUT3, showWarnings = FALSE, recursive = TRUE)
			dir.create(datadir3, showWarnings = FALSE, recursive = TRUE)

			index.out <- don
			index.out$varInfo$longname <- paste(freqData, "anomaly from:", don$varInfo$longname)
			index.out$dateInfo$date <- daty
			index.out$dateInfo$index <- seq_along(daty)

			##########
			saveRDS(index.out, index.file.anomal)

			output <- list(params = GeneralParameters, dates = daty, mean.file = index.file.moy, sds.file = index.file.sds)
			saveRDS(output, out.anom.index)
			close(out.anom.index)

			EnvAnomalyCalcPlot$output <- output
			EnvAnomalyCalcPlot$PathAnom <- outDIR
		}

		#########################################

		chunkfile <- sort(unique(don$colInfo$index))
		chunkcalc <- split(chunkfile, ceiling(chunkfile/don$chunkfac))

		do.parChunk <- if(don$chunkfac > length(chunkcalc)) TRUE else FALSE
		do.parCALC <- if(do.parChunk) FALSE else TRUE

		toExports <- c("readCdtDatasetChunk.sequence", "writeCdtDatasetChunk.sequence", "doparallel")
		packages <- c("doParallel")

		is.parallel <- doparallel(do.parCALC & (length(chunkcalc) > 10))
		`%parLoop%` <- is.parallel$dofun
		ret <- foreach(jj = seq_along(chunkcalc), .export = toExports, .packages = packages) %parLoop% {
			don.data <- readCdtDatasetChunk.sequence(chunkcalc[[jj]], GeneralParameters$cdtdataset$index, do.par = do.parChunk)
			don.data <- don.data[don$dateInfo$index, , drop = FALSE]
			don.data <- don.data[iyear, , drop = FALSE]

			dat.moy <- readCdtDatasetChunk.sequence(chunkcalc[[jj]], index.file.moy, do.par = do.parChunk)

			if(anomaly.fonct == "Difference"){
				anom <- don.data[index1[, 2], , drop = FALSE] - dat.moy[index1[, 1], , drop = FALSE]
			}

			if(anomaly.fonct == "Percentage"){
				anom <- 100 * (don.data[index1[, 2], , drop = FALSE] - dat.moy[index1[, 1], , drop = FALSE]) / (dat.moy[index1[, 1], , drop = FALSE]+0.001)
			}

			if(anomaly.fonct == "Standardized"){
				dat.sds <- readCdtDatasetChunk.sequence(chunkcalc[[jj]], index.file.sds, do.par = do.parChunk)
				anom <- (don.data[index1[, 2], , drop = FALSE] - dat.moy[index1[, 1], , drop = FALSE]) / dat.sds[index1[, 1], , drop = FALSE]
			}

			if(GeneralParameters$outdir$update){
				dat.anom <- readCdtDatasetChunk.sequence(chunkcalc[[jj]], index.file.anomal, do.par = do.parChunk)
				if(length(ixold) == 0){
					anom <- rbind(dat.anom, anom)
				}else{
					anom <- rbind(dat.anom[-ixold, , drop = FALSE], anom)
				}
				rm(dat.anom)
			}
			writeCdtDatasetChunk.sequence(anom, chunkcalc[[jj]], index.out, datadir3, do.par = do.parChunk)

			rm(don.data, dat.moy, dat.sds, anom); gc()
		}
		if(is.parallel$stop) stopCluster(is.parallel$cluster)

		##########################################

		x <- index.out$coords$mat$x
		y <- index.out$coords$mat$y
		nx <- length(x)
		ny <- length(y)
		dx <- ncdim_def("Lon", "degreeE", x)
		dy <- ncdim_def("Lat", "degreeN", y)
		xy.dim <- list(dx, dy)
		if(anomaly.fonct == "Difference") units <- index.out$varInfo$units
		if(anomaly.fonct == "Percentage") units <- "percentage"
		if(anomaly.fonct == "Standardized") units <- ""
		nc.grd <- ncvar_def("anom", units, xy.dim, -9999, index.out$varInfo$longname, "float", compression = 9)

		######################

		chunkfile <- sort(unique(don$colInfo$index))
		datyread <- split(daty, ceiling(seq_along(daty)/50))

		do.parChunk <- if(length(chunkfile) > length(datyread)) TRUE else FALSE
		do.parCALC <- if(do.parChunk) FALSE else TRUE

		toExports <- c("readCdtDatasetChunk.multi.dates.order", "doparallel")
		packages <- c("doParallel", "ncdf4")

		is.parallel <- doparallel(do.parCALC & (length(datyread) > 50))
		`%parLoop%` <- is.parallel$dofun
		ret <- foreach(jj = seq_along(datyread), .export = toExports, .packages = packages) %parLoop% {
			daty0 <- datyread[[jj]]
			dat.anom <- readCdtDatasetChunk.multi.dates.order(index.file.anomal, daty0, do.par = do.parChunk)

			for(j in seq_along(daty0)){
				anom <- dat.anom[j, ]
				dim(anom) <- c(nx, ny)
				anom[is.na(anom) | is.nan(anom) | is.infinite(anom)] <- -9999

				filenc <- file.path(ncdfOUT3, paste0("anomaly_", daty0[j], ".nc"))
				nc <- nc_create(filenc, nc.grd)
				ncvar_put(nc, nc.grd, anom)
				nc_close(nc)
			}
			rm(daty0, dat.anom, anom); gc()
			return(0)
		}
		if(is.parallel$stop) stopCluster(is.parallel$cluster)

		rm(don, index, index1, index.out)
	}

	return(0)
}