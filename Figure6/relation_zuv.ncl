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
data="EIP_SMI"

if data .eq. "EIP_SMI" then
ts_dat		= "EIP_SMI"
ts_name		= "MAM"
ts_filedir	="/mnt/e/westsouth/yunnan/essay1/"
ts_filename	= "EIP_SMI_MAM.txt"
end if
if data .eq. "ts1" then
ts_dat		= "ts1"
ts_name		= "ts1"
ts_filedir	="/mnt/e/westsouth/data/"
ts_filename	= "output1.txt"
end if


ts_ys			= 1980			;ts start year 
ts_ye			= 2020			;ts end year 
lv_filename="Nino34_MAM.txt"

varname		= "zuv"
setup_name  = "zz"


var_dat		= "ERA5"
varname_x		= "u" 
filedir_x		=  "/mnt/e/westsouth/data/"
filename_x	= "ERA5.mon.u_component_of_wind.1950-2022.nc"
 
varname_y		= "v" 
filedir_y		= "/mnt/e/westsouth/data/"
filename_y	= "ERA5.mon.v_component_of_wind.1950-2022.nc" 

  ;;----------------------------------------------------------------------------------
  ;;----------------------------------------------------------------------------------
  ;var_4
var_dat_4	= var_dat
var_name_4	= "z"
var_filedir_4	= "/mnt/e/westsouth/data/"
var_filename_4= "ERA5_z_mon_197901_202209.nc" 

level=500
cor_reg_flag	= "reg"		; "cor" or "reg"
dtrend_flag	= 1			; 0 for raw,else for detrend
maxy_flag		= 1			; years for lead or lag the currnet year(Y(0)) 
area_flag		= 3			; significant area type,0 for x only, 1 for y only,2 for x or y,3,for sqrt(x^2,y^2)   
plot_flag		= 0			; 0 for shaded,1 for only significant area plot   
lv_flag  =0;1 for lv,0 for ts 

