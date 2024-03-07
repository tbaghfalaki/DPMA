rm(list=ls())
data(pbc2_long)
data(pbc2_surv)


Modelmvglmer=list()
Modelmvglmer[[1]]=list(spiders ~  1+ year  + (1 + year | id))
Modelmvglmer[[2]]=list(albumin ~  1+ year  + (1 + year | id))
Modelmvglmer[[3]]=list(log(alkaline) ~  1+ year  + (1 + year | id))

Modelsurv=survival::Surv(years, status2) ~ 1

Results=UDP(Modelsurv=Modelsurv, Modelmvglmer=Modelmvglmer, timeVar="year", nmark = 3, ncl = 2,
             families=c("binomial","gaussian","gaussian"), S = c(0,0.5,1), W = rep(0.5,3),
             index_training=c(1:50), datalong=pbc2_long,
             datasurv=pbc2_surv)



summary_UJMs(Results,num_marker=2)
summary_DP(Results)

