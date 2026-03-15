print("hello")

import pandas as pd
import numpy as np

from sklearn.model_selection import KFold, cross_val_score
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
from sklearn.gaussian_process import GaussianProcessRegressor
from sklearn.gaussian_process.kernels import Matern
import joblib

df = pd.read_csv("dataset_06.csv")
df = df.replace([np.inf, -np.inf], np.nan).dropna()

y = df.iloc[:, 0].values

X = df.iloc[:, 1:-3].values # Everything except last 3 columns

print("Rows after cleaning:", len(df))

print("X shape:", X.shape)
print("y shape:", y.shape)

kernel = Matern(nu=2.5)

model = Pipeline([
    ("scaler", StandardScaler()),
    ("gpr", GaussianProcessRegressor(kernel=kernel))
])

kf = KFold(n_splits=5, shuffle=True, random_state=42)

neg_mse_scores = cross_val_score(
    model,
    X,
    y,
    scoring="neg_mean_squared_error",
    cv=kf
)

rmse = np.sqrt(-neg_mse_scores.mean())
print(f"Python RMSE: {rmse:.6f}")

model.fit(X, y)

joblib.dump(model, "gpr_model_06.joblib")
print("Saved model as gpr_model_06.joblib")
