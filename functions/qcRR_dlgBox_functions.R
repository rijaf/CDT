qc.get.info.rain <- function(parent.win, GeneralParameters){
	listOpenFiles <- openFile_ttkcomboList()
	if (Sys.info()["sysname"] == "Windows"){
		largeur <- 47
		largeur1 <- 44
		largeur2 <- 25
		spady <- 0
	}else{
		largeur <- 30
		largeur1 <- 29
		largeur2 <- 18
		spady <- 1
	}

	################################
	
	tt <- tktoplevel()
	tkgrab.set(tt)
	tkfocus(tt)

	frDialog <- tkframe(tt, relief = 'raised', borderwidth = 2)
	frButt <- tkframe(tt)

	frLeft <- tkframe(frDialog, relief = "groove", borderwidth = 2)

	################################

	frIO <- tkframe(frLeft, relief = 'sunken', borderwidth = 2)

	file.period <- tclVar()
	cb.periodVAL <- c('Daily data', 'Dekadal data', 'Monthly data')
	tclvalue(file.period) <- switch(GeneralParameters$period, 
									'daily' = cb.periodVAL[1], 
									'dekadal' = cb.periodVAL[2],
									'monthly' = cb.periodVAL[3])
	file.choix1 <- tclVar(GeneralParameters$IO.files$STN.file)

	############

	cb.period <- ttkcombobox(frIO, values = cb.periodVAL, textvariable = file.period, width = largeur2)
	txt.file.stn <- tklabel(frIO, text = 'Input data to control', anchor = 'w', justify = 'left')
	cb.file.stn <- ttkcombobox(frIO, values = unlist(listOpenFiles), textvariable = file.choix1, width = largeur1)
	bt.file.stn <- tkbutton(frIO, text = "...") 

	####
	tkconfigure(bt.file.stn, command = function(){
		dat.opfiles <- getOpenFiles(parent.win, all.opfiles)
		if(!is.null(dat.opfiles)){
			nopf <- length(AllOpenFilesType)
			AllOpenFilesType[[nopf+1]] <<- 'ascii'
			AllOpenFilesData[[nopf+1]] <<- dat.opfiles

			listOpenFiles[[length(listOpenFiles)+1]] <<- AllOpenFilesData[[nopf+1]][[1]] 
			tclvalue(file.choix1) <- AllOpenFilesData[[nopf+1]][[1]]
			tkconfigure(cb.file.stn, values = unlist(listOpenFiles), textvariable = file.choix1)
			tkconfigure(cb.file.elv, values = unlist(listOpenFiles), textvariable = file.choix2)
		}else{
			return(NULL)
		}
	})

	####

	tkgrid(cb.period, row = 0, column = 0, sticky = '', rowspan = 1, columnspan = 1, padx = 0, pady = 5, ipadx = 1, ipady = 1)
	tkgrid(txt.file.stn, row = 1, column = 0, sticky = 'we', rowspan = 1, columnspan = 2, padx = 1, pady = 1, ipadx = 1, ipady = 1)
	tkgrid(cb.file.stn, row = 2, column = 0, sticky = 'we', rowspan = 1, columnspan = 1, padx = 0, pady = 1, ipadx = 1, ipady = 1)
	tkgrid(bt.file.stn, row = 2, column = 1, sticky = 'w', rowspan = 1, columnspan = 1, padx = 0, pady = 1, ipadx = 1, ipady = 1)

	infobulle(cb.period, 'Choose the time step of the data')
	status.bar.display(cb.period, TextOutputVar, 'Choose the time step of the data')
	infobulle(cb.file.stn, 'Choose the file in the list')
	status.bar.display(cb.file.stn, TextOutputVar, 'Choose the file containing the data to control')
	infobulle(bt.file.stn, 'Browse file if not listed')
	status.bar.display(bt.file.stn, TextOutputVar, 'Browse file if not listed')

	##################

	frELV <- tkframe(frLeft, relief = 'sunken', borderwidth = 2)

	file.choix2 <- tclVar(GeneralParameters$IO.files$DEM.file)
	cb.1uselv.val <- tclVar(GeneralParameters$dem$use.elv)
	uselv.ch <- tclVar(GeneralParameters$dem$interp.dem)

	if(!GeneralParameters$stn.type$single.series & !GeneralParameters$dem$use.elv){
		state <- c('disabled', 'normal', 'disabled')
	}else if(GeneralParameters$stn.type$single.series){
		state <- c('disabled', 'normal', 'disabled')
	}else if(GeneralParameters$dem$use.elv){
		state <- if(GeneralParameters$dem$interp.dem == '0') c('normal', 'normal', 'normal') else c('disabled', 'normal', 'normal')
	}

	cb.1uselv <- tkcheckbutton(frELV, variable = cb.1uselv.val, text = 'Use Elevation', anchor = 'w', justify = 'left', state = state[2])
	cb.1intelv <- tkradiobutton(frELV, text = "Elevation from DEM", anchor = 'w', justify = 'left', state = state[3])
	cb.1datelv <- tkradiobutton(frELV, text = "Elevation from STN data", anchor = 'w', justify = 'left', state = state[3])
	tkconfigure(cb.1intelv, variable = uselv.ch, value = "0")
	tkconfigure(cb.1datelv, variable = uselv.ch, value = "1")

	txt.file.elv <- tklabel(frELV, text = 'Elevation Data (NetCDF)', anchor = 'w', justify = 'left')
	cb.file.elv <- ttkcombobox(frELV, values = unlist(listOpenFiles), textvariable = file.choix2, width = largeur1, state = state[1])
	bt.file.elv <- tkbutton(frELV, text = "...", state = state[1]) 

	#####
	tkconfigure(bt.file.elv, command = function(){
		nc.opfiles <- getOpenNetcdf(parent.win, all.opfiles)
		if(!is.null(nc.opfiles)){
			nopf <- length(AllOpenFilesType)
			AllOpenFilesType[[nopf+1]] <<- 'netcdf'
			AllOpenFilesData[[nopf+1]] <<- nc.opfiles
			tclvalue(file.choix2) <- AllOpenFilesData[[nopf+1]][[1]]

			listOpenFiles[[length(listOpenFiles)+1]] <<- AllOpenFilesData[[nopf+1]][[1]]
			tclvalue(file.choix2) <- AllOpenFilesData[[nopf+1]][[1]]
			tkconfigure(cb.file.elv, values = unlist(listOpenFiles), textvariable = file.choix2)
			tkconfigure(cb.file.stn, values = unlist(listOpenFiles), textvariable = file.choix1)
		}else{
			return(NULL)
		}
	})

	#####

	tkgrid(cb.1uselv, row = 0, column = 0, sticky = 'we', rowspan = 1, columnspan = 2, padx = 1, ipadx = 1, pady = spady)
	tkgrid(cb.1datelv, row = 1, column = 0, sticky = 'we', rowspan = 1, columnspan = 2, padx = 1, ipadx = 1, pady = spady)
	tkgrid(cb.1intelv, row = 2, column = 0, sticky = 'we', rowspan = 1, columnspan = 2, padx = 1, ipadx = 1, pady = spady)
	tkgrid(txt.file.elv, row = 3, column = 0, sticky = 'we', rowspan = 1, columnspan = 2, padx = 1, pady = 1, ipadx = 1, ipady = 1)
	tkgrid(cb.file.elv, row = 4, column = 0, sticky = 'we', rowspan = 1, columnspan = 1, padx = 0, pady = 1, ipadx = 1, ipady = 1)
	tkgrid(bt.file.elv, row = 4, column = 1, sticky = 'w', rowspan = 1, columnspan = 1, padx = 0, pady = 1, ipadx = 1, ipady = 1)

	infobulle(cb.file.elv, 'Choose the file in the list')
	status.bar.display(cb.file.elv, TextOutputVar, 'Choose the file containing the elevation data')
	infobulle(bt.file.elv, 'Browse file if not listed')
	status.bar.display(bt.file.elv, TextOutputVar, 'Browse file if not listed')
	infobulle(cb.1uselv, 'Check this box if you want to use elevation data to choose neighbors stations')
	status.bar.display(cb.1uselv, TextOutputVar, 'Check this box if you want to use elevation data to choose neighbors stations')
	infobulle(cb.1intelv, 'Tick this box if the elevation data will be extracted from DEM')
	status.bar.display(cb.1intelv, TextOutputVar, 'Tick this box if the elevation data will be extracted from DEM')
	infobulle(cb.1datelv, 'Tick this box if the elevation data from CDT station data')
	status.bar.display(cb.1datelv, TextOutputVar, 'Tick this box if the elevation data from CDT station data')

	####
	tkbind(cb.1uselv, "<Button-1>", function(){
		if(tclvalue(cb.1uselv.val) == "0"){
			state1 <- if(tclvalue(uselv.ch) == "0") 'normal' else 'disabled'
			tkconfigure(cb.file.elv, state = state1)
			tkconfigure(bt.file.elv, state = state1)
			tkconfigure(cb.1uselv, state = 'normal')
			tkconfigure(cb.1intelv, state = 'normal')
			tkconfigure(cb.1datelv, state = 'normal')
		}else{
			tkconfigure(cb.file.elv, state = 'disabled')
			tkconfigure(bt.file.elv, state = 'disabled')
			tkconfigure(cb.1uselv, state = 'normal')
			tkconfigure(cb.1intelv, state = 'disabled')
			tkconfigure(cb.1datelv, state = 'disabled')
		}
	})

	####
	tkbind(cb.1intelv, "<Button-1>", function(){
		if(tclvalue(cb.1uselv.val) == "1"){
			tkconfigure(cb.file.elv, state = 'normal')
			tkconfigure(bt.file.elv, state = 'normal')
		}
	})

	tkbind(cb.1datelv, "<Button-1>", function(){
		if(tclvalue(cb.1uselv.val) == "1"){
			tkconfigure(cb.file.elv, state = 'disabled')
			tkconfigure(bt.file.elv, state = 'disabled')
		}
	})

	##################

	frSave <- tkframe(frLeft, relief = 'sunken', borderwidth = 2)

	file.save1 <- tclVar(GeneralParameters$IO.files$dir2save)

	txt.file.save <- tklabel(frSave, text = 'Directory to save result', anchor = 'w', justify = 'left')
	en.file.save <- tkentry(frSave, textvariable = file.save1, width = largeur) 
	bt.file.save <- tkbutton(frSave, text = "...")

	####
	tkconfigure(bt.file.save, command = function(){
		file2save1 <- tk_choose.dir(str_trim(GeneralParameters$IO.files$dir2save), "")
		if(!file.exists(file2save1)){
			tkmessageBox(message = paste(file2save1, 'does not exist. It will be created.'), icon = "warning", type = "ok")
			dir.create(file2save1, recursive = TRUE)
			tclvalue(file.save1) <- file2save1
		}else tclvalue(file.save1) <- file2save1
	})

	####
	tkgrid(txt.file.save, row = 0, column = 0, sticky = 'we', rowspan = 1, columnspan = 2, padx = 1, pady = 1, ipadx = 1, ipady = 1)
	tkgrid(en.file.save, row = 1, column = 0, sticky = 'we', rowspan = 1, columnspan = 1, padx = 0, pady = 1, ipadx = 1, ipady = 1)
	tkgrid(bt.file.save, row = 1, column = 1, sticky = 'w', rowspan = 1, columnspan = 1, padx = 0, pady = 1, ipadx = 1, ipady = 1)

	infobulle(en.file.save, 'Enter the full path to directory to save result')
	status.bar.display(en.file.save, TextOutputVar, 'Enter the full path to directory to save result')
	infobulle(bt.file.save, 'or browse here')

	##################

	frSetOpt <- tkframe(frLeft, relief = 'sunken', borderwidth = 2)

	bt.opt.set <- ttkbutton(frSetOpt, text = "Options - Settings")

	####
	tkconfigure(bt.opt.set, command = function(){
		GeneralParameters <<- get.param.rainfall(tt, GeneralParameters)
	})

	####
	tkgrid(bt.opt.set, sticky = 'we', padx = 10, pady = 1, ipadx = 1, ipady = 1)

	infobulle(bt.opt.set, 'Set general options for QC')
	status.bar.display(bt.opt.set, TextOutputVar, 'Set general options for QC')

	############################################
	tkgrid(frIO, row = 0, column = 0, sticky = 'we', padx = 1, pady = 1, ipadx = 1, ipady = 1)
	tkgrid(frELV, row = 1, column = 0, sticky = 'we', padx = 1, pady = 1, ipadx = 1, ipady = 1)
	tkgrid(frSave, row = 2, column = 0, sticky = 'we', padx = 1, pady = 1, ipadx = 1, ipady = 1)
	tkgrid(frSetOpt, row = 3, column = 0, padx = 1, pady = 1, ipadx = 1, ipady = 1)

	############################################

	tkgrid(frLeft, row = 0, column = 0, sticky = 'news', padx = 5, pady = 1, ipadx = 1, ipady = 1)

	###################################################

	bt.opt.OK <- tkbutton(frButt, text = "OK")
	bt.opt.CA <- tkbutton(frButt, text = "Cancel")

	tkconfigure(bt.opt.OK, command = function(){
		if(tclvalue(file.choix1) == ""){
			tkmessageBox(message = "Choose the file to control", icon = "warning", type = "ok")
		}else if(tclvalue(cb.1uselv.val) == "1" & tclvalue(uselv.ch) == "0" & tclvalue(file.choix2) == ""){
			tkmessageBox(message = "You have to choose DEM data in NetCDF format if you want to extract elevation from DEM",
						icon = "warning", type = "ok")
			tkwait.window(tt)
		}else if(tclvalue(file.save1) == "" | tclvalue(file.save1) == "NA"){
			tkmessageBox(message = "Choose a directory to save results", icon = "warning", type = "ok")
			tkwait.window(tt)
		}else{
			donne <- getStnOpenData(file.choix1)
			if(is.null(donne)){
				tkmessageBox(message = "Station data not found or in the wrong format", icon = "warning", type = "ok")
				tkwait.window(tt)
			}
			infoDonne <- getStnOpenDataInfo(file.choix1)[2:3]

			##
			dirQcRain <- file.path(tclvalue(file.save1), paste('QcRainfall', getf.no.ext(tclvalue(file.choix1)), sep = '_'))
			dirparams <- file.path(dirQcRain, 'OriginalData')
			if(!file.exists(dirparams)) dir.create(dirparams, showWarnings = FALSE, recursive = TRUE)
			fileparams <- file.path(dirparams, 'Parameters.RData')
			
			GeneralParameters$period <<- switch(tclvalue(file.period), 
			 									'Daily data' = 'daily',
												'Dekadal data' = 'dekadal',
												'Monthly data' = 'monthly')
			GeneralParameters$IO.files$STN.file <<- str_trim(tclvalue(file.choix1))
			GeneralParameters$IO.files$DEM.file <<- str_trim(tclvalue(file.choix2))
			GeneralParameters$IO.files$dir2save <<- str_trim(tclvalue(file.save1))

			GeneralParameters$dem$use.elv <<- switch(tclvalue(cb.1uselv.val), '0' = FALSE, '1' = TRUE)
			GeneralParameters$dem$interp.dem <<- tclvalue(uselv.ch)

			######
			getInitDataParams <- function(GeneralParameters){
				donstn <- getCDTdataAndDisplayMsg(donne, GeneralParameters$period)

				xycrds <- NULL
				if(!is.null(donstn)){
					limControl <- data.frame(donstn$id, GeneralParameters$limits$Upper.Bounds, donstn$lon, donstn$lat)
					names(limControl) <- c('Station.ID', 'Upper.Bounds', 'Lon', 'Lat')
					GeneralParameters$stnInfo <- limControl
					# GeneralParameters$stnInfo <- getRainInitParams0(donstn, GeneralParameters$period)
					lchoixStnFr$env$stn.choix <- as.character(donstn$id)
					xycrds <- paste(c(as.character(donstn$lon), as.character(donstn$lat)), sep = '', collapse = ' ')
				}else tkwait.window(tt)

				paramsGAL <- list(inputPars = GeneralParameters, dataPars = infoDonne, data = donstn)
				save(paramsGAL, file = fileparams)
				return(list(paramsGAL, lchoixStnFr$env$stn.choix, xycrds))
			}

			######
			if(file.exists(fileparams)){
				load(fileparams)
				if(paramsGAL$inputPars$period == GeneralParameters$period & all(infoDonne %in% paramsGAL$dataPars)){
					donstn <- paramsGAL$data
					GeneralParameters$stnInfo <<- paramsGAL$inputPars$stnInfo
					lchoixStnFr$env$stn.choix <<- as.character(GeneralParameters$stnInfo$Station.ID)
					tclvalue(XYCoordinates) <<- paste(c(GeneralParameters$stnInfo$Lon, GeneralParameters$stnInfo$Lat), sep = '', collapse = ' ')
					rm(paramsGAL)
				}else{
					retDonPar <- getInitDataParams(GeneralParameters)
					donstn <- retDonPar[[1]]$data
					GeneralParameters <<- retDonPar[[1]]$inputPars
					lchoixStnFr$env$stn.choix <<- retDonPar[[2]]
					tclvalue(XYCoordinates) <<- retDonPar[[3]]
					rm(retDonPar)
				}
			}else{
				retDonPar <- getInitDataParams(GeneralParameters)
				donstn <- retDonPar[[1]]$data
				GeneralParameters <<- retDonPar[[1]]$inputPars
				lchoixStnFr$env$stn.choix <<- retDonPar[[2]]
				tclvalue(XYCoordinates) <<- retDonPar[[3]]
				rm(retDonPar)
			}
			assign('donnees', donstn, envir = EnvQcOutlierData)
			assign('baseDir', dirQcRain, envir = EnvQcOutlierData)

			##################
			##set choix stn

			if(GeneralParameters$retpar == 0){
				ik <- if(lchoixStnFr$env$stn.choix[1] != '') 1 else 2
				tclvalue(lchoixStnFr$env$stn.choix.val) <- lchoixStnFr$env$stn.choix[ik]
			}else{
				istn <- as.numeric(tclvalue(tcl(lchoixStnFr$env$stn.choix.cb, "current")))+1
				istn <- if(istn > 0) istn else 1
				tclvalue(lchoixStnFr$env$stn.choix.val) <- lchoixStnFr$env$stn.choix[istn]
			}

			tkconfigure(lchoixStnFr$env$stn.choix.cb, values = lchoixStnFr$env$stn.choix, textvariable = lchoixStnFr$env$stn.choix.val)
			if(GeneralParameters$AllOrOne == 'one'){
				tkconfigure(lchoixStnFr$env$setting.button, state = 'normal')
				stateReplaceAll <- 'disabled'
			}
			if(GeneralParameters$AllOrOne == 'all'){
				tkconfigure(lchoixStnFr$env$setting.button, state = 'disabled')
				stateReplaceAll <- 'normal'
			}
			tkconfigure(lchoixStnFr$env$stn.choix.prev, state = 'normal')
			tkconfigure(lchoixStnFr$env$stn.choix.next, state = 'normal')
			tkconfigure(spinH, state = 'normal')
			tkconfigure(spinV, state = 'normal')

			####button command
			if(is.null(lcmd.frame_qc)){
				lcmd.frame <<- QcCmdBut(stateReplaceAll)
				lcmd.frame_qc <<- 1
			}
			GeneralParameters$retpar <<- GeneralParameters$retpar+1
			######
			tkgrab.release(tt)
			tkdestroy(tt)
			tkfocus(parent.win)
		}
	})

	tkconfigure(bt.opt.CA, command = function(){
		tkgrab.release(tt)
		tkdestroy(tt)
		tkfocus(parent.win)
	})

	tkgrid(bt.opt.OK, row = 0, column = 0, sticky = 'w', padx = 5, pady = 1, ipadx = 10, ipady = 1)
	tkgrid(bt.opt.CA, row = 0, column = 1, sticky = 'e', padx = 5, pady = 1, ipadx = 1, ipady = 1)

	###############################################################	

	tkgrid(frDialog, row = 0, column = 0, sticky = 'nswe', rowspan = 1, columnspan = 2, padx = 1, pady = 1, ipadx = 1, ipady = 1)
	tkgrid(frButt, row = 1, column = 1, sticky = 'se', rowspan = 1, columnspan = 1, padx = 1, pady = 1, ipadx = 1, ipady = 1)

	tkwm.withdraw(tt)
	tcl('update')
	tt.w <- as.integer(tkwinfo("reqwidth", tt))
	tt.h <- as.integer(tkwinfo("reqheight", tt))
	tt.x <- as.integer(width.scr*0.5-tt.w*0.5)
	tt.y <- as.integer(height.scr*0.5-tt.h*0.5)
	tkwm.geometry(tt, paste0('+', tt.x, '+', tt.y))
	tkwm.transient(tt)
	tkwm.title(tt, 'Quality Control - Settings')
	tkwm.deiconify(tt)

	tkfocus(tt)
	tkbind(tt, "<Destroy>", function() {tkgrab.release(tt); tkfocus(parent.win)})
	tkwait.window(tt)
	return(GeneralParameters)
}

