load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/mnt/e/mytool.ncl"
begin
;**********************************************************
;A program for calculating interannual Composite for seasonal 3-D scalar field variable

;Plot( User should adjust the cnLevels and cnFillColors accroding to different statistics)
;**********************************************************
;User can select:
				
;		a. detrend or not 

;		b. critical value for selecting year, such as: 0.5 or 1.0 of std

;		c. different composite, such as: low-ave, for high-low, for high-ave

;		e. different plot for significant level

;		f. different plot for average

;**********************************************************
;Options for user
  ;input Control

  ts_ys			= 1980			;ts start year 
  ts_ye			= 2020			;ts end year 


  varname="700wind"
  lvl=700
  season=3
  if season .eq. 3 then
  monname=(/"MAM","JJA"/)
  monmin	= (/3,6/)	;starting month for averaging,(monmin != 0,-12 <= monmin <= monmax <=12). negative value for previou year(year(-1)) 
  monmax	= (/5,8/)	;ending month for averaging,	   1<= monmax <= 12 
  plotmon=(/35,68/)
  stringplot=(/"a","d"/)
  end if 
  if season .eq. 1 then
  monmin=(/3,4,5,6,7,8/)
  monmax=(/3,4,5,6,7,8/)
  plotmon=(/3,4,5,6,7,8/)
  stringplot=(/"a","b","c","d","e","f"/)
  monname=(/"Mar","Apr","May","Jun","Jul","Aug"/)
  end if
  var_dat_1		= "ERA5"

  varname_1		= "u" 
  filedir_1		= "/mnt/e/westsouth/data/"
  filename_1		= "ERA5_u_mon_197901_202209.nc"

  var_dat_2		= "ERA5"
  varname_2		= "v"   
  filedir_2		= "/mnt/e/westsouth/data/"
  filename_2		= "ERA5_v_mon_197901_202209.nc"

  ymstar		= 198001
  ymend			= 202012
  plotyear=2019
  dtrend_flag=1

  latmin	=  0
  latmax	=  40
  lonmin	=  45
  lonmax	=  150


  
  std_flag	= 1	; standardized or not, 0 for raw data , else for standardized data
  critic_flag	= 1	; critical value for selecting year
  plotd_flag	= 1	; 0 for contour,1 for dot Shaded,2 for color shaded,3 for only significant area plot(not used right now) 
  plota_flag	= 2 	; 0 for contour, 1 for shaded, 2 for contour + shaded
  
 ;output Control
  plottype	= "pdf"
  plotname	= varname+"_"+season+"_"+"_"+var_dat_1+"_"+var_dat_2+"_"+ymstar/100+"-"+ymend/100
  plotdir	= "./"
  savename	= varname+"_"+season+"_"+"_"+var_dat_1+"_"+var_dat_2+"_"+ymstar/100+"-"+ymend/100
  savedir	= "./"
