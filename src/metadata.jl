const featuretable = ["nonlin_autocorr_035" "AC_nl_035" "⟨x²(t)⋅x(t-3)⋅x(t-5)⟩ₜ";
                      "nonlin_autocorr_036" "AC_nl_036" "⟨x²(t)⋅x(t-3)⋅x(t-6)⟩ₜ";
                      "nonlin_autocorr_112" "AC_nl_112" "⟨x(t)⋅x²(t-1)⋅x(t-2)⟩ₜ";
                      "ami3_10bin" "CO_HistogramAMI_even_10_3" "Automutual information at lag 3 using a 10-bin histogram estimation method";
                      "ami3_2bin" "CO_HistogramAMI_even_2_3" "Automutual information at lag 3 using a 2-bin histogram estimation method";
                      "increment_ami8" "IN_AutoMutualInfoStats_diff_20_gaussian_ami8" "Mutual information at time lag 8 using Gaussian estimator";
                      "dfa_longscale_fit" "SC_FluctAnal_2_dfa_50_2_logi_r2_se2" "Timescale-fluctuation curve using DFA";
                      "noise_titration" "CO_AddNoise_1_even_10_ami_at_10" "Automutual information at lag 1 after adding white noise at a SNR of 1";
                      "prediction_scale" "FC_LoopLocalSimple_mean_stderr_chn" "Change in prediction error from a mean forecaster using prior windows of data";
                      "floating_circle" "CO_TranslateShape_circle_35_pts_std" "Variability of time-series points inside a circle translated across the time domain.";
                      "walker_crossings" "PH_Walker_momentum_5_w_momentumzcross" "Statistics of a simulated mechanical particle driven by the time series";
                      "walker_diff" "PH_Walker_biasprop_05_01_sw_meanabsdiff" "Statistics of a simulated mechanical particle driven by the time series";
                      "stationarity_min" "SY_DriftingMean50_min" "Minimum mean across 50 segments divided by mean variance in segments";
                      "stationarity_floating_circle" "CO_TranslateShape_circle_35_pts_statav4_m" "StatAv of the statistics of local time-series shapes";
                      "outlier_corr" "DN_RemovePoints_absclose_05_ac2rat" "Change in lag-2 autocorrelation from removing 50% of the time-series values closest to the mean";
                      "outlier_asymmetry" "ST_LocalExtrema_n100_diffmaxabsmin" "Asymmetry in extreme local events"]

const featurenames = featuretable[:, 2] .|> Symbol
const short_featurenames = featuretable[:, 1] .|> Symbol
const featuredescriptions = featuretable[:, 3]
const featurekeywords = fill(["fMRI"], length(featurenames))

# const featuretypes = Dict(

# # AC_nl_035
# Cdouble
# # AC_nl_036
# Cdouble
# # AC_nl_112
# Cdouble
# # CO_HistogramAMI_even_10bin_ami3
# Cdouble
# # CO_HistogramAMI_even_2bin_ami3
# Cdouble
# # IN_AutoMutualInfoStats_diff_20_gaussian_ami8
# Cdouble
# # SC_FluctAnal_2_dfa_50_2_logi_r2_se2
# Cdouble
# # CO_AddNoise_1_even_10_ami_at_10
# Cdouble
# # FC_LoopLocalSimple_mean_stderr_chn
# Cdouble
# # CO_TranslateShape_circle_35_pts_std
# Cdouble
# # PH_Walker_momentum_5_w_momentumzcross
# Cdouble
# # PH_Walker_biasprop_05_01_sw_meanabsdiff
# Cdouble
# # SY_DriftingMean50_min
# Cdouble
# # CO_TranslateShape_circle_35_pts_statav4_m
# Cdouble
# # DN_RemovePoints_absclose_05_ac2rat
# Cdouble
# # ST_LocalExtrema_n100_diffmaxabsmin
# Cdouble

