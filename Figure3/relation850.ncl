load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/mnt/e/mytool.ncl"
begin
;**********************************************************************
;A script calculating Correlation or Regresssion coefficients for monthal 3-Dimension vector field

;Plot the a prescribed statistic by cor_reg_flag( User should adjust the cnLevels and cnFillColors accroding to different statistics) 
;**********************************************************************
;user can select:

;				 1��Correlation or Regression

;				 2��detrend or not for each month

;                3��lead or lag time 

;                4��different plot for significant level
;**********************************************************************
;Options for user
;**********************************************************************
data="TS1"

if data .eq. "EIP_SMI" then
ts_dat		= "EIP_SMI"
ts_name		= "MAM"
ts_filedir	="/mnt/e/westsouth/data/"
ts_filename	= "EIP_SMI_MAM.txt"
end if
if data .eq. "TS1" then
ts_dat		= "TS1"
ts_name		= "TS1"
ts_filedir	="/mnt/e/westsouth/data/"
ts_filename	= "output1.txt"
end if

if data .eq. "ICP_SMI" then
ts_dat		= "ICP_swvl"
ts_name		= "MAM"
ts_filedir	="/mnt/e/westsouth/data/"
ts_filename	= "ICP_swvl1_MAM.txt"
end if

lvl 		= 850

ts_ys			= 1980			;ts start year 
ts_ye			= 2020			;ts end year 

varname		= "uv"
var_dat		= "ERA5"
varname_x		= "u" 
filedir_x		=  "/mnt/e/westsouth/data/"
filename_x	= "ERA5_u_mon_197901_202209.nc"
 
varname_y		= "v" 
filedir_y		= "/mnt/e/westsouth/data/"
filename_y	= "ERA5_v_mon_197901_202209.nc" 
lv_filename="nino34_MAM.txt"

cor_reg_flag	= "reg"		; "cor" or "reg"
dtrend_flag	= 1		; 0 for raw,else for detrend
maxy_flag		= 1			; years for lead or lag the currnet year(Y(0)) 
area_flag		= 2			; significant area type,0 for x only, 1 for y only,2 for x or y,3,for sqrt(x^2,y^2)   
plot_flag		= 0			; 0 for shaded,1 for only significant area plot   
lv_flag    = 0			; 0 for no lv, 1 for lv
;**********************************************************************
  ymstar		= 198001
  ymend			= 202012
  
  
  latmin	= 0
  latmax	= 40
  lonmin	= 60
  lonmax	= 150
  season="JJA(0)"
  title_name	= "(f) Reg. UV"+lvl+" on "+data
  setup_name  = ts_dat+"vs_"+lvl+"uv_"+season
  if lv_flag .eq. 1 then
