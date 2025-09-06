load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/mnt/e/shapefile_utils.ncl"
load "/mnt/e/mytool.ncl"

begin
    ; 设置数据文件路径和文件名

    filedir1="/mnt/e/westsouth/data/"
    filename1="spei03.nc"
    ts_ys			= 1980			;ts start year 
    ts_ye			= 2020			;ts end year 
    ;filename2="grid_frequency.txt"
    ;filename3="ynts1.txt"
    ;filename4="ynts2.txt"
    var_dat    ="WJ"
    varname1    = "spei"        ;spei
    ; 打开数据文件
    f =addfile(filedir1+filename1, "r")
    ;frequency = asciiread(filedir1+filename2,-1,"float")
    ;TS1 = asciiread(filedir1+filename3,-1,"float")
    ;TS2 = asciiread(filedir1+filename4,-1,"float")


    ymstar	= 198001
    ymend		= 202012	
    PN=(/"(a) ","(b) ","(c) ","(d) "/)
Ls=(/"(a) SPEI_MAM","(b) SPEI_JJA"/);left string from plot1-plot4
Rs=(/"EEOF","EEOF"/) ;Right string from plot1-plot4
    crit_flag        = -0.5
    monmin	= (/5,8,11,2/)  ;starting month for averaging,(monmin != 0,-12 <= monmin <= monmax <=12). negative value for previou year(year(-1)) 
    monmax	= (/5,8,11,2/)	;ending month for averaging,	   1<= monmax <= 12 
    dtrend_flag	     = 0	; 0 for row data, else for detrended data
    sea_opt = "(c) MAM_JJA"

    SWC_latmin	= 21 ;20；目前是改成了云南地区
    SWC_latmax	= 30
    SWC_lonmin	= 97
    SWC_lonmax	= 107

    nEOF		= 4	;Number of eigenvalues and eigenvectors to be returned
optEOF	= True;False	;matrix type: ( default:optEOF = False ) or (optEOF = True, optEOF@jopt = 0)  both for covariance matrix 			
optEOF@jopt	= 0;0	;( optEOF = True, optEOF@jopt = 1 ) for correlation matrix
    yrs01=ispan(ts_ys,ts_ye,1)

    plotdir="./"
    plotname="grid_spei_eeof_"+sea_opt+"."+ymstar+"-"+ymend
    plottype="pdf"
 ;--------------------------------------------------------------------------------------------------------------
    ; 读取需要的变量（例如纬向风场、时间）
    var =short2flt(f->spei(:,:,:))    ;更改变量名
    printVarSummary(var)
    time=f->time
    var_time_DATE	= cd_calendar(time,-1)
    printMinMax(var,0)
    printVarSummary(var)
  
    tstar		= ind(var_time_DATE .eq. ymstar)
    tlast		= ind(var_time_DATE .eq. ymend)

    var_new   = var(tstar:tlast,{21:30},{97:107})
    delete([/var/])

    printVarSummary(var_new)
;截出云南数据------------------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------------------------- 
shp_name = "/mnt/e/westsouth/yunnan.shp"  
mask_in = shapefile_mask_data(var_new(0,:,:),shp_name,True) ; 构建母版——最基础的2D mask范围
mask_io = where(ismissing(mask_in), 0, 1)     ;将所需范围内外数据的分离开