# const featuretypes = Dict(featurenames .=> [
#                            #DN_HistogramMode_5
#                            Cdouble
#                            #DN_HistogramMode_10
#                            Cdouble
#                            #CO_Embed2_Dist_tau_d_expfit_meandiff
#                            Cdouble
#                            #CO_f1ecac
#                            Cdouble
#                            #CO_FirstMin_ac
#                            Cint
#                            #CO_HistogramAMI_even_2_5
#                            Cdouble
#                            #CO_trev_1_num
#                            Cdouble
#                            #DN_OutlierInclude_p_001_mdrmd
#                            Cdouble
#                            #DN_OutlierInclude_n_001_mdrmd
#                            Cdouble
#                            #FC_LocalSimple_mean1_tauresrat
#                            Cdouble
#                            #FC_LocalSimple_mean3_stderr
#                            Cdouble
#                            #IN_AutoMutualInfoStats_40_gaussian_fmmi
#                            Cdouble
#                            #MD_hrv_classic_pnn40
#                            Cdouble
#                            #SB_BinaryStats_diff_longstretch0
#                            Cdouble
#                            #SB_BinaryStats_mean_longstretch1
#                            Cdouble
#                            #SB_MotifThree_quantile_hh
#                            Cdouble
#                            #SC_FluctAnal_2_rsrangefit_50_1_logi_prop_r1
#                            Cdouble
#                            #SC_FluctAnal_2_dfa_50_1_2_logi_prop_r1
#                            Cdouble
#                            #SP_Summaries_welch_rect_area_5_1
#                            Cdouble
#                            #SP_Summaries_welch_rect_centroid
#                            Cdouble
#                            #SB_TransitionMatrix_3ac_sumdiagcov
#                            Cdouble
#                            #PD_PeriodicityWang_th0_01
#                            Cint])

"""
    CatchaMouse16.featurekeywords
A vector listing keywords of features as vectors of strings.
"""
# const featurekeywords = [ # See hctsa
#     #DN_HistogramMode_5
#     ["distribution", "location"],
#     #DN_HistogramMode_10
#     ["distribution", "location"],
#     #CO_Embed2_Dist_tau_d_expfit_meandiff
#     ["correlation", "embedding"],
#     #CO_f1ecac
#     ["correlation", "timescale"],
#     #CO_FirstMin_ac
#     ["correlation", "timescale"],
#     #CO_HistogramAMI_even_2_5
#     ["information", "correlation", "AMI"],
#     #CO_trev_1_num
#     ["correlation", "nonlinear"],
#     #DN_OutlierInclude_p_001_mdrmd
#     ["distribution", "outliers"],
#     #DN_OutlierInclude_n_001_mdrmd
#     ["distribution", "outliers"],
#     #FC_LocalSimple_mean1_tauresrat
#     ["forecasting"],
#     #FC_LocalSimple_mean3_stderr
#     ["forecasting"],
#     #IN_AutoMutualInfoStats_40_gaussian_fmmi
#     ["information", "correlation", "AMI"],
#     #MD_hrv_classic_pnn40
#     ["medical"],
#     #SB_BinaryStats_diff_longstretch0
#     ["distribution", "stationarity"],
#     #SB_BinaryStats_mean_longstretch1
#     ["distribution", "stationarity"],
#     #SB_MotifThree_quantile_hh
#     ["symbolic", "motifs"],
#     #SC_FluctAnal_2_rsrangefit_50_1_logi_prop_r1
#     ["scaling"],
#     #SC_FluctAnal_2_dfa_50_1_2_logi_prop_r1
#     ["scaling"],
#     #SP_Summaries_welch_rect_area_5_1
#     ["FourierSpectrum"],
#     #SP_Summaries_welch_rect_centroid
#     ["FourierSpectrum"],
#     #SB_TransitionMatrix_3ac_sumdiagcov
#     ["symbolic", "transitionmat"],
#     #PD_PeriodicityWang_th0_01
#     ["periodicity", "spline"]]
