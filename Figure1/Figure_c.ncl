load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/mnt/e/mytool.ncl"
begin

  t_ymstar	    = 198001
  t_ymend	      = 202012

  var_dat	    = "CN05"
  var_dims	    = "2D"


  Ts_filename  = "output2.txt"
  Ts_filedir   = "/mnt/e/westsouth/data/"

  Ts1_filename  = "yn_spei_MAM.txt"
  Ts1_filedir   = "./"

  Ts2_filename  = "yn_spei_JJA.txt"
  Ts2_filedir   = "./"


  ;options for output
  plottype	  = "pdf";eps
  plotdir	    = "./"
  savename	  = "FigureR1"
  savedir    = plotdir
  print(savename)
  
  ;;---------------------------------------------------------------------
  ;**read variables
  ;;-----------------------------------------------------------------------

  nyear = t_ymend/100-t_ymstar/100+1
  ts1		= asciiread(Ts_filedir+Ts_filename,-1,"float") 
  Ts    = 1.0*ts1 ;;!!!!Attention
  Ts!0  = "year"
  print(Ts)
  Ts&year  = ispan(t_ymstar/100,t_ymend/100,1)		
  printVarSummary(Ts)
  delete([/ts1/])
  Ts = dim_standardize_n_Wrap(Ts,1,0)
  printVarSummary(Ts)
  
  Ts1	= asciiread(Ts1_filedir+Ts1_filename,-1,"float") 
  Ts2		= asciiread(Ts2_filedir+Ts2_filename,-1,"float") 
  Ts1!0      = "year"
  Ts1&year  = ispan(t_ymstar/100,t_ymend/100,1)
  printVarSummary(Ts1)
  copy_VarCoords(Ts1,Ts2)
  printVarSummary(Ts2)
  
  Ts1 = dim_standardize_n_Wrap(Ts1,1,0)
  Ts2 = dim_standardize_n_Wrap(Ts2,1,0)
  printVarSummary(Ts1)
 

    ;elements for Composite
  ; yeara			= ispan(t_ymstar/100,t_ymend/100,1)		
  ; yeara@long_name	= "year-all"
  ; critic_flag	= 0.5
  ; con_wet			= ind( Ts1 .ge. critic_flag .and. Ts2 .ge. critic_flag .and. Ts .ge.0.75)
  ; con_dry      = ind( Ts1 .le. -1*critic_flag .and. Ts2 .le. -1*critic_flag .and. Ts .le. -0.75)
  
  ; dry_to_wet=  ind(Ts1.le. -1*critic_flag .and. Ts2 .ge. critic_flag .and. Ts .le.-0.75)
  ; wet_to_dry=  ind(Ts1.ge. critic_flag .and. Ts2 .le. -1*critic_flag .and. Ts .ge. 0.75)
  ; year_conwet			= yeara(con_wet)			
  ; year_conwet@long_name	= "year-conwet"
  ; year_condry			= yeara(con_dry)
  ; year_condry@long_name	= "year-condry"
  ; year_dry_to_wet	= yeara(dry_to_wet)
  ; year_dry_to_wet@long_name	= "year-dry_to_wet"
  ; year_wet_to_dry	= yeara(wet_to_dry)
  ; year_wet_to_dry@long_name	= "year-wet_to_dry"	
  ; ;end if
  ; print(year_conwet)
  ; print(year_condry)
  ; print(year_dry_to_wet)
  ; print(year_wet_to_dry)

  ; TS1_high= ind(Ts.ge.0.8)
  ; TS1_low = ind(Ts.le.-0.8)
  ; year_TS1_high = yeara(TS1_high)
  ; year_TS1_low  = yeara(TS1_low)
  ; print(year_TS1_high)
  ; print(year_TS1_low)
  ; exit
  ;----------------------------------------------------------------
  
  ;;;time series
  rest		= True
  rest@gsnDraw           = False
  rest@gsnFrame          = False
  rest@vpWidthF          = 0.80
  rest@vpHeightF         = 0.35
  rest@vpXF              = 0.2
  rest@vpYF              = 0.8
  ;;----------------------------------------------------------------------------
  rest@gsnXYBarChart         	= True	;gsn resource
  rest@gsnYRefLine		= 0.
  rest@gsnXYBarChartBarWidth	= 0.30
  rest@xyLineColors		= (/"transparent","transparent"/)
  ; rest@gsnAboveYRefLineColor	="red" ;""
  ; rest@gsnBelowYRefLineColor	="blue" ;""
  ;;----------------------------------------------------------------------------
  font_height   = 0.018	;font size
  rest@tmYLLabelFontHeightF	= font_height
  rest@tmXBLabelFontHeightF	= font_height
  rest@tiXAxisFontHeightF	= 1.2 * font_height
  rest@tiYAxisFontHeightF    	= 1.2 * font_height
  rest@tiMainFontHeightF     	= 1.2 * font_height
  ;;----------------------------------------------------------------------------
  ; rest@tiMainFont                 = "helvetica-bold"
  ; rest@tiXAxisFont                = "helvetica-bold"
  ; rest@tmXBLabelFont              = "helvetica-bold"
  ; rest@tmYLLabelFont              = "helvetica-bold"
  ; rest@gsnStringFont              = "helvetica-bold"
  ; rest@tiMainFont                 = "helvetica-bold"

  rest@gsnLeftString		= ""
  rest@gsnRightString		= ""
  ;;----------------------------------------------------------------------------
  rest@tiXAxisString		= "Year";X and Y axis
  rest@tiYAxisString		= ""
  ;;----------------------------------------------------------------------------
  rest@trXMinF			= t_ymstar/100-1
  rest@trXMaxF			= t_ymend/100+1
  ;;----------------------------------------------------------------------------
  ; rest@tmXBMinorOn		= False
  rest@tmYLMinorOn		= False
  rest@tmXTMinorOn		= False
  rest@tmYRMinorOn		= False
  rest@tmXTOn			= False
  rest@tmYROn			= False
  ;;----------------------------------------------------------------------------
  rest@tmXBMajorLengthF		= 0.006
  rest@tmXBMajorOutwardLengthF	= 0.006
  rest@tmXBLabelDeltaF		= -0.8
  rest@tmYLMajorLengthF		= 0.006
  rest@tmYLMajorOutwardLengthF	= 0.006
  rest@tmYLLabelDeltaF		= -0.8
  ;;----------------------------------------------------------------------------
  ;  rest@tmXBMinorValues		= ispan(1,nt,1)
  rest@tmXBMode			= "Explicit"
  rest@tmXBValues		= ispan(t_ymstar/100,t_ymend/100+1,5)
  rest@tmXBLabels		= ispan(t_ymstar/100,t_ymend/100+1,5)
  rest@tmXBMinorValues = ispan(t_ymstar/100,t_ymend/100+1,1)

  plotname = savename
  plot   = new(3,graphic)
  dum    = new(3,graphic)
  wks   = gsn_open_wks("pdf",plotdir+plotname)
  ;;----------------------------------------------------------------------------

  
  rest@gsnLeftString		  ="(f) TS2"
  rest@gsnXYBarChartColors = (/"tomato"/)	
  plot1			  = gsn_csm_xy(wks,fspan(t_ymstar/100-0.15,t_ymend/100-0.15,nyear),Ts1,rest)
   
  rest@gsnXYBarChartColors = (/"pink"/)	
  plot2		  = gsn_csm_xy(wks,fspan(t_ymstar/100+0.15,t_ymend/100+0.15,nyear),Ts2,rest)
  overlay(plot1,plot2)
  
  getvalues plot1
  "vpXF"      : vpx
  "vpYF"      : vpy
  "vpWidthF"  : vpw
  "vpHeightF" : vph
  "trYMinF":trYMinF
  "trYMaxF":trYMaxF
  end getvalues
  
  ;;---------------------------------------------------------
  ; Make sure XY curve is drawn in same viewport space as bar plot
  ; Note there is no attempt to mathematically map the left and right Y axis to each other. 
  delete([/rest@gsnXYBarChart/])
  rest@vpXF=vpx
  rest@vpYF=vpy
  rest@gsndraw=False
  rest@gsnFrame  = False
  rest@vpWidthF=vpw
  rest@vpHeightF=vph
  rest@trYMinF=trYMinF
  rest@trYMaxF=trYMaxF
  
  ; rest@gsnXYBarChart         	= False	;gsn resource
  ; rest@gsnAboveYRefLineColor	="transparent" ;""
  ; rest@gsnBelowYRefLineColor	="transparent"
  rest@xyMarkLineMode		= "MarkLines"
  rest@xyMarkers			= 16
  rest@xyDashPatterns		= 0
  rest@xyMarkerThicknesses	= 1.0
  rest@xyLineColors		= (/"gray20","gray20"/)
  rest@xyMarkerColors 		=(/"gray20","gray20"/)
  rest@xyLineThicknessF		= 2.15
  rest@xyMarkerSizes		= 0.005

  rest@pmLegendDisplayMode     = "Always"
  rest@xyExplicitLegendLabels  = (/"TS2"/);;"Tb","HZ"
  rest@pmLegendParallelPosF    = 0.85     ; Move to right
  rest@pmLegendOrthogonalPosF  =-1.18     ; Move to top
  rest@lgPerimOn               = False
  rest@lgLabelOffsetF          = 0.1
  rest@lgLabelFontHeightF      = 0.012     ; label font height
  rest@pmLegendWidthF          = 0.08      ; Decrease width
  rest@pmLegendHeightF         = 0.05      ; Decrease height
  plot3		  = gsn_csm_xy(wks,ispan(t_ymstar/100,t_ymend/100,1),Ts,rest)
  ; anno_id  = gsn_add_annotation(plot1, plot3, False)
  overlay(plot1,plot3)
  ;;----------------------------------------------------------------------------
  lbres                    = True          ; labelbar only resources 
  lbres@vpWidthF           = 0.10           ; labelbar width
  lbres@vpHeightF          = 0.05           ; labelbar height
  lbres@lbBoxMajorExtentF  = 0.12         ; puts space between color boxes
  lbres@lbFillColors       = (/"pink","tomato"/)
  lbres@lbPerimColor       = "white"
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbLabelFontHeightF = 0.008         ; font height. default is small
  lbres@lbLabelJust        = "CenterLeft"  ; left justify labels
  lbres@lbPerimOn          = False
  lbres@lgPerimColor 	 = "white"
  labels = (/"SPEI_JJA","SPEI_MAM"/)
  ; lbres@lbLabelFont       = "helvetica-bold"
  gsn_labelbar_ndc(wks,2,labels,0.22,0.42,lbres)	; draw right labelbar column

  nyear   = dimsizes(Ts1&year)
  refline = new(nyear, float)
  refline = 1.0*0.5
  refline_year = fspan(t_ymstar/100-1, t_ymend/100+1, nyear) 
  reflres = True
  reflres@gsndraw=False
  reflres@gsnFrame  = False
  reflres@vpXF=vpx
  reflres@vpYF=vpy
  reflres@vpWidthF=vpw
  reflres@vpHeightF=vph
  reflres@trYMinF=trYMinF
  reflres@trYMaxF=trYMaxF
  reflres@gsLineColor = "gray70"
  reflres@gsLineDashPattern = 1;16
  reflres@gsLineThicknessF  = 2.5
  ; ref1= gsn_csm_xy(wks,refline_year, refline, reflres)
  ; anno_id  = gsn_add_annotation(plot1, ref1, False)
  ;;-------------------------------------------------
  refline = -1.0*0.5
  reflres@gsLineColor = "gray70"
  ; gsn_polyline(wks, plot1, refline_year, refline, reflres)
  ; draw(plot1)
  ; frame(wks)
  ; exit
  resP=True
  resP@gsnMaximize=True
  ; resP@gsnPanelLabelBar=True                     ;设置公共的colorbar
  resP@lbLabelFontHeightF  = 0.014               ; make labels smaller（设置colorbar的字体）
  resP@gsnPaperOrientation="Portrait"                       ;设置纸张形式
  resP@amJust="TopLeft"                                    ;标注的位置
  resP@gsnPanelFigureStringsFontHeightF= 0.020               ;图形标注的字体大小
  resP@pmLabelBarWidthF    = 0.60
  resP@pmLabelBarHeightF   = 0.06
  ;  resP@gsnPanelRowSpec=True
  resP@gsnPanelYWhiteSpacePercent = 2
  resP@gsnPanelXWhiteSpacePercent = 2

  resP@gsnPanelXF = (/0.210,0.63,0.210/)            ; Adjust topmost plots
  resP@gsnPanelYF = (/0.90,0.90,0.42/)            ; Adjust topmost plots
  gsn_panel(wks,(/plot(0),plot(1),plot1/),(/2,2/),resP)


end