if lv_flag .eq. 1 then
setup_name  = "WVT_MAM&DIV VS "+data+"(lv nino34)"
end if
  ymstar		= 198001
  ymend			= 202012
   		
  latmin	=  0
  latmax	=  50
  lonmin	=  45
  lonmax	=  150

  season= "MAM(0)"	;season name
  if season .eq. "MAM(0)" then
  monmin	= 3	;starting month for averaging,(monmin != 0,-12 <= monmin <= monmax <=12). negative value for previou year(year(-1)) 
  monmax	= 5	;ending month for averaging,	   1<= monmax <= 12
  end if
  if season .eq. "JJA(0)" then
  monmin	= 6	;starting month for averaging,(monmin != 0,-12 <= monmin <= monmax <=12). negative value for previou year(year(-1))
  monmax	= 8	;ending month for averaging,	   1<= monmax <= 12
  end if
  if season .eq. "DJF(0)" then
  monmin	= -12	;starting month for averaging,(monmin != 0,-12 <= monmin <= monmax <=12). negative value for previou year(year(-1)) 
  monmax	= 2	;ending month for averaging,	   1<= monmax <= 12
  end if
  lefttitle="(i) Reg. "+level+var_name_4+" on "+data
  ;---------------------------------------------------------------------------------- 
  
  months	= (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
 
  ;options for output  
  plottype	= "pdf"                 ;type of plotting
  plotdir	= "./"
  plotname	= "Reg."+level+var_name_4+"_on_"+data+season
  savedir	= "./"
  savename	= "Reg."+level+var_name_4+"_on_"+data+season
;**********************************************************************
;Handle variable
;**********************************************************************
  ;read time series
  Ts_init		= asciiread(ts_filedir+ts_filename,ts_ye-ts_ys+1,"float")
  Ts_init!0		= "year"
  Ts_init&year	= ispan(ts_ys,ts_ye,1)
  printVarSummary(Ts_init)
  
  if data .eq. "EIP_SMI" then
  Ts			= Ts_init({year|ymstar/100:ymend/100})
  end if
  if data .eq. "ts1" then
  Ts			= -1*Ts_init({year|ymstar/100:ymend/100})
  end if
  print(Ts)
 
  if lv_flag .eq. 1 then
  lv_init		= asciiread(ts_filedir+lv_filename,ts_ye-ts_ys+1,"float")
  lv_init!0		= "year"
  lv_init&year	= ispan(ts_ys,ts_ye,1)
  printVarSummary(lv_init)
  print(lv_init)
  lv			= lv_init({year|ymstar/100:ymend/100})
  print(lv)

end if 
  ;read variable 
  f				= addfile(filedir_x+filename_x,"r")
  tim			= f->time
  u_time_DATE	= cd_calendar(tim,-1)
  tstar		= ind(u_time_DATE .eq. ymstar)
  tlast		= ind(u_time_DATE .eq. ymend)
  print(tstar)
  print(tlast)  
  
  varx			= short2flt(f->$varname_x$(tstar:tlast,{level},{latmin:latmax},{lonmin:lonmax}))
  varx!0		= "time"
  varx!1		= "lat"
  varx!2		= "lon"
  printVarSummary(varx)
  delete([/tim,u_time_DATE/])

  f				= addfile(filedir_y+filename_y,"r")
  tim			= f->time
  u_time_DATE	= cd_calendar(tim,-1)
  tstar		= ind(u_time_DATE .eq. ymstar)
  tlast		= ind(u_time_DATE .eq. ymend)
  print(tstar)
  print(tlast)  
  
  vary			= short2flt(f->$varname_y$(tstar:tlast,{level},{latmin:latmax},{lonmin:lonmax}))
  vary!0		= "time"
  vary!1		= "lat"
  vary!2		= "lon"
  printVarSummary(vary)
  
  delete([/tim,u_time_DATE/])
  f4		= addfile(var_filedir_4+var_filename_4,"r")
  tim   = f4->time
  u_time_DATE = cd_calendar(tim,-1)
  ;print(u_time_DATE)
  tstar   = ind(u_time_DATE .eq. ymstar)
  tlast   = ind(u_time_DATE .eq. ymend)
  print(tstar)
  print(tlast)  

  var_div	= short2flt(f4->$var_name_4$(tstar:tlast,{level},{latmin:latmax},{lonmin:lonmax}))
  var_div=[var_div/9.8]
  var_div!0	= "time"
  var_div!1	= "lat"
  var_div!2	= "lon"
  printVarSummary(var_div)

  varx_monave	= month_to_monave(varx,monmin,monmax)
  printVarSummary(varx_monave)
  
  vary_monave	= month_to_monave(vary,monmin,monmax)
  printVarSummary(vary_monave)
  
  var_div_monave	= month_to_monave(var_div,monmin,monmax)
  printVarSummary(var_div_monave)

  varm_monave	= sqrt(varx_monave^2+vary_monave^2)
  copy_VarCoords(varx_monave,varm_monave)
  varm_monave@long_name	= "sqrt(varx_monave^2+vary_monave^2)"
  printVarSummary(varm_monave)
  
  nyear		= dimsizes(varx_monave&year)
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
	 
   var_div_monave	= var_div_monave
    var_div_monave@detrend= dtrend_flag +"--(0 for raw data, else for detrended data)"
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

    var_div_monave	= (/dtrend_msg_n(lv,var_div_monave,False,True,0)/)
      var_div_monave@detrend= dtrend_flag +"--(0 for raw data, else for detrended data)"
    end if
     Ts						= (/dtrend_msg_n(ispan(1,nyear,1)*1.0,Ts,False,True,0)/) 
	 Ts@detrend				= dtrend_flag +"--(0 for raw data, else for detrended data)" 
	 
	 varx_monave			= (/dtrend_msg_n(ispan(1,nyear,1)*1.0,varx_monave,False,True,0)/) 
     varx_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 
	 
	 vary_monave			= (/dtrend_msg_n(ispan(1,nyear,1)*1.0,vary_monave,False,True,0)/) 
     vary_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 
	 
	 varm_monave			= (/dtrend_msg_n(ispan(1,nyear,1)*1.0,varm_monave,False,True,0)/) 
     varm_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 
  
  var_div_monave	= (/dtrend_msg_n(ispan(1,nyear,1)*1.0,var_div_monave,False,True,0)/)
  var_div_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)"

  end if
  printVarSummary(Ts)
  printVarSummary(varx_monave)
  printVarSummary(vary_monave)
  printVarSummary(varm_monave)
  
  ;Correlation or Regression  
  
  ;Correlation
  ;x->Correlation
  cor_Ts_lead_varx		= esccr(Ts,varx_monave(lat|:,lon|:,year|:),maxy_flag)
  printVarSummary(cor_Ts_lead_varx)
  
  cor_varx_lead_Ts		= esccr(varx_monave(lat|:,lon|:,year|:),Ts,maxy_flag)  
  printVarSummary(cor_varx_lead_Ts)
  
  corx								= new((/ny,nx,2*maxy_flag+1/),"float")
  corx(:,:,0:maxy_flag)				= cor_varx_lead_Ts(:,:,::-1)
  corx(:,:,maxy_flag+1:2*maxy_flag)	= cor_Ts_lead_varx(:,:,1:maxy_flag)
  
  corx!0				= "lat"
  corx&lat				= varx_monave&lat
  corx!1				= "lon"
  corx&lon				= varx_monave&lon
  corx!2				= "lead"
  corx&lead			    = ispan(-1*maxy_flag,maxy_flag,1)*1.0
  corx@long_name		= "Corrrelation--Ts lead var. If lead dimension is negative, Ts lag var" 
  ;y->Correlation
  cor_Ts_lead_vary		= esccr(Ts,vary_monave(lat|:,lon|:,year|:),maxy_flag)
  printVarSummary(cor_Ts_lead_vary)
  
  cor_vary_lead_Ts		= esccr(vary_monave(lat|:,lon|:,year|:),Ts,maxy_flag)  
  printVarSummary(cor_vary_lead_Ts)
  
  cory								= new((/ny,nx,2*maxy_flag+1/),"float")
  cory(:,:,0:maxy_flag)				= cor_vary_lead_Ts(:,:,::-1)
  cory(:,:,maxy_flag+1:2*maxy_flag)	= cor_Ts_lead_vary(:,:,1:maxy_flag)
  
  copy_VarCoords(corx,cory)
  cory@long_name		= "Corrrelation--Ts lead var. If lead dimension is negative, Ts lag var" 
  
  ;sqrt(varx^2+vary^2)
  cor_Ts_lead_varm		= esccr(Ts,varm_monave(lat|:,lon|:,year|:),maxy_flag)
  printVarSummary(cor_Ts_lead_varm)
  
  cor_varm_lead_Ts		= esccr(varm_monave(lat|:,lon|:,year|:),Ts,maxy_flag)  
  printVarSummary(cor_varm_lead_Ts)
  
  corm								= new((/ny,nx,2*maxy_flag+1/),"float")
  corm(:,:,0:maxy_flag)				= cor_varm_lead_Ts(:,:,::-1)
  corm(:,:,maxy_flag+1:2*maxy_flag)	= cor_Ts_lead_varm(:,:,1:maxy_flag)
  
  copy_VarCoords(corx,corm)
  corm@long_name		= "Corrrelation--Ts lead var. If lead dimension is negative, Ts lag var" 
  
  cor_Ts_lead_var_div		= esccr(Ts,var_div_monave(lat|:,lon|:,year|:),maxy_flag);滞后？
  printVarSummary(cor_Ts_lead_var_div)
  
  cor_var_div_lead_Ts		= esccr(var_div_monave(lat|:,lon|:,year|:),Ts,maxy_flag)  
  printVarSummary(cor_var_div_lead_Ts)

  cor_div								= new((/ny,nx,2*maxy_flag+1/),"float")
  cor_div(:,:,0:maxy_flag)				= cor_var_div_lead_Ts(:,:,::-1)
  cor_div(:,:,maxy_flag+1:2*maxy_flag)	= cor_Ts_lead_var_div(:,:,1:maxy_flag)

  cor_div!0				= "lat"
  cor_div&lat				= var_div_monave&lat
  cor_div!1					= "lon"
  cor_div&lon				= var_div_monave&lon
  cor_div!2					= "lead"
  cor_div&lead			    = ispan(-1*maxy_flag,maxy_flag,1)*1.0
  cor_div@long_name			= "Corrrelation--Ts lead var. If lead dimension is negative, Ts lag var" 
		
  ;Regression 
  reg_div					= new((/ny,nx,2*maxy_flag+1/),"float")
  do i=0,maxy_flag
  
	reg_div(:,:,maxy_flag-i)	= regCoef(Ts(i:nyear-1),var_div_monave(lat|:,lon|:,year|0:nyear-i-1))			
    reg_div(:,:,maxy_flag+i)	= regCoef(Ts(0:nyear-i-1),var_div_monave(lat|:,lon|:,year|i:nyear-1))
		
  end do	

  reg_div!0					= "lat"
  reg_div&lat				= var_div_monave&lat
  reg_div!1					= "lon"
  reg_div&lon				= var_div_monave&lon
  reg_div!2					= "lead"
  reg_div&lead			    = ispan(-1*maxy_flag,maxy_flag,1)*1.0
  reg_div@long_name			= "Regression--Ts lead var. If lead dimension is negative, Ts lag var"   
  ;Regression 
  regx					= new((/ny,nx,2*maxy_flag+1/),"float")
  regy					= new((/ny,nx,2*maxy_flag+1/),"float")
  
  do i=0,maxy_flag
  
	regx(:,:,maxy_flag-i)	= regCoef(Ts(i:nyear-1),varx_monave(lat|:,lon|:,year|0:nyear-i-1))			
    regx(:,:,maxy_flag+i)	= regCoef(Ts(0:nyear-i-1),varx_monave(lat|:,lon|:,year|i:nyear-1))
	
	regy(:,:,maxy_flag-i)	= regCoef(Ts(i:nyear-1),vary_monave(lat|:,lon|:,year|0:nyear-i-1))			
    regy(:,:,maxy_flag+i)	= regCoef(Ts(0:nyear-i-1),vary_monave(lat|:,lon|:,year|i:nyear-1))	
	
  end do	
		
  copy_VarCoords(corx,regx)
  regx@long_name		= "Regression--Ts lead var. If lead dimension is negative, Ts lag var"   
  
  copy_VarCoords(corx,regy)
  regy@long_name		= "Regression--Ts lead var. If lead dimension is negative, Ts lag var"  
  
  delete([/varx,vary,cor_Ts_lead_vary,cor_varx_lead_Ts,cor_Ts_lead_varx,cor_vary_lead_Ts,cor_Ts_lead_varm,cor_varm_lead_Ts/])

  if cor_reg_flag .eq. "cor"
   
	cor_reg_x			= corx
    cor_reg_y			= cory
	cor_reg_div      = cor_div
  end if 
   
  if cor_reg_flag .eq. "reg"
	
	cor_reg_x				= regx
	cor_reg_y				= regy
  cor_reg_div      = reg_div
	
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

  cor_div@tValue			= tValue
  cor_div@tValue_desc		= "Critical t Value for 0.1,0.05,001 significant level"
  
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
    
  corxy_plot			= (/abs(cor_div)/)
  varx_plot				= cor_reg_x
  vary_plot				= cor_reg_y
  var_div_plot      = cor_reg_div
  printVarSummary(corxy_plot)
  printVarSummary(varx_plot)
  printVarSummary(vary_plot)
  printVarSummary(var_div_plot)
  

  corxy_plot_area		= corxy_plot({lat|latmin:latmax},{lon|lonmin:lonmax},lead|:)
  varx_plot_area		= varx_plot({lat|latmin:latmax},{lon|lonmin:lonmax},lead|:)
  vary_plot_area		= vary_plot({lat|latmin:latmax},{lon|lonmin:lonmax},lead|:)
  var_div_plot_area	= var_div_plot({lat|latmin:latmax},{lon|lonmin:lonmax},lead|:)
  printMinMax(corxy_plot_area,True)
  printMinMax(varx_plot_area,True)
  printMinMax(vary_plot_area,True)
  printMinMax(var_div_plot_area,True)
  i_flag				= "(" + ispan(-maxy_flag,maxy_flag,1) + ")"  
  