erai_mask  = var_new                                       ;简化的数组创建方案                 
erai_mask  = mask (erai_mask, conform(erai_mask, mask_io, (/1,2/)), 1)  ;处理高维数组进行mask
copy_VarCoords(var_new,erai_mask)                 ;复制坐标信息
delete([/var_new/])
;var_new=erai_mask
;printVarSummary(var_new)

    ; 读取云南省的行政边界数据
    ;printVarSummary(erai_mask)

    var_new = where(ismissing(erai_mask),1e+30,erai_mask)
    ;printVarSummary(var_new)
    copy_VarCoords(erai_mask,var_new) 
    printVarSummary(var_new)
   
  ; 计算春夏SPEI连续
    var_0 = month_to_monave(var_new,monmin(3),monmax(3));;DJF
    var_1 = month_to_monave(var_new,monmin(0),monmax(0));;Such an May denoting the accumulation of 3-5 
    var_2 = month_to_monave(var_new,monmin(1),monmax(1))
    var_3 = month_to_monave(var_new,monmin(2),monmax(2))
    delete([/var_new/])


    dims = dimsizes(var_1);取出他的维度
  
    var_sea = new((/4,dims(0),dims(1),dims(2)/),float)
    var_sea = (/var_0,var_1,var_2,var_3/)
    var_sea!0 = "season"
    var_sea&season = ispan(1,4,1);;the DJF is previous winter
    copy_VarCoords(var_1,var_sea(0,:,:,:))
    printVarSummary(var_sea)
    delete([/var_0,var_1,var_2,var_3/])
    ;;---------------------------------------------------------------------------------
    ;var_sea = where(ismissing(var_sea),0.0,var_sea)
    printVarSummary(var_sea)
    
    ny = dims(0)
    var_new = new((/4,ny+1,dims(1),dims(2)/),float)
    printVarSummary(var_new)
    ; var_new(:,0,:) = 0.0
    var_new(:,0:ny-1,:,:) = var_sea
    var_new(:,ny,:,:) = 0.0
    printVarSummary(var_new)
   
    ;;-------------------------------------------------------------------------------------------
    if dtrend_flag .eq. 0 
     
     var_new    = var_new
     var_new@detrend	= dtrend_flag+"--(0 for raw data, else for detrended data)" 
    
    else
   
     var_new			= (/dtrend_msg_n(ispan(1,dimsizes(var&time),1)*1.0,var_sea,False,True,1)/)
     var_new@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 
   
    end if
    printVarSummary(var_new)
   
     ;;---------------choose MAM-JJA SPEI-------------------------------------------------------------
    
     if sea_opt.eq."(c) MAM_JJA"
       var_MAM = var_new(1,:,:,:)
       var_JJA = var_new(2,:,:,:)
       printVarSummary(var_JJA)
     end if
   
   ;**********************************************************************
   ;EOF anaylsis 
   ;**********************************************************************
   latS1 = SWC_latmin
   latL1 = SWC_latmax
   lonS1 = SWC_lonmin
   lonL1 = SWC_lonmax
   printVarSummary(var_MAM)
   nyear = dimsizes(var_MAM&year)
   
   xdata1		= dim_rmvmean_n_Wrap(var_MAM,0);
   xdata2		= dim_rmvmean_n_Wrap(var_JJA,0);


   ;give weight for xdata
   rad		= 4.0*atan(1.0)/180.0
   clat		= xdata1&lat
   clat		= sqrt(cos(rad*clat))

   spei_1				= xdata1*conform(xdata1,clat,1)
   copy_VarCoords(xdata1,spei_1)
   printVarSummary(spei_1)
   spei_2				= xdata2*conform(xdata2,clat,1)
   copy_VarCoords(xdata2,spei_2)
   printVarSummary(spei_2)