;**********************************************************************
;Handle variable
;**********************************************************************
  ;read time series
  ;read variable 
  f1		= addfile(filedir_1+filename_1,"r")
  tim		= f1->time
  u_time_DATE	= cd_calendar(tim,-1)
  tstar		= ind(u_time_DATE .eq. ymstar)
  tlast		= ind(u_time_DATE .eq. ymend)
  print(tstar)
  print(tlast)  
  ;var1111111111111111111111111111111111111111111111111111111

  var_1		= short2flt(f1->$varname_1$(tstar:tlast,{(/lvl/)},{latmin:latmax},{lonmin:lonmax}))
  var_1!0		= "time"
  ;var_1!1		= "level"
  var_1!1		= "lat"
  var_1!2		= "lon"
  printVarSummary(var_1)

  nyear=ymend/100-ymstar/100+1
  dims= dimsizes(var_1)
  print(dims)

   var_new=new((/nyear,num(plotmon),dims(1),dims(2)/),typeof(var_1),var_1@_FillValue)
   var_ano=new((/nyear,num(plotmon),dims(1),dims(2)/),typeof(var_1),var_1@_FillValue)
   var_extreme=new((/nyear,num(plotmon),dims(1),dims(2)/),typeof(var_1),var_1@_FillValue) 

   do i=0,num(plotmon)-1  
   var_mon = month_to_monave(var_1,monmin(i),monmax(i))
   printVarSummary(var_mon)
   var_new(:,i,:,:)=var_mon
 end do
   var_new!1="month"
   var_new&month=plotmon
     printVarSummary(var_new)
 

    ;var2222222222222222222222222222222222222222222222222222
    f2		= addfile(filedir_2+filename_2,"r")

  var_2		= short2flt(f2->$varname_2$(tstar:tlast,{(/lvl/)},{latmin:latmax},{lonmin:lonmax}))
  ;var   =(/var/100/)
  var_2!0		= "time"
  ;var_2!1		= "level"
  var_2!1		= "lat"
  var_2!2		= "lon"
  printVarSummary(var_2)


   var_new2=new((/nyear,num(plotmon),dims(1),dims(2)/),typeof(var_2),var_2@_FillValue)
   var_ano2=new((/nyear,num(plotmon),dims(1),dims(2)/),typeof(var_2),var_2@_FillValue)
   var_extreme2=new((/nyear,num(plotmon),dims(1),dims(2)/),typeof(var_2),var_2@_FillValue) 

   do i=0,num(plotmon)-1  
   var_mon2 = month_to_monave(var_2,monmin(i),monmax(i))
   printVarSummary(var_mon2)
   var_new2(:,i,:,:)=var_mon2
  end do
    var_new2!1="month"
    var_new2&month=plotmon
      printVarSummary(var_new2)

      varm_monave	= sqrt(var_new^2+var_new2^2)
      printVarSummary(varm_monave)
      copy_VarCoords(var_new,varm_monave)
      varm_monave@long_name	= "sqrt(varx_monave^2+vary_monave^2)"
      printVarSummary(varm_monave)
      

  ;detrend or not
  if dtrend_flag .eq. 0 then  
    var_new = var_new
    var_new2 = var_new2
    varm_monave = varm_monave     
    else
    var_new	= (/dtrend_msg_n(ispan(1,dimsizes(var_new&year),1)*1.0,var_new,False,True,0)/)
    var_new2	= (/dtrend_msg_n(ispan(1,dimsizes(var_new2&year),1)*1.0,var_new2,False,True,0)/)
    varm_monave  = (/dtrend_msg_n(ispan(1,dimsizes(varm_monave&year),1)*1.0,varm_monave,False,True,0)/)

    end if
    var_ori=var_new
    var_ori2=var_new2
    var_ori3=varm_monave

    var_ano3=new((/nyear,num(plotmon),dims(1),dims(2)/),typeof(varm_monave),varm_monave@_FillValue)
    var_extreme3=new((/nyear,num(plotmon),dims(1),dims(2)/),typeof(varm_monave),varm_monave@_FillValue) 

  
    do i=0,nyear-1
    do j=0,num(plotmon)-1
    var_ano(i,j,:,:)=var_new(i,j,:,:)-dim_avg_n_Wrap(var_new(:,j,:,:),0)
    var_ano2(i,j,:,:)=var_new2(i,j,:,:)-dim_avg_n_Wrap(var_new2(:,j,:,:),0)
    var_ano3(i,j,:,:)=varm_monave(i,j,:,:)-dim_avg_n_Wrap(varm_monave(:,j,:,:),0)
  
    end do
    end do
    copy_VarCoords(var_new,var_ano)
    copy_VarCoords(var_new2,var_ano2)
    copy_VarCoords(varm_monave,var_ano3)

    printVarSummary(var_ano)
    printVarSummary(var_ano2)
    printVarSummary(var_ano3)
    

    var_std=dim_stddev_n_Wrap(var_ori,0);标准化
    var_std2=dim_stddev_n_Wrap(var_ori2,0);标准化
    var_std3=dim_stddev_n_Wrap(var_ori3,0);标准化
    printVarSummary(var_std)

    do i=0,nyear-1
    var_extreme_p=where(var_ano(i,:,:,:) .ge. var_std,1,0)
    var_extreme_n=where(var_ano(i,:,:,:) .le. -1.0*var_std,-1,0)
    var_extreme_p2=where(var_ano2(i,:,:,:) .ge. var_std2,1,0)
    var_extreme_n2=where(var_ano2(i,:,:,:) .le. -1.0*var_std2,-1,0)
    var_extreme_p3=where(var_ano3(i,:,:,:) .ge. var_std3,1,0)
    var_extreme_n3=where(var_ano3(i,:,:,:) .le. -1.0*var_std3,-1,0)
    var_extreme(i,:,:,:)=var_extreme_p+var_extreme_n
    var_extreme2(i,:,:,:)=var_extreme_p2+var_extreme_n2
    var_extreme3(i,:,:,:)=var_extreme_p3+var_extreme_n3
  end do 
    copy_VarCoords(var_ano,var_extreme);将std的信息复制给extreme
    copy_VarCoords(var_ano2,var_extreme2);将std的信息复制给extreme
    copy_VarCoords(var_ano3,var_extreme3);将std的信息复制给extreme
    printVarSummary(var_extreme)
    printMinMax(var_extreme,0)
    printVarSummary(var_extreme3)
    printMinMax(var_extreme3,0)
    
 plot_extreme=var_extreme3({plotyear},:,:,:)
 plot_u=var_ano({plotyear},:,:,:)
  plot_v=var_ano2({plotyear},:,:,:)
  
  ;Plotting
  ;**********************************************************************
  ;--------------------------------------------
  ;Shaded plot resources

 ;;-------------------------------------------------------------------
  ;;------------------------------------------------------------
  ;;-------------------------------------------------------------------------------
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

  font_height			= 0.02					       
  res@tmYLLabelFontHeightF	= 1.2*font_height
  res@tmXBLabelFontHeightF	= 1.2*font_height
  res@tiXAxisFontHeightF	= 1.2 * font_height
  res@tiYAxisFontHeightF	= 1.2 * font_height
  res@tiMainFontHeightF		= 1.2 * font_height
  res@gsnLeftStringFontHeightF  = 1.2 * font_height
  res@gsnRightStringFontHeightF=1.2 *font_height
  ;res@gsnRightString		= "~S~o~N~C"
  res@gsnLeftStringOrthogonalPosF	= 0.01	;vcRefAnnoOrthogonalPosF+1.0
  res@gsnRightStringOrthogonalPosF=0.01
  res@tiMainString			= ""
  res@tiMainOffsetYF 		= 0

  
  res@tmXBValues  = ispan(45,150,15)
  res@tmXBLabels  = ispan(45,150,15)+"E"
 ;  res@tmYLValues   = (/-60,-30,0,30/)
 ;  res@tmYLLabels   = (/"60~S~o~N~S","30~S~o~N~S","Eq","30~S~o~N~N"/)
 ;  res@tmXBMinorValues    = ispan(40,120,10)
 ;  res@tmYLMinorValues    = ispan(-60,30,10)
 res@tmYLValues = ispan(0,50,10);(/-60,-30,0,30/)
 res@tmYLLabels  = ispan(0,50,10)+"N";(/"60~S~o~N~S","30~S~o~N~S","Eq","30~S~o~N~N"/)
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
  ; res@gsnMajorLatSpacing=10
  ; res@gsnMajorLonSpacing=15

