library(tidyverse)
library(R2jags)
library(boot)

scaling <- readRDS("data/scaling.RDS")
load("model_ABIBAL.RData")

#-------------------------
# LA SORTIE DE JAGS
#-------------------------

print(model_ABIBAL)

#-------------------------
# LES PARAMETRES DE SORTIE
#-------------------------

summary_out <- model_ABIBAL$BUGSoutput[10]
summary_out <- summary_out$summary

min <- data.frame(par = rownames(summary_out), min = as.numeric(summary_out[,"2.5%"]))
max <- data.frame(par = rownames(summary_out), max = as.numeric(summary_out[,"97.5%"]))

out_value <- data.frame(par = names(model_ABIBAL$BUGSoutput$mean[c(1:16,21:38,43:45)]),
    value_out = as.numeric(model_ABIBAL$BUGSoutput$mean[c(1:16,21:38,43:45)]))
out_value <- out_value %>% merge(min) %>% merge(max)

ggplot(out_value %>% filter(par != "deviance")) +
    geom_point(aes(x = par, y = value_out)) +
    geom_errorbar(aes(x = par, ymin = min, ymax = max), width = 0.2) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    ylim(-5,5)

#-------------------------
# Plot, exemple pour logging sur la probabilité de présence
#-------------------------

y <- c()
y.min<- c()
y.max <- c()
y.true <- c()
for(t in 1:50){
    y <- append(y, summary_out[paste0("pa_pred_l[", t, "]"),"mean"])
    y.min <- append(y.min, summary_out[paste0("pa_pred_l[", t, "]"),"2.5%"])
    y.max <- append(y.max, summary_out[paste0("pa_pred_l[", t, "]"),"97.5%"])
}
df <- data.frame(x = seq(1,50),y, y.min, y.max)

ggplot(df) +
    geom_point(aes(x = x, y = y), size = 3) +
    geom_errorbar(aes(x = x, ymin = y.min, ymax = y.max), width = 0.2)