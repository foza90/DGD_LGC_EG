*---------------------------------------------------------------------------------------------------------------------------------------*

*                                数字政府建设，地方竞争和经济增长     
*                                      使用stata15版本运行
*----------------------------------------------------------------------------------------------------------------------------------------*

cd "C:\Users\Foza\Desktop"

clear all
set more off 
use "省级merge.dta", clear

global pcontrol "poden urban fotra"

*表1-描述性统计
estpost summarize ln_realGDP com digi bdpoli $pcontrol, detail
esttab using "描述性统计.rtf", replace cells("count(fmt(%9.0fc)) mean(fmt(%9.4f)) sd(fmt(%9.4f)) min(fmt(%9.4f)) max(fmt(%9.4f)) p50(fmt(%9.4f))")  title("表1 描述性统计") nonumbers nomtitle



*表2-面板OLS回归
regress ln_realGDP com c.dig#c.com dig
est store a1
regress ln_realGDP com c.dig#c.com dig $pcontrol
est store a2
xtset id year
xtreg ln_realGDP com c.dig#c.com dig  $pcontrol
est store a3
xtreg ln_realGDP com c.dig#c.com dig $pcontrol i.year, fe 
est store a4
esttab a1 a2 a3 a4 using "基准回归.rtf", replace ///
    b(%9.4f) se(%9.4f) t(%9.4f) ///
    scalars(r2 r2_a F) sfmt(%9.4f) ///     // R² 和 F 都保留4位小数
    label star(* 0.10 ** 0.05 *** 0.01) ///
    title("基准回归结果") ///
    nonumbers nomtitle


*稳健性检验-替换关键变量
xtreg ln_realGDP com c.bdpoli#c.com  bdpoli $pcontrol i.year, fe
est store b1
*稳健性检验-关键变量滞后一期
xtreg ln_realGDP com c.l.dig#c.com l.dig  $pcontrol i.year, fe
est store b2
*稳健性检验-使用地级数据
use "地级merge.dta", clear
xtset id year
xtreg ln_realGDP com c.dig#c.com dig 人口密度 城镇化率 二三产业占比, fe
est store b3
esttab b1 b2 b3 using "稳健性检验.rtf", replace ///
    b(%9.4f) se(%9.4f) t(%9.4f) ///
    scalars(r2 r2_a F) sfmt(%9.4f) ///     // R² 和 F 都保留4位小数
    label star(* 0.10 ** 0.05 *** 0.01) ///
	drop(*.year) ///
    title("稳健性检验") ///
    nonumbers nomtitle
	
	
*异质性分析-受教育水平分组
use "省级merge.dta", clear
global pcontrol "poden urban fotra"
xtset id year
xtreg ln_realGDP com c.dig#c.com dig $pcontrol i.year if group1==1,  fe
est store c1
xtreg ln_realGDP com c.dig#c.com  dig $pcontrol i.year if group1==0,  fe
est store c2
*异质性分析-数字基础设施分组
xtreg ln_realGDP com c.dig#c.com  dig $pcontrol i.year if group2==1, fe
est store c3
xtreg ln_realGDP com c.dig#c.com  dig $pcontrol i.year if group2==0, fe
est store c4
esttab c1 c2 c3 c4 using "异质性检验.rtf", replace ///
    b(%9.4f) se(%9.4f) t(%9.4f) ///
    scalars(r2 r2_a F) sfmt(%9.4f) ///     // R² 和 F 都保留4位小数
    label star(* 0.15 ** 0.10 *** 0.05) ///
	drop(*.year) ///
    title("异质性检验") ///
    nonumbers nomtitle


	
	
*机制检验-省级	
use "省级merge.dta", clear
global pcontrol "poden urban fotra"
xtset id year
reg fitr_prv dig $pcontrol 
est store d1
 xtreg ln_realGDP com c.fitr_prv#c.com  fitr_prv $pcontrol i.year, fe
est store d2
*机制检验-地级
use "地级merge.dta", clear
xtset id year
xtreg fitr dig  人口密度 城镇化率 二三产业占比,  fe
est store d3
xtreg ln_realGDP ln_com c.ln_fitr#c.ln_com ln_fitr 人口密度 城镇化率 二三产业占比, fe
est store d4
esttab d1 d2 d3 d4 using "机制检验.rtf", replace ///
    b(%9.4f) se(%9.4f) t(%9.4f) ///
    scalars(r2 r2_a F) sfmt(%9.4f) ///     // R² 和 F 都保留4位小数
    label star(* 0.10 ** 0.05 *** 0.01) ///
	drop(*.year) ///
    title("异质性检验") ///
    nonumbers nomtitle
