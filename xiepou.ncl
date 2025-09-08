load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/mnt/e/mytool.ncl"
;; Main code
;;要先输出reg的u,v,w的nc文件，然后再读取这些nc文件，然后再画图（level*lat*lon）
;;需要改的有：n(年份)、所需要level、nlabels就是你想设几个横坐标、npts是你想插值格点的数量，leftlat、leftlon、rightlat、rightlon是你想要的斜剖线左端和右端的经纬度
;;---------------------------------------------------------------------
begin

;------------------------------------------------------------------------------------ 
  ;var for space distribution
  var_dat       = "ERA5"  
  var_filedir   = "./"
 
  varname1       = "u"
  var_filename1  = "EIP_reg_u.nc"

  varname2       = "v"  
  var_filename2  = "EIP_reg_v.nc"

  varname3      = "w"  
  var_filename3 = "EIP_reg_w.nc"
;------------------------------------------------------------------------------------

;spatial distribution
  lvlmin = 100
  lvlmax = 1000

 LS     = "(b) Reg. u&w on EIP_SMI"
 RS    = "MAM(0)"

 vcf = 2
 nLabels      = 8

 leftlat=40
 leftlon=60

 rightlat=10
 rightlon=105

 npts = 15
 N1=npts-1
  ;output 
 ;----------------------------------------
 plottype      = "pdf"
 plotdir       =  "./"
 plotname      = LS+"_"+RS

;**********************************************************************
;Handle variable

  ;--------------------------------------------------------
  ;red var
  fu             = addfile(var_filedir+var_filename1, "r")
  fv             = addfile(var_filedir+var_filename2, "r")
  fw             = addfile(var_filedir+var_filename3, "r")


  var_u		= short2flt(fu->$varname1$({200:1000},:,:))
  var_u!0		= "level"
  var_u!1		= "lat"
  var_u!2		= "lon"
  printVarSummary(var_u)
  printMinMax(var_u,0)

  var_v         = short2flt(fv->$varname2$({200:1000},:,:))

  var_w         = short2flt(fw->$varname3$({200:1000},:,:))
  cor_w         = short2flt(fw->cor_w({200:1000},:,:))
  copy_VarCoords(var_u,var_v)
  copy_VarCoords(var_u,var_w)

  dist = gc_latlon(leftlat,leftlon,rightlat,rightlon,npts,2)
  lat_new = dist@gclat
  lon_new = dist@gclon
  points = ispan(0,npts-1,1)*1.0
  print (lat_new+"  "+lon_new )  ; print the lats/lons


  XBValues_pos    = toint(fspan(0,N1,nLabels) )
  XBLabels_pos    = new(nLabels,"string")
  do i=0,nLabels-1
  x = lon_new(XBValues_pos(i))
  y = lat_new(XBValues_pos(i))
  XBLabels_pos(i) = sprintf("%3.1f", y)+"N"+"~C~"+sprintf("%3.1f", x)+"E"
  end do
print(XBValues_pos)
print(XBLabels_pos)

  ;interpolate data to great circle
  var_u_cross = linint2_points_Wrap(var_u&lon,var_u&lat,var_u,True,dist@gclon,dist@gclat,0)
  var_v_cross = linint2_points_Wrap(var_v&lon,var_v&lat,var_v,True,dist@gclon,dist@gclat,0)
  var_w_cross = linint2_points_Wrap(var_w&lon,var_w&lat,var_w,True,dist@gclon,dist@gclat,0)
  cor_w_cross = linint2_points_Wrap(cor_w&lon,cor_w&lat,cor_w,True,dist@gclon,dist@gclat,0)
  printVarSummary(var_u_cross)
  printMinMax(var_w_cross,0)
;------------------------------------------------------
  ; system("/bin/rm -f "+plotdir+"ERA5_uvw_mon_1.0_1980_2022_JJA.nc")
  ; fo                 = addfile(plotdir+"ERA5_uvw_mon_1.0_1980_2022_JJA.nc","c")
  ; filedimdef(fo,"time",-1,True)
  ; fo->u        = var_u
  ; fo->v        = var_v
  ; fo->w        = var_w
;------------------------------
 
  ;--------------------------------------------------------------------------------------------------------------
   tValue		= new(3,"float")				
   rflag	  = new(3,"float")
    n				= 41
   tValue	  = cdft_t((/1-0.05,1-0.025,1-0.005/),(/n-2,n-2,n-2/))
   rflag		= sqrt(tValue^2/(n-2+tValue^2))
   rflag		= round(rflag*100.0,0)/100.0		;round the float data
  ;--------------------------------------------------------------------------------------------------------------
  var_v_cross@tValue			  = tValue
  var_v_cross@tValue_desc	= "Critical t Value for 0.1,0.05,001 significant level"
  var_v_cross@rflag				= rflag
  var_v_cross@rflag_desc		= "Critical correlation for 0.1,0.05,001 significant level"
   printVarSummary(var_v_cross)

  ;save anomaly data 
  savedir    =  "./"
  savename1  = "40.60_10.105.vw_cross"