;------------------------------------------------------------------------  
  ;Plotting
  ;**********************************************************************
  ;--------------------------------------------
  ;Shaded plot resources
  if plot_flag .eq. 0 
  res			= True
  res@gsnFrame	= False
  res@gsnDraw	= False  
  ;--------------------------------------------
  ;Resources for Contour 
  res@cnFillOn			= True
  res@cnLinesOn			= False
  res@cnLineLabelsOn	= False
  res@cnInfoLabelOn		= False
  ;res@gsnScalarContour	= True		;required for contour
  res@lbLabelBarOn		= True
  
  res@gsnLeftString		 = ""
  res@gsnRightString         = ""
  res@tiMainString           = ""
  ;--------------------------------------------
  ;Resources for map
  res@mpMinLonF		= lonmin
  res@mpMaxLonF		= lonmax
  res@mpMinLatF		= latmin
  res@mpMaxLatF		= latmax
  res@mpCenterLonF	= 0
  ;;-----------------------------------------------------------
  res@mpDataSetName = "/mnt/e/nclstudy/nclscripts/Earth..4"
  res@mpDataBaseVersion = "MediumRes" ; or "Ncarg4_1"
  ;sres@mpOutlineOn = True
  ;sres@mpOutlineSpecifiers = (/"China","China:Provinces"/)
  res@mpOutlineSpecifiers = (/"China:Yunnan"/)
  ;sres@mpOutlineBoundarySets = "NoBoundaries"
  ;sres@Geophysical = "NoBoundaries"
  ;res@mpNationalLineThicknessF = 4.0
  res@mpFillAreaSpecifiers = (/"land","water","China"/)
  res@mpSpecifiedFillColors = (/"white","white","transparent"/)
  res@mpFillDrawOrder = "Draw"
  
    res@mpCenterLonF	= 180
    res@mpGeophysicalLineColor		= "blue"
    res@mpGeophysicalLineThicknessF	= 1.0
    res@mpFillOn		= False
    res@gsnAddCyclic	= False 
  
    font_height			= 0.024								       
    res@tmYLLabelFontHeightF	= 0.95*font_height
    res@tmXBLabelFontHeightF	= 0.95* font_height
    res@tiXAxisFontHeightF	= 1 * font_height
    res@tiYAxisFontHeightF	= 1 * font_height
    res@tiMainFontHeightF		= 1.2 * font_height
    res@gsnLeftStringFontHeightF  = 1.2 * font_height
    res@gsnRightStringFontHeightF  = 1.2*font_height

    ;res@gsnRightString		= "~S~o~N~C"
   ; res@gsnLeftStringOrthogonalPosF	= -0.2	;vcRefAnnoOrthogonalPosF+1.0
    res@tiMainString			= ""
    res@tiMainOffsetYF 		= 0

  ; res@tiMainFont                 = "helvetica-bold"
  ; res@tiXAxisFont                = "helvetica-bold"
  ; res@tmXBLabelFont              = "helvetica-bold"
  ; res@tmYLLabelFont              = "helvetica-bold"
  ; res@lbLabelFont                = "helvetica-bold"
  ; res@lgLabelFont                = "helvetica-bold"
  ; res@gsnStringFont              = "helvetica-bold"
  ; res@tiMainFont                 = "helvetica-bold"
  ;;------------------------------------------------------------------
  res@tmXBMinorOn	= False
  res@tmYLMinorOn	= False
  res@tmYROn		= False
  res@tmXTOn		= False
  res@gsnMajorLonSpacing = 20
  res@gsnMajorLatSpacing = 10
  ;;-------------------------------------------------------------------
  res@tmXBMajorLengthF			= 0.004
  res@tmXBMajorOutwardLengthF	= 0.004
  res@tmXBLabelDeltaF			= -0.5
  res@tmYLMajorLengthF			= 0.004
  res@tmYLMajorOutwardLengthF	= 0.004
  res@tmYLLabelDeltaF			= -0.5
  ;;-------------------------------------------------------------------
  ;;;;----------label bar--------------
  res@lbBoxMinorExtentF   = 0.35 ;
  ;res@lbLabelFont         = "times-roman"
  res@lbLabelStride       = 1
  res@lbOrientation		= "horizontal"
  res@lbLabelFontThicknessF = 0.05
  ; res@lbBoxEndCapStyle   = "TriangleBothEnds";RectangleEnds
  res@lbLabelBarOn         = True;True;

  ;;------------------------------------------------------------------------

  ; res@vpHeightF	= 0.8
  ; res@vpWidthF		= 0.7