################################################################################################################################
##Edit parameter rainfall

get.param.rainfall <- function(tt, GeneralParameters){
	tt1 <- tktoplevel()
	tkgrab.set(tt1)
	tkfocus(tt1)

	frDialog <- tkframe(tt1, relief = 'raised', borderwidth = 2)
	frButt <- tkframe(tt1)

	##################
	frOpt <- tkframe(frDialog, relief = "sunken", borderwidth = 2)

	min.stn <- tclVar(GeneralParameters$select.pars$min.stn)
	CInt <- tclVar(GeneralParameters$select.pars$conf.lev)
	max.dist <- tclVar(GeneralParameters$select.pars$max.dist)
	elv.diff <- tclVar(GeneralParameters$select.pars$elv.diff)
	limSup <- tclVar(GeneralParameters$limits$Upper.Bounds)

	min.stn.l <- tklabel(frOpt, text = 'Min.stn', anchor = 'e', justify = 'right')
	max.dist.l <- tklabel(frOpt, text = 'Max.dist(km)', anchor = 'e', justify = 'right')
	elv.diff.l <- tklabel(frOpt, text = 'Elv.diff(m)', anchor = 'e', justify = 'right')
	CInt.l <- tklabel(frOpt, text = 'Conf.lev(%)', anchor = 'e', justify = 'right')
	max.precip.l <- tklabel(frOpt, text = 'Precip.max', anchor = 'e', justify = 'right')

	min.stn.v <- tkentry(frOpt, width = 5, textvariable = min.stn)
	max.dist.v <- tkentry(frOpt, width = 5, textvariable = max.dist)
	elv.diff.v <- tkentry(frOpt, width = 8, textvariable = elv.diff)
	CInt.v <- tkentry(frOpt, width = 8, textvariable = CInt)
	max.precip.v <- tkentry(frOpt, width = 8, textvariable = limSup)

	tkgrid(min.stn.l, row = 0, column = 0, sticky = 'ew', padx = 1, pady = 1)
	tkgrid(min.stn.v, row = 0, column = 1, sticky = 'ew', padx = 1, pady = 1)
	tkgrid(CInt.l, row = 0, column = 2, sticky = 'ew', padx = 1, pady = 1)
	tkgrid(CInt.v, row = 0, column = 3, sticky = 'ew', padx = 1, pady = 1)
	tkgrid(max.dist.l, row = 1, column = 0, sticky = 'ew', padx = 1, pady = 1)
	tkgrid(max.dist.v, row = 1, column = 1, sticky = 'ew', padx = 1, pady = 1)

	tkgrid(max.precip.l, row = 1, column = 2, sticky = 'ew', padx = 1, pady = 1)
	tkgrid(max.precip.v, row = 1, column = 3, sticky = 'ew', padx = 1, pady = 1)

	tkgrid(elv.diff.l, row = 2, column = 0, sticky = 'ew', padx = 1, pady = 1)
	tkgrid(elv.diff.v, row = 2, column = 1, sticky = 'ew', padx = 1, pady = 1)

	infobulle(min.stn.v, 'Minimum number of neighbor stations to use')
	status.bar.display(min.stn.v, TextOutputVar, 'Minimum number of neighbor stations to use')
	infobulle(max.dist.v, 'Maximum distance of neighbor stations to use (km)')
	status.bar.display(max.dist.v, TextOutputVar, 'Maximum distance of neighbor stations to use (km)')
	infobulle(elv.diff.v, 'Maximum altitude difference of neighbor stations to use (m)')
	status.bar.display(elv.diff.v, TextOutputVar, 'Maximum altitude difference of neighbor stations to use (m)')
	infobulle(CInt.v, 'Confidence level (%)')
	status.bar.display(CInt.v, TextOutputVar, 'Confidence level (%)')

	infobulle(max.precip.v, 'Maximum value of precipitation to be considered (mm)')
	status.bar.display(max.precip.v, TextOutputVar, 'Maximum value of precipitation to be considered (mm),\nabove that value, corresponding precipitation values are set to missing')

	##################
	frRain <- tkframe(frDialog, relief = "sunken", borderwidth = 2)

	ispmax <- tclVar(GeneralParameters$sp.check$ispmax)
	ispobs <- tclVar(GeneralParameters$sp.check$ispobs)
	isdmin <- tclVar(GeneralParameters$sp.check$isdmin)
	isdobs <- tclVar(GeneralParameters$sp.check$isdobs)
	isdq1 <- tclVar(GeneralParameters$sp.check$isdq1)
	ftldev <- tclVar(GeneralParameters$sp.check$ftldev)

	ispmax.l <- tklabel(frRain, text = 'ispmax', anchor = 'e', justify = 'right')
	ispobs.l <- tklabel(frRain, text = 'ispobs', anchor = 'e', justify = 'right')
	isdmin.l <- tklabel(frRain, text = 'isdmin', anchor = 'e', justify = 'right')
	isdobs.l <- tklabel(frRain, text = 'isdobs', anchor = 'e', justify = 'right')
	isdq1.l <- tklabel(frRain, text = 'isdq1', anchor = 'e', justify = 'right')
	ftldev.l <- tklabel(frRain, text = 'ftldev', anchor = 'e', justify = 'right')

	ispmax.v <- tkentry(frRain, width = 8, textvariable = ispmax)
	ispobs.v <- tkentry(frRain, width = 8, textvariable = ispobs)
	isdmin.v <- tkentry(frRain, width = 8, textvariable = isdmin)
	isdobs.v <- tkentry(frRain, width = 8, textvariable = isdobs)
	isdq1.v <- tkentry(frRain, width = 8, textvariable = isdq1)
	ftldev.v <- tkentry(frRain, width = 8, textvariable = ftldev)

	sep.col <- tklabel(frRain, text = '', width = 8)

	tkgrid(ispmax.l, row = 0, column = 0, sticky = 'ew', padx = 1, pady = 1)
	tkgrid(ispmax.v, row = 0, column = 1, sticky = 'ew', padx = 1, pady = 1)

	tkgrid(sep.col, row = 0, column = 2, sticky = 'ew', padx = 1, pady = 1)

	tkgrid(ispobs.l, row = 0, column = 3, sticky = 'ew', padx = 1, pady = 1)
	tkgrid(ispobs.v, row = 0, column = 4, sticky = 'ew', padx = 1, pady = 1)

	tkgrid(isdmin.l, row = 1, column = 0, sticky = 'ew', padx = 1, pady = 1)
	tkgrid(isdmin.v, row = 1, column = 1, sticky = 'ew', padx = 1, pady = 1)
	tkgrid(isdobs.l, row = 1, column = 3, sticky = 'ew', padx = 1, pady = 1)
	tkgrid(isdobs.v, row = 1, column = 4, sticky = 'ew', padx = 1, pady = 1)

	tkgrid(isdq1.l, row = 2, column = 0, sticky = 'ew', padx = 1, pady = 1)
	tkgrid(isdq1.v, row = 2, column = 1, sticky = 'ew', padx = 1, pady = 1)
	tkgrid(ftldev.l, row = 2, column = 3, sticky = 'ew', padx = 1, pady = 1)
	tkgrid(ftldev.v, row = 2, column = 4, sticky = 'ew', padx = 1, pady = 1)

	infobulle(ispmax.v, 'Maximum value of the neighbors stations is less than ispmax')
	status.bar.display(ispmax.v, TextOutputVar, 'Maximum value of the neighbors stations is less than ispmax')
	infobulle(ispobs.v, 'Value of target station is greater ispobs')
	status.bar.display(ispobs.v, TextOutputVar, 'Value of target station is greater ispobs')
	infobulle(isdmin.v, 'Minimum value of the  neighbors stations is greater isdmin')
	status.bar.display(isdmin.v, TextOutputVar, 'Minimum value of the  neighbors stations is greater isdmin')
	infobulle(isdobs.v, 'Value of target station is less than isdobs')
	status.bar.display(isdobs.v, TextOutputVar, 'Value of target station is less than isdobs')
	infobulle(isdq1.v, 'The first quartile value of the neighbors stations is greater than isdq1')
	status.bar.display(isdq1.v, TextOutputVar, 'The first quartile value of the neighbors stations is greater than isdq1')
	infobulle(ftldev.v, 'Outliers factor value between 2 and 4, multiplier of IQR')
	status.bar.display(ftldev.v, TextOutputVar, 'Outliers factor value between 2 and 4, multiplier of IQR')

	##############################

	tkgrid(frOpt, row = 0, column = 0, sticky = 'we', padx = 1, pady = 1, ipadx = 1, ipady = 1)
	tkgrid(frRain, row = 1, column = 0, sticky = 'we', padx = 1, pady = 1, ipadx = 1, ipady = 1)

	####################################

	bt.prm.OK <- tkbutton(frButt, text = "OK")
	bt.prm.CA <- tkbutton(frButt, text = "Cancel")

	###############
	ret.param.rain1 <<- NULL

	tkconfigure(bt.prm.OK, command = function(){
		GeneralParameters$select.pars$min.stn <<- as.numeric(str_trim(tclvalue(min.stn)))
		GeneralParameters$select.pars$max.dist <<- as.numeric(str_trim(tclvalue(max.dist)))
		GeneralParameters$select.pars$elv.diff <<- as.numeric(str_trim(tclvalue(elv.diff)))
		GeneralParameters$select.pars$conf.lev <<- as.numeric(str_trim(tclvalue(CInt)))

		GeneralParameters$limits$Upper.Bounds <<- as.numeric(str_trim(tclvalue(limSup)))

		GeneralParameters$sp.check$ispmax <<- as.numeric(str_trim(tclvalue(ispmax)))
		GeneralParameters$sp.check$ispobs <<- as.numeric(str_trim(tclvalue(ispobs)))
		GeneralParameters$sp.check$isdmin <<- as.numeric(str_trim(tclvalue(isdmin)))
		GeneralParameters$sp.check$isdobs <<- as.numeric(str_trim(tclvalue(isdobs)))
		GeneralParameters$sp.check$isdq1 <<- as.numeric(str_trim(tclvalue(isdq1)))
		GeneralParameters$sp.check$ftldev <<- as.numeric(str_trim(tclvalue(ftldev)))

		ret.param.rain1 <<- 0
		tkgrab.release(tt1)
		tkdestroy(tt1)
		tkfocus(tt)	
	})

	tkconfigure(bt.prm.CA, command = function(){
		tkgrab.release(tt1)
		tkdestroy(tt1)
		tkfocus(tt)
	})

	tkgrid(bt.prm.OK, row = 0, column = 0, sticky = 'w', padx = 5, pady = 1, ipadx = 10, ipady = 1)
	tkgrid(bt.prm.CA, row = 0, column = 1, sticky = 'e', padx = 5, pady = 1, ipadx = 1, ipady = 1)

	###############################################################	

	tkgrid(frDialog, row = 0, column = 0, sticky = 'nswe', rowspan = 1, columnspan = 2, padx = 1, pady = 1, ipadx = 1, ipady = 1)
	tkgrid(frButt, row = 1, column = 1, sticky = 'se', rowspan = 1, columnspan = 1, padx = 1, pady = 1, ipadx = 1, ipady = 1)

	tkwm.withdraw(tt1)
	tcl('update')
	tt.w <- as.integer(tkwinfo("reqwidth", tt1))
	tt.h <- as.integer(tkwinfo("reqheight", tt1))
	tt.x <- as.integer(width.scr*0.5-tt.w*0.5)
	tt.y <- as.integer(height.scr*0.5-tt.h*0.5)
	tkwm.geometry(tt1, paste0('+', tt.x, '+', tt.y))
	tkwm.transient(tt1)
	tkwm.title(tt1, 'Options- Settings')
	tkwm.deiconify(tt1)

	tkfocus(tt1)
	tkbind(tt1, "<Destroy>", function() {tkgrab.release(tt1); tkfocus(tt)})
	tkwait.window(tt1)
	return(GeneralParameters)
}