;做一个EEOF分析=========================================================================================
   
   spei_12 = new((/dimsizes(var_MAM&year),2*dims(1),dims(2)/),"float")
   spei_12(:,0*dims(1):1*dims(1)-1,:) = var_MAM
   spei_12(:,1*dims(1):2*dims(1)-1,:) = var_JJA
   ; sat_djf(:, 2*dimsizes(lat):3*dimsizes(lat)-1, 2*dimsizes(lon):3*dimsizes(lon)-1) = var3
   printVarSummary(spei_12)
  
   eof = eofunc_Wrap(spei_12(lat|:,lon|:,year|:), nEOF, optEOF)
   eof_ts = eofunc_ts_Wrap(spei_12(lat|:,lon|:,year|:), eof, False)
   eof_ts@units = ""
   eof_ts!0="neof"
   eof_ts!1="year"
   printVarSummary(eof_ts)
   
   pcvar = eof@pcvar*100
   pcvar = round(pcvar, 1)/100
   print(pcvar)
   
   prinfo = True
   sig_ev  = eofunc_north(eof@eval, nyear, prinfo)
   print(sig_ev)
   
   var_MAM_eof= eof(:,0*dims(1):1*dims(1)-1,:)
   var_JJA_eof= eof(:,1*dims(1):2*dims(1)-1,:)
   ;var3_eof= eof(:, 2*dimsizes(lat):3*dimsizes(lat)-1, 2*dimsizes(lon):3*dimsizes(lon)-1)
   printVarSummary(var_MAM_eof)
   printMinMax(var_MAM_eof,True)
   
   a0 = -5.9/max(abs(eof(0,:,:)))
   var_MAM_eof(0,:,:)	= (/a0*var_MAM_eof(0,:,:)/)
   var_JJA_eof(0,:,:)	= (/a0*var_JJA_eof(0,:,:)/)
   eof_ts(0,:)	= (/1.0/a0*eof_ts(0,:)/)
   printVarSummary(var_MAM_eof(0,:,:))


   a1 = 5.9/max(abs(eof(1,:,:)))
   var_MAM_eof(1,:,:)	= (/a1*var_MAM_eof(1,:,:)/)
   var_JJA_eof(1,:,:)	= (/a1*var_JJA_eof(1,:,:)/)
   eof_ts(1,:)	= (/1.0/a1*eof_ts(1,:)/)
   printVarSummary(eof_ts)
   eof_ts_std = dim_standardize_n_Wrap(eof_ts,0,1)
   printVarSummary(eof_ts_std)

   eof_ts1=eof_ts_std(year|:,neof|:)
   printVarSummary(eof_ts_std)
   printVarSummary(eof_ts1)
   eeof_index=eof_ts_std(0,:)
   eeof_index2=eof_ts_std(1,:)
  
   runave_index=runave(eeof_index2,11,0)
   print(runave_index)

   ;====================保存一下一二模态的时间序列============================
   filedir1="/mnt/e/westsouth/lianhan/grid_eeof/"
   filename1="output1.txt"
   filename2="output2.txt"
   asciiwrite(filedir1+filename1,eeof_index) 
   asciiwrite(filedir1+filename2,eeof_index2) 
   ;=======================================
   
   ;MAM_cor_PC1=escorc_n(eof_ts(:,:), spei_1,1,0)
   MAM_cor_PC1=escorc_n(eof_ts(:,:), spei_1,1,0)
   print(MAM_cor_PC1)
   
   JJA_cor_PC2=escorc_n(eof_ts(:,:), spei_2,1,0)
   print(JJA_cor_PC2)
   
   ;=====================把所有缺测值插值到网格上===========================================
   guess     = 1               ; use zonal means
   is_cyclic = False             ; cyclic [global]
   nscan     = 1500             ; usually much less than this
   eps       = 0.001            ; variable dependent
   relc      = 0.6              ; relaxation coefficient
   opt       = 0                ; not used
    poisson_grid_fill(var_MAM_eof, is_cyclic, guess, nscan, eps, relc, opt)
    poisson_grid_fill(var_JJA_eof, is_cyclic, guess, nscan, eps, relc, opt)

   printVarSummary(var_MAM_eof)
;======================================================================