;  res@vpXF			= 0.1
;  res@vpYF			= 0.9
  ;;-------------------------------------------------------------------
  ;res@gsnRightString		= "~S~o~N~C"
  ;res@gsnLeftStringOrthogonalPosF	= -0.18	;vcRefAnnoOrthogonalPosF+1.0上下移动位置
  ;res@gsnLeftStringParallelPosF     = -0.50
  ;res@tiMainString			= abs(monmin)+ " - " + monmax + "."+ lvl +" hPa." + varname + "."+ymstar/100+ " - " +ymend/100
  ;res@tiMainOffsetYF 		= -0.04
 ;;-------------------------------------------------------------------
;  res@tmXBValues		= (/30,60,90,120/)
;  res@tmXBLabels		= (/"30~S~o~N~E","60~S~o~N~E","90~S~o~N~E","120~S~o~N~E"/)
;  res@tmYLValues		= (/-60,-30,0,30/)
;  res@tmYLLabels		= (/"60~S~o~N~S","30~S~o~N~S","Eq","30~S~o~N~N"/)
;  res@tmXBMinorValues		= ispan(40,120,10)
;  res@tmYLMinorValues		= ispan(-60,30,10)
 ;;-------------------------------------------------------------------
 ;;-------------------------------------------------------------------  
  ;;Resource for vector
  vres		= True
  vres@gsnFrame	= False
  vres@gsnDraw	= False
  ;;---------------------------------------------------------------------
  vres@vcRefMagnitudeF			= 0.5
  vres@vcRefLengthF				= 0.035
  vres@vcMinDistanceF			= 0.035;0.022
  vres@vcMagnitudeFormat			= "@*+^sg"
  vres@vcRefAnnoOn				= True	
  vres@vcRefAnnoOrthogonalPosF	= -1.25
  ; vres@vcRefAnnoBackgroundColor 	= -1.0 
  vres@vcRefAnnoPerimOn			= True;False 
  vres@vcGlyphStyle				= "CurlyVector"
  vres@vcLineArrowColor			= "Black"
  vres@vcLineArrowThicknessF		= 1.5;1.2
  vres@vcVectorDrawOrder			= "PostDraw"
  vres@vcRefAnnoString1On    = True
  vres@vcRefAnnoString2On   = False
 ;;-------------------------------------------------------------------
  ;;------------------------------------------------------------
  vres@gsnLeftString		 = "";+" units: 10~S~-4~N~ kg/(m~S~-2~N~ s)"
  vres@gsnRightString         = ""
  vres@tiMainString           = ""
  vres@tiMainFontHeightF       = 0.0120
   res@gsnLeftStringOrthogonalPosF	= 0.01
   res@gsnRightStringOrthogonalPosF	= 0.01
  ;;-------------------------------------------------------------------------------

  wks                 		= gsn_open_wks(plottype,plotdir+plotname)

 
  plot	= gsn_csm_vector(wks,varx_plot(:,:,1),vary_plot(:,:,1),vres)
  ;;;--------------------------------------------------------------------
       ;;-------------------------------------------------------------
       y           =(/28.,28.,33.,33.,28./)
       x           = (/60.,70.,70.,60.,60./) ;;NINO34
     
       y2           = (/21.,21.,29.,29.,21./)
       x2           = (/97.,107.,107.,97.,97./) 
     
       y3           =(/5.,5.,25.,25.,5./)
       x3           = (/45.,90.,90.,45.,45./) ;;NIOS
         resk=True
         resk@gsFillColor  =57
         resk@gsLineThicknessF = 4.0
         resk@gsLineDashPattern =0
         resk@gsLineColor  = "black"
         resk@cnFillDrawOrder ="Draw"
       ;;--------------------------------------------------------------------------------
       ;dum1=gsn_add_polyline(wks,plot(0), x, y, resk)
       resk@gsLineColor  = "Purple"
       dum2=gsn_add_polyline(wks,plot(0), x2, y2, resk)
       resk@gsLineColor  = "green"
       ;dum3=gsn_add_polyline(wks,plot(0), x3, y3, resk)
  ;;------------------------------------------------------------------
  gsn_define_colormap(wks,"BlueDarkRed18");BlueDarkRed18;cmp_b2r;NCV_blue_red
  res@cnLevelSelectionMode ="ManualLevels"    ;手动设置等值线
  res@cnMinLevelValF       = -8
  res@cnMaxLevelValF       = 8
  res@cnLevelSpacingF      = 2
  
  res@gsnLeftStringOrthogonalPosF	= 0.01
  res@gsnRightStringOrthogonalPosF	= 0.01
  res@gsnLeftString		 = lefttitle
  res@gsnRightString         = season
  res@tiMainString           = ""

  res@pmLabelBarOrthogonalPosF     = 0.11
  res@pmLabelBarWidthF    = 0.7
  res@pmLabelBarHeightF   = 0.08
  res@gsnAddCyclic					= False
   ;;-------------------------------------------------------------------
   resp					= True
   resp@gsnDraw			= False
   resp@gsnFrame			= False
   
   resp@cnFillOn					= True
   resp@cnLinesOn					= False
   resp@cnLineLabelsOn			= False
   resp@cnInfoLabelOn    			= False
   resp@cnMonoFillPattern			= False
   
   resp@cnFillPatterns			= (/17,-1,17/)
   resp@cnFillDotSizeF			= 0.005
   resp@cnFillScaleF=2
   resp@cnLevelSelectionMode		= "ExplicitLevels"
   resp@cnFillColors=(/"black","white","black"/)
   resp@gsnAddCyclic					= False
   resp@cnLevels				= (/-1.0*rflag(1,1),rflag(1,1)/)
  ;var_div_plot(:,:,:)    = (/2*10.0^4*var_div_plot(:,:,:)/)
  ploth	=  gsn_csm_contour_map_overlay(wks,var_div_plot({latmin:latmax},{lonmin:lonmax},1),corxy_plot({latmin:latmax},{lonmin:lonmax},1),res,resp)
 ; ploth	=  gsn_csm_contour_map(wks,var_div_plot({latmin:latmax},{lonmin:lonmax},1),res)
  overlay(ploth,plot)

;  plott	=  gsn_csm_contour(wks,tvalue_plot_area({m},:,:),resp)
;  overlay(ploth,plott)
  draw(ploth)
  frame(wks)
end if

end