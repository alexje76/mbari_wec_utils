# Wave prediction output for one processing window

std_msgs/Header header  # Timestamp for this output message

# Measurement window metadata
float64 window_start_time  # Time of first measurement in window (seconds, relative)
float64 window_end_time    # Time of last measurement in window (seconds, relative)
int32 n_measurements       # Number of measurement samples in window

# Wavespec used for prediction
float64[] frequencies      # Wave frequencies [Hz]
float64[] directions       # Wave directions [deg True, FROM] (0°=North, 90°=East), shape: n_directions
float64[] energy_by_freq   # 1D spectrum energy [m^2/Hz]

# Target location in local coordinates (meters)
float64 x_target
float64 y_target

# Input measurements used by solver (plot/debug)
MeasurementData measurements

# Future predictions at target location
WavePredictionPoint[] predictions

# Future predictions at the buoy locations, from the same solved model.
# These cost no extra solve and can be scored against real measurements once
# those timestamps arrive -- the only forecast-skill signal available without
# ground truth at the target.
# Ordered location-major: buoy 0 at every lead, then buoy 1, etc., matching the
# column order of measurements.*_meas. Each point carries its own x/y.
WavePredictionPoint[] buoy_predictions
int32 n_buoy_prediction_buoys  # B
int32 n_buoy_prediction_leads  # L; buoy_predictions has B*L entries

# Reconstruction at measurement locations (fit quality)
ReconstructionData reconstruction

# Optional latest "actual at target" sample
bool has_wec_actual
float64 wec_time
float64 wec_z
float64 wec_u
float64 wec_v

# Optional higher-rate "actual at target" series
bool has_wec_actual_series
float64[] wec_series_time
float64[] wec_series_z
float64[] wec_series_u
float64[] wec_series_v

# Optional dense model prediction at target over the measurement window
# Useful for frequency/phase comparison against wec_series_*.
bool has_dense_predictions
float64[] dense_predictions_time
float64[] dense_predictions_z
float64[] dense_predictions_u
float64[] dense_predictions_v

# Solver diagnostics
float64 solve_time  # Time to solve least-squares problem [seconds]
int32 num_wavelengths  # Number of wave components solved
float64 centroid_period  # Spectral centroid period [seconds]

# L-BFGS-B fit metrics at the solution.
# solver_error is the projected-gradient infinity norm, the quantity the
# solver's gtol is tested against (jaxopt state.error; computed from res.jac on
# the scipy path). Smaller = more converged.
# solver_objective is the value the solver minimizes, 0.5*||P*A - b||^2, over
# the stacked z/u/v measurement rows; its scale depends on window length, so
# only compare it across windows of equal size.
float64 solver_error
float64 solver_objective

# Retrospective forecast skill, scored by comparing past buoy forecasts against
# the measurements that later arrived at those timestamps. Needs no ground
# truth at the target, so it works in deployment.
#   skill = 1 - sum(z_meas - z_forecast)^2 / sum z_meas^2
# 1.0 perfect, 0.0 no better than flat water, negative worse than flat water.
# NaN until enough forecasts have come due.
float64 forecast_skill
float64 forecast_skill_lead_sec  # lead time it was evaluated at [s]
int32 forecast_skill_n_scored  # forecasts in the rolling window

# Same metric per buoy, in the column order of measurements.*_meas.
# forecast_skill above is variance-weighted across buoys, NOT the mean of this
# array; this one exists so a single degraded SWIFT stays visible rather than
# being averaged away by three healthy ones.
float64[] forecast_skill_by_buoy

# Bulk wavespec parameters (directions in deg True, FROM)
bool has_wavespec_bulk
float64 wavespec_hs  # Significant wave height Hs [m]
float64 wavespec_tp  # Peak period Tp [s]
float64 wavespec_tm01  # Mean period Tm01 [s]
float64 wavespec_tm02  # Mean period Tm02 [s]
float64 wavespec_dp  # Peak direction Dp [deg True, FROM]
float64 wavespec_dm  # Mean direction Dm [deg True, FROM]
float64 wavespec_spreadp  # Directional spread at peak frequency [deg]