;挑选异常年==================================================================-------
yeara			= ispan(ymstar/100,ymend/100,1)		
yeara@long_name	= "year-all"
   hi			= ind( eof_ts_std(0,:) .ge. 1.0)
   li			= ind( eof_ts_std(0,:) .le. -1.0)
 
   yearh			= yeara(hi)			
   yearh@long_name	= "year-high"
 
   ;if critic_flag .eq. 0.5
   yearl			= yeara(li);;;;改
   yearl@long_name	= "year-low"		
   ;end if
   print(yearh)
   print(yearl)
  filedir5="./"
  filename5="yunnan_grid_Ts_high_flag1.txt"
  filename6="yunnan_grid_Ts_low_flag1.txt"
  asciiwrite(filedir5+filename5,yearh) 
  asciiwrite(filedir5+filename6,yearl) 


   ; Feb_cor_PC3=escorc_n(eof_ts(:,:), tmp_3,1,0)
   ; print(Feb_cor_PC3)
   ;**********************************************************************
    ;将obj_anal_ic
   ;plot
   ;**********************************************************************
   ;Resources for contour plot
   res				= True
   res@gsnDraw			= False
   res@gsnFrame			= False
   ;;----------------------------------------------------------------------------
   res@cnLinesOn			= False			; if only shaded plot, set to False
   res@cnLineLabelsOn		= False			; if only shaded plot, set to False
   res@cnInfoLabelOn		= False	
   res@cnLinesOn			= False	
   ;;----------------------------------------------------------------------------
   res@cnFillOn     = True	
   res@cnLineDrawOrder       ="PreDraw"          ;先画等值线,超出数值区域被遮盖
   res@cnFillDrawOrder       ="PreDraw"
   res@cnLabelDrawOrder      = "preDraw"	
   ;;----------------------------------------------------------------------------
   font_height			= 0.025						       
   res@tmYLLabelFontHeightF	=  0.8 *font_height
   res@tmXBLabelFontHeightF	=  0.8 *font_height
   res@tiXAxisFontHeightF	= 0.8 * font_height
   res@tiYAxisFontHeightF	= 0.8 * font_height
   res@tiMainFontHeightF		= 0.8 * font_height
   ;;----------------------------------------------------------------------------
   res@cnLineLabelFormat		= "@*+^sg"
   res@cnLineLabelPlacementMode	= "Computed"
   res@cnLabelMasking		= True
   res@cnLineLabelBackgroundColor= "white"  
   res@cnLineLabelInterval	= 1
   res@cnLineLabelFontHeightF   	= 0.018
   res@cnLineThicknessF		= 2
   ; res@cnLevelSelectionMode	= "ExplicitLevels"
   ; res@cnLevels			= ispan(-4,4,1)
   res@cnLevelSelectionMode ="ManualLevels"    ;手动设置等值线
   res@cnMinLevelValF       = -5.0
   res@cnMaxLevelValF       = 5.0
   res@cnLevelSpacingF      = 0.5
   res@cnMonoLineColor		   = False
   res@lbLabelStride       = 1
   res@tmXTOn			= False
   res@tmYROn			= False
   ;;----------------------------------------------------------------------------
   res@gsnContourNegLineDashPattern	= 5
   ; res@gsnContourZeroLineThicknessF	= 0.0
   res@gsnAddCyclic			= False
  ; res@tiMainFont                 = "helvetica-bold"
   ;res@tiXAxisFont                = "helvetica-bold"
   ;res@tmXBLabelFont              = "helvetica-bold"
   ;res@tmYLLabelFont              = "helvetica-bold"
   ;res@lbLabelFont                = "helvetica-bold"
   ;res@lgLabelFont                = "helvetica-bold"
   ;res@gsnStringFont              = "helvetica-bold"
   ;res@tiMainFont                 = "helvetica-bold"
   ;;----------------------------------------------------------------------------
   ;Resources for map
   ; res@mpCenterLonF      = 180
   res@mpMinLatF         = SWC_latmin
   res@mpMaxLatF         = SWC_latmax
   res@mpMinLonF         = SWC_lonmin
   res@mpMaxLonF         = SWC_lonmax
   ;;----------------------------------------------------------------------------
   res@mpFillOn          = True
   res@mpDataSetName     = "/mnt/e/nclstudy/nclscripts/Earth..4" 
   res@mpDataBaseVersion     = "MediumRes" ; or "Ncarg4_1"
   res@mpOutlineOn       = True
   ;res@mpOutlineSpecifiers   = (/"China","China:Provinces"/)  
   res@mpOutlineSpecifiers   = (/"China:Yunnan"/) 
   ;res@mpFillAreaSpecifiers        = (/"China:Yunnan"/)                       ;指定填色的地图区域
   res@mpGeophysicalLineColor    = "black"
   res@mpOutlineBoundarySets = "NoBoundaries"
   res@mpNationalLineThicknessF  = 2.0
   res@mpFillAreaSpecifiers      = (/"land","water","China:Yunnan"/)
   res@mpSpecifiedFillColors     = (/"white","white","transparent"/)
   res@mpFillDrawOrder           = "Draw"
   res@gsnMajorLonSpacing        = 5
   res@gsnMajorLatSpacing        = 5
   ; res@tmXBMinorOn               = False
   ; res@tmYLMinorOn               = False
   res@gsnMinorLatSpacing        = 2 
   res@gsnMinorLonSpacing        = 2
   res@tiMainString			= ""
   res@pmLabelBarWidthF = 0.50
   res@pmLabelBarHeightF = 0.08
   res@pmLabelBarOrthogonalPosF = 0.12
   
   wks       = gsn_open_wks(plottype,plotdir+plotname)
   wksy      = gsn_open_wks(plottype,plotdir+plotname+".ts")
   gsn_define_colormap(wks,"BlueDarkRed18")
   ;gsn_reverse_colormap(wks);翻转色标
   
   plot=new(nEOF,graphic)
   ploty=new(nEOF,graphic)
   plotrunave=new(1,graphic)

   
    
    sres1=res
     ;sres6@vpWidthF            = 0.5
     ;sres6@vpHeightF           = 0.25
    
   
     do p=0,nEOF-3
     sres1@tiMainString			= ""
     sres1@gsnLeftString   = Ls(0)
     sres1@gsnLeftStringOrthogonalPosF	= 0.01
     sres1@gsnRightStringOrthogonalPosF	= 0.02
     sres1@gsnRightString   = Rs(0)+(p+1)+"-"+sprintf("%5.1f",pcvar(p))+"%"
     if p.eq.1
     sres1@cnLevelSelectionMode = "ManualLevels"
     sres1@cnMinLevelValF   = -2.0 ; set min contour level
     sres1@cnMaxLevelValF   =  2.0 ; set max contour level
     sres1@cnLevelSpacingF  = 0.2
     end if
     plot(0+2*p)  =  gsn_csm_contour_map(wks,var_MAM_eof(p,:,:),sres1)
     end do
     delete([/p/])
     
     sres2=res
     ; do p1=0,nEOF-3
     sres2@tiMainString			= ""
     sres2@gsnLeftString   = Ls(1)
     sres2@gsnLeftStringOrthogonalPosF	= 0.01
     sres2@gsnRightStringOrthogonalPosF	= 0.02
     sres2@gsnRightString   = Rs(1)+(1)+"-"+sprintf("%5.1f",pcvar(0))+"%"
    
     sres2@cnLevelSelectionMode = "ManualLevels"
     sres2@cnMinLevelValF   = -2.0 ; set min contour level
     sres2@cnMaxLevelValF   =  2.0 ; set max contour level
     sres2@cnLevelSpacingF  = 0.2
     plot(1)  =  gsn_csm_contour_map(wks,var_JJA_eof(0,:,:),sres2)
     
     sres2@gsnLeftString   = Ls(1)
     sres2@gsnRightString   = Rs(1)+(2)+"-"+sprintf("%5.1f",pcvar(1))+"%"
     sres2@cnLevelSelectionMode = "ManualLevels"
     sres2@cnMinLevelValF   = -5.0 ; set min contour level
     sres2@cnMaxLevelValF   =  5.0 ; set max contour level
     sres2@cnLevelSpacingF  =  0.5
     plot(3)  =  gsn_csm_contour_map(wks,var_JJA_eof(1,:,:),sres2)
     ; end do
   
     ;;-----------------------------------------------------------------
     ;;;time series
     rest		= True
     rest@vpWidthF          = 0.70
     rest@vpHeightF         = 0.30
     rest@vpXF              = 0.2
     rest@vpYF              = 0.8
     ;;----------------------------------------------------------------------------
     rest@gsnXYBarChart         	= True	;gsn resource
     rest@gsnYRefLine		= 0.
     rest@gsnXYBarChartBarWidth	= 0.6
     rest@xyLineColors		= (/"transparent","transparent"/)
     rest@gsnAboveYRefLineColor	="red" ;""
     rest@gsnBelowYRefLineColor	="blue" ;""
     ;;----------------------------------------------------------------------------
     ; rest@xyMarkLineMode		= "MarkLines"
     ; rest@xyMarkers			= 16
     ; rest@xyDashPatterns		= 0
     ; rest@xyMarkerThicknesses	= 1.0
     ; rest@xyLineColors		= "black"
     ; rest@xyMarkerColors 		= "black"
     ; rest@xyLineThicknessF		= 5.15
     ; rest@xyMarkerSizes		= 0.015
     ;;----------------------------------------------------------------------------
     font_height   = 0.016	;font size
     rest@tmYLLabelFontHeightF	= font_height
     rest@tmXBLabelFontHeightF	= font_height
     rest@tiXAxisFontHeightF	= 1.2 * font_height
     rest@tiYAxisFontHeightF    	= 1.2 * font_height
     rest@tiMainFontHeightF     	= 1.2 * font_height
     ;;----------------------------------------------------------------------------
     ;rest@tiMainFont                 = "helvetica-bold"
     ;rest@tiXAxisFont                = "helvetica-bold"
     ;rest@tmXBLabelFont              = "helvetica-bold"
     ;rest@tmYLLabelFont              = "helvetica-bold"
     ;rest@gsnStringFont              = "helvetica-bold"
     ;rest@tiMainFont                 = "helvetica-bold"
   
     rest@gsnLeftString		= ""
     rest@gsnRightString		= ""
     ;;----------------------------------------------------------------------------
     rest@tiXAxisString		= "Year";X and Y axis
     rest@tiYAxisString		= ""
     ;;----------------------------------------------------------------------------
     rest@trXMinF			= 1979
     rest@trXMaxF			= 2021
     ;;----------------------------------------------------------------------------
     rest@tmXBMinorOn		= False
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
     rest@gsnLeftStringOrthogonalPosF	= 0.01
     rest@gsnRightStringOrthogonalPosF	= 0.02
     ;;----------------------------------------------------------------------------
   ;  rest@tmXBMinorValues		= ispan(1,nt,1)
     rest@tmXBMode			= "Explicit"
     rest@tmXBValues		= ispan(ymstar/100,ymend/100,5)
     rest@tmXBLabels		= ispan(ymstar/100,ymend/100,5)
     ;;----------------------------------------------------------------------------
    do i= 0,nEOF-3
     rest@gsnRightString	    = ""
     rest@tiMainString 	    = ""
     rest@gsnLeftString			= "(c) TS"+(i+1)
     
     ploty(i)	    = gsn_csm_xy(wksy,eof_ts_std&year,eof_ts_std(i,:),rest)
     ;XXYY即在图中位置
