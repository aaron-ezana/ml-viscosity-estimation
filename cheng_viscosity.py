import numpy as np

# Volume fraction (phi) -> mass fraction (Cm) using constant densities
def volfrac_to_massfrac(phi, rho_g=1260.0, rho_w=998.0):
    phi = np.asarray(phi, dtype=float)
    return (phi * rho_g) / (phi * rho_g + (1.0 - phi) * rho_w)

# Pure water viscosity in cP as a function of temperature in °C (Cheng correlation form)
def mu_water_cp(T):
    T = np.asarray(T, dtype=float)
    return 1.790 * np.exp((-1230.0 - T) * T / (36100.0 + 360.0 * T))

# Pure glycerol viscosity in cP as a function of temperature in °C (Cheng correlation form)
def mu_glycerol_cp(T):
    T = np.asarray(T, dtype=float)
    return 12100.0 * np.exp((-1233.0 + T) * T / (9900.0 + 70.0 * T))

# Cheng alpha term (depends on mass fraction and temperature)
def alpha_cheng(Cm, T):
    Cm = np.asarray(Cm, dtype=float)
    T = np.asarray(T, dtype=float)

    a = 0.705 - 0.0017 * T
    b = (4.9 + 0.036 * T) * (a ** 2.5)

    return 1.0 - Cm + (a * b * Cm * (1.0 - Cm)) / (a * Cm + b * (1.0 - Cm))

# Final: mixture viscosity in mPa·s from volume fraction and temperature
def mixture_viscosity_mpas_from_volfrac(phi, T):
    Cm = volfrac_to_massfrac(phi)
    mu_w = mu_water_cp(T)
    mu_g = mu_glycerol_cp(T)
    alpha = alpha_cheng(Cm, T)
    mu_mix = (mu_w ** alpha) * (mu_g ** (1.0 - alpha))
    return mu_mix