setup_name  = ts_dat+" vs "+lvl+"uv_"+season+"(lv nino)"
end if

  monmin	= 6;starting month for averaging,(monmin != 0,-12 <= monmin <= monmax <=12). negative value for previou year(year(-1)) 
  monmax	= 8	;ending month for averaging,	   1<= monmax <= 12 
  
  months	= (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
 
  ;options for output  
  plottype	= "pdf"                 ;type of plotting
  plotdir	= "./"
  plotname	= setup_name
  savedir	= "./"
  savename	= setup_name
;**********************************************************************
;Handle variable
;**********************************************************************
  ;read time series
  Ts_init		= asciiread(ts_filedir+ts_filename,ts_ye-ts_ys+1,"float")
  Ts_init!0		= "year"
  Ts_init&year	= ispan(ts_ys,ts_ye,1)
  printVarSummary(Ts_init)

  if data .eq. "ICP_SMI" then
  Ts			= -1*Ts_init({year|ymstar/100:ymend/100})
  end if
  if data .eq. "TS1" then
  Ts			= -1*Ts_init({year|ymstar/100:ymend/100})
  end if
  if data .eq. "EIP_SMI" then
  Ts			= Ts_init({year|ymstar/100:ymend/100})
  end if
  print(Ts)
 
  ;read variable 
  f				= addfile(filedir_x+filename_x,"r")
  tim			= f->time
  u_time_DATE	= cd_calendar(tim,-1)
  tstar		= ind(u_time_DATE .eq. ymstar)
  tlast		= ind(u_time_DATE .eq. ymend)
  print(tstar)
  print(tlast)  
  
  
  varx			= short2flt(f->$varname_x$(tstar:tlast,{(/925,850,700,500,200/)},{latmin:latmax},{lonmin:lonmax}))
  varx!0		= "time"
  varx!1		= "level"
  varx!2		= "lat"
  varx!3		= "lon"
  printVarSummary(varx)
  delete([/tim,u_time_DATE/])

  f				= addfile(filedir_y+filename_y,"r")
  tim			= f->time
  u_time_DATE	= cd_calendar(tim,-1)
  tstar		= ind(u_time_DATE .eq. ymstar)
  tlast		= ind(u_time_DATE .eq. ymend)
  print(tstar)
  print(tlast)  
  
  vary			= short2flt(f->$varname_y$(tstar:tlast,{(/925,850,700,500,200/)},{latmin:latmax},{lonmin:lonmax}))
  vary!0		= "time"
  vary!1		= "level"
  vary!2		= "lat"
  vary!3		= "lon"
  printVarSummary(vary)
  
   
  if lv_flag .eq. 1 then
  lv_init		= asciiread(ts_filedir+lv_filename,ts_ye-ts_ys+1,"float")
  lv_init!0		= "year"
  lv_init&year	= ispan(ts_ys,ts_ye,1)
  printVarSummary(lv_init)
  print(lv_init)
  lv			= lv_init({year|ymstar/100:ymend/100})
  print(lv)

end if 

  varx_monave	= month_to_monave(varx,monmin,monmax)
  printVarSummary(varx_monave)
  
  vary_monave	= month_to_monave(vary,monmin,monmax)
  printVarSummary(vary_monave)
  
  varm_monave	= sqrt(varx_monave^2+vary_monave^2)
  copy_VarCoords(varx_monave,varm_monave)
  varm_monave@long_name	= "sqrt(varx_monave^2+vary_monave^2)"
  printVarSummary(varm_monave)
  
  nyear		= dimsizes(varx_monave&year)
  nz				= dimsizes(varx_monave&level)
  ny		= dimsizes(varx_monave&lat)
  nx		= dimsizes(varx_monave&lon)
    
  ;detrend or not
  if dtrend_flag .eq. 0 
   
     Ts					= Ts
	 Ts@detrend			= dtrend_flag +"--(0 for raw data, else for detrended data)" 
	 
	 varx_monave			= varx_monave
     varx_monave@detrend= dtrend_flag +"--(0 for raw data, else for detrended data)" 
     
	 vary_monave			= vary_monave
     vary_monave@detrend= dtrend_flag +"--(0 for raw data, else for detrended data)" 
	 
	 varm_monave			= varm_monave
     varm_monave@detrend= dtrend_flag +"--(0 for raw data, else for detrended data)" 
	 
  else
  
  if lv_flag .eq. 1 then
  Ts					= (/dtrend_msg_n(lv,Ts,False,True,0)/) 
Ts@detrend			= dtrend_flag +"--(0 for raw data, else for detrended data)" 

varx_monave			= (/dtrend_msg_n(lv,varx_monave,False,True,0)/)
   varx_monave@detrend= dtrend_flag +"--(0 for raw data, else for detrended data)"

 vary_monave			= (/dtrend_msg_n(lv,vary_monave,False,True,0)/)
   vary_monave@detrend= dtrend_flag +"--(0 for raw data, else for detrended data)"

 varm_monave			= (/dtrend_msg_n(lv,varm_monave,False,True,0)/)
   varm_monave@detrend= dtrend_flag +"--(0 for raw data, else for detrended data)"

 end if

     Ts						= (/dtrend_msg_n(ispan(1,nyear,1)*1.0,Ts,False,True,0)/) 
	 Ts@detrend				= dtrend_flag +"--(0 for raw data, else for detrended data)" 
	 
	 varx_monave			= (/dtrend_msg_n(ispan(1,nyear,1)*1.0,varx_monave,False,True,0)/) 
     varx_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 
	 
	 vary_monave			= (/dtrend_msg_n(ispan(1,nyear,1)*1.0,vary_monave,False,True,0)/) 
     vary_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 
	 
	 varm_monave			= (/dtrend_msg_n(ispan(1,nyear,1)*1.0,varm_monave,False,True,0)/) 
     varm_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 
  
  end if
  printVarSummary(Ts)
  printVarSummary(varx_monave)
  printVarSummary(vary_monave)
  printVarSummary(varm_monave)
  
  ;Correlation or Regression  
  
  ;Correlation
  ;x->Correlation
  cor_Ts_lead_varx		= esccr(Ts,varx_monave(level|:,lat|:,lon|:,year|:),maxy_flag)
  printVarSummary(cor_Ts_lead_varx)
  
  cor_varx_lead_Ts		= esccr(varx_monave(level|:,lat|:,lon|:,year|:),Ts,maxy_flag)  
  printVarSummary(cor_varx_lead_Ts)
  
  corx								= new((/nz,ny,nx,2*maxy_flag+1/),"float")
  corx(:,:,:,0:maxy_flag)				= cor_varx_lead_Ts(:,:,:,::-1)
  corx(:,:,:,maxy_flag+1:2*maxy_flag)	= cor_Ts_lead_varx(:,:,:,1:maxy_flag)
  
  corx!0					= "level"
  corx&level				= varx_monave&level
  corx!1					= "lat"
  corx&lat				= varx_monave&lat
  corx!2					= "lon"
  corx&lon				= varx_monave&lon
  corx!3					= "lead"
  corx&lead			    = ispan(-1*maxy_flag,maxy_flag,1)*1.0
  corx@long_name			= "Corrrelation--Ts lead var. If lead dimension is negative, Ts lag var" 
  ;y->Correlation
  cor_Ts_lead_vary		= esccr(Ts,vary_monave(level|:,lat|:,lon|:,year|:),maxy_flag)
  printVarSummary(cor_Ts_lead_vary)
  
  cor_vary_lead_Ts		= esccr(vary_monave(level|:,lat|:,lon|:,year|:),Ts,maxy_flag)  
  printVarSummary(cor_vary_lead_Ts)
  
  cory								= new((/nz,ny,nx,2*maxy_flag+1/),"float")
  cory(:,:,:,0:maxy_flag)				= cor_vary_lead_Ts(:,:,:,::-1)
  cory(:,:,:,maxy_flag+1:2*maxy_flag)	= cor_Ts_lead_vary(:,:,:,1:maxy_flag)
  
  copy_VarCoords(corx,cory)
  cory@long_name		= "Corrrelation--Ts lead var. If lead dimension is negative, Ts lag var" 
  
  ;sqrt(varx^2+vary^2)
  cor_Ts_lead_varm		= esccr(Ts,varm_monave(level|:,lat|:,lon|:,year|:),maxy_flag)
  printVarSummary(cor_Ts_lead_varm)
  
  cor_varm_lead_Ts		= esccr(varm_monave(level|:,lat|:,lon|:,year|:),Ts,maxy_flag)  
  printVarSummary(cor_varm_lead_Ts)
  
  corm								= new((/nz,ny,nx,2*maxy_flag+1/),"float")
  corm(:,:,:,0:maxy_flag)				= cor_varm_lead_Ts(:,:,:,::-1)
  corm(:,:,:,maxy_flag+1:2*maxy_flag)	= cor_Ts_lead_varm(:,:,:,1:maxy_flag)
  
  copy_VarCoords(corx,corm)
  corm@long_name		= "Corrrelation--Ts lead var. If lead dimension is negative, Ts lag var" 
  
  ;Regression 
  regx					= new((/nz,ny,nx,2*maxy_flag+1/),"float")
  regy					= new((/nz,ny,nx,2*maxy_flag+1/),"float")
  
  do i=0,maxy_flag
  
	regx(:,:,:,maxy_flag-i)	= regCoef(Ts(i:nyear-1),varx_monave(level|:,lat|:,lon|:,year|0:nyear-i-1))			
    regx(:,:,:,maxy_flag+i)	= regCoef(Ts(0:nyear-i-1),varx_monave(level|:,lat|:,lon|:,year|i:nyear-1))
	
	regy(:,:,:,maxy_flag-i)	= regCoef(Ts(i:nyear-1),vary_monave(level|:,lat|:,lon|:,year|0:nyear-i-1))			
    regy(:,:,:,maxy_flag+i)	= regCoef(Ts(0:nyear-i-1),vary_monave(level|:,lat|:,lon|:,year|i:nyear-1))	
	
  end do	
		
  copy_VarCoords(corx,regx)
  regx@long_name		= "Regression--Ts lead var. If lead dimension is negative, Ts lag var"   
  
  copy_VarCoords(corx,regy)
  regy@long_name		= "Regression--Ts lead var. If lead dimension is negative, Ts lag var"  
  
  delete([/varx,vary,cor_Ts_lead_vary,cor_varx_lead_Ts,cor_Ts_lead_varx,cor_vary_lead_Ts,cor_Ts_lead_varm,cor_varm_lead_Ts/])

  if cor_reg_flag .eq. "cor"
   
	cor_reg_x			= corx
    cor_reg_y			= cory
	
  end if 
   
  if cor_reg_flag .eq. "reg"
	
	cor_reg_x				= regx
	cor_reg_y				= regy
	
  end if
  
  ;Critical t value and correlation coefficients for 0.10,0.05 and 0,01
  
  tValue				= new((/2*maxy_flag+1,3/),"float")				
  rflag					= new((/2*maxy_flag+1,3/),"float")
  
  
  do i=0,2*maxy_flag
        n				= nyear-abs(i-maxy_flag)
		tValue(i,:)		= cdft_t((/1-0.05,1-0.025,1-0.005/),(/n-2,n-2,n-2/))
		rflag(i,:)		= sqrt(tValue(i,:)^2/(n-2+tValue(i,:)^2))
  end do
  rflag					= round(rflag*100.0,0)/100.0		;round the float data
 
  write_matrix(tValue,"3f8.2",False)
  write_matrix(rflag,"3f8.2",False)
  
  corx@tValue			= tValue
  corx@tValue_desc		= "Critical t Value for 0.1,0.05,001 significant level"
  
  corx@rflag			= rflag
  corx@rflag_desc		= "Critical correlation for 0.1,0.05,001 significant level"
  
  cory@tValue			= tValue
  cory@tValue_desc		= "Critical t Value for 0.1,0.05,001 significant level"
  
  cory@rflag			= rflag
  cory@rflag_desc		= "Critical correlation for 0.1,0.05,001 significant level"
  
  corm@tValue			= tValue
  corm@tValue_desc		= "Critical t Value for 0.1,0.05,001 significant level"
  
  corm@rflag			= rflag
  corm@rflag_desc		= "Critical correlation for 0.1,0.05,001 significant level"
  
  printVarSummary(corx)
  printVarSummary(cory)
  printVarSummary(corm)
  
  printVarSummary(regx)
  printVarSummary(regy)
  
  corxymax				= where(abs(corx) .gt. abs(cory),abs(corx),abs(cory))
  copy_VarCoords(corx,corxymax)
  corxymax@long_name	= "an element-by-element minimum or maximum between abs(corx) and abs(cory)"
  printVarSummary(corxymax)  
  
;**********************************************************************
;Saving data
;********************************************************************** 
  system("/bin/rm -f "+savedir+savename+".nc")
  fo            			= addfile(savedir+savename+".nc","c")
  filedimdef(fo,"time",-1,True)
  fo->corx					= corx
  fo->cory					= cory
  fo->corm					= corm
  fo->corxymax				= corxymax
  
  fo->regx					= regx
  fo->regy					= regy
 
;**********************************************************************
;Plotting
;**********************************************************************

  if area_flag .eq. 0 	; x-> only
   
        corxy_plot		= corx

  
  end if  
  
  if area_flag .eq. 1	; y-> only
  
		corxy_plot		= cory
  
  end if 
 
  if area_flag .eq. 2	; x-> or y-> 
    	
		corxy_plot		= corxymax
		
  end if 
  
  if area_flag .eq. 3	; sqrt(x^2+y^2) 
  
		corxy_plot		= corm
  
  end if
    
  corxy_plot			= (/abs(corxy_plot)/)
  varx_plot				= cor_reg_x
  vary_plot				= cor_reg_y
  printVarSummary(corxy_plot)
  printVarSummary(varx_plot)
  printVarSummary(vary_plot)
  
  corxy_plot_area		= corxy_plot({level|lvl},{lat|latmin:latmax},{lon|lonmin:lonmax},lead|:)
  varx_plot_area		= varx_plot({level|lvl},{lat|latmin:latmax},{lon|lonmin:lonmax},lead|:)
  vary_plot_area		= vary_plot({level|lvl},{lat|latmin:latmax},{lon|lonmin:lonmax},lead|:)
  printMinMax(corxy_plot_area,True)
  printMinMax(varx_plot_area,True)
  printMinMax(vary_plot_area,True)
  
  i_flag				= "(" + ispan(-maxy_flag,maxy_flag,1) + ")"  
  
;------------------------------------------------------------------------  
if plot_flag .eq. 0
  res			= True
  res@gsnFrame	= False
  res@gsnDraw	= False  
  
  ;Resources for Contour 
  res@cnFillOn			= True
  res@cnLinesOn			= False
  res@cnLineLabelsOn	= False
  res@cnInfoLabelOn		= False
  res@gsnScalarContour	= True		;required for contour
  res@lbLabelBarOn		= False
  res@cnLevelSelectionMode	= "ExplicitLevels"
  ;res@cnFillColors			= (/2,100,101/);(/"transparent","grey","gray61"/)
  
  ;Resources for map
  res@mpMinLonF		= lonmin
  res@mpMaxLonF		= lonmax
  res@mpMinLatF		= latmin
  res@mpMaxLatF		= latmax

     ;-----resource for China map 
res@mpDataSetName = "/mnt/e/nclstudy/nclscripts/Earth..4"
res@mpDataBaseVersion = "MediumRes" ; or "Ncarg4_1"
;sres@mpOutlineOn = True
;sres@mpOutlineSpecifiers = (/"China","China:Provinces"/)
res@mpOutlineSpecifiers = (/"China:Yunnan"/)
res@mpGeophysicalLineColor = "black"
;sres@mpOutlineBoundarySets = "NoBoundaries"
;sres@Geophysical = "NoBoundaries"
;sres@mpNationalLineThicknessF = 2.0
res@mpFillAreaSpecifiers = (/"land","water","China"/)
res@mpSpecifiedFillColors = (/"white","white","transparent"/)
res@mpFillDrawOrder = "Draw"

  res@mpCenterLonF	= 180
  res@mpGeophysicalLineColor		= "black"
  res@mpGeophysicalLineThicknessF	= 1.0
  res@mpFillOn		= False
  res@gsnAddCyclic	= False 

  font_height			= 0.018								       
  res@tmYLLabelFontHeightF	= font_height
  res@tmXBLabelFontHeightF	= font_height
  res@tiXAxisFontHeightF	= 1.2 * font_height
  res@tiYAxisFontHeightF	= 1.2 * font_height
  res@tiMainFontHeightF		= 1.2 * font_height
  res@gsnLeftStringFontHeightF  =1.2 *  font_height
  res@gsnRightStringFontHeightF  =1.2 *  font_height
  ;res@gsnRightString		= "~S~o~N~C"
  res@gsnLeftStringOrthogonalPosF	= 0.01	;vcRefAnnoOrthogonalPosF+1.0
  res@gsnRightStringOrthogonalPosF=0
  res@tiMainString			= ""
  res@tiMainOffsetYF 		= 0

;  res@tmXBValues		= (/30,60,90,120/)
;  res@tmXBLabels		= (/"30~S~o~N~E","60~S~o~N~E","90~S~o~N~E","120~S~o~N~E"/)
;  res@tmYLValues		= (/-60,-30,0,30/)
;  res@tmYLLabels		= (/"60~S~o~N~S","30~S~o~N~S","Eq","30~S~o~N~N"/)
;  res@tmXBMinorValues		= ispan(40,120,10)
;  res@tmYLMinorValues		= ispan(-60,30,10)

  res@tmXBMinorOn	= False
  res@tmYLMinorOn	= False
  res@tmYROn		= False
  res@tmXTOn		= False
  
  res@tmXBMajorLengthF			= 0.004
  res@tmXBMajorOutwardLengthF	= 0.004
  res@tmXBLabelDeltaF			= -0.5
  res@tmYLMajorLengthF			= 0.004
  res@tmYLMajorOutwardLengthF	= 0.004
  res@tmYLLabelDeltaF			= -0.5
  res@gsnMajorLatSpacing=10
  res@gsnMajorLonSpacing=15

;  res@vpHeightF	= 0.8
;  res@vpWidthF		= 0.7
;  res@vpXF			= 0.1
;  res@vpYF			= 0.9
  
  ;Resource for vector
  res@vcRefMagnitudeF			= 0.5
  res@vcRefLengthF				= 0.045
  res@vcMinDistanceF			= 0.025
  res@vcMagnitudeFormat			= "@*+^sg"
  res@vcRefAnnoOn				= True	
  res@vcRefAnnoOrthogonalPosF	= -1
  ;res@vcRefAnnoBackgroundColor 	= -1
  res@vcRefAnnoPerimOn			= True
  res@vcGlyphStyle				= "CurlyVector"
  res@vcLineArrowColor			= "Black"
  res@vcLineArrowThicknessF		= 1.2
  res@vcVectorDrawOrder			= "PreDraw"
  res@vcRefAnnoString1On    = True
  res@vcRefAnnoString2On   = False
 ; res@cnFillColors			=  (/15,14,12,-1,12,14,15/);红色的哦！！！bluered那个
 ;res@cnFillColors			= (/2,100,101/);(/"transparent","grey","gray61"/)
 res@cnFillColors			=  (/14,-1,14/);(/"yellow2","yellow","transparent","yellow","yellow2"/)


  ;do i=0,2*maxy_flag
  i=1
  ;res@cnLevels		       	= (/-rflag(i,2),-rflag(i,1),-rflag(i,0),rflag(i,0),rflag(i,1),rflag(i,2)/);bluered哦
  res@cnLevels		       	= (/-1.0*rflag(1,1),rflag(1,1)/)
	 res@gsnLeftString			= title_name
   res@gsnRightString=season
   res@gsnCenterString=""
	 wks                 		= gsn_open_wks(plottype,plotdir+plotname+".lead"+i_flag(i))
   gsn_define_colormap(wks,"BlueDarkRed18");MPL_RdBu;BlueDarkRed18;WhiteBlue
	 nc 						= NhlNewColor(wks,0.83,0.83,0.83) ;add a named color
     plot	= gsn_csm_vector_scalar_map_ce(wks,varx_plot({lvl},:,:,i),vary_plot({lvl},:,:,i),corxy_plot({lvl},:,:,i),res)

       ;;;--------------------------------------------------------------------
  y_swc           = (/21.,21.,29.,29.,21./)
  x_swc           = (/97.,107.,107.,97.,97./) 

  y_swc1           = (/28.,28.,33.,33.,28./)
  x_swc1           = (/60.,70.,70.,60.,60./) 

  y_swc2           = (/40.,40.,10.,10.,40./)
  x_swc2           = (/60.,60.,105.,105.,60./) 
  resk=True
  resk@gsFillColor  =57
  resk@gsLineThicknessF = 4.0
  resk@gsLineDashPattern = 0
  resk@gsLineColor  = "Purple"
  resk@cnFillDrawOrder ="Draw"
  dum = gsn_add_polyline(wks, plot(0), x_swc , y_swc, resk)
  resk@gsLineColor  = "black"
  ;dum2 = gsn_add_polyline(wks, plot(0), x_swc1 , y_swc1, resk)
  resk@gsLineColor  = "green"
  ;dum3 = gsn_add_polyline(wks, plot(0), x_swc2 , y_swc2, resk)

	     ;地形遮罩
       pres = True
       ;pres@gsnPanelLabelBar = False
       filename = "/mnt/e/westsouth/data/tibetan_shp/tibetan.shp"
       pres@gsLineColor = "gainsboro"
       pres@gsLineThicknessF = 2
       pres@gsEdgesOn = True;True
       pres@gsFillColor = "white";grey70;white
       pres@cnFillDrawOrder ="PreDraw"
   
       if lvl .eq. 850 then
       terrain1 = gsn_add_shapefile_polygons(wks,plot,filename,pres) 
       end if 
       draw(plot)
       frame(wks)
  ;end do 


end if
;------------------------------------------------------------------------

;########################################################################
  
if plot_flag .eq. 1

  do i=0,2*maxy_flag
  
    rflag_A					= varx_plot(:,:,i)
	rflag_A					= rflag(i,1)
	
	varx_plot(:,:,i)		= (/where(corxy_plot(:,:,i) .ge. rflag_A,varx_plot(:,:,i),0)/)
	vary_plot(:,:,i)		= (/where(corxy_plot(:,:,i) .ge. rflag_A,vary_plot(:,:,i),0)/)
  
  end do  

  res			= True
  res@gsnFrame	= False
  res@gsnDraw	= False  
  
  ;Resources for Contour 
  res@cnFillOn			= False
  res@cnLinesOn			= False
  res@cnLineLabelsOn	= False
  res@cnInfoLabelOn		= False
  res@gsnScalarContour	= True		;required for contour
  res@lbLabelBarOn		= False
  res@cnLevelSelectionMode	= "ExplicitLevels"
  res@cnFillColors			= (/"transparent","grey","gray61"/)
  
  ;Resources for map
  res@mpMinLonF		= lonmin
  res@mpMaxLonF		= lonmax
  res@mpMinLatF		= latmin
  res@mpMaxLatF		= latmax
  res@mpCenterLonF	= 180
  res@mpGeophysicalLineColor		= "blue"
  res@mpGeophysicalLineThicknessF	= 1.0
  res@mpFillOn		= False
  res@gsnAddCyclic	= False 

  font_height			= 0.02								       
  res@tmYLLabelFontHeightF	= font_height
  res@tmXBLabelFontHeightF	= font_height
  res@tiXAxisFontHeightF	= 1.2 * font_height
  res@tiYAxisFontHeightF	= 1.2 * font_height
  res@tiMainFontHeightF		= 1.2 * font_height
  
  ;res@gsnRightString		= "~S~o~N~C"
  res@gsnLeftStringOrthogonalPosF	= -0.32	;vcRefAnnoOrthogonalPosF+1.0
  res@tiMainString			= abs(monmin)+ " - " + monmax + "." + varname + "."+ymstar/100+ " - " +ymend/100
  res@tiMainOffsetYF 		= -0.04

;  res@tmXBValues		= (/30,60,90,120/)
;  res@tmXBLabels		= (/"30~S~o~N~E","60~S~o~N~E","90~S~o~N~E","120~S~o~N~E"/)
;  res@tmYLValues		= (/-60,-30,0,30/)
;  res@tmYLLabels		= (/"60~S~o~N~S","30~S~o~N~S","Eq","30~S~o~N~N"/)
;  res@tmXBMinorValues		= ispan(40,120,10)
;  res@tmYLMinorValues		= ispan(-60,30,10)

  res@tmXBMinorOn	= False
  res@tmYLMinorOn	= False
  res@tmYROn		= False
  res@tmXTOn		= False
  
  res@tmXBMajorLengthF			= 0.004
  res@tmXBMajorOutwardLengthF	= 0.004
  res@tmXBLabelDeltaF			= -0.5
  res@tmYLMajorLengthF			= 0.004
  res@tmYLMajorOutwardLengthF	= 0.004
  res@tmYLLabelDeltaF			= -0.5
;  res@vpHeightF	= 0.8
;  res@vpWidthF		= 0.7
;  res@vpXF			= 0.1
;  res@vpYF			= 0.9
  
  ;Resource for vector
  res@vcRefMagnitudeF			= 1.0 
  res@vcRefLengthF				= 0.045
  res@vcMinDistanceF			= 0.022
  res@vcMagnitudeFormat			= "@*+^sg"
  res@vcRefAnnoPerimOn			= False 
  res@vcRefAnnoOrthogonalPosF	= -1.32
  res@vcRefAnnoBackgroundColor 	= -1
  res@vcRefAnnoPerimOn			= False 
  res@vcGlyphStyle				= "CurlyVector"
  res@vcLineArrowColor			= "Black"
  res@vcLineArrowThicknessF		= 1.2
  res@vcVectorDrawOrder			= "PostDraw"
  
  do i=0,2*maxy_flag
  
	 res@cnLevels		       	= (/rflag(i,0),rflag(i,1)/)
	 res@gsnLeftString			= "lead-"+i_flag(i)
	 wks                 		= gsn_open_wks(plottype,plotdir+plotname+".lead"+i_flag(i))
	 nc 						= NhlNewColor(wks,0.61,0.61,0.61) ;add a named color
	 plot	= gsn_csm_vector_scalar_map_ce(wks,varx_plot(:,:,i),vary_plot(:,:,i),corxy_plot(:,:,i),res)
     draw(plot)
     frame(wks)
	 
  end do 
end if
;########################################################################

end  