res_lines	=True	
res_lines@gsLineDashPattern =2.
res_lines@gsLineThicknessF	=4.	
res_lines@gsLineColor	="red"	

xx =(/1979,2021/)
yy =(/1,1/)
dum1 = gsn_add_polyline(wks,ploty(i),xx,yy,res_lines)
xx =(/1979,2021/)
yy =(/-1,-1/)
dum2 = gsn_add_polyline(wks,ploty(i),xx,yy,res_lines)


    end do

     resP=True
     ; resP@gsnMaximize =True
     ; resP@txString    ="Pre.Obs"
     ; resP@gsnPanelLabelBar=True                     ;设置公共的colorbar
     resP@lbLabelFontHeightF  = 0.014              ; make labels smaller（设置colorbar的字体）
     resP@gsnPaperOrientation="Portrait"                       ;设置纸张形式
     ;resP@lbLabelFont                = "helvetica-bold"
     ; resP@gsnPanelFigureStrings=(/"a)May","b)Jun","c)Jul","d)Aug","e)Sep","f)Oct"/);给每个子图添加标注
     ; resP@amJust  ="BottomLeft"                                    ;标注的位置
     resP@gsnPanelFigureStringsFontHeightF=0.010               ;图形标注的字体大小
     resP@pmLabelBarHeightF = 0.08
     resP@pmLabelBarWidthF  = 0.60
     ;resP@gsnPanelRowSpec=True
     resP@gsnPanelDebug= True                                   ;显示一些画图信息
     resP@gsnPanelYWhiteSpacePercent = 1
     resP@gsnPanelXWhiteSpacePercent = 1
     gsn_panel(wks,plot,(/2,2/),resP)
     gsn_panel(wksy,ploty,(/2,1/),resP)
     

     resk		= True

     font_height			= 0.015	
     resk@tmYLLabelFontHeightF	= font_height
     resk@tmXBLabelFontHeightF	= font_height
     resk@tiMainFontHeightF		= 1.2 * font_height
     resk@tiXAxisFontHeightF	= 1.2 * font_height
     resk@tiYAxisFontHeightF	= 1.2 * font_height
     
   
     resk@gsnRightString		= ""
     resk@gsnCenterString		= ""
     resk@gsnLeftString		= ""
   

     ;resuorce for Lines and Markers 
     resk@xyMarkLineMode		= "MarkLines"

    
     ;resource for legends
     ;res@pmLegendDisplayMode	= "Always" ;这个B东西就注释的
     ;res@xyExplicitLegendLabels	= (/"I~B~"+ts1+"~N~ .cor. I~B~"+ts2+"~N~"/)

     plotrunave	= gsn_csm_xy(wks,eof_ts_std&year,runave_index,resk)
     overlay(ploty(1),plotrunave)
     
   end 
   
   
   
   