;  res@vpHeightF	= 0.8
;  res@vpWidthF		= 0.7
;  res@vpXF			= 0.1
;  res@vpYF			= 0.9
  
  ;Resource for vector
  res@vcRefMagnitudeF			= 2
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
 res@cnFillColors			= (/13,-1,13/);(/"transparent","grey","gray61"/)
 res@cnLevels		       	= (/-0.5,0.5/)
  res@gsnRightString		= "2019"

  wks                 		= gsn_open_wks(plottype,plotdir+plotname)
  gsn_define_colormap(wks,"BlueDarkRed18");MPL_RdBu;BlueDarkRed18;WhiteBlue
  nc 						= NhlNewColor(wks,0.83,0.83,0.83) ;add a named color

  plot=new(num(plotmon),graphic)
  plott=new(num(plotmon),graphic)
  terrain1=new(num(plotmon),graphic)
dum=new(num(plotmon),graphic)
dum2=new(num(plotmon),graphic)
do i=0,num(plotmon)-1


if i.eq.0 then  
res@gsnLeftString		 = "(c) Ano. 700wind_MAM"
end if 
if i.eq.1 then
res@gsnLeftString		 = "(f) Ano. 700wind_JJA"
end if
  plot(i) 	= gsn_csm_vector_map(wks,plot_u(i,:,:),plot_v(i,:,:),res)
  plot(i)	= gsn_csm_vector_scalar_map_ce(wks,plot_u(i,:,:),plot_v(i,:,:),plot_extreme(i,:,:),res)

  ;;;--------------------------------------------------------------------
  y_swc           = (/21.,21.,29.,29.,21./)
  x_swc           = (/97.,107.,107.,97.,97./) 

  ; y_swc           = (/40.,40.,60.,60.,40./)
  ; x_swc           = (/0.,35.,35.,0.,0./) 
  resk=True
  resk@gsnFrame	= False
  resk@gsnDraw	= False  
  resk@gsFillColor  =57
  resk@gsLineThicknessF = 4.0
  resk@gsLineDashPattern = 0
  resk@gsLineColor  = "purple"
  resk@cnFillDrawOrder ="PostDraw"
  dum(i) = gsn_add_polyline(wks, plot(i), x_swc , y_swc, resk)
  ;;------------------------------------------------------------------


  ;draw(ploth(m))
  ;frame(wks)
  if lvl.eq.850 then 
  pres = True
  ;pres@gsnPanelLabelBar = False
  filename = "/mnt/e/westsouth/data/tibetan_shp/tibetan.shp"
  pres@gsLineColor = "gainsboro"
  pres@gsLineThicknessF = 2
  pres@gsEdgesOn = False;True
  pres@gsFillColor = "white";grey70;white
  pres@cnFillDrawOrder ="Draw"
  terrain1(i) = gsn_add_shapefile_polygons(wks, plot(i),filename, pres) 
  end if
  end do
  if season .eq. 1 then
gsn_panel(wks, plot, (/2,3/), True)
end if 
if season .eq. 3 then
gsn_panel(wks, plot, (/2,1/), True)
end if;draw(plot)
  end