;plotting
;*********************************************************************************************************************
  wks       = gsn_open_wks(plottype,plotdir+plotname)
  gsn_define_colormap(wks,"BlueDarkRed18") ; BlueDarkRed18   cmp_b2r

  res               = True
  res@gsnDraw       = False
  res@gsnFrame      = False
  res@gsnAddCyclic  = False  ; region only

  res@cnLinesOn         = False
  res@cnLineLabelsOn    = False
  res@cnInfoLabelOn     = False
  res@cnFillOn          = True
  res@cnFillDrawOrder       = "PreDraw"

  ; Resources for Axis
  font_height               = 0.016                                 
  res@tmYLLabelFontHeightF  = font_height
  res@tmXBLabelFontHeightF  = font_height
  res@tiXAxisFontHeightF    = 1.2 * font_height
  res@tiYAxisFontHeightF    = 1.2 * font_height
  res@tiMainFontHeightF     = 1.2 * font_height
  res@tiMainOffsetYF        = -0.01
  res@gsnLeftStringFontHeightF=1.25 * font_height
  res@gsnRightStringFontHeightF=1.25 * font_height
  res@vpHeightF	= 0.5
  res@vpWidthF		= 0.73
  ; res@gsnStringFont              =  "helvetica-bold"
  ; res@tiMainFont                 = "helvetica-bold"
  ; res@tiXAxisFont                = "helvetica-bold"
  ; res@tmXBLabelFont              = "helvetica-bold"
  ; res@tmYLLabelFont              = "helvetica-bold"
  ; res@lbLabelFont                = "helvetica-bold"
  ; res@vcRefAnnoFont              ="helvetica-bold"

  ; res@lgLabelFont                ="helvetica-bold"
  ; res@gsnStringFont              =  "helvetica-bold"
  ; res@tiMainFont                 = "helvetica-bold"

  ;Resource for vector
  res@vcRefMagnitudeF     = vcf
  res@vcRefAnnoFontHeightF= 0.015
  res@vcRefLengthF        = 0.035
  res@vcMinDistanceF      = 0.03;0.025
  res@vcMagnitudeFormat     = "@*+^sg"
  res@vcFillArrowEdgeThicknessF = 0.3
  res@vcRefAnnoOn       = True  
  res@vcRefAnnoOrthogonalPosF = -1.13;-1.185
  res@vcRefAnnoParallelPosF = 0.97
  ;res@vcRefAnnoBackgroundColor  = "White"; -1.
  res@vcRefAnnoPerimOn      = True 
  ; res@vcGlyphStyle       = "CurlyVector"
  res@vcLineArrowColor   = "black"
  ;res@vcPositionMode     = "ArrowHead"
  res@vcGlyphStyle		   = "CurlyVector";FillArrow;LineArrow;CurlyVector
  res@vcRefAnnoString2On = False
  res@vcRefAnnoString1On    = True

  res@vcMinAnnoFontHeightF  = True
  res@vcMinAnnoFontHeightF   = 0.15

   res@vcLineArrowThicknessF = 3.

    res@tmXBMinorOn        = False
    res@tmYLMinorOn        = False
    res@tmXTOn             = False
    res@tmYROn             = False
    res@tmYRLabelsOn       = False
    res@tmYRMode           = "Automatic"

    res@tmYLMode              = "Explicit"
    res@tmYLValues            = (/200,250,300,400,500,600,700,850,1000/)
    res@tmYLLabels            = res@tmYLValues+"hPa"
    res@pmTickMarkDisplayMode="Always"
    res@tmYLLabelFontHeightF = 0.025

    res@tmXBMode              = "Explicit"
    res@tmXBValues          = XBValues_pos
    res@tmXBLabels          = XBLabels_pos

    res@tmYLMinorOn        = False
    res@tiYAxisString=""

    res@cnLevelSelectionMode	= "ExplicitLevels"
    res@cnFillColors			=  (/14,-1,14/);(/"yellow2","yellow","transparent","yellow","yellow2"/)
    res@cnLevels		       	= (/-rflag(1),rflag(1)/)
    res@cnMissingValFillColor    = "gray40" ; set color for missing areas

;------------------------------------------------------------------------------------------------------------------
  ; res@vpWidthF  = 0.43
  ; res@vpHeightF = 0.16

  res@gsnLeftStringOrthogonalPosF    = 0.00
  res@gsnRightStringOrthogonalPosF   = 0.00
  res@gsnRightStringFontHeightF= 0.024
res@gsnLeftStringFontHeightF = 0.024
  ; res@lbOrientation                 = "Horizontal";"Vertical"
  ; res@lbLabelBarOn                  = True
  ; res@pmLabelBarParallelPosF        =  0.5
  ; res@pmLabelBarOrthogonalPosF      = 0.23
  ; res@pmLabelBarHeightF             = 0.05
  ; res@pmLabelBarWidthF              = 0.4
  ; res@lbLabelFontHeightF            = 0.012
;------------------------------------------------------------------------------------------------------------------
 ; res1@cnFillColors       = 
  res@gsnLeftString  = LS
  res@gsnRightString = RS

  plot  =  gsn_csm_pres_hgt_vector(wks,cor_w_cross({lvlmin:lvlmax},:),\
  var_u_cross({lvlmin:lvlmax},:),var_w_cross({lvlmin:lvlmax},:),res);我这里用的是v和w画斜剖，显著性用的是相关系数的
  draw(plot)
  frame(wks)

  end