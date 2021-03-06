
PlotSeqNcdfCmd <- function(){
	listOpenFiles <- openFile_ttkcomboList()
	if(Sys.info()["sysname"] == "Windows"){
		wscrlwin <- w.scale(26)
		hscrlwin <- h.scale(46.5)
		largeur0 <- as.integer(w.scale(26)/sfont0)
		largeur1 <- as.integer(w.scale(28)/sfont0)
		largeur2 <- as.integer(w.scale(14)/sfont0)
		largeur3 <- 29
		largeur4 <- 11
	}else{
		wscrlwin <- w.scale(27)
		hscrlwin <- h.scale(50)
		largeur0 <- as.integer(w.scale(23)/sfont0)
		largeur1 <- as.integer(w.scale(22)/sfont0)
		largeur2 <- as.integer(w.scale(14)/sfont0)
		largeur3 <- 20
		largeur4 <- 8
	}

	# PlotCDTdata <- fromJSON(file.path(apps.dir, 'init_params', 'Plot_CDT_Data.json'))
	GeneralParameters <- list(dir = "", sample = "", format = "rfe%S.nc")

	###################

	cmd.frame <- tkframe(panel.left)

	tknote.cmd <- bwNoteBook(cmd.frame)
	tkgrid(tknote.cmd, sticky = 'nwes')
	tkgrid.columnconfigure(tknote.cmd, 0, weight = 1)

	cmd.tab1 <- bwAddTab(tknote.cmd, text = "Plot NetCDF Data")

	bwRaiseTab(tknote.cmd, cmd.tab1)
	tkgrid.columnconfigure(cmd.tab1, 0, weight = 1)

	#######################################################################################################

	#Tab1
	frTab1 <- tkframe(cmd.tab1)
	tkgrid(frTab1, padx = 0, pady = 1, ipadx = 1, ipady = 1)
	tkgrid.columnconfigure(frTab1, 0, weight = 1)

	scrw1 <- bwScrolledWindow(frTab1)
	tkgrid(scrw1)
	tkgrid.columnconfigure(scrw1, 0, weight = 1)
	subfr1 <- bwScrollableFrame(scrw1, width = wscrlwin, height = hscrlwin)
	tkgrid.columnconfigure(subfr1, 0, weight = 1)

		#######################

		frameNC <- tkframe(subfr1, relief = 'groove', borderwidth = 2)

		ncDIR <- tclVar(GeneralParameters$dir)
		ncSample <- tclVar(GeneralParameters$sample)
		ncFormat <- tclVar(GeneralParameters$format)

		txt.ncdr <- tklabel(frameNC, text = 'Directory containing the NetCDF data', anchor = 'w', justify = 'left')
		en.ncdr <- tkentry(frameNC, textvariable = ncDIR, width = largeur0)
		bt.ncdr <- tkbutton(frameNC, text = "...")
		txt.ncfl <- tklabel(frameNC, text = "NetCDF data sample file", anchor = 'w', justify = 'left')
		cb.ncfl <- ttkcombobox(frameNC, values = unlist(listOpenFiles), textvariable = ncSample, width = largeur1)
		bt.ncfl <- tkbutton(frameNC, text = "...")
		txt.ncff <- tklabel(frameNC, text = "Filename format", anchor = 'e', justify = 'right')
		en.ncff <- tkentry(frameNC, textvariable = ncFormat, width = largeur2)

		#################
		tkconfigure(bt.ncdr, command = function(){
			dir4cdf <- tk_choose.dir(getwd(), "")
			tclvalue(ncDIR) <- if(is.na(dir4cdf)) "" else dir4cdf
		})

		tkconfigure(bt.ncfl, command = function(){
			initialdir <- if(file.exists(tclvalue(ncDIR))) tclvalue(ncDIR) else getwd()
			nc.opfiles <- getOpenNetcdf(main.win, all.opfiles, initialdir = initialdir)
			if(!is.null(nc.opfiles)){
				nopf <- length(AllOpenFilesType)
				AllOpenFilesType[[nopf+1]] <<- 'netcdf'
				AllOpenFilesData[[nopf+1]] <<- nc.opfiles

				listOpenFiles[[length(listOpenFiles)+1]] <<- AllOpenFilesData[[nopf+1]][[1]]
				tclvalue(ncSample) <- AllOpenFilesData[[nopf+1]][[1]]
				tkconfigure(cb.ncfl, values = unlist(listOpenFiles), textvariable = ncSample)
				tkconfigure(cb.addshp, values = unlist(listOpenFiles), textvariable = file.plotShp)
			}else return(NULL)
		})

		tkgrid(txt.ncdr, row = 0, column = 0, sticky = 'we', rowspan = 1, columnspan = 6, padx = 1, pady = 0, ipadx = 1, ipady = 1)
		tkgrid(en.ncdr, row = 1, column = 0, sticky = 'we', rowspan = 1, columnspan = 5, padx = 0, pady = 0, ipadx = 1, ipady = 1)
		tkgrid(bt.ncdr, row = 1, column = 5, sticky = 'w', rowspan = 1, columnspan = 1, padx = 0, pady = 0, ipadx = 1, ipady = 1)
		tkgrid(txt.ncfl, row = 2, column = 0, sticky = 'we', rowspan = 1, columnspan = 6, padx = 1, pady = 0, ipadx = 1, ipady = 1)
		tkgrid(cb.ncfl, row = 3, column = 0, sticky = 'we', rowspan = 1, columnspan = 5, padx = 0, pady = 0, ipadx = 1, ipady = 1)
		tkgrid(bt.ncfl, row = 3, column = 5, sticky = 'w', rowspan = 1, columnspan = 1, padx = 0, pady = 0, ipadx = 1, ipady = 1)
		tkgrid(txt.ncff, row = 4, column = 0, sticky = 'e', rowspan = 1, columnspan = 2, padx = 1, pady = 1, ipadx = 1, ipady = 1)
		tkgrid(en.ncff, row = 4, column = 2, sticky = 'we', rowspan = 1, columnspan = 4, padx = 1, pady = 1, ipadx = 1, ipady = 1)

		infobulle(en.ncdr, 'Enter the full path to directory containing the NetCDF data')
		status.bar.display(en.ncdr, TextOutputVar, 'Enter the full path to directory containing the NetCDF data')
		status.bar.display(cb.ncfl, TextOutputVar, 'File containing a sample of the data in NetCDF')
		infobulle(bt.ncfl, 'Browse file if not listed')
		infobulle(en.ncff, 'Enter the filename format of NetCDF data, example: rfe2017_01-dk2.nc')
		status.bar.display(en.ncff, TextOutputVar, 'Enter the filename format of NetCDF data, example: rfe2017_01-dk2.nc\nReplace the whole string representing the date or sequence by %S\nrfe2017_01-dk2.nc becomes rfe%S.nc')

		##############################################

		frameMap <- ttklabelframe(subfr1, text = "Map", relief = 'groove')

		ncdf.date.file <- tclVar()

		cb.nc.maps <- ttkcombobox(frameMap, values = "", textvariable = ncdf.date.file, width = largeur3)
		bt.nc.maps <- ttkbutton(frameMap, text = "PLOT", width = largeur4)
		bt.nc.Date.prev <- ttkbutton(frameMap, text = "<<- Previous", width = 11)
		bt.nc.Date.next <- ttkbutton(frameMap, text = "Next ->>", width = 11)
		bt.nc.MapOpt <- ttkbutton(frameMap, text = "Options", width = largeur4)


		###################

		EnvSeqNCDFPlot$ncMapOp <- list(presetCol = list(color = 'tim.colors', reverse = FALSE),
												userCol = list(custom = FALSE, color = NULL),
												userLvl = list(custom = FALSE, levels = NULL, equidist = FALSE),
												title = list(user = FALSE, title = ''),
												colkeyLab = list(user = FALSE, label = ''),
												scalebar = list(add = FALSE, pos = 'bottomleft'))

		tkconfigure(bt.nc.MapOpt, command = function(){
			if(!is.null(EnvSeqNCDFPlot$ncData$map)){
				atlevel <- pretty(EnvSeqNCDFPlot$ncData$map$z, n = 10, min.n = 7)
				if(is.null(EnvSeqNCDFPlot$ncMapOp$userLvl$levels)){
					EnvSeqNCDFPlot$ncMapOp$userLvl$levels <- atlevel
				}else{
					if(!EnvSeqNCDFPlot$ncMapOp$userLvl$custom)
						EnvSeqNCDFPlot$ncMapOp$userLvl$levels <- atlevel
				}
			}
			EnvSeqNCDFPlot$ncMapOp <- MapGraph.MapOptions(main.win, EnvSeqNCDFPlot$ncMapOp)
		})

		###################

		EnvSeqNCDFPlot$notebookTab.dataNCMap <- NULL

		tkconfigure(bt.nc.maps, command = function(){
			ret <- try(get.All.NCDF.Files(), silent = TRUE)
			if(inherits(ret, "try-error") | is.null(ret)) return(NULL)

			if(str_trim(tclvalue(ncdf.date.file)) != ""){
				ret <- try(get.NCDF.DATA(), silent = TRUE)
				if(inherits(ret, "try-error") | is.null(ret)) return(NULL)

				imgContainer <- SeqNCDF.Display.Maps(tknotes)
				retNBTab <- imageNotebookTab_unik(tknotes, imgContainer, EnvSeqNCDFPlot$notebookTab.dataNCMap, AllOpenTabType, AllOpenTabData)
				EnvSeqNCDFPlot$notebookTab.dataNCMap <- retNBTab$notebookTab
				AllOpenTabType <<- retNBTab$AllOpenTabType
				AllOpenTabData <<- retNBTab$AllOpenTabData
			}
		})

		tkconfigure(bt.nc.Date.prev, command = function(){
			ret <- try(get.All.NCDF.Files(), silent = TRUE)
			if(inherits(ret, "try-error") | is.null(ret)) return(NULL)

			if(str_trim(tclvalue(ncdf.date.file)) != ""){
				donDates <- EnvSeqNCDFPlot$NcFiles2Plot
				idaty <- which(donDates == str_trim(tclvalue(ncdf.date.file)))
				idaty <- idaty-1
				if(idaty < 1) idaty <- length(donDates)
				tclvalue(ncdf.date.file) <- donDates[idaty]

				ret <- try(get.NCDF.DATA(), silent = TRUE)
				if(inherits(ret, "try-error") | is.null(ret)) return(NULL)

				imgContainer <- SeqNCDF.Display.Maps(tknotes)
				retNBTab <- imageNotebookTab_unik(tknotes, imgContainer, EnvSeqNCDFPlot$notebookTab.dataNCMap, AllOpenTabType, AllOpenTabData)
				EnvSeqNCDFPlot$notebookTab.dataNCMap <- retNBTab$notebookTab
				AllOpenTabType <<- retNBTab$AllOpenTabType
				AllOpenTabData <<- retNBTab$AllOpenTabData
			}
		})

		tkconfigure(bt.nc.Date.next, command = function(){
			ret <- try(get.All.NCDF.Files(), silent = TRUE)
			if(inherits(ret, "try-error") | is.null(ret)) return(NULL)

			if(str_trim(tclvalue(ncdf.date.file)) != ""){
				donDates <- EnvSeqNCDFPlot$NcFiles2Plot
				idaty <- which(donDates == str_trim(tclvalue(ncdf.date.file)))
				idaty <- idaty+1
				if(idaty > length(donDates)) idaty <- 1
				tclvalue(ncdf.date.file) <- donDates[idaty]

				ret <- try(get.NCDF.DATA(), silent = TRUE)
				if(inherits(ret, "try-error") | is.null(ret)) return(NULL)

				imgContainer <- SeqNCDF.Display.Maps(tknotes)
				retNBTab <- imageNotebookTab_unik(tknotes, imgContainer, EnvSeqNCDFPlot$notebookTab.dataNCMap, AllOpenTabType, AllOpenTabData)
				EnvSeqNCDFPlot$notebookTab.dataNCMap <- retNBTab$notebookTab
				AllOpenTabType <<- retNBTab$AllOpenTabType
				AllOpenTabData <<- retNBTab$AllOpenTabData
			}
		})

		###################

		tkgrid(cb.nc.maps, row = 0, column = 0, sticky = 'we', rowspan = 1, columnspan = 4, padx = 1, pady = 1, ipadx = 1, ipady = 1)
		tkgrid(bt.nc.maps, row = 0, column = 4, sticky = '', rowspan = 1, columnspan = 2, padx = 1, pady = 1, ipadx = 1, ipady = 1)
		tkgrid(bt.nc.Date.prev, row = 1, column = 0, sticky = 'we', rowspan = 1, columnspan = 2, padx = 1, pady = 1, ipadx = 1, ipady = 1)
		tkgrid(bt.nc.Date.next, row = 1, column = 2, sticky = 'we', rowspan = 1, columnspan = 2, padx = 1, pady = 1, ipadx = 1, ipady = 1)
		tkgrid(bt.nc.MapOpt, row = 1, column = 4, sticky = 'we', rowspan = 1, columnspan = 2, padx = 1, pady = 1, ipadx = 1, ipady = 1)

		##############################################

		frameSHP <- ttklabelframe(subfr1, text = "Boundaries", relief = 'groove')

		EnvSeqNCDFPlot$shp$add.shp <- tclVar(0)
		file.plotShp <- tclVar()
		stateSHP <- "disabled"

		chk.addshp <- tkcheckbutton(frameSHP, variable = EnvSeqNCDFPlot$shp$add.shp, text = "Add boundaries to Map", anchor = 'w', justify = 'left')
		bt.addshpOpt <- ttkbutton(frameSHP, text = "Options", state = stateSHP)
		cb.addshp <- ttkcombobox(frameSHP, values = unlist(listOpenFiles), textvariable = file.plotShp, width = largeur1, state = stateSHP)
		bt.addshp <- tkbutton(frameSHP, text = "...", state = stateSHP)

		########
		tkconfigure(bt.addshp, command = function(){
			shp.opfiles <- getOpenShp(main.win, all.opfiles)
			if(!is.null(shp.opfiles)){
				nopf <- length(AllOpenFilesType)
				AllOpenFilesType[[nopf+1]] <<- 'shp'
				AllOpenFilesData[[nopf+1]] <<- shp.opfiles
				tclvalue(file.plotShp) <- AllOpenFilesData[[nopf+1]][[1]]
				listOpenFiles[[length(listOpenFiles)+1]] <<- AllOpenFilesData[[nopf+1]][[1]]

				tkconfigure(cb.addshp, values = unlist(listOpenFiles), textvariable = file.plotShp)

				shpofile <- getShpOpenData(file.plotShp)
				if(is.null(shpofile)) EnvSeqNCDFPlot$shp$ocrds <- NULL
				EnvSeqNCDFPlot$shp$ocrds <- getBoundaries(shpofile[[2]])
			}else return(NULL)
		})

		########
		EnvSeqNCDFPlot$SHPOp <- list(col = "black", lwd = 1.5)

		tkconfigure(bt.addshpOpt, command = function(){
			EnvSeqNCDFPlot$SHPOp <- MapGraph.GraphOptions.LineSHP(main.win, EnvSeqNCDFPlot$SHPOp)
		})

		########
		tkgrid(chk.addshp, row = 0, column = 0, sticky = 'we', rowspan = 1, columnspan = 6, padx = 1, pady = 1)
		tkgrid(bt.addshpOpt, row = 0, column = 6, sticky = 'we', rowspan = 1, columnspan = 2, padx = 1, pady = 1)
		tkgrid(cb.addshp, row = 1, column = 0, sticky = 'we', rowspan = 1, columnspan = 7, padx = 1, pady = 1)
		tkgrid(bt.addshp, row = 1, column = 7, sticky = 'w', rowspan = 1, columnspan = 1, padx = 0, pady = 1)

		#################
		tkbind(cb.addshp, "<<ComboboxSelected>>", function(){
			shpofile <- getShpOpenData(file.plotShp)
			if(is.null(shpofile)) EnvSeqNCDFPlot$shp$ocrds <- NULL
			EnvSeqNCDFPlot$shp$ocrds <- getBoundaries(shpofile[[2]])
		})

		tkbind(chk.addshp, "<Button-1>", function(){
			stateSHP <- if(tclvalue(EnvSeqNCDFPlot$shp$add.shp) == "1") "disabled" else "normal"
			tkconfigure(cb.addshp, state = stateSHP)
			tkconfigure(bt.addshp, state = stateSHP)
			tkconfigure(bt.addshpOpt, state = stateSHP)
		})

		############################################

		tkgrid(frameNC, row = 0, column = 0, sticky = 'we', padx = 1, pady = 1, ipadx = 1, ipady = 1)
		tkgrid(frameMap, row = 1, column = 0, sticky = 'we', padx = 1, pady = 1, ipadx = 1, ipady = 1)
		tkgrid(frameSHP, row = 2, column = 0, sticky = 'we', padx = 1, pady = 1, ipadx = 1, ipady = 1)

	#######################################################################################################

	get.All.NCDF.Files <- function(){
		tkconfigure(main.win, cursor = 'watch')
		tcl('update')
		on.exit({
			tkconfigure(main.win, cursor = '')
			tcl('update')
		})

		nc.dir <- str_trim(tclvalue(ncDIR))
		nc.format <- str_trim(tclvalue(ncFormat))

		if(nc.dir == "" | nc.format == ""){
			tkconfigure(cb.nc.maps, values = "")
			tclvalue(ncdf.date.file) <- ""
			EnvSeqNCDFPlot$loaded.nc <- NULL
			return(NULL)
		}

		loaded.nc <- list(nc.dir, nc.format)
		if(is.null(EnvSeqNCDFPlot$loaded.nc)){
			getNCFiles <- TRUE
		}else{
			getNCFiles <- if(!isTRUE(all.equal(EnvSeqNCDFPlot$loaded.nc, loaded.nc))) TRUE else FALSE
		}

		if(getNCFiles){
			nc.files <- list.files(nc.dir, sub("%S", ".+", nc.format))
			if(length(nc.files) == 0){
				InsertMessagesTxt(main.txt.out, "No ncdf files found", format = TRUE)
				tkconfigure(cb.nc.maps, values = "")
				tclvalue(ncdf.date.file) <- ""
				EnvSeqNCDFPlot$loaded.nc <- NULL
				return(NULL)
			}
			frmt <- strsplit(nc.format, "%S")[[1]]

			seq_dat <- gsub(frmt[1], "", gsub(frmt[2], "", nc.files))
			nb_only <- grepl("^[0-9]+$", seq_dat)
			seq_order <- seq_along(seq_dat)
			if(all(nb_only)){
				nmax <- max(nchar(seq_dat))
				seq_dat <- str_pad(seq_dat, nmax, pad = "0")
				seq_order <- order(seq_dat)
			}else{
				nb_mixed <- gregexpr("[[:digit:]]+", seq_dat)
				ch_mixed <- gregexpr("[[:alpha:]]+", seq_dat)
				nb_cont <- sapply(nb_mixed, function(x) x[1] > 0)
				ch_cont <- sapply(ch_mixed, function(x) x[1] > 0)
				if(all(nb_cont) & !all(ch_cont)){
					nb_mixed <- regmatches(seq_dat, nb_mixed)
					nb_cont <- diff(range(sapply(nb_mixed, length)))
					if(nb_cont == 0){
						nb_mixed <- do.call(rbind, nb_mixed)
						nb_mixed <- apply(nb_mixed, 2, as.numeric)
						seq_order <- sort.filename.data(nb_mixed)
					}
				}
				if(!all(nb_cont) & all(ch_cont)){
					ch_mixed <- regmatches(seq_dat, ch_mixed)
					ch_cont <- diff(range(sapply(ch_mixed, length)))
					if(ch_cont == 0){
						ch_mixed <- do.call(rbind, ch_mixed)
						seq_order <- sort.filename.data(ch_mixed)
					}
				}
				if(all(nb_cont) & all(ch_cont)){
					nb_mixed <- regmatches(seq_dat, nb_mixed)
					nb_cont <- diff(range(sapply(nb_mixed, length)))
					ch_mixed <- regmatches(seq_dat, ch_mixed)
					ch_cont <- diff(range(sapply(ch_mixed, length)))
					if(nb_cont == 0 & ch_cont == 0){
						nb_mixed <- do.call(rbind, nb_mixed)
						nb_mixed <- apply(nb_mixed, 2, as.numeric)
						ch_mixed <- do.call(rbind, ch_mixed)
						seq_order <- sort.filename.data(data.frame(ch_mixed, nb_mixed))
					}
					if(nb_cont == 0 & ch_cont != 0){
						nb_mixed <- do.call(rbind, nb_mixed)
						nb_mixed <- apply(nb_mixed, 2, as.numeric)
						seq_order <- sort.filename.data(nb_mixed)
					}
					if(nb_cont != 0 & ch_cont == 0){
						ch_mixed <- do.call(rbind, ch_mixed)
						seq_order <- sort.filename.data(ch_mixed)
					}
				}
			}

			nc.files <- nc.files[seq_order]

			rfeDataInfo <- getRFESampleData(str_trim(tclvalue(ncSample)))
			if(is.null(rfeDataInfo)){
				InsertMessagesTxt(main.txt.out, "No NetCDF data sample found", format = TRUE)
				return(NULL)
			}

			ncinfo <- list(xo = rfeDataInfo$rfeILon, yo = rfeDataInfo$rfeILat, varid = rfeDataInfo$rfeVarid)

			ncfileInit <- file.path(nc.dir, nc.files[1])
			nc <- nc_open(ncfileInit)
			xlon <- nc$var[[ncinfo$varid]]$dim[[ncinfo$xo]]$vals
			xlat <- nc$var[[ncinfo$varid]]$dim[[ncinfo$yo]]$vals
			nc_close(nc)
			xo <- order(xlon)
			xlon <- xlon[xo]
			yo <- order(xlat)
			xlat <- xlat[yo]

			EnvSeqNCDFPlot$ncInfo$ncinfo <- ncinfo
			EnvSeqNCDFPlot$ncInfo$coords <- list(lon = xlon, lat = xlat, ix = xo, iy = yo)

			tkconfigure(cb.nc.maps, values = nc.files)
			tclvalue(ncdf.date.file) <- nc.files[1]
			EnvSeqNCDFPlot$NcFiles2Plot <- nc.files

			EnvSeqNCDFPlot$loaded.nc <- loaded.nc
		}
		return(0)
	}

	get.NCDF.DATA <- function(){
		tkconfigure(main.win, cursor = 'watch')
		tcl('update')
		on.exit({
			tkconfigure(main.win, cursor = '')
			tcl('update')
		})

		nc.dir <- str_trim(tclvalue(ncDIR))
		nc.file <- str_trim(tclvalue(ncdf.date.file))
		ncfile.path <- file.path(nc.dir, nc.file)

		readNCFILE <- TRUE
		if(!is.null(EnvSeqNCDFPlot$ncData))
			if(!is.null(EnvSeqNCDFPlot$ncData$ncfile))
				if(EnvSeqNCDFPlot$ncData$ncfile == ncfile.path) readNCFILE <- FALSE

		if(readNCFILE){
			EnvSeqNCDFPlot$ncData$map$x <- EnvSeqNCDFPlot$ncInfo$coords$lon
			EnvSeqNCDFPlot$ncData$map$y <- EnvSeqNCDFPlot$ncInfo$coords$lat

			ncinfo <- EnvSeqNCDFPlot$ncInfo$ncinfo
			ix <- EnvSeqNCDFPlot$ncInfo$coords$ix
			iy <- EnvSeqNCDFPlot$ncInfo$coords$iy

			nc <- try(nc_open(ncfile.path), silent = TRUE)
			if(inherits(nc, "try-error")) return(NULL)
			ncdon <- ncvar_get(nc, varid = ncinfo$varid)
			nc_close(nc)
			ncdon <- if(ncinfo$xo < ncinfo$yo) ncdon[ix, iy] else t(ncdon)[ix, iy]
			EnvSeqNCDFPlot$ncData$map$z <- ncdon

			EnvSeqNCDFPlot$ncData$file2plot <- nc.file
			EnvSeqNCDFPlot$ncData$ncfile <- ncfile.path
		}

		return(0)
	}

	#######################################################################################################

	tcl('update')
	tkgrid(cmd.frame, sticky = '', pady = 1)
	tkgrid.columnconfigure(cmd.frame, 0, weight = 1)
	######
	return(cmd.frame)
}
