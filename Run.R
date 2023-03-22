Run_jags <- function(sp){
    # Run jags model for a given species
    # First : load data
    # Second : prepare data
    # Third : Run model
    # Fourth : Save results

    # 1. Load data
    #--------------
    data <- readRDS("data/jags_data.RDS") %>%
        filter(sp_code == sp) %>%
        filter(is_burn == 0, is_outbreak == 0)
    scaling <- readRDS("data/scaling.RDS") # tableau avec les moyenne et ecart type utilisé pour le scale
    
    # 2. Prepare data
    #----------------
    # Create the lists of time or ph I want to predict from
    tpred_pl =  (seq(0,50) -
        scaling$partial_logging_mean)/scaling$partial_logging_sd
    tpred_l = (seq(0,50) -
        scaling$logging_mean)/scaling$logging_sd
    phpred = (seq(0,14, 0.5) -
       scaling$ph_humus_mean)/scaling$ph_humus_sd
    emopred = (seq(0,100, 1) -
         scaling$epmatorg_mean)/scaling$epmatorg_sd
    # create the list of data to be used in the model
    jags_data <- list(
        # data to fit
        N = nrow(data),
        pa = data$presence_gaule,
        nb = data$all_cl,
        # variables
        year = data$year_measured_sc,
        latitude = data$latitude_sc,
        longitude = data$longitude_sc,
        epmatorg = data$epmatorg_sc,
        ph_humus = data$ph_humus_sc,
        total_ba = data$tree_ba_sc,
        is_species = data$is_species,
        TSpl = data$partial_logging_sc,
        TSl = data$logging_sc,
        is_pl = data$is_partial_logging,
        is_l = data$is_logging,
        placette = data$id_pe,
        n_placettes = max(data$id_pe),
        # prediction variables
        tpred_l = tpred_l,
        tpred_pl = tpred_pl,
        phpred = phpred,
        emopred = emopred
    )
    # parameters to save in the model
    parameters = c(
        # Intercept
        "pa_intercept",
        "nb_intercept",
        # Spatial-temporal variables
        "pa_t", "pa_lat", "pa_lon", "pa_interaction_lat_t",
        "nb_t", "nb_lat", "nb_lon", "nb_interaction_lat_t",
        # Soil variables
        "pa_emo", "pa_emo2", "pa_ph", "pa_ph2",
        "nb_emo", "nb_emo2", "nb_ph", "nb_ph2",
        # Biotic variables
        "pa_ba", "pa_sp",
        "nb_ba", "nb_sp",
        # Perturbation
        "pa_beta_pl", "pa_TSD_pl", "pa_TSD2_pl",
        "pa_beta_l", "pa_TSD_l", "pa_TSD2_l",
        # "pa_beta_b", "pa_TSD_b", "pa_TSD2_b",
        "pa_beta_o", "pa_TSD_o", "pa_TSD2_o",
        "nb_beta_pl", "nb_TSD_pl", "nb_TSD2_pl",
        "nb_beta_l", "nb_TSD_l", "nb_TSD2_l",
        # "nb_beta_b", "nb_TSD_b", "nb_TSD2_b",
        "nb_beta_o", "nb_TSD_o", "nb_TSD2_o",
        # Random effect of placette
        "pa_tau", "nb_tau",
        # Predictions
        "pa_pred_ph", "pa_pred_emo", "pa_pred_pl", "pa_pred_l",
        #"pa_pred_b", "pa_pred_o",
        "nb_pred_ph", "nb_pred_emo", "nb_pred_pl", "nb_pred_l"
        #"nb_pred_b", "nb_pred_o"
    )
    
    # 3. Run model
    #-------------
    # temps au début
    begin = Sys.time()
    
    out <- jags.parallel(
        model.file = "model.txt",
        data = jags_data,
        parameters.to.save = parameters,
        n.chains = 4,
        n.burnin = 1000,
        n.iter = 2000)

    # temps d'exécution
    Tex <- Sys.time() - begin
    out$runtime <- Tex
    print(Tex)

    # 4. Save results
    #----------------
    save(out, file = paste0("model",sp, ".RData"))
    beep() # juste pour me dire que c'est fini
}

# ABIBAL, PICMAR,PICGLA (Boréales)
#  BETPAP, POPTRE (Mixtes)
# ACERUB, ACESAC, BETALL, ACESPI, THUOCC (Tempérées)

library(tidyverse)
library(R2jags)
library(boot)
library(beepr)

# Pour le tourner 
# Run_jags("ACERUB")
# environs 